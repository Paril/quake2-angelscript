#pragma once

#include "q2as_local.h"
#include "bg_local.h"

struct q2as_edict_t;

class as_pmove_t : public q2as_ref_t
{
public:
	as_pmove_t()
	{
	}

	~as_pmove_t()
	{
        if (trace_f)
            trace_f->Release();
        if (clip_f)
            clip_f->Release();
        if (pointcontents_f)
            pointcontents_f->Release();
	}

    // for quick memcpy's
    pmove_t pm {};
    
    // new stuff
	asIScriptFunction *trace_f = nullptr;
	asIScriptFunction *clip_f = nullptr;
	asIScriptFunction *pointcontents_f = nullptr;

    uint32_t touch_length() const { return pm.touch.num; }
    void touch_push_back(const trace_t &v)
    {
        if (pm.touch.num == pm.touch.traces.size())
            return;
        
        pm.touch.traces[pm.touch.num++] = v;
    }
    const trace_t &touch_get(uint32_t i) { return pm.touch.traces[i]; }
    void touch_clear() { pm.touch.num = 0; }
};

#include "q2as_reg.h"

// register the factory for pmove itself.
template<typename T>
bool Q2AS_RegisterPmoveFactory(asIScriptEngine *engine)
{
	EnsureRegisteredBehaviourRaw("pmove_t", asBEHAVE_FACTORY, "pmove_t@ f()", asFUNCTION((Q2AS_Factory<as_pmove_t, T>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("pmove_t", asBEHAVE_ADDREF, "void f()", asFUNCTION((Q2AS_AddRef<as_pmove_t, T>)), asCALL_GENERIC);
	EnsureRegisteredBehaviourRaw("pmove_t", asBEHAVE_RELEASE, "void f()", asFUNCTION((Q2AS_Release<as_pmove_t, T>)), asCALL_GENERIC);

    return true;
}