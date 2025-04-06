#include "q2as_local.h"
#include "g_local.h"

static std::string *q2as_string_append_char(uint8_t c, std::string *s)
{
    *s += (char) c;
    return s;
}

static int q2as_Q_strcasecmp(const std::string &a, const std::string &b)
{
    return Q_strcasecmp(a.c_str(), b.c_str());
}

static int q2as_Q_strncasecmp(const std::string &a, const std::string &b, uint32_t n)
{
    return Q_strncasecmp(a.c_str(), b.c_str(), n);
}

constexpr int FORMATTER_USERDATA = 1;
using formatter_map = std::unordered_map<int, asIScriptFunction *>;

static void q2as_formatter_cleanup(asIScriptEngine *engine)
{
    auto mapptr = reinterpret_cast<formatter_map *>(engine->GetUserData(FORMATTER_USERDATA));

    if (mapptr)
    {
        mapptr->~formatter_map();
        asFreeMem(mapptr);
    }
}

void q2as_format_init(asIScriptEngine *engine)
{
    // find matching formatters.
    // they have to match the following decl:
    // void formatter(string &str, const string &in args, const T &in if_handle_then_const);
    int stringTypeId = engine->GetStringFactory();

    // sanity
    if (!stringTypeId)
        return;
    
    formatter_map *map = reinterpret_cast<formatter_map *>(asAllocMem(sizeof(formatter_map)));
    new(map) formatter_map;

    auto add_function = [&](asIScriptFunction *func) {
        if (strcmp(func->GetName(), "formatter"))
            return;
        else if (func->IsVariadic() || func->GetParamCount() != 3 || func->GetReturnTypeId() != asTYPEID_VOID)
            return;

        // check params; check arg 2
        int paramTypeId;
        {
            asDWORD paramFlags;

            if (func->GetParam(2, &paramTypeId, &paramFlags) < 0)
                return;

            if ((paramFlags & asTM_CONST) == 0 || (paramFlags & asTM_INREF) == 0)
                return;
            else if ((paramTypeId & asTYPEID_OBJHANDLE) != 0 && (paramTypeId & asTYPEID_HANDLETOCONST) == 0)
                return;
        }

        // check the string inputs
        {
            int otherParamTypeId;
            asDWORD paramFlags;

            if (func->GetParam(0, &otherParamTypeId, &paramFlags) < 0)
                return;

            if (otherParamTypeId != stringTypeId || paramFlags != asTM_INOUTREF)
                return;

            if (func->GetParam(1, &otherParamTypeId, &paramFlags) < 0)
                return;

            if (otherParamTypeId != stringTypeId || paramFlags != (asTM_INREF | asTM_CONST))
                return;
        }

        map->emplace(paramTypeId, func);
    };

    // check globals (host registered formatters)
    for (size_t i = 0; i < engine->GetGlobalFunctionCount(); i++)
        add_function(engine->GetGlobalFunctionByIndex(i));

    // check functions in modules
    for (size_t i = 0; i < engine->GetModuleCount(); i++)
    {
        asIScriptModule *module = engine->GetModuleByIndex(i);

        for (size_t m = 0; m < module->GetFunctionCount(); m++)
            add_function(module->GetFunctionByIndex(m));
    }

    formatter_map *old = reinterpret_cast<formatter_map *>(engine->SetUserData(map, FORMATTER_USERDATA));

    if (old)
    {
        old->~formatter_map();
        asFreeMem(old);
    }
    else
        engine->SetEngineUserDataCleanupCallback(q2as_formatter_cleanup, FORMATTER_USERDATA);
}

#ifndef USE_CPP20_FORMAT
#include <fmt/args.h>
#else
#include <format>
#endif

template<typename T>
static void q2as_call_formatter(std::string &str, const std::string_view args, const void *addr)
{
    if (args.empty())
        fmt::format_to(std::back_inserter(str), "{}", *reinterpret_cast<const T *>(addr));
    else
    {
        // this should be safe for recursion
        // since code formatters can't ping-pong
        // through this function (this is only
        // used for primitives + strings).
        static char format_str[128] { 0 };
        auto end = fmt::format_to_n(format_str, sizeof(format_str) - 1, "{{:{}}}", args);
        *(end.out) = '\0';
        fmt::vformat_to(std::back_inserter(str), format_str, fmt::make_format_args(*reinterpret_cast<const T *>(addr)));
    }
}

