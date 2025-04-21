#pragma once

#include <array>
#include "q_std.h"
#include "q2as_reg.h"

template<typename T, size_t N>
struct q2as_fixedarray
{
    using array = std::array<T, N>;

    static void ListConstruct(asIScriptGeneric *gen)
    {
        array &v = *reinterpret_cast<array *>(gen->GetObject());
        v = *reinterpret_cast<array *>(gen->GetArgAddress(0));
    }

    template<typename... Args>
    static void PackConstruct(Args... args, array &v)
    {
        size_t i = 0;
        ((v[i++] = args), ...);
    }

    static T &IndexRef(uint32_t i, array &v)
    {
        if (i >= N)
        {
            asGetActiveContext()->SetException("Index out of range");
            return v[0];
        }

        return v[i];
    }

    static const T &IndexRefConst(uint32_t i, const array &v)
    {
        if (i >= N)
        {
            asGetActiveContext()->SetException("Index out of range");
            return v[0];
        }

        return v[i];
    }

    static uint32_t Size(const array &)
    {
        return N;
    }

    static uint32_t opForBegin(const array &v)
    {
        return 0;
    }

    static uint32_t opForNext(uint32_t v, const array &a)
    {
        return v + 1;
    }

    static T opForValue(uint32_t v, const array &a)
    {
        return IndexRefConst(v, a);
    }

    static bool opForEnd(uint32_t v, const array &a)
    {
        return v >= N;
    }
};

template<typename T, size_t... I>
constexpr auto q2as_get_fixed_constructor_expanded(std::index_sequence<I...>)
{
    return &q2as_fixedarray<T, sizeof...(I)>::template PackConstruct<std::enable_if_t<I || true, T>...>;
}

template<typename T, size_t N>
constexpr auto q2as_get_fixed_constructor()
{
    return q2as_get_fixed_constructor_expanded<T>(std::make_index_sequence<N>());
}

template<typename T, size_t N>
inline void Q2AS_RegisterFixedArray(q2as_registry &registry, const char *name, const char *underlying, int traits, bool register_constructors = true)
{
    using AT = std::array<T, N>;
    using FT = q2as_fixedarray<T, N>;

    auto type = registry
        .type(name, sizeof(AT), asOBJ_VALUE | asOBJ_POD | traits | asGetTypeTraits<AT>())
        .methods({
            { fmt::format("{} &opIndex(uint)", underlying),             asFUNCTION(FT::IndexRef),      asCALL_CDECL_OBJLAST },
            { fmt::format("const {} &opIndex(uint) const", underlying), asFUNCTION(FT::IndexRefConst), asCALL_CDECL_OBJLAST },
            { "uint32 size() const",                                    asFUNCTION(FT::Size),          asCALL_CDECL_OBJLAST },
            
            { "uint opForBegin() const",                            asFUNCTION(FT::opForBegin), asCALL_CDECL_OBJLAST },
            { "uint opForNext(uint) const",                         asFUNCTION(FT::opForNext),  asCALL_CDECL_OBJLAST },
            { fmt::format("{} opForValue(uint) const", underlying), asFUNCTION(FT::opForValue), asCALL_CDECL_OBJLAST },
            { "bool opForEnd(uint) const",                          asFUNCTION(FT::opForEnd),   asCALL_CDECL_OBJLAST },
        });

    if (register_constructors)
    {
        std::string list;

        for (size_t i = 0; i < N; i++)
        {
            if (i != 0)
                list += ", ";

            list += underlying;
        }

        type.behaviors({ { asBEHAVE_CONSTRUCT, fmt::format("void f({})", list),
                           asFUNCTION((q2as_get_fixed_constructor<T, N>())), asCALL_CDECL_OBJLAST },
                         { asBEHAVE_LIST_CONSTRUCT, fmt::format("void f(int &in) {{ {} }}", list),
                           asFUNCTION(FT::ListConstruct), asCALL_GENERIC } });
    }
}