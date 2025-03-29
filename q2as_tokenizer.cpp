#include "q2as_json.h"
#include "bg_local.h"
#include "cg_local.h"
#include "q2as_cgame.h"
#include "g_local.h"
#include "q2as_game.h"

int Q_strcasecmp(const std::string_view s1, const std::string_view s2)
{
	char c1, c2;
    size_t i1 = 0, i2 = 0;

	do
	{
		c1 = i1 >= s1.length() ? '\0' : s1[i1];
		c2 = i2 >= s2.length() ? '\0' : s2[i2];

        i1++;
        i2++;

		if (c1 != c2)
		{
			if (c1 >= 'a' && c1 <= 'z')
				c1 -= ('a' - 'A');
			if (c2 >= 'a' && c2 <= 'z')
				c2 -= ('a' - 'A');
			if (c1 != c2)
				return c1 < c2 ? -1 : 1; // strings not equal
		}
	} while (c1);

	return 0; // strings are equal
}

int Q_strncasecmp(const std::string_view s1, const std::string_view s2, size_t n)
{
	char c1, c2;
    size_t i1 = 0, i2 = 0;

	do
	{
		c1 = i1 >= s1.length() ? '\0' : s1[i1];
		c2 = i2 >= s2.length() ? '\0' : s2[i2];

        i1++;
        i2++;

		if (!n--)
			return 0; // strings are equal until end point

		if (c1 != c2)
		{
			if (c1 >= 'a' && c1 <= 'z')
				c1 -= ('a' - 'A');
			if (c2 >= 'a' && c2 <= 'z')
				c2 -= ('a' - 'A');
			if (c1 != c2)
				return c1 < c2 ? -1 : 1; // strings not equal
		}
	} while (c1);

	return 0; // strings are equal
}

// simple tokenizer that is similar to COM_Parse.
// states begin in a 'start' state, with no token stored.
// once a token is retrieved, it is stored in the
// current state and can be re-fetched at any time.
struct tokenizer_t : q2as_ref_t
{
    std::string str;
    std::array<char, 16> separators = { '\r', '\n', '\t', ' ', '\0' }; // is this too limiting?

    struct state_t
    {
        std::string_view base;
        std::string_view view = base;
        std::optional<std::string_view> token;
    };
    
    std::vector<state_t> states;

    inline tokenizer_t() { }
    inline tokenizer_t(const char *s) :
        str(s)
    {
        states.push_back(state_t{std::string_view(str)});
    }
    inline tokenizer_t(const std::string &s) :
        str(s)
    {
        states.push_back(state_t{std::string_view(str)});
    }
    inline tokenizer_t(std::string &&move) :
        str(std::move(move))
    {
        states.push_back(state_t{std::string_view(str)});
    }

    inline void set_separators(const std::string &in)
    {
        Q_strlcpy(separators.data(), in.c_str(), separators.size());
    }

    inline std::string get_separators() const
    {
        return std::string(separators.data());
    }

    // get the current token state
    inline const state_t &cur() const { return states.back(); }
    inline state_t &cur() { return states.back(); }

    // returns true if the top of the tokenizer stack
    // is empty; this will occur *as* the last token is parsed,
    // not after. 
    inline bool has_next() const { return !cur().view.empty(); }

    // returns true if the current tokenizer stack has
    // a token ready to be used.
    inline bool has_token() const { return cur().token.has_value(); }

    // grab the next token from the tokenizer.
    // returns true if not EOF.
    inline bool next()
    {
        cur().token = COM_ParseView(cur().view, separators.data());
        return has_token();
    }

    // parse primitive
    template<typename T>
    inline T as_primitive() const
    {
        std::string_view ot = cur().token.value_or("");
        T value {};
        std::from_chars(ot.data(), ot.data() + ot.size(), value);
        return value;
    }

    // get raw string
    inline std::string as_string() const
    {
        return std::string(cur().token.value_or(""));
    }