void q2as_impl_format_to(q2as_state_t &as, asIScriptContext *ctx, asIScriptGeneric *gen, int base_arg, std::string &str)
{
    const std::string *base = (std::string *) gen->GetArgAddress(base_arg);
    const formatter_map *mapptr = reinterpret_cast<formatter_map *>(as.engine->GetUserData(FORMATTER_USERDATA));

    size_t start = 0;
    size_t next_position = 0;
    bool uses_manual_positioning = false;
    bool uses_automatic_positioning = false;

    // estimate resulting `str`'s length.
    size_t estimated_length = base->size();

    for (int i = base_arg + 1; i < gen->GetArgCount(); i++)
    {
        int type = gen->GetArgTypeId(i);

        if (type == as.stringTypeId)
            estimated_length += ((std::string *) gen->GetArgAddress(i))->size();
        else
            estimated_length += 8;
    }

    str.reserve(str.size() + estimated_length);

    // parse the format
    for (;;)
    {
        size_t c = base->find_first_of("{}", start);

        if (c == std::string::npos)
            break;
        // `{` and `}` can never be the last character parsed
        else if (c == base->size() - 1)
        {
            ctx->SetException("invalid format string: unexpected { or }");
            return;
        }
        // {{ or }} is an escape sequence
        else if (base->at(c + 1) == base->at(c))
        {
            str.push_back(base->at(c));
            start = c + 2;
            continue;
        }
        // } can't be at the root
        else if (base->at(c) == '}')
        {
            ctx->SetException("invalid format string: unexpected }");
            return;
        }

        // push everything between start and c
        for (size_t i = start; i < c; i++)
            str.push_back(base->at(i));

        c++;

        // we're at char after {
        // parse the position
        size_t arg;

        if (base->at(c) == ':' || base->at(c) == '}')
        {
            uses_automatic_positioning = true;
            arg = next_position++;
        }
        else
        {
            uses_manual_positioning = true;

            const char *start = &(*(base->begin() + c));
            auto result = std::from_chars(start, base->data() + base->size(), arg);

            if (result.ec != std::errc())
            {
                ctx->SetException("invalid format string: invalid manual position");
                return;
            }

            c += result.ptr - start;

            if (base->at(c) != ':' && base->at(c) != '}')
            {
                ctx->SetException("invalid format string: manual position must be followed by : or }");
                return;
            }
        }

        if (arg >= (gen->GetArgCount() - base_arg) - 1)
        {
            ctx->SetException("invalid format string: argument mismatch or out of range");
            return;
        }

        if (uses_automatic_positioning == uses_manual_positioning)
        {
            ctx->SetException("invalid format string: can't mix auto and manual positioning");
            return;
        }

        std::string_view args = "";

        if (base->at(c) == ':')
        {
            // calc args
            size_t e = base->find_first_of('}', c + 1);

            // TODO: support nested values eventually

            if (e == std::string::npos)
            {
                ctx->SetException("invalid format string: missing end } after :");
                return;
            }

            args = std::string_view(base->data() + c + 1, (e - 1) - c);
            c = e;
        }

        // do the formatting
        int type = gen->GetArgTypeId(base_arg + 1 + arg);
        void *addr = gen->GetArgAddress(base_arg + 1 + arg);
        
        if (type == asTYPEID_BOOL) q2as_call_formatter<bool>(str, args, addr);
        else if (type == asTYPEID_INT8) q2as_call_formatter<int8_t>(str, args, addr);
        else if (type == asTYPEID_INT16) q2as_call_formatter<int16_t>(str, args, addr);
        else if (type == asTYPEID_INT32) q2as_call_formatter<int32_t>(str, args, addr);
        else if (type == asTYPEID_INT64) q2as_call_formatter<int64_t>(str, args, addr);
        else if (type == asTYPEID_UINT8) q2as_call_formatter<uint8_t>(str, args, addr);
        else if (type == asTYPEID_UINT16) q2as_call_formatter<uint16_t>(str, args, addr);
        else if (type == asTYPEID_UINT32) q2as_call_formatter<uint32_t>(str, args, addr);
        else if (type == asTYPEID_UINT64) q2as_call_formatter<uint64_t>(str, args, addr);
        else if (type == asTYPEID_FLOAT) q2as_call_formatter<float>(str, args, addr);
        else if (type == asTYPEID_DOUBLE) q2as_call_formatter<double>(str, args, addr);
        else if (type == as.stringTypeId) q2as_call_formatter<std::string>(str, args, addr);
        else
        {
            // check type
            auto typeInfo = as.engine->GetTypeInfoById(type);
            std::string arg_string(args);

            if (auto funcdef = typeInfo->GetFuncdefSignature())
                str.append(funcdef->GetName());
            else if (auto formatter = mapptr->find(type); formatter != mapptr->end())
            {
                auto ctx = asGetActiveContext();
                ctx->PushState();
                ctx->Prepare(formatter->second);
                ctx->SetArgAddress(0, &str);
                ctx->SetArgAddress(1, &arg_string);
                ctx->SetArgAddress(2, addr);
                as.Execute(ctx);
                ctx->PopState();
            }
            else
            {
                asGetActiveContext()->SetException("unformattable type");
                return;
            }
        }

        start = c + 1;
    }

    // add the remainder
    for (size_t i = start; i < base->size(); i++)
        str.push_back(base->at(i));
}

