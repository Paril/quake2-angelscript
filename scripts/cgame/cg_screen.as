// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.

const int32 STAT_MINUS      = 10;  // num frame for '-' stats digit
const array<array<string>> sb_nums =
{
    {   "num_0", "num_1", "num_2", "num_3", "num_4", "num_5",
        "num_6", "num_7", "num_8", "num_9", "num_minus"
    },
    {   "anum_0", "anum_1", "anum_2", "anum_3", "anum_4", "anum_5",
        "anum_6", "anum_7", "anum_8", "anum_9", "anum_minus"
    }
};

const int32 CHAR_WIDTH    = 16;
const int32 CONCHAR_WIDTH = 8;

int32 font_y_offset;

const rgba_t alt_color = { 112, 255, 52, 255 };

cvar_t @scr_usekfont;

cvar_t @scr_centertime;
cvar_t @scr_printspeed;
cvar_t @cl_notifytime;
cvar_t @scr_maxlines;
cvar_t @ui_acc_contrast;
cvar_t @ui_acc_alttypeface;

// static temp data used for hud
class hud_temp_t
{
    array<array<string>> table;

    array<uint32> column_widths;
    uint32 num_rows = 0;
    uint32 num_columns = 0;
};

hud_temp_t hud_temp;

// max number of centerprints in the rotating buffer
const uint MAX_CENTER_PRINTS = 4;

class cl_bind_t
{
    string bind;
    string purpose;

    cl_bind_t() { }

    cl_bind_t(string bind, string purpose = "")
    {
        this.bind = bind;
        this.purpose = purpose;
    }
};

class cl_centerprint_t
{
    array<cl_bind_t> binds; // binds

    array<string> lines;
    bool        instant; // don't type out

    uint        current_line; // current line we're typing out
    uint        line_count; // byte count to draw on current line
    bool        finished; // done typing it out
    uint64      time_tick, time_off; // time to remove at
};

bool CG_ViewingLayout(const player_state_t &in ps)
{
    return (ps.stats[player_stat_t::LAYOUTS] & (layout_flags_t::LAYOUT | layout_flags_t::INVENTORY)) != 0;
}

bool CG_InIntermission(const player_state_t &in ps)
{
    return (ps.stats[player_stat_t::LAYOUTS] & layout_flags_t::INTERMISSION) != 0;
}

bool CG_HudHidden(const player_state_t &in ps)
{
    return (ps.stats[player_stat_t::LAYOUTS] & layout_flags_t::HIDE_HUD) != 0;
}

layout_flags_t CG_LayoutFlags(const player_state_t &in ps)
{
    return layout_flags_t(ps.stats[player_stat_t::LAYOUTS]);
}

const uint MAX_NOTIFY = 8;

class cl_notify_t
{
    string          message; // utf8 message
    bool            is_active = false; // filled or not
    bool            is_chat = false; // green or not
    uint64          time = 0; // rotate us when < CL_Time()
};

// per-splitscreen client hud storage
class hud_data_t
{
    array<cl_centerprint_t> centers(MAX_CENTER_PRINTS); // list of centers
    uint32 center_index = uint32(-1); // current index we're drawing, or -1 if none left
    array<cl_notify_t> notify(MAX_NOTIFY); // list of notifies
};

array<hud_data_t> hud_data;

void CG_ClearCenterprint(int32 isplit)
{
    hud_data[isplit].center_index = uint32(-1);
}

void CG_ClearNotify(int32 isplit)
{
    //foreach (cl_notify_t @msg : hud_data[isplit].notify)
    for (uint i = 0; i < MAX_NOTIFY; i++)
        hud_data[isplit].notify[i].is_active = false;
}

// if the top one is expired, cycle the ones ahead backwards (since
// the times are always increasing)
void CG_Notify_CheckExpire(hud_data_t &data)
{
    while (data.notify[0].is_active && data.notify[0].time < cgi_CL_ClientTime())
    {
        data.notify[0].is_active = false;

        for (uint i = 1; i < MAX_NOTIFY; i++)
            if (data.notify[i].is_active)
            {
                cl_notify_t a = data.notify[i];
                data.notify[i] = data.notify[i - 1];
                data.notify[i - 1] = a;
            }
    }
}

// add notify to list
void CG_AddNotify(hud_data_t &data, string msg, bool is_chat)
{
    uint i = 0;

    if (scr_maxlines.integer <= 0)
        return;

    const uint max = min(MAX_NOTIFY, uint32(scr_maxlines.integer));

    for (; i < max; i++)
        if (!data.notify[i].is_active)
            break;

    // none left, so expire the topmost one
    if (i >= max)
    {
        data.notify[0].time = 0;
        CG_Notify_CheckExpire(data);
        i = max - 1;
    }
    
    data.notify[i].message = msg;
    data.notify[i].is_active = true;
    data.notify[i].is_chat = is_chat;
    data.notify[i].time = cgi_CL_ClientTime() + uint(cl_notifytime.value * 1000);
}

// draw notifies
void CG_DrawNotify(int32 isplit, vrect_t hud_vrect, vrect_t hud_safe, int32 scale)
{
    auto @data = hud_data[isplit];

    CG_Notify_CheckExpire(data);

    int y;
    
    y = (hud_vrect.y * scale) + hud_safe.y;

    cgi_SCR_SetAltTypeface((ui_acc_alttypeface.integer != 0) && true);

    if (ui_acc_contrast.integer != 0)
    {
        foreach (auto @msg : data.notify)
        {
            if (!msg.is_active || msg.message.empty())
                break;

            vec2_t sz = cgi_SCR_MeasureFontString(msg.message, scale);
            sz.x += 10; // extra padding for black bars
            cgi_SCR_DrawColorPic(int((hud_vrect.x * scale) + hud_safe.x - 5), y, int(sz.x), 15 * scale, "_white", rgba_black);
            y += 10 * scale;
        }
    }

    y = (hud_vrect.y * scale) + hud_safe.y;
    foreach (auto @msg : data.notify)
    {
        if (!msg.is_active)
            break;

        cgi_SCR_DrawFontString(msg.message, (hud_vrect.x * scale) + hud_safe.x, y, scale, msg.is_chat ? alt_color : rgba_white, true, text_align_t::LEFT);
        y += 10 * scale;
    }

    cgi_SCR_SetAltTypeface(false);

    // draw text input (only the main player can really chat anyways...)
    if (isplit == 0)
    {
        string input_msg;
        bool input_team;

        if (cgi_CL_GetTextInput(input_msg, input_team))
            cgi_SCR_DrawFontString(format("{}: {}", input_team ? "say_team" : "say", input_msg), (hud_vrect.x * scale) + hud_safe.x, y, scale, rgba_white, true, text_align_t::LEFT);
    }
}

