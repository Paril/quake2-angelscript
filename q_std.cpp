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

/*
============================================================================

					LIBRARY REPLACEMENT FUNCTIONS

============================================================================
*/
// NB: these funcs are duplicated in the engine; this define gates us for
// static compilation.
#if defined(KEX_Q2GAME_DYNAMIC)
int Q_strcasecmp(const char* s1, const char* s2)
{
	int c1, c2;

	do
	{
		c1 = *s1++;
		c2 = *s2++;

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

int Q_strncasecmp(const char* s1, const char* s2, size_t n)
{
	int c1, c2;

	do
	{
		c1 = *s1++;
		c2 = *s2++;

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

/*
=====================================================================

  BSD STRING UTILITIES - haleyjd 20170610

=====================================================================
*/
/*
 * Copyright (c) 1998 Todd C. Miller <Todd.Miller@courtesan.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

 /*
  * Copy src to string dst of size siz.  At most siz-1 characters
  * will be copied.  Always NUL terminates (unless siz == 0).
  * Returns strlen(src); if retval >= siz, truncation occurred.
  */
size_t Q_strlcpy(char* dst, const char* src, size_t siz)
{
	char* d = dst;
	const char* s = src;
	size_t n = siz;

	/* Copy as many bytes as will fit */
	if (n != 0 && --n != 0)
	{
		do
		{
			if ((*d++ = *s++) == 0)
				break;
		} while (--n != 0);
	}

	/* Not enough room in dst, add NUL and traverse rest of src */
	if (n == 0)
	{
		if (siz != 0)
			*d = '\0'; /* NUL-terminate dst */
		while (*s++)
			; // counter loop
	}

	return (s - src - 1); /* count does not include NUL */
}

#endif