std::string q2as_impl_format(q2as_state_t &as, asIScriptGeneric *gen, int start)
{
    std::string s;
    q2as_impl_format_to(as, asGetActiveContext(), gen, start, s);
    return s;
}

static void q2as_format(asIScriptGeneric *gen)
{
    std::string result = q2as_impl_format(*(q2as_state_t *) gen->GetEngine()->GetUserData(), gen, 0);
    new(gen->GetAddressOfReturnLocation()) std::string(std::move(result));
}

static void q2as_format_to(asIScriptGeneric *gen)
{
    std::string *str = (std::string *) gen->GetArgAddress(0);
    q2as_impl_format_to(*(q2as_state_t *) gen->GetEngine()->GetUserData(), asGetActiveContext(), gen, 1, *str);
}

static std::string q2as_string_aslower(const std::string &in)
{
    std::string result = in;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

static std::string q2as_string_asupper(const std::string &in)
{
    std::string result = in;
    std::transform(result.begin(), result.end(), result.begin(), ::toupper);
    return result;
}

int32_t FindStartOfUTF8Codepoint(const std::string &str, int32_t pos)
{
    if (pos >= str.length())
    {
        return -1;
    }

    if ((str[pos] & 0xC0) != 0x80)
    {
        return pos;
    }

    int32_t start = pos;
    while (start > 0 && (str[start] & 0xC0) == 0x80)
    {
        --start;
    }

    uint8_t c = str[start];
    if ((c & 0x80) == 0 ||
        (c & 0xE0) == 0xC0 ||
        (c & 0xF0) == 0xE0 ||
        (c & 0xF8) == 0xF0)
    {
        return start;
    }

    return -1;
}

int32_t FindEndOfUTF8Codepoint(const std::string &str, int32_t pos)
{
    if (pos < 0 || pos >= str.length())
    {
        return -1;
    }

    int32_t start = FindStartOfUTF8Codepoint(str, pos);
    if (start == -1)
    {
        return -1;
    }

    uint8_t c = str[start];
    int32_t length = 0;
    if ((c & 0x80) == 0)
    {
        length = 1;
    }
    else if ((c & 0xE0) == 0xC0)
    {
        length = 2;
    }
    else if ((c & 0xF0) == 0xE0)
    {
        length = 3;
    }
    else if ((c & 0xF8) == 0xF0)
    {
        length = 4;
    }
    else
    {
        return -1;
    }

    if (start + length > (int32_t) str.length())
    {
        return -1;
    }

    for (int i = 1; i < length; ++i)
    {
        if ((str[start + i] & 0xC0) != 0x80)
        {
            return -1;
        }
    }

    return start + length - 1;
}

void Q2AS_RegisterStringEx(q2as_registry &registry)
{
    registry
        .for_type("string")
        .methods({
            { "string &appendChar(uint8)", asFUNCTION(q2as_string_append_char), asCALL_CDECL_OBJLAST },
            { "string aslower() const",    asFUNCTION(q2as_string_aslower),     asCALL_CDECL_OBJLAST },
            { "string asupper() const",    asFUNCTION(q2as_string_asupper),     asCALL_CDECL_OBJLAST },
            { "int32 findStartOfUTF8Codepoint(const string &in, int32 pos)", asFUNCTION(FindStartOfUTF8Codepoint), asCALL_CDECL_OBJFIRST },
            { "int32 findEndOfUTF8Codepoint(const string &in, int32 pos)", asFUNCTION(FindEndOfUTF8Codepoint), asCALL_CDECL_OBJFIRST },
        });

    registry
        .for_global()
        .functions({
            { "int Q_strcasecmp(const string &in, const string &in)",             asFUNCTION(q2as_Q_strcasecmp),  asCALL_CDECL },
            { "int Q_strncasecmp(const string &in, const string &in, uint n)",    asFUNCTION(q2as_Q_strncasecmp), asCALL_CDECL },
            { "string format(const string&in fmt, const ?&in ...)",               asFUNCTION(q2as_format),        asCALL_GENERIC },
            { "void format_to(string &str, const string&in fmt, const ?&in ...)", asFUNCTION(q2as_format_to),     asCALL_GENERIC }
        });
}