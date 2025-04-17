#pragma once

void q2as_format_init(q2as_state_t &state);
bool q2as_call_formatter(std::string &str, q2as_state_t &as, const std::string_view args, int typeId, const void *addr);
void q2as_impl_format_to(q2as_state_t &as, asIScriptContext *ctx, asIScriptGeneric *gen, int base_arg, std::string &str);
std::string q2as_impl_format(q2as_state_t &as, asIScriptGeneric *gen, int start);
int Q_strcasecmp(const std::string_view &a, const std::string_view &b);
int Q_strncasecmp(const std::string_view &a, const std::string_view &b, uint32_t n);
std::optional<std::string_view> q2as_ParseView(std::string_view &data_p, const std::string_view seps);