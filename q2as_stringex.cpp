#include "q2as_local.h"
#include "q2as_reg.h"
#include "g_local.h"
#include <fmt/args.h>

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

std::string q2as_format_to(q2as_state_t &as, asIScriptGeneric *gen, int start)
{
	const std::string *base = (std::string *) gen->GetArgAddress(start);
    fmt::dynamic_format_arg_store<fmt::format_context> sto;
	std::string result = "BAD FORMAT";

	for (int i = start + 1; i < gen->GetArgCount(); i++)
	{
		int typeId = gen->GetArgTypeId(i);
		void* ref = gen->GetArgAddress(i);
		
		if (typeId == as.stringTypeId)
			sto.push_back(((std::string *) ref)->data());
		else if (typeId == asTYPEID_BOOL)
			sto.push_back(*(bool *) ref);
		else if (typeId == asTYPEID_INT8)
			sto.push_back(*(int8_t *) ref);
		else if (typeId == asTYPEID_INT16)
			sto.push_back(*(int16_t *) ref);
		else if (typeId == asTYPEID_INT32)
			sto.push_back(*(int32_t *) ref);
		else if (typeId == asTYPEID_INT64)
			sto.push_back(*(int64_t *) ref);
		else if (typeId == asTYPEID_UINT8)
			sto.push_back(*(uint8_t *) ref);
		else if (typeId == asTYPEID_UINT16)
			sto.push_back(*(uint16_t *) ref);
		else if (typeId == asTYPEID_UINT32)
			sto.push_back(*(uint32_t *) ref);
		else if (typeId == asTYPEID_UINT64)
			sto.push_back(*(uint64_t *) ref);
		else if (typeId == asTYPEID_FLOAT)
			sto.push_back(*(float *) ref);
		else if (typeId == asTYPEID_DOUBLE)
			sto.push_back(*(float *) ref);
		else if (typeId == as.vec3TypeId)
			sto.push_back(*(vec3_t *) ref);
		else if (typeId == as.timeTypeId)
			sto.push_back(((gtime_t *) ref)->seconds());
		// TODO: gtime_t
		// TODO: custom formatter
		else
		{
			// check type
			auto typeInfo = as.engine->GetTypeInfoById(typeId);

            if (auto funcdef = typeInfo->GetFuncdefSignature())
            {
                sto.push_back(((asIScriptFunction *) ref)->GetName());
            }
			// TODO: speed this up
			else if ((as.IASEntityTypeId &&
                typeInfo &&
                typeInfo->Implements(as.engine->GetTypeInfoById(as.IASEntityTypeId))) ||
				typeId == as.edict_tTypeId)
			{
				edict_t *entity_handle = nullptr;

				if (typeId == as.edict_tTypeId)
					entity_handle = (edict_t *) ref;
				else
				{
                    // AS_TODO cache func
					auto func = typeInfo->GetMethodByName("get_handle");
					auto ctx = as.RequestContext();
					ctx->Prepare(func);
					ctx->SetObject(ref);
					ctx.Execute();
					entity_handle = *(edict_t **)ctx->GetAddressOfReturnValue();
				}

				sto.push_back(fmt::format("edict {} ({} {} {})", entity_handle->s.number, entity_handle->s.origin[0], entity_handle->s.origin[1], entity_handle->s.origin[2]));
			}
			else
			{
				asGetActiveContext()->SetException("unformattable");
				return result;
			}
		}
	}

    try
    {
        result = fmt::vformat(*base, sto);
    }
    catch (const fmt::format_error& e)
    {
        gi.Com_ErrorFmt("Malformed format string: {}\n", e.what());
        gi.Com_ErrorFmt(" fmt: {}\n", *base);
    }

    return result;
}

static void q2as_format(asIScriptGeneric *gen)
{
    std::string result = q2as_format_to(*(q2as_state_t *) gen->GetEngine()->GetUserData(), gen, 0);
	new(gen->GetAddressOfReturnLocation()) std::string(std::move(result));
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

bool Q2AS_RegisterStringEx(asIScriptEngine *engine)
{
	EnsureRegisteredMethodRaw("string", "string &appendChar(uint8)", asFUNCTION(q2as_string_append_char), asCALL_CDECL_OBJLAST);
	EnsureRegisteredGlobalFunction("int Q_strcasecmp(const string &in, const string &in)", asFUNCTION(q2as_Q_strcasecmp), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("int Q_strncasecmp(const string &in, const string &in, uint n)", asFUNCTION(q2as_Q_strncasecmp), asCALL_CDECL);
	EnsureRegisteredGlobalFunction("string format(const string&in fmt, const ?&in ...)", asFUNCTION(q2as_format), asCALL_GENERIC);
    EnsureRegisteredMethodRaw("string", "string aslower() const", asFUNCTION(q2as_string_aslower), asCALL_CDECL_OBJLAST);
    EnsureRegisteredMethodRaw("string", "string asupper() const", asFUNCTION(q2as_string_asupper), asCALL_CDECL_OBJLAST);

	return true;
}