/*
==============
CG_DrawHUDString
==============
*/
int CG_DrawHUDString (const string &in str, int x, int y, int centerwidth, int _xor, int scale, bool shadow = true)
{
    int     margin;
    string  line;

    margin = x;

    uint l = 0;

    while (l < str.length())
    {
        // scan out one line of text from the string
        line.resize(0);

        while (l < str.length() && str[l] != '\n')
        {
            line.appendChar(str[l]);
            l++;
        }

        vec2_t size;
        
        if (scr_usekfont.integer != 0)
        {
            size = cgi_SCR_MeasureFontString(line, scale);
        }

        if (centerwidth != 0)
        {
            if (scr_usekfont.integer == 0)
                x = int(margin + ((centerwidth - line.length()*CONCHAR_WIDTH*scale))/2);
            else
                x = int(margin + ((centerwidth - size.x))/2);
        }
        else
            x = margin;

        if (scr_usekfont.integer == 0)
        {
            for (uint i=0 ; i<line.length() ; i++)
            {
                cgi_SCR_DrawChar (x, y, scale, line[i]^_xor, shadow);
                x += CONCHAR_WIDTH * scale;
            }
        }
        else
        {
            cgi_SCR_DrawFontString(line, x, y - (font_y_offset * scale), scale, _xor != 0 ? alt_color : rgba_white, true, text_align_t::LEFT);
            x = int(x + size.x);
        }

        if (l < str.length())
        {
            l++; // skip the \n
            x = margin;
            if (scr_usekfont.integer == 0)
                y += CONCHAR_WIDTH * scale;
            else
                // TODO
                y += 10 * scale;//size.y;
        }
    }

    return x;
}

// Shamefully stolen from Kex
uint32 FindStartOfUTF8Codepoint(const string &in str, uint32 pos)
{
    if(pos >= str.length())
    {
        return uint32(-1);
    }

    for(int64 i = pos; i >= 0; i--)
    {
        uint8 ch = str[i];

        if((ch & 0x80) == 0)
        {
            // character is one byte
            return i;
        }
        else if((ch & 0xC0) == 0x80)
        {
            // character is part of a multi-byte sequence, keep going
            continue;
        }
        else
        {
            // character is the start of a multi-byte sequence, so stop now
            return i;
        }
    }

    return uint32(-1);
}

uint32 FindEndOfUTF8Codepoint(const string &in str, uint32 pos)
{
    if(pos >= str.length())
    {
        return uint32(-1);
    }

    for(uint32 i = pos; i < str.length(); i++)
    {
        uint8 ch = str[i];

        if((ch & 0x80) == 0)
        {
            // character is one byte
            return i;
        }
        else if((ch & 0xC0) == 0x80)
        {
            // character is part of a multi-byte sequence, keep going
            continue;
        }
        else
        {
            // character is the start of a multi-byte sequence, so stop now
            return i;
        }
    }

    return uint32(-1);
}

void CG_NotifyMessage(int32 isplit, const string &in msg, bool is_chat)
{
    CG_AddNotify(hud_data[isplit], msg, is_chat);
}

// centerprint stuff
cl_centerprint_t @CG_QueueCenterPrint(int isplit, bool instant)
{
    auto @icl = hud_data[isplit];

    // just use first index
    if (icl.center_index == uint(-1) || instant)
    {
        icl.center_index = 0;

        for (uint i = 1; i < MAX_CENTER_PRINTS; i++)
            icl.centers[i].lines.resize(0);

        return icl.centers[0];
    }

    // pick the next free index if we can find one
    for (uint i = 1; i < MAX_CENTER_PRINTS; i++)
    {
        auto @center = icl.centers[(icl.center_index + i) % MAX_CENTER_PRINTS];

        if (center.lines.empty())
            return center;
    }
    
    // none, so update the current one (the new end of buffer)
    // and skip ahead
    auto @center = icl.centers[icl.center_index];
    icl.center_index = (icl.center_index + 1) % MAX_CENTER_PRINTS;
    return center;
}

/*
==============
SCR_CenterPrint

Called for important messages that should stay in the center of the screen
for a few moments
==============
*/
void CG_ParseCenterPrint(const string &in str, int isplit, bool instant) // [Sam-KEX] Made 1st param const
{
    string  line;
    uint    i, j, l;

    // handle center queueing
    cl_centerprint_t @center = CG_QueueCenterPrint(isplit, instant);

    center.lines.resize(0);

    // split the string into lines
    uint line_start = 0;

    string line_str(str);

    center.binds.resize(0);

    // [Paril-KEX] pull out bindings. they'll always be at the start
    while (line_str.substr(0, 6) == "%bind:")
    {
        int32 end_of_bind = line_str.findFirstOf("%", 1);

        if (end_of_bind == -1)
            break;

        string bind = line_str.substr(6, end_of_bind - 6);

        auto purpose_index = bind.findFirstOf(":");

        if (purpose_index != -1)
            center.binds.push_back(cl_bind_t(bind.substr(0, purpose_index), bind.substr(purpose_index + 1)));
        else
            center.binds.push_back(cl_bind_t(bind));

        line_str = line_str.substr(end_of_bind + 1);
    }

    // echo it to the console
    cgi_Com_Print("\n\n\x1D\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1F\n\n");

    uint s = 0;
    do
    {
        line.resize(0);

        // scan the width of the line
        for (l=0 ; l<40 ; l++)
            if ((s + l) >= line_str.length() || line_str[s + l] == '\n')
                break;
        for (i=0 ; i<(40-l)/2 ; i++)
            line.appendChar(' ');

        for (j=0 ; j<l ; j++)
        {
            line.appendChar(line_str[s + j]);
        }

        line.appendChar('\n');

        cgi_Com_Print(line);

        while (s < line_str.length() && line_str[s] != '\n')
            s++;

        if (s >= line_str.length())
            break;

        s++;        // skip the \n
    } while (true);

    cgi_Com_Print("\n\x1D\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1E\x1F\n\n");
    CG_ClearNotify (isplit);

    for (uint32 line_end = 0; ; )
    {
        line_end = FindEndOfUTF8Codepoint(line_str, line_end);

        if (line_end == uint(-1))
        {
            // final line
            if (line_start < line_str.length())
                center.lines.push_back(line_str.substr(line_start));
            break;
        }
        
        // char part of current line;
        // if newline, end line and cut off
        uint8 ch = line_str[line_end];

        if (ch == '\n')
        {
            if (line_end > line_start)
                center.lines.push_back(line_str.substr(line_start, line_end - line_start));
            else
                center.lines.push_back("");
            line_start = line_end + 1;
            line_end++;
            continue;
        }

        line_end++;
    }

    if (center.lines.empty())
    {
        center.finished = true;
        return;
    }

    center.time_tick = int(cgi_CL_ClientRealTime() + (scr_printspeed.value * 1000));
    center.instant = instant;
    center.finished = false;
    center.current_line = 0;
    center.line_count = 0;
}