    // parse a localized string with the number of args
    // specified. note that this modifies the state of
    // the parser.
    inline std::string as_localized(int num_args)
    {
        static char arg_tokens[MAX_LOCALIZATION_ARGS + 1][MAX_TOKEN_CHARS];
        static const char *arg_buffers[MAX_LOCALIZATION_ARGS];

        // parse base
        G_FmtTo(arg_tokens[0], "{}", cur().token.value_or(""));

        // parse args
        for (int32_t i = 0; i < num_args; i++)
        {
            next();
            G_FmtTo(arg_tokens[i + 1], "{}", cur().token.value_or(""));
            arg_buffers[i] = arg_tokens[1 + i];
        }

        return cgi.Localize(arg_tokens[0], arg_buffers, num_args);
    }

    inline bool skip_tokens(int n)
    {
        for (int i = 0; i < n; i++)
            if (!next())
                return false;

        return true;
    }

    inline uint32_t token_length() const
    {
        return cur().token.value_or("").length();
    }

    inline uint8_t token_char(uint32_t i) const
    {
        if (cur().token.value_or("").empty())
            return '\0';

        return (*cur().token)[min(uint32_t(cur().token->length() - 1), i)];
    }

    inline bool token_equals(const std::string &str) const
    {
        return cur().token.value_or("").compare(str) == 0;
    }

    inline bool token_iequals(const std::string &str) const
    {
        return Q_strcasecmp(cur().token.value_or(""), str) == 0;
    }

    inline bool token_equalsn(const std::string &str, uint32_t len) const
    {
        return cur().token.value_or("").compare(0, len, str) == 0;
    }

    inline bool token_iequalsn(const std::string &str, uint32_t len) const
    {
        return Q_strncasecmp(cur().token.value_or(""), str, len) == 0;
    }

    // grab the last token parsed from the tokenizer &
    // push it into its own state.
    inline void push_state()
    {
        states.push_back(state_t{cur().token.value_or("")});
    }

    // resume the tokenizer below this one
    inline void pop_state()
    {
        states.pop_back();
    }

    // reset the tokenizer to the beginning of the stream
    // and with no token loaded
    inline void reset()
    {
        cur().token = cur().base.substr(0, 0);
        cur().view = cur().base;
    }
};

// TODO: move to factory (see pmove)
void Q2AS_tokenizer_t_factory_cgcs(asIScriptGeneric *gen)
{
	tokenizer_t *ptr = reinterpret_cast<tokenizer_t *>(q2as_cg_state_t::AllocStatic(sizeof(tokenizer_t)));
	*(tokenizer_t **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) tokenizer_t(cgi.get_configstring(gen->GetArgDWord(0)));
}

// TODO: move to factory (see pmove)
void Q2AS_tokenizer_t_factory_svcs(asIScriptGeneric *gen)
{
	tokenizer_t *ptr = reinterpret_cast<tokenizer_t *>(q2as_sv_state_t::AllocStatic(sizeof(tokenizer_t)));
	*(tokenizer_t **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) tokenizer_t(gi.get_configstring(gen->GetArgDWord(0)));
}

void Q2AS_tokenizer_t_factory_str(asIScriptGeneric *gen)
{
	tokenizer_t *ptr = reinterpret_cast<tokenizer_t *>(q2as_sv_state_t::AllocStatic(sizeof(tokenizer_t)));
	*(tokenizer_t **)gen->GetAddressOfReturnLocation() = ptr;
	new(ptr) tokenizer_t(*((std::string *) gen->GetArgAddress(0)));
}

