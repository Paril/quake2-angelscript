// Copyright (c) ZeniMax Media Inc.
// Licensed under the GNU General Public License 2.0.


/*
* AS wishlist:
* 
* - backed enums
* - ability to change visibility of default generated constructors/assignment operators
*   use case: special handle type that you don't want to ever be able to `=` by accident,
*   but the code should still be there since it's used internally to reset the members
*   back to empty or whatever.
* - ability to create conversion constructors, for implicit conversions;
*   ie `class X { int y; implicit X(int h) { this.y = h; } }` would allow `X x = 5`, etc
* - aggregate type init, although it might conflict with list init... I'd be fine if
*   aggregate init required type to preceed it; for instance `class C { int y; string z = "defaulted"; }`
*   could be initialized with `C c = C { 50, "hello" }`, `C c = C { 50 }` maybe.
*   bonus points for allowing the variable specification syntax (`C c = C { .z = "ayy" }`)
* - funcdefs should natively allow opAssign on themselves. There's no ambiguity unlike regular
*   handles (they either hold a function or they don't). `funcdef void T(); T @x; x = some_func;` should just work
*   but atm you *have* to do `@x = some_func;` which is redundant, as unlike classes there's not an opAssign that might
*   change the semantics here.
* - enums have operators, but they don't produce a result of the enum type; I get why, but
*   it would be nice to have an option to specify that the enum is a bitflag or something
*   which changes the semantics of operators.
* - for some reason, can't pass custom 8 byte value type by value from script to native.
* - support for integer literal separators (ie 1'000'000)
* - it's "legal" to call functions to initialize enum members, but the values are garbage: uint64 bit_v(int n) { return uint64(1) << n; } enum Test { TEST = bit_v(1) }
* - varargs functions (ie `string format(const string&in fmt, const ?&in ...)`) don't consider zero arguments to the `...` to be a valid number, and always expect
*   something to be passed in. I'm of two minds about this; on one hand, it allows for you to make an optimized overload that does not use
*   the varargs, but on the other hand it means you *have* to make an overload that accepts zero.
* - asEP_ALLOW_IMPLICIT_HANDLE_TYPES and asEP_DISALLOW_VALUE_ASSIGN_FOR_REF_TYPE are useful but only situationally, which makes
*   these options a hammer to the entire codebase when you rather need a chisel to a specific type. I think this would be better
*   as a modifier on specific types. For reference types, it isn't uncommon to still need to use the value-assign (for resetting
*   the values to default); I think a C++-style solution of being able to do, for instance, `protected T &opAssign(const T &in) = default;` would
*   be better. It doesn't require any options and would let the class type opt out of value assign, except in member functions where it is explicitly
*   necessary. It would allow the compiler (ideally) to then know that `T = T` (value assign) is not allowed outside of member funcs, and it can automatically switch it to
*   identity assign. The only downside is this changes the semantics of `=` whether you're in a member function or not. Alternatively, it could still force the switch,
*   but programmers would need to call `opAssign` explicitly for value assign.
* - support for a `nodiscard` attribute of some kind. It's diagnostic-only, it should just warn if you attempt to call a function
*   without storing or using the result. It's especially helpful for scripting languages since it attracts newer programmers imo.
* - inout support for value types. I know this is a topic that is technically covered already, but I end up just doing `void F(const int &in, int &out)` and calling it
*   with the same two parameters anyways - isn't that something that could be just done automatically as syntactic sugar?
* - asEP_ flag to require overridden methods to contain `override`. I always set this to be an error in C++ because it's error-prone otherwise.
* - CScriptArray has no `clear()` member. I think resize(0) might be equivalent but semantically this might
*   be confusing since generally resize(0) will reallocate the buffer in other languages, whereas clear
*   does not.
* - the new implicit bool conversion feature does not take logical operators into account; a type with `bool opImplConv() const` registered
*   by the host cannot be used with `if (a || b)` for instance.
* - calling constructors from other constructors. similar to `super()` this should be allowed; it is mainly useful when you want to
*   provide a non-default constructor that sets members, while letting the default initializer do its magic. This might be a different issue,
*   but an example is provided here:
* ```
* class pushed_t
{
	ASEntity @ent;
	vec3_t	 origin;
	vec3_t	 angles;
	bool	 rotated = false;
	float	 yaw = 0;

    pushed_t() { }

    pushed_t(ASEntity @ent, bool rotated = false)
    {
        @this.ent = ent;
        this.origin = ent.e.s.origin;
        this.angles = ent.e.s.angles;

        if (rotated) // error: says this.rotated is not set in all paths
		             // but this may be confusing because it is initialized
					 // up top. I didn't check atm if it actually is initialized
					 // and this is a false-positive, or if using a constructor
					 // causes it to not initialize the members.
        {
            this.rotated = true;
            this.yaw = ent.client !is null ? float(ent.e.client.ps.pmove.delta_angles[YAW]) : ent.e.s.angles[YAW];
        }
    }
};
* ```
* - a long shot, but there's a specific syntax in a few other languages I really like
*   for object construction. C# has it, and it's super useful for chaining and making bespoke
*   constructors on the fly when you only need to adjust one or two things.
*   X obj = X() { a = 0, b = 1, c = 2 };
* - why is it required to have the default case be the last one in a switch? optimization?
*/

#include "../g_local.h"
#include "../cg_local.h"
#include "q2as_main.h"
#include "q2as_local.h"

#define ALLOW_FILESYSTEM