void CG_DrawCenterString( const player_state_t &in ps, const vrect_t &in hud_vrect, const vrect_t &in hud_safe, int isplit, int scale, cl_centerprint_t &center)
{
    int32 y = hud_vrect.y * scale;
    
    if (CG_ViewingLayout(ps))
        y += hud_safe.y;
    else if (center.lines.length() <= 4)
        y += int((hud_vrect.height * 0.2f) * scale);
    else
        y += 48 * scale;

    int lineHeight = (scr_usekfont.integer != 0 ? 10 : 8) * scale;
    if (ui_acc_alttypeface.integer  != 0)
        lineHeight = int(lineHeight * 1.5f);

    // easy!
    if (center.instant)
    {
        for (uint i = 0; i < center.lines.length(); i++)
        {
            auto line = center.lines[i];

            cgi_SCR_SetAltTypeface((ui_acc_alttypeface.integer != 0) && true);

            if (ui_acc_contrast.integer != 0 && !line.empty())
            {
                vec2_t sz = cgi_SCR_MeasureFontString(line, scale);
                sz.x += 10; // extra padding for black bars
                int barY = ui_acc_alttypeface.integer != 0 ? y - 8 : y;
                cgi_SCR_DrawColorPic(int((hud_vrect.x + hud_vrect.width / 2) * scale - (sz.x / 2)), barY, int(sz.x), lineHeight, "_white", rgba_black);
            }
            CG_DrawHUDString(line, (hud_vrect.x + hud_vrect.width/2 + -160) * scale, y, (320 / 2) * 2 * scale, 0, scale);

            cgi_SCR_SetAltTypeface(false);

            y += lineHeight;
        }

        foreach (auto @bind : center.binds)
        {
            y += lineHeight * 2;
            cgi_SCR_DrawBind(isplit, bind.bind, bind.purpose, (hud_vrect.x + (hud_vrect.width / 2)) * scale, y, scale);
        }

        if (!center.finished)
        {
            center.finished = true;
            center.time_off = int(cgi_CL_ClientRealTime() + (scr_centertime.value * 1000));
        }

        return;
    }

    // hard and annoying!
    // check if it's time to fetch a new char
    const uint64 t = cgi_CL_ClientRealTime();

    if (!center.finished)
    {
        if (center.time_tick < t)
        {
            center.time_tick = int(t + (scr_printspeed.value * 1000));
            center.line_count = FindEndOfUTF8Codepoint(center.lines[center.current_line], center.line_count + 1);

            if (center.line_count == uint(-1))
            {
                center.current_line++;
                center.line_count = 0;

                if (center.current_line == center.lines.length())
                {
                    center.current_line--;
                    center.finished = true;
                    center.time_off = int(t + (scr_centertime.value * 1000));
                }
            }
        }
    }

    string buffer;

    for (uint i = 0; i < center.lines.length(); i++)
    {
        cgi_SCR_SetAltTypeface(ui_acc_alttypeface.integer != 0 && true);

        auto line = center.lines[i];

        buffer.resize(0);

        if (center.finished || i != center.current_line)
            buffer = line;
        else
            buffer = line.substr(0, center.line_count + 1);

        int blinky_x;

        if (ui_acc_contrast.integer != 0 && !line.empty())
        {
            vec2_t sz = cgi_SCR_MeasureFontString(line, scale);
            sz.x += 10; // extra padding for black bars
            int barY = ui_acc_alttypeface.integer != 0 ? y - 8 : y;
            cgi_SCR_DrawColorPic(int((hud_vrect.x + hud_vrect.width / 2) * scale - (sz.x / 2)), barY, int(sz.x), lineHeight, "_white", rgba_black);
        }
        
        if (!buffer.empty())
            blinky_x = CG_DrawHUDString(buffer, (hud_vrect.x + hud_vrect.width/2 + -160) * scale, y, (320 / 2) * 2 * scale, 0, scale);
        else
            blinky_x = (hud_vrect.width / 2) * scale;

        cgi_SCR_SetAltTypeface(false);

        if (i == center.current_line && ui_acc_alttypeface.integer == 0)
            cgi_SCR_DrawChar(blinky_x, y, scale, 10 + ((cgi_CL_ClientRealTime() >> 8) & 1), true);

        y += lineHeight;

        if (i == center.current_line)
            break;
    }
}

void CG_CheckDrawCenterString( const player_state_t &in ps, const vrect_t &in hud_vrect, const vrect_t &in hud_safe, int isplit, int scale )
{
    if (CG_InIntermission(ps))
        return;
    if (hud_data[isplit].center_index == uint(-1))
        return;

    auto @data = hud_data[isplit];
    auto @center = data.centers[data.center_index];

    // ran out of center time
    if (center.finished && center.time_off < cgi_CL_ClientRealTime())
    {
        center.lines.resize(0);

        uint next_index = (data.center_index + 1) % MAX_CENTER_PRINTS;
        auto @next_center = data.centers[next_index];

        // no more
        if (next_center.lines.empty())
        {
            data.center_index = uint(-1);
            return;
        }

        // buffer rotated; start timer now
        data.center_index = next_index;
        next_center.current_line = next_center.line_count = 0;
    }

    if (data.center_index == uint(-1))
        return;

    CG_DrawCenterString( ps, hud_vrect, hud_safe, isplit, scale, data.centers[data.center_index] );
}

/*
==============
CG_DrawString
==============
*/
void CG_DrawString (int x, int y, int scale, const string &in s, bool alt = false, bool shadow = true)
{
    uint c = 0;

    while (c < s.length())
    {
        cgi_SCR_DrawChar (x, y, scale, s[c] ^ (alt ? 0x80 : 0), shadow);
        x += 8*scale;
        c++;
    }
}

/*
==============
CG_DrawField
==============
*/
void CG_DrawField (int x, int y, int color, int width, int value, int scale)
{
    int     l;
    int     frame;

    if (width < 1)
        return;

    // draw number string
    if (width > 5)
        width = 5;

    string result = format("{}", value);

    l = result.length();

    if (l > width)
        l = width;

    x += (2 + CHAR_WIDTH*(width - l)) * scale;

    uint ptr = 0;

    while (ptr < result.length() && l != 0)
    {
        if (result[ptr] == '-')
            frame = STAT_MINUS;
        else
            frame = result[ptr] - '0';
        int w, h;
        cgi_Draw_GetPicSize(w, h, sb_nums[color][frame]);
        cgi_SCR_DrawPic(x, y, w * scale, h * scale, sb_nums[color][frame]);
        x += CHAR_WIDTH * scale;
        ptr++;
        l--;
    }
}

