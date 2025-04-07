// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

// standard library stuff for game DLL

#include "g_local.h"

//====================================================================================

g_fmt_data_t g_fmt_data;

/*
==============
COM_ParseView

Parse a token out of a string; returns a string view
that is within `data_p`'s range.

If we're parsing past EOF, nullopt will be returned.

The input string view is modified to be ranged to where the next
operation should take place.
==============
*/
std::optional<std::string_view> COM_ParseView(std::string_view& data_p, const char* seps)
{
	if (data_p.empty())
	{
		data_p = std::string_view{ data_p.data(), 0 };
		return std::nullopt;
	}

	// skip whitespace
skipwhite:
	// skip whitespace at the start of the string
	{
		size_t next_non_white = data_p.find_first_not_of(seps);

		if (next_non_white == std::string_view::npos)
		{
			data_p = std::string_view{ data_p.data(), 0 };
			return std::nullopt;
		}

		data_p.remove_prefix(next_non_white);
	}

	// skip // comments
	if (data_p.size() >= 2 && data_p[0] == '/' && data_p[1] == '/')
	{
		data_p.remove_prefix(2);

		size_t end_of_comment = data_p.find_first_of('\n');

		if (end_of_comment == std::string_view::npos)
		{
			data_p = std::string_view{ data_p.data(), 0 };
			return std::nullopt;
		}

		data_p.remove_prefix(end_of_comment + 1);
		goto skipwhite;
	}

	// handle quoted strings specially
	if (data_p[0] == '\"')
	{
		data_p.remove_prefix(1);
		size_t end_of_quote = data_p.find_first_of('\"', 0);

		if (end_of_quote == std::string_view::npos)
		{
			// a bit weird, but un-matched quotes just
			// return the whole end of the string.
			std::string_view result = data_p.substr(0);
			data_p = std::string_view{ data_p.data(), 0 };
			return result;
		}

		std::string_view result = data_p.substr(0, end_of_quote);
		data_p.remove_prefix(end_of_quote + 1);
		return result;
	}

	// parse a regular word
	{
		size_t next_separator = data_p.find_first_of(seps);

		// EOF found, just return whatever is left
		if (next_separator == std::string_view::npos)
		{
			std::string_view result = data_p.substr(0);
			data_p = std::string_view{ data_p.data(), 0 };
			return result;
		}

		std::string_view result = data_p.substr(0, next_separator);
		data_p.remove_prefix(next_separator);
		return result;
	}
}