void Q2AS_RegisterTokenizer(q2as_registry &registry)
{
    registry
        .type("tokenizer_t", sizeof(tokenizer_t), asOBJ_REF)
        .behaviors({
            { asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<tokenizer_t>)), asCALL_GENERIC },
    // TODO: move to factory (see pmove)
            { asBEHAVE_FACTORY, "tokenizer_t@ f()",                 asFUNCTION((Q2AS_Factory<tokenizer_t, q2as_sv_state_t>)), asCALL_GENERIC },
            { asBEHAVE_FACTORY, "tokenizer_t@ f(const string &in)", asFUNCTION(Q2AS_tokenizer_t_factory_str),                 asCALL_GENERIC },
            { asBEHAVE_RELEASE, "void f()",                         asFUNCTION((Q2AS_Release<tokenizer_t, q2as_sv_state_t>)), asCALL_GENERIC }
        })
        .methods({
            { "string get_separators() const property",            asMETHOD(tokenizer_t, get_separators),         asCALL_THISCALL },
            { "void set_separators(const string &in) property",    asMETHOD(tokenizer_t, set_separators),         asCALL_THISCALL },
            { "bool get_has_next() const property",                asMETHOD(tokenizer_t, has_next),               asCALL_THISCALL },
            { "bool get_has_token() const property",               asMETHOD(tokenizer_t, has_token),              asCALL_THISCALL },
            { "bool token_equals(const string &in) const",         asMETHOD(tokenizer_t, token_equals),           asCALL_THISCALL },
	        { "bool token_iequals(const string &in) const",        asMETHOD(tokenizer_t, token_iequals),          asCALL_THISCALL },
	        { "bool token_equalsn(const string &in, uint) const",  asMETHOD(tokenizer_t, token_equalsn),          asCALL_THISCALL },
	        { "bool token_iequalsn(const string &in, uint) const", asMETHOD(tokenizer_t, token_iequalsn),         asCALL_THISCALL },
	        { "bool next()",                                       asMETHOD(tokenizer_t, next),                   asCALL_THISCALL },
	        { "uint32 token_length() const",                       asMETHOD(tokenizer_t, token_length),           asCALL_THISCALL },
	        { "uint8 token_char(uint32) const",                    asMETHOD(tokenizer_t, token_char),             asCALL_THISCALL },
	        { "uint8 as_uint8() const",                            asMETHOD(tokenizer_t, as_primitive<uint8_t>),  asCALL_THISCALL },
	        { "uint16 as_uint16() const",                          asMETHOD(tokenizer_t, as_primitive<uint16_t>), asCALL_THISCALL },
	        { "uint32 as_uint32() const",                          asMETHOD(tokenizer_t, as_primitive<uint32_t>), asCALL_THISCALL },
	        { "uint64 as_uint64() const",                          asMETHOD(tokenizer_t, as_primitive<uint64_t>), asCALL_THISCALL },
	        { "int8 as_int8() const",                              asMETHOD(tokenizer_t, as_primitive<int8_t>),   asCALL_THISCALL },
	        { "int16 as_int16() const",                            asMETHOD(tokenizer_t, as_primitive<int16_t>),  asCALL_THISCALL },
	        { "int32 as_int32() const",                            asMETHOD(tokenizer_t, as_primitive<int32_t>),  asCALL_THISCALL },
	        { "int64 as_int64() const",                            asMETHOD(tokenizer_t, as_primitive<int64_t>),  asCALL_THISCALL },
	        { "float as_float() const",                            asMETHOD(tokenizer_t, as_primitive<float>),    asCALL_THISCALL },
	        { "double as_double() const",                          asMETHOD(tokenizer_t, as_primitive<double>),   asCALL_THISCALL },
	        { "string as_string() const",                          asMETHOD(tokenizer_t, as_string),              asCALL_THISCALL },
	        { "bool skip_tokens(int)",                             asMETHOD(tokenizer_t, skip_tokens),            asCALL_THISCALL },
	        { "void push_state()",                                 asMETHOD(tokenizer_t, push_state),             asCALL_THISCALL },
	        { "void pop_state()",                                  asMETHOD(tokenizer_t, pop_state),              asCALL_THISCALL },
	        { "void reset()",                                      asMETHOD(tokenizer_t, reset),                  asCALL_THISCALL }
        });
    
    // TODO: move to factory (see pmove)
    if (registry.engine->GetUserData(0) == &cgas)
    {
        registry
            .for_type("tokenizer_t")
            .behaviors({
                { asBEHAVE_FACTORY, "tokenizer_t@ f(configstring_id_t id)", asFUNCTION(Q2AS_tokenizer_t_factory_cgcs), asCALL_GENERIC }
            })
            .methods({
                { "string as_localized(int)", asMETHOD(tokenizer_t, as_localized), asCALL_THISCALL }
            });
    }
    else
    {
        registry
            .for_type("tokenizer_t")
            .behaviors({
                { asBEHAVE_FACTORY, "tokenizer_t@ f(configstring_id_t id)", asFUNCTION(Q2AS_tokenizer_t_factory_svcs), asCALL_GENERIC }
            });
    }
}