// [Paril-KEX]
void CG_DrawTable(int x, int y, uint32 width, uint32 height, int32 scale)
{
    // half left
    int32 width_pixels = width;
    x -= width_pixels / 2;
    y += CONCHAR_WIDTH * scale;
    // use Y as top though

    int32 height_pixels = height;
    
    // draw border
    // KEX_FIXME method that requires less chars
    cgi_SCR_DrawChar(x - (CONCHAR_WIDTH * scale), y - (CONCHAR_WIDTH * scale), scale, 18, false);
    cgi_SCR_DrawChar((x + width_pixels), y - (CONCHAR_WIDTH * scale), scale, 20, false);
    cgi_SCR_DrawChar(x - (CONCHAR_WIDTH * scale), y + height_pixels, scale, 24, false);
    cgi_SCR_DrawChar((x + width_pixels), y + height_pixels, scale, 26, false);

    for (int cx = x; cx < x + width_pixels; cx += CONCHAR_WIDTH * scale)
    {
        cgi_SCR_DrawChar(cx, y - (CONCHAR_WIDTH * scale), scale, 19, false);
        cgi_SCR_DrawChar(cx, y + height_pixels, scale, 25, false);
    }

    for (int cy = y; cy < y + height_pixels; cy += CONCHAR_WIDTH * scale)
    {
        cgi_SCR_DrawChar(x - (CONCHAR_WIDTH * scale), cy, scale, 21, false);
        cgi_SCR_DrawChar((x + width_pixels), cy, scale, 23, false);
    }

    cgi_SCR_DrawColorPic(x, y, width_pixels, height_pixels, "_white", { 0, 0, 0, 255 });

    // draw in columns
    for (uint i = 0; i < hud_temp.num_columns; i++)
    {
        for (uint r = 0, ry = y; r < hud_temp.num_rows; r++, ry += (CONCHAR_WIDTH + font_y_offset) * scale)
        {
            int x_offset = 0;
            array<string> @row = hud_temp.table[r];

            if (i >= row.length())
                continue;

            string cell = row[i];

            // center 
            if (r == 0)
            {
                x_offset = int(((hud_temp.column_widths[i]) / 2) -
                    ((cgi_SCR_MeasureFontString(cell, scale).x) / 2));
            }
            // right align
            else if (i != 0)
            {
                x_offset = int((hud_temp.column_widths[i] - cgi_SCR_MeasureFontString(cell, scale).x));
            }

            //CG_DrawString(x + x_offset, ry, scale, hud_temp.table_rows[r].table_cells[i].text, r == 0, true);
            cgi_SCR_DrawFontString(cell, x + x_offset, ry - (font_y_offset * scale), scale, r == 0 ? alt_color : rgba_white, true, text_align_t::LEFT);
        }

        x += int(hud_temp.column_widths[i] + cgi_SCR_MeasureFontString(" ", 1).x);
    }
}

