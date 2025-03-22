// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

enum pmenu_align_t
{
	LEFT,
	CENTER,
	RIGHT
};

funcdef void UpdateFunc_t(ASEntity &ent);

class pmenuhnd_t
{
	array<pmenu_t>      entries;
	int		            cur;
	any	                @arg;
	UpdateFunc_t        @UpdateFunc;
};

funcdef void SelectFunc_t(ASEntity &ent, pmenuhnd_t &hnd);

class pmenu_t
{
	string        text;
	pmenu_align_t align;
	SelectFunc_t  @SelectFunc;
	string        text_arg1;

    pmenu_t() { }

    pmenu_t(const string &in text, pmenu_align_t align, SelectFunc_t @SelectFunc = null)
    {
        this.text = text;
        this.align = align;
        @this.SelectFunc = SelectFunc;
    }
};

// Note that the pmenu entries are duplicated
// this is so that a static set of pmenu entries can be used
// for multiple clients and changed without interference
pmenuhnd_t @PMenu_Open(ASEntity &ent, const array<pmenu_t> &in entries, int cur, any @arg, UpdateFunc_t @UpdateFunc)
{
	uint			i;

	if (ent.client is null)
		return null;

	if (ent.client.menu !is null)
	{
		gi_Com_Print("warning, ent already has a menu\n");
		PMenu_Close(ent);
	}

	pmenuhnd_t hnd;

	hnd.entries = entries;

    uint num = entries.length();

	if (cur < 0 || entries[cur].SelectFunc is null)
	{
		for (i = 0; i < num; i++)
			if (entries[i].SelectFunc !is null)
				break;
	}
	else
		i = cur;

	if (i >= num)
		hnd.cur = -1;
	else
		hnd.cur = i;

	@hnd.arg = arg;
	@hnd.UpdateFunc = UpdateFunc;

	ent.client.showscores = true;
	ent.client.inmenu = true;
	@ent.client.menu = hnd;

	if (UpdateFunc !is null)
		UpdateFunc(ent);

	PMenu_Do_Update(ent);
	gi_unicast(ent.e, true);

	return hnd;
}

void PMenu_Close(ASEntity &ent)
{
	pmenuhnd_t @hnd = ent.client.menu;

	if (hnd is null)
		return;

	@ent.client.menu = null;
	ent.client.showscores = false;
}

// only use on pmenu's that have been called with PMenu_Open
void PMenu_UpdateEntry(pmenu_t &entry, string text, pmenu_align_t align, SelectFunc_t @SelectFunc)
{
    entry.text = text;
	entry.align = align;
	@entry.SelectFunc = SelectFunc;
}

void PMenu_Do_Update(ASEntity &ent)
{
	int			i;
	int			x;
	pmenuhnd_t  @hnd;
	bool		alt = false;

	@hnd = ent.client.menu;

	if (hnd is null)
	{
		gi_Com_Print("warning:  ent has no menu\n");
		return;
	}

	if (hnd.UpdateFunc !is null)
		hnd.UpdateFunc(ent);

	statusbar_t sb;

	sb.xv(32).yv(8).picn("inventory");

    i = 0;

	foreach (const pmenu_t @p : hnd.entries)
	{
		if (p.text.empty())
        {
            i++;
			continue; // blank line
        }

		int offset = 0;

		if (p.text[0] == '*')
		{
			alt = true;
			offset = 1;
		}

		sb.yv(32 + i * 8);

		string loc_func = "loc_string";

		if (p.align == pmenu_align_t::CENTER)
		{
			x = 0;
			loc_func = "loc_cstring";
		}
		else if (p.align == pmenu_align_t::RIGHT)
		{
			x = 260;
			loc_func = "loc_rstring";
		}
		else
			x = 64;

		sb.xv(x);

		sb.sb += loc_func;

		if (hnd.cur == i || alt)
			sb.sb += "2";

		sb.sb += " 1 \"" + p.text.substr(offset) + "\" \"" + p.text_arg1 + "\" ";

		if (hnd.cur == i)
		{
			sb.xv(56);
			sb.string2("\">\"");
		}

		alt = false;
        i++;
	}

	gi_WriteByte(svc_t::layout);
	gi_WriteString(sb.sb);
}

void PMenu_Update(ASEntity &ent)
{
	if (ent.client.menu is null)
	{
		gi_Com_Print("warning:  ent has no menu\n");
		return;
	}

	if (level.time - ent.client.menutime >= time_sec(1))
	{
		// been a second or more since last update, update now
		PMenu_Do_Update(ent);
		gi_unicast(ent.e, true);
		ent.client.menutime = level.time + time_sec(1);
		ent.client.menudirty = false;
	}
	ent.client.menutime = level.time;
	ent.client.menudirty = true;
}

void PMenu_Next(ASEntity &ent)
{
	int		   i;
	pmenu_t	   @p;
	pmenuhnd_t @hnd = ent.client.menu;

	if (hnd is null)
	{
		gi_Com_Print("warning:  ent has no menu\n");
		return;
	}

	if (hnd.cur < 0)
		return; // no selectable entries

	i = hnd.cur;
	do
	{
		i++;
		if (i == int(hnd.entries.length()))
			i = 0;
	    @p = hnd.entries[i];
		if (p.SelectFunc !is null)
			break;
	} while (i != hnd.cur);

	hnd.cur = i;

	PMenu_Update(ent);
}

void PMenu_Prev(ASEntity &ent)
{
	int		   i;
	pmenu_t	   @p;
	pmenuhnd_t @hnd = ent.client.menu;

	if (hnd is null)
	{
		gi_Com_Print("warning:  ent has no menu\n");
		return;
	}

	if (hnd.cur < 0)
		return; // no selectable entries

	i = hnd.cur;
	do
	{
		if (i == 0)
			i = hnd.entries.length() - 1;
		else
			i--;
	    @p = hnd.entries[i];

		if (p.SelectFunc !is null)
			break;
	} while (i != hnd.cur);

	hnd.cur = i;

	PMenu_Update(ent);
}

void PMenu_Select(ASEntity &ent)
{
	int		   i;
	pmenu_t	   @p;
	pmenuhnd_t @hnd = ent.client.menu;

	if (hnd is null)
	{
		gi_Com_Print("warning:  ent has no menu\n");
		return;
	}

	if (hnd.cur < 0)
		return; // no selectable entries

	@p = hnd.entries[hnd.cur];

	if (p.SelectFunc !is null)
		p.SelectFunc(ent, hnd);
}
