#pragma once

void q2as_format_init(asIScriptEngine *engine);
void q2as_impl_format_to(q2as_state_t &as, asIScriptContext *ctx, asIScriptGeneric *gen, int base_arg, std::string &str);
std::string q2as_impl_format(q2as_state_t &as, asIScriptGeneric *gen, int start);