/*
================
CG_ExecuteLayoutString

================
*/
void CG_ExecuteLayoutString (tokenizer_t &tokenizer, const vrect_t &in hud_vrect, const vrect_t &in hud_safe, int32 scale, int32 playernum, const player_state_t &in ps)
{
    int     x, y;
    int     w, h;
    int     hx, hy;
    int     value;
    int     width;
    int     index;

    if (!tokenizer.has_next)
        return;

    x = hud_vrect.x;
    y = hud_vrect.y;
    width = 3;

    hx = 320 / 2;
    hy = 240 / 2;

    bool flash_frame = (cgi_CL_ClientTime() % 1000) < 500;

    // if non-zero, parse but don't affect state
    int32 if_depth = 0; // current if statement depth
    int32 endif_depth = 0; // at this depth, toggle skip_depth
    bool skip_depth = false; // whether we're in a dead stmt or not

    while (tokenizer.next())
    {
        if (tokenizer.token_equals("xl"))
        {
            tokenizer.next();
            if (!skip_depth)
                x = ((hud_vrect.x + tokenizer.as_int32()) * scale) + hud_safe.x;
        }
        else if (tokenizer.token_equals("xr"))
        {
            tokenizer.next();
            if (!skip_depth)
                x = ((hud_vrect.x + hud_vrect.width + tokenizer.as_int32()) * scale) - hud_safe.x;
        }
        else if (tokenizer.token_equals("xv"))
        {
            tokenizer.next();
            if (!skip_depth)
                x = (hud_vrect.x + hud_vrect.width/2 + (tokenizer.as_int32() - hx)) * scale;
        }

        else if (tokenizer.token_equals("yt"))
        {
            tokenizer.next();
            if (!skip_depth)
                y = ((hud_vrect.y + tokenizer.as_int32()) * scale) + hud_safe.y;
        }
        else if (tokenizer.token_equals("yb"))
        {
            tokenizer.next();
            if (!skip_depth)
                y = ((hud_vrect.y + hud_vrect.height + tokenizer.as_int32()) * scale) - hud_safe.y;
        }
        else if (tokenizer.token_equals("yv"))
        {
            tokenizer.next();
            if (!skip_depth)
                y = (hud_vrect.y + hud_vrect.height/2 + (tokenizer.as_int32() - hy)) * scale;
        }

        else if (tokenizer.token_equals("pic"))
        {   // draw a pic from a stat number
            tokenizer.next();
            if (!skip_depth)
            {
                value = ps.stats[tokenizer.as_int32()];
                if (value >= MAX_IMAGES)
                    cgi_Com_Error("Pic >= MAX_IMAGES");

                string pic = cgi_get_configstring(configstring_id_t::IMAGES + value);

                if (!pic.empty())
                {
                    cgi_Draw_GetPicSize (w, h, pic);
                    cgi_SCR_DrawPic (x, y, w * scale, h * scale, pic);
                }
            }
        }
/*
        else if (!strcmp(token, "client"))
        {   // draw a deathmatch client block
            token = COM_Parse (&s);
            if (!skip_depth)
            {
                x = (hud_vrect.x + hud_vrect.width/2 + (atoi(token) - hx)) * scale;
                x += 8 * scale;
            }
            token = COM_Parse (&s);
            if (!skip_depth)
            {
                y = (hud_vrect.y + hud_vrect.height/2 + (atoi(token) - hy)) * scale;
                y += 7 * scale;
            }

            token = COM_Parse (&s);

            if (!skip_depth)
            {
                value = atoi(token);
                if (value >= MAX_CLIENTS || value < 0)
                    cgi.Com_Error("client >= MAX_CLIENTS");
            }

            int score, ping;

            token = COM_Parse (&s);
            if (!skip_depth)
                score = atoi(token);

            token = COM_Parse (&s);
            if (!skip_depth)
            {
                ping = atoi(token);

                if (!scr_usekfont->integer)
                    CG_DrawString (x + 32 * scale, y, scale, cgi.CL_GetClientName(value));
                else
                    cgi.SCR_DrawFontString(cgi.CL_GetClientName(value), x + 32 * scale, y - (font_y_offset * scale), scale, rgba_white, true, text_align_t::LEFT);
                
                if (!scr_usekfont->integer)
                    CG_DrawString (x + 32 * scale, y + 10 * scale, scale, G_Fmt("{}", score).data(), true);
                else
                    cgi.SCR_DrawFontString(G_Fmt("{}", score).data(), x + 32 * scale, y + (10 - font_y_offset) * scale, scale, rgba_white, true, text_align_t::LEFT);

                cgi.SCR_DrawPic(x + 96 * scale, y + 10 * scale, 9 * scale, 9 * scale, "ping");
                
                if (!scr_usekfont->integer)
                    CG_DrawString (x + 73 * scale + 32 * scale, y + 10 * scale, scale, G_Fmt("{}", ping).data());
                else
                    cgi.SCR_DrawFontString (G_Fmt("{}", ping).data(), x + 107 * scale, y + (10 - font_y_offset) * scale, scale, rgba_white, true, text_align_t::LEFT);
            }
        }

        else if (!strcmp(token, "ctf"))
        {   // draw a ctf client block
            int     score, ping;

            token = COM_Parse (&s);
            if (!skip_depth)
                x = (hud_vrect.x + hud_vrect.width/2 - hx + atoi(token)) * scale;
            token = COM_Parse (&s);
            if (!skip_depth)
                y = (hud_vrect.y + hud_vrect.height/2 - hy + atoi(token)) * scale;

            token = COM_Parse (&s);
            if (!skip_depth)
            {
                value = atoi(token);
                if (value >= MAX_CLIENTS || value < 0)
                    cgi.Com_Error("client >= MAX_CLIENTS");
            }

            token = COM_Parse (&s);
            if (!skip_depth)
                score = atoi(token);

            token = COM_Parse (&s);
            if (!skip_depth)
            {
                ping = atoi(token);
                if (ping > 999)
                    ping = 999;
            }

            token = COM_Parse (&s);

            if (!skip_depth)
            {

                cgi.SCR_DrawFontString (G_Fmt("{}", score).data(), x, y - (font_y_offset * scale), scale, value == playernum ? alt_color : rgba_white, true, text_align_t::LEFT);
                x += 3 * 9 * scale;
                cgi.SCR_DrawFontString (G_Fmt("{}", ping).data(), x, y - (font_y_offset * scale), scale, value == playernum ? alt_color : rgba_white, true, text_align_t::LEFT);
                x += 3 * 9 * scale;
                cgi.SCR_DrawFontString (cgi.CL_GetClientName(value), x, y - (font_y_offset * scale), scale, value == playernum ? alt_color : rgba_white, true, text_align_t::LEFT);

                if (*token)
                {
                    cgi.Draw_GetPicSize(&w, &h, token);
                    cgi.SCR_DrawPic(x - ((w + 2) * scale), y, w * scale, h * scale, token);
                }
            }
        }
*/

        else if (tokenizer.token_equals("picn"))
        {   // draw a pic from a name
            tokenizer.next();
            if (!skip_depth)
            {
                string token = tokenizer.as_string();
                cgi_Draw_GetPicSize(w, h, token);
                cgi_SCR_DrawPic(x, y, w * scale, h * scale, token);
            }
        }
        else if (tokenizer.token_equals("num"))
        {   // draw a number
            tokenizer.next();
            if (!skip_depth)
                width = tokenizer.as_int32();
            tokenizer.next();
            if (!skip_depth)
            {
                value = ps.stats[tokenizer.as_int32()];
                CG_DrawField (x, y, 0, width, value, scale);
            }
        }
        // [Paril-KEX] special handling for the lives number
        else if (tokenizer.token_equals("lives_num"))
        {
            tokenizer.next();
            if (!skip_depth)
            {
                value = ps.stats[tokenizer.as_int32()];
                CG_DrawField(x, y, (value <= 2) ? (flash_frame ? 1 : 0) : 0, 1, max(0, value - 2), scale);
            }
        }

        else if (tokenizer.token_equals("hnum"))
        {
            // health number
            if (!skip_depth)
            {
                int     color;

                width = 3;
                value = ps.stats[player_stat_t::HEALTH];
                if (value > 25)
                    color = 0;  // green
                else if (value > 0)
                    color = flash_frame ? 1 : 0;      // flash
                else
                    color = 1;
                if ((ps.stats[player_stat_t::FLASHES] & 1) != 0)
                {
                    cgi_Draw_GetPicSize(w, h, "field_3");
                    cgi_SCR_DrawPic(x, y, w * scale, h * scale, "field_3");
                }

                CG_DrawField (x, y, color, width, value, scale);
            }
        }

        else if (tokenizer.token_equals("anum"))
        {
            // ammo number
            if (!skip_depth)
            {
                int     color;

                width = 3;
                value = ps.stats[player_stat_t::AMMO];

                int32 min_ammo = cgi_CL_GetWarnAmmoCount(ps.stats[player_stat_t::ACTIVE_WEAPON]);

                if (min_ammo == 0)
                    min_ammo = 5; // back compat

                if (value > min_ammo)
                    color = 0;  // green
                else if (value >= 0)
                    color = flash_frame ? 1 : 0;      // flash
                else
                    continue;   // negative number = don't show
                if ((ps.stats[player_stat_t::FLASHES] & 4) != 0)
                {
                    cgi_Draw_GetPicSize(w, h, "field_3");
                    cgi_SCR_DrawPic(x, y, w * scale, h * scale, "field_3");
                }

                CG_DrawField (x, y, color, width, value, scale);
            }
        }

        else if (tokenizer.token_equals("rnum"))
        {
            // armor number
            if (!skip_depth)
            {
                int     color;

                width = 3;
                value = ps.stats[player_stat_t::ARMOR];
                if (value < 0)
                    continue;

                color = 0;  // green
                if ((ps.stats[player_stat_t::FLASHES] & 2) != 0)
                {
                    cgi_Draw_GetPicSize(w, h, "field_3");
                    cgi_SCR_DrawPic(x, y, w * scale, h * scale, "field_3");
                }

                CG_DrawField (x, y, color, width, value, scale);
            }
        }

        else if (tokenizer.token_equals("stat_string"))
        {
            tokenizer.next();

            if (!skip_depth)
            {
                index = tokenizer.as_int32();
                if (index < 0 || index >= MAX_STATS)
                    cgi_Com_Error("Bad stat_string index");
                index = ps.stats[index];

                if (cgi_CL_ServerProtocol() <= PROTOCOL_VERSION_3XX)
                {
                    int start, length;
                    CS_REMAP(configstring_old_id_t(index), start, length);
                    index = start / CS_MAX_STRING_LENGTH;
                }

                if (index < 0 || index >= configstring_id_t::MAX)
                    cgi_Com_Error("Bad stat_string index");
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x, y, scale, cgi_get_configstring(index));
                else
                    cgi_SCR_DrawFontString(cgi_get_configstring(index), x, y - (font_y_offset * scale), scale, rgba_white, true, text_align_t::LEFT);
            }
        }

        else if (tokenizer.token_equals("cstring"))
        {
            tokenizer.next();
            if (!skip_depth)
                CG_DrawHUDString (tokenizer.as_string(), x, y, hx*2*scale, 0, scale);
        }

        else if (tokenizer.token_equals("string"))
        {
            tokenizer.next();
            if (!skip_depth)
            {
                string token = tokenizer.as_string();
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x, y, scale, token);
                else
                    cgi_SCR_DrawFontString(token, x, y - (font_y_offset * scale), scale, rgba_white, true, text_align_t::LEFT);
            }
        }

        else if (tokenizer.token_equals("cstring2"))
        {
            tokenizer.next();
            if (!skip_depth)
                CG_DrawHUDString (tokenizer.as_string(), x, y, hx*2*scale, 0x80, scale);
        }

        else if (tokenizer.token_equals("string2"))
        {
            tokenizer.next();
            if (!skip_depth)
            {
                string token = tokenizer.as_string();
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x, y, scale, token, true);
                else
                    cgi_SCR_DrawFontString(token, x, y - (font_y_offset * scale), scale, alt_color, true, text_align_t::LEFT);
            }
        }

        else if (tokenizer.token_equals("if"))
        {
            // if stmt
            tokenizer.next();

            if_depth++;

            // skip to endif
            if (!skip_depth && ps.stats[tokenizer.as_int32()] == 0)
            {
                skip_depth = true;
                endif_depth = if_depth;
            }
        }

        else if (tokenizer.token_equals("ifgef"))
        {
            // if stmt
            tokenizer.next();

            if_depth++;

            // skip to endif
            if (!skip_depth && cgi_CL_ServerFrame() < tokenizer.as_int32())
            {
                skip_depth = true;
                endif_depth = if_depth;
            }
        }

        else if (tokenizer.token_equals("endif"))
        {
            if (skip_depth && (if_depth == endif_depth))
                skip_depth = false;

            if_depth--;

            if (if_depth < 0)
                cgi_Com_Error("endif without matching if");
        }

        // localization stuff
        else if (tokenizer.token_equals("loc_stat_string"))
        {
            tokenizer.next();

            if (!skip_depth)
            {
                index = tokenizer.as_int32();
                if (index < 0 || index >= MAX_STATS)
                    cgi_Com_Error("Bad stat_string index");
                index = ps.stats[index];

                if (cgi_CL_ServerProtocol() <= PROTOCOL_VERSION_3XX)
                {
                    int start, length;
                    CS_REMAP(configstring_old_id_t(index), start, length);
                    index = start / CS_MAX_STRING_LENGTH;
                }

                if (index < 0 || index >= configstring_id_t::MAX)
                    cgi_Com_Error("Bad stat_string index");
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x, y, scale, cgi_Localize(cgi_get_configstring(index)));
                else
                    cgi_SCR_DrawFontString(cgi_Localize(cgi_get_configstring(index)), x, y - (font_y_offset * scale), scale, rgba_white, true, text_align_t::LEFT);
            }
        }

        else if (tokenizer.token_equals("loc_stat_rstring"))
        {
            tokenizer.next();

            if (!skip_depth)
            {
                index = tokenizer.as_int32();
                if (index < 0 || index >= MAX_STATS)
                    cgi_Com_Error("Bad stat_string index");
                index = ps.stats[index];

                if (cgi_CL_ServerProtocol() <= PROTOCOL_VERSION_3XX)
                {
                    int start, length;
                    CS_REMAP(configstring_old_id_t(index), start, length);
                    index = start / CS_MAX_STRING_LENGTH;
                }

                if (index < 0 || index >= configstring_id_t::MAX)
                    cgi_Com_Error("Bad stat_string index");
                string s = cgi_Localize(cgi_get_configstring(index));
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x - (s.length() * CONCHAR_WIDTH * scale), y, scale, s);
                else
                {
                    vec2_t size = cgi_SCR_MeasureFontString(s, scale);
                    cgi_SCR_DrawFontString(s, int(x - size.x), int(y - (font_y_offset * scale)), scale, rgba_white, true, text_align_t::LEFT);
                }
            }
        }
        
        else if (tokenizer.token_equals("loc_stat_cstring"))
        {
            tokenizer.next();

            if (!skip_depth)
            {
                index = tokenizer.as_int32();
                if (index < 0 || index >= MAX_STATS)
                    cgi_Com_Error("Bad stat_string index");
                index = ps.stats[index];

                if (cgi_CL_ServerProtocol() <= PROTOCOL_VERSION_3XX)
                {
                    int start, length;
                    CS_REMAP(configstring_old_id_t(index), start, length);
                    index = start / CS_MAX_STRING_LENGTH;
                }

                if (index < 0 || index >= configstring_id_t::MAX)
                    cgi_Com_Error("Bad stat_string index");
                CG_DrawHUDString (cgi_Localize(cgi_get_configstring(index)), x, y, hx*2*scale, 0, scale);
            }
        }

        else if (tokenizer.token_equals("loc_stat_cstring2"))
        {
            tokenizer.next();

            if (!skip_depth)
            {
                index = tokenizer.as_int32();
                if (index < 0 || index >= MAX_STATS)
                    cgi_Com_Error("Bad stat_string index");
                index = ps.stats[index];

                if (cgi_CL_ServerProtocol() <= PROTOCOL_VERSION_3XX)
                {
                    int start, length;
                    CS_REMAP(configstring_old_id_t(index), start, length);
                    index = start / CS_MAX_STRING_LENGTH;
                }

                if (index < 0 || index >= configstring_id_t::MAX)
                    cgi_Com_Error("Bad stat_string index");
                CG_DrawHUDString (cgi_Localize(cgi_get_configstring(index)), x, y, hx*2*scale, 0x80, scale);
            }
        }

        else if (tokenizer.token_equals("loc_cstring"))
        {
            tokenizer.next();

            int32 num_args = tokenizer.as_int32();

            tokenizer.next();

            if (num_args < 0 || num_args >= MAX_LOCALIZATION_ARGS)
                cgi_Com_Error("Bad loc string");

            if (!skip_depth)
                CG_DrawHUDString (tokenizer.as_localized(num_args), x, y, hx*2*scale, 0, scale);
            else
                tokenizer.skip_tokens(num_args); // nb: there's an implicit next in the loop so
                                                 // we don't skip + 1
        }

        else if (tokenizer.token_equals("loc_string"))
        {
            tokenizer.next();

            int32 num_args = tokenizer.as_int32();

            tokenizer.next();

            if (num_args < 0 || num_args >= MAX_LOCALIZATION_ARGS)
                cgi_Com_Error("Bad loc string");
            
            if (!skip_depth)
            {
                string s = tokenizer.as_localized(num_args);
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x, y, scale, s);
                else
                    cgi_SCR_DrawFontString(s, x, y - (font_y_offset * scale), scale, rgba_white, true, text_align_t::LEFT);
            }
            else
                tokenizer.skip_tokens(num_args);
        }

        else if (tokenizer.token_equals("loc_cstring2"))
        {
            tokenizer.next();

            int32 num_args = tokenizer.as_int32();

            tokenizer.next();

            if (num_args < 0 || num_args >= MAX_LOCALIZATION_ARGS)
                cgi_Com_Error("Bad loc string");

            if (!skip_depth)
                CG_DrawHUDString (tokenizer.as_localized(num_args), x, y, hx*2*scale, 0x80, scale);
            else
                tokenizer.skip_tokens(num_args);
        }

        else if (tokenizer.token_equals("loc_string2") || tokenizer.token_equals("loc_rstring2") ||
            tokenizer.token_equals("loc_string") ||  tokenizer.token_equals("loc_rstring"))
        {
            bool green = tokenizer.token_char(tokenizer.token_length() - 1) == '2';
            bool rightAlign = tokenizer.token_iequalsn("loc_rstring", 11);

            tokenizer.next();

            int32 num_args = tokenizer.as_int32();

            tokenizer.next();

            if (num_args < 0 || num_args >= MAX_LOCALIZATION_ARGS)
                cgi_Com_Error("Bad loc string");
            
            if (!skip_depth)
            {
                string locStr = tokenizer.as_localized(num_args);
                int xOffs = 0;
                if (rightAlign)
                {
                    xOffs = scr_usekfont.integer != 0 ? int(cgi_SCR_MeasureFontString(locStr, scale).x) : (locStr.length() * CONCHAR_WIDTH * scale);
                }

                if (scr_usekfont.integer == 0)
                    CG_DrawString (x - xOffs, y, scale, locStr, green);
                else
                    cgi_SCR_DrawFontString(locStr, x - xOffs, y - (font_y_offset * scale), scale, green ? alt_color : rgba_white, true, text_align_t::LEFT);
            }
            else
                tokenizer.skip_tokens(num_args);
        }

        // draw time remaining
        else if (tokenizer.token_equals("time_limit"))
        {
            // end frame
            tokenizer.next();

            if (!skip_depth)
            {
                int32 end_frame = tokenizer.as_int32();

                if (end_frame < cgi_CL_ServerFrame())
                    continue;

                uint64 remaining_ms = (end_frame - cgi_CL_ServerFrame()) * cgi_frame_time_ms;

                const bool green = true;
                string time = format("{:02}:{:02}", (remaining_ms / 1000) / 60, (remaining_ms / 1000) % 60);

                string locStr = cgi_Localize("$g_score_time", time);
                int xOffs = scr_usekfont.integer != 0 ? int(cgi_SCR_MeasureFontString(locStr, scale).x) : (locStr.length() * CONCHAR_WIDTH * scale);
                if (scr_usekfont.integer == 0)
                    CG_DrawString (x - xOffs, y, scale, locStr, green);
                else
                    cgi_SCR_DrawFontString(locStr, x - xOffs, y - (font_y_offset * scale), scale, green ? alt_color : rgba_white, true, text_align_t::LEFT);
            }
        }

        // draw client dogtag
        else if (tokenizer.token_equals("dogtag"))
        {
            tokenizer.next();
            
            if (!skip_depth)
            {
                value = tokenizer.as_int32();
                if (value >= MAX_CLIENTS || value < 0)
                    cgi_Com_Error("client >= MAX_CLIENTS");

                const string path = format("/tags/{}", cgi_CL_GetClientDogtag(value));
                cgi_SCR_DrawPic(x, y, 198 * scale, 32 * scale, path);
            }
        }

        else if (tokenizer.token_equals("start_table"))
        {
            tokenizer.next();
            value = tokenizer.as_int32();

            if (!skip_depth)
            {
                hud_temp.num_columns = value;
                hud_temp.num_rows = 1;
                hud_temp.column_widths.resize(0);
                hud_temp.column_widths.resize(value);
                hud_temp.table.resize(0);
                hud_temp.table.resize(1);
            }

            for (int i = 0; i < value; i++)
            {
                tokenizer.next();

                if (!skip_depth)
                {
                    string token = tokenizer.as_localized(0);
                    hud_temp.table[0].push_back(token);
                    hud_temp.column_widths[i] = max(hud_temp.column_widths[i], uint(cgi_SCR_MeasureFontString(token, scale).x));
                }
            }
        }

        else if (tokenizer.token_equals("table_row"))
        {
            tokenizer.next();
            value = tokenizer.as_int32();

            hud_temp.table.push_back(array<string>());            
            array<string> @row = hud_temp.table[hud_temp.num_rows];

            row.resize(value);

            for (int i = 0; i < value; i++)
            {
                tokenizer.next();
                if (!skip_depth)
                {
                    string token = tokenizer.as_string();
                    row[i] = token;
                    hud_temp.column_widths[i] = max(hud_temp.column_widths[i], uint(cgi_SCR_MeasureFontString(token, scale).x));
                }
            }
            
            if (!skip_depth)
                hud_temp.num_rows++;
        }

        else if (tokenizer.token_equals("draw_table"))
        {
            if (!skip_depth)
            {
                // in scaled pixels, incl padding between elements
                uint32 total_inner_table_width = 0;

                for (uint i = 0; i < hud_temp.num_columns; i++)
                {
                    if (i != 0)
                        total_inner_table_width += uint(cgi_SCR_MeasureFontString(" ", scale).x);

                    total_inner_table_width += hud_temp.column_widths[i];
                }

                // in scaled pixels
                uint32 total_table_height = hud_temp.num_rows * (CONCHAR_WIDTH + font_y_offset) * scale;

                CG_DrawTable(x, y, total_inner_table_width, total_table_height, scale);
            }
        }

        else if (tokenizer.token_equals("stat_pname"))
        {
            tokenizer.next();

            if (!skip_depth)
            {
                index = tokenizer.as_int32();
                if (index < 0 || index >= MAX_STATS)
                    cgi_Com_Error("Bad stat_string index");
                index = ps.stats[index] - 1;

                if (scr_usekfont.integer == 0)
                    CG_DrawString(x, y, scale, cgi_CL_GetClientName(index));
                else
                    cgi_SCR_DrawFontString(cgi_CL_GetClientName(index), x, y - (font_y_offset * scale), scale, rgba_white, true, text_align_t::LEFT);
            }
            continue;
        }

        else if (tokenizer.token_equals("health_bars"))
        {
            if (skip_depth)
                continue;

            uint16 stat = uint16(ps.stats[player_stat_t::HEALTH_BARS]);
            string name = cgi_Localize(cgi_get_configstring(game_configstring_id_t::HEALTH_BAR_NAME));

            CG_DrawHUDString(name, (hud_vrect.x + hud_vrect.width/2 + -160) * scale, y, (320 / 2) * 2 * scale, 0, scale);

            float bar_width = ((hud_vrect.width * scale) - (hud_safe.x * 2)) * 0.50f;
            float bar_height = 4 * scale;

            y += int(cgi_SCR_FontLineHeight(scale));

            int bx = int(((hud_vrect.x + (hud_vrect.width * 0.5f)) * scale) - (bar_width * 0.5f));

            // 2 health bars, hardcoded
            for (uint i = 0; i < 2; i++, stat >>= 8)
            {
                uint8 bar = (stat & 0xFF);

                if ((bar & 0b10000000) == 0)
                    continue;

                float percent = (bar & 0b01111111) / 127.f;

                cgi_SCR_DrawColorPic(bx, y, int(bar_width + scale), int(bar_height + scale), "_white", rgba_black);

                if (percent > 0)
                    cgi_SCR_DrawColorPic(bx, y, int(bar_width * percent), int(bar_height), "_white", rgba_red);
                if (percent < 1)
                    cgi_SCR_DrawColorPic(int(bx + (bar_width * percent)), y, int(bar_width * (1.f - percent)), int(bar_height), "_white", { 80, 80, 80, 255 });

                y += int(bar_height * 3);
            }
        }

