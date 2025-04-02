#pragma once

template<typename T, size_t N>
struct q2as_fixedarray
{
    using array = std::array<T, N>;

    static void ListConstruct(int *buffer, array &v)
    {
        int n = *buffer;

        if (n != N)
        {
            asGetActiveContext()->SetException("List needs exactly N params");
            return;
        }

        T *p = (T *) (buffer + 1);

        for (int i = 0; i < n; i++)
        {
            v[i] = *p;

            if constexpr (sizeof(T) <= 4)
                p++;
            else
                p = (T *) (((uint8_t *) p) + sizeof(T) + (sizeof(T) % 4));
        }
    }

    static T &IndexRef(uint32_t i, array &v)
    {
        if (i < 0 || i >= N)
        {
            asGetActiveContext()->SetException("Index out of range");
            return v[0];
        }

        return v[i];
    }

    static const T &IndexRefConst(uint32_t i, const array &v)
    {
        if (i < 0 || i >= N)
        {
            asGetActiveContext()->SetException("Index out of range");
            return v[0];
        }

        return v[i];
    }

    static uint32_t Size()
    {
        return N;
    }
};

template<typename T, size_t N>
inline void Q2AS_RegisterFixedArray(q2as_registry &registry, const char *name, const char *underlying, int traits)
{
    using AT = std::array<T, N>;
    using FT = q2as_fixedarray<T, N>;

    registry
        .type(name, sizeof(AT), asOBJ_VALUE | asOBJ_POD | traits | asGetTypeTraits<AT>())
        .behaviors({
            { asBEHAVE_LIST_CONSTRUCT, fmt::format("void f(int &in) {{ repeat {} }}", underlying), asFunctionPtr(FT::ListConstruct), asCALL_CDECL_OBJLAST }
        })
        .methods({
            { fmt::format("{} &opIndex(uint)", underlying),             asFunctionPtr(FT::IndexRef),      asCALL_CDECL_OBJLAST },
            { fmt::format("const {} &opIndex(uint) const", underlying), asFunctionPtr(FT::IndexRefConst), asCALL_CDECL_OBJLAST },
            { "uint32 size() const",                                    asFunctionPtr(FT::Size),          asCALL_CDECL_OBJLAST }
        });
}