/*
        else if (!strcmp(token, "story"))
        {
            const char *story_str = cgi.get_configstring(CONFIG_STORY);

            if (!*story_str)
                continue;

            const char *localized = cgi.Localize(story_str, nullptr, 0);
            vec2_t size = cgi.SCR_MeasureFontString(localized, scale);
            float centerx = ((hud_vrect.x + (hud_vrect.width * 0.5f)) * scale);
            float centery = ((hud_vrect.y + (hud_vrect.height * 0.5f)) * scale) - (size.y * 0.5f);

            cgi.SCR_DrawFontString(localized, centerx, centery, scale, rgba_white, true, text_align_t::CENTER);
        }
*/
        else
        {
            //cgi_Com_Print("invalid layout cmd: {}\n", tokenizer.as_string());
        }
    }

    if (skip_depth)
        cgi_Com_Error("if with no matching endif");
}

cvar_t @cl_skipHud;
cvar_t @cl_paused;

/*
================
CL_DrawInventory
================
*/
const uint DISPLAY_ITEMS   = 19;

void CG_DrawInventory(const player_state_t &in ps, const item_array_t &in inventory, const vrect_t &in hud_vrect, int32 scale)
{
    int     i;
    int     num, selected_num, item;
    item_array_t index; // AS_TODO: reusing this type instead of array
    int     x, y;
    int     width, height;
    int     selected;
    int     top;

    selected = ps.stats[player_stat_t::SELECTED_ITEM];

    num = 0;
    selected_num = 0;
    for (i=0 ; i<MAX_ITEMS ; i++) {
        if ( i == selected ) {
            selected_num = num;
        }
        if ( inventory[i] != 0 ) {
            index[num] = i;
            num++;
        }
    }

    // determine scroll point
    top = selected_num - DISPLAY_ITEMS/2;
    if (num - top < DISPLAY_ITEMS)
        top = num - DISPLAY_ITEMS;
    if (top < 0)
        top = 0;

    x = hud_vrect.x * scale;
    y = hud_vrect.y * scale;
    width = hud_vrect.width;
    height = hud_vrect.height;

    x += ((width / 2) - (256 / 2)) * scale;
    y += ((height / 2) - (216 / 2)) * scale;

    int pich, picw;
    cgi_Draw_GetPicSize(picw, pich, "inventory");
    cgi_SCR_DrawPic(x, y+8*scale, picw * scale, pich * scale, "inventory");

    y += 27 * scale;
    x += 22 * scale;

    for (i=top ; i<num && i < top+DISPLAY_ITEMS ; i++)
    {
        item = index[i];
        if (item == selected) // draw a blinky cursor by the selected item
        {
            if (( (cgi_CL_ClientRealTime() * 10) & 1) != 0)
                cgi_SCR_DrawChar(x-8, y, scale, 15, false);
        }

        if (scr_usekfont.integer == 0)
        {
            CG_DrawString(x, y, scale,
                format("{:3} {}", inventory[item],
                    cgi_Localize(cgi_get_configstring(configstring_id_t::ITEMS + item))),
                item == selected, false);
        }
        else
        {
            string s = format("{}", inventory[item]);
            cgi_SCR_DrawFontString(s, x + (216 * scale) - (16 * scale), y - (font_y_offset * scale), scale, (item == selected) ? alt_color : rgba_white, true, text_align_t::RIGHT);

            s = cgi_Localize(cgi_get_configstring(configstring_id_t::ITEMS + item));
            cgi_SCR_DrawFontString(s, x + (16 * scale), y - (font_y_offset * scale), scale, (item == selected) ? alt_color : rgba_white, true, text_align_t::LEFT);
        }
            
        y += 8 * scale;
    }
}

void CG_DrawHUD (int32 isplit, const cg_server_data_t &data, const vrect_t &in hud_vrect, const vrect_t &in hud_safe, int32 scale, int32 playernum, const player_state_t &in ps)
{
    if (cgi_CL_InAutoDemoLoop())
    {
        if (cl_paused.integer != 0)
            return; // demo is paused, menu is open

        uint64 time = cgi_CL_ClientRealTime() - cgame_init_time;
        if (time < 20000 && 
            (time % 4000) < 2000)
            cgi_SCR_DrawFontString(cgi_Localize("$m_eou_press_button"), int(hud_vrect.width * 0.5f * scale), int((hud_vrect.height - 64.f) * scale), scale, rgba_green, true, text_align_t::CENTER);
        return;
    }

    // draw HUD
    cgi_SCR_DrawFontString("AS CG", hud_safe.x * scale, ((hud_vrect.y + hud_vrect.height - 10) * scale) - hud_safe.y, scale, rgba_white, true, text_align_t::LEFT);

    if (cl_skipHud.integer == 0 && (ps.stats[player_stat_t::LAYOUTS] & layout_flags_t::HIDE_HUD) == 0)
    {
        tokenizer_t tokenizer(configstring_id_t::STATUSBAR);
        CG_ExecuteLayoutString(tokenizer, hud_vrect, hud_safe, scale, playernum, ps);
    }

    // draw centerprint string
    CG_CheckDrawCenterString(ps, hud_vrect, hud_safe, isplit, scale);

    // draw notify
    CG_DrawNotify(isplit, hud_vrect, hud_safe, scale);

    // svc_layout still drawn with hud off
    if ((ps.stats[player_stat_t::LAYOUTS] & layout_flags_t::LAYOUT) != 0)
    {
        tokenizer_t tokenizer(data.layout);
        CG_ExecuteLayoutString(tokenizer, hud_vrect, hud_safe, scale, playernum, ps);
    }

    // inventory too
    if ((ps.stats[player_stat_t::LAYOUTS] & layout_flags_t::INVENTORY) != 0)
        CG_DrawInventory(ps, data.inventory, hud_vrect, scale);
}

/*
================
CG_TouchPics

================
*/
void CG_TouchPics()
{
    foreach (auto @nums : sb_nums)
        foreach (auto str : nums)
            cgi_Draw_RegisterPic(str);

    cgi_Draw_RegisterPic("inventory");

    font_y_offset = int((cgi_SCR_FontLineHeight(1) - CONCHAR_WIDTH) / 2);
}

void CG_InitScreen()
{
    @cl_paused = cgi_cvar("paused", "0", cvar_flags_t::NOFLAGS);
    @cl_skipHud = cgi_cvar("cl_skipHud", "0", cvar_flags_t::ARCHIVE);
    @scr_usekfont = cgi_cvar("scr_usekfont", "1", cvar_flags_t::NOFLAGS);

    @scr_centertime  = cgi_cvar("scr_centertime", "5.0",  cvar_flags_t::ARCHIVE); // [Sam-KEX] Changed from 2.5
    @scr_printspeed  = cgi_cvar("scr_printspeed", "0.04", cvar_flags_t::NOFLAGS); // [Sam-KEX] Changed from 8
    @cl_notifytime   = cgi_cvar("cl_notifytime", "5.0",   cvar_flags_t::ARCHIVE);
    @scr_maxlines    = cgi_cvar("scr_maxlines", "4",      cvar_flags_t::ARCHIVE);
    @ui_acc_contrast = cgi_cvar("ui_acc_contrast", "0",   cvar_flags_t::NOFLAGS);
    @ui_acc_alttypeface = cgi_cvar("ui_acc_alttypeface", "0", cvar_flags_t::NOFLAGS);

    hud_data = array<hud_data_t>(MAX_SPLIT_PLAYERS);
}