// MIT Licensed
// see https://github.com/Paril/angelscript-ui-debugger

#pragma once

/*
 * 
 * a lightweight debugger for AngelScript. Built originally for Q2AS,
 * but hopefully usable for other purposes.
 * Design philosophy:
 * - zero overhead unless any debugging features are actually in use
 * - renders to an ImGui window
 * - only renders elements when requested; all rendered elements
 *   are cached by type + address.
 * - subclass to change how certain elements are rendered, etc.
 * - uses STL stuff to be portable.
 * - requires either fmt or std::format
 */

#include <unordered_map>
#include <unordered_set>
#include <type_traits>
#include <string>
#include <map>
#include <set>
#include <fmt/format.h>
#include <variant>
#include <mutex>
#include <filesystem>
#include "angelscript.h"

class asIDBDebugger;

template <class T>
inline void asIDBHashCombine(size_t &seed, const T& v)
{
    std::hash<T> hasher;
    seed ^= hasher(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
}

enum class asIDBExpandType : uint8_t
{
    None,      // no expansion
    Value,     // expands to display value
    Children,  // expands to display children
    Entries    // expands to display entries
};

struct asIDBTypeId
{
    int                 typeId = 0;
    asETypeModifiers    modifiers = asTM_NONE;

    constexpr bool operator==(const asIDBTypeId &other) const
    {
        return typeId == other.typeId && modifiers == other.modifiers;
    }
};

template<>
struct std::hash<asIDBTypeId>
{
    inline std::size_t operator()(const asIDBTypeId &key) const
    {
        size_t h = std::hash<int>()(key.typeId);
        asIDBHashCombine(h, std::hash<asETypeModifiers>()(key.modifiers));
        return h;
    }
};

using asIDBTypeNameMap = std::unordered_map<asIDBTypeId, std::string>;

// a reference to a type ID + fixed address somewhere
// in memory that will always be alive as long as
// the debugger is currently broken on a frame.
struct asIDBVarAddr
{
    int     typeId = 0;
    bool    constant = false;
    void    *address = nullptr;

    asIDBVarAddr() = default;

    constexpr asIDBVarAddr(int typeId, bool constant, void *address) :
        typeId(typeId),
        constant(constant),
        address(address)
    {
    }
    asIDBVarAddr(const asIDBVarAddr &) = default;

    constexpr bool operator==(const asIDBVarAddr &other) const
    {
        return typeId == other.typeId && address == other.address && constant == other.constant;
    }
};

// a resolved reference of a `asIDBVarAddr`. Similar to `asIDBVarAddr`,
// you should not keep these around very long.
struct asIDBResolvedVarAddr
{
    asIDBVarAddr    source;
    void            *resolved = nullptr;

    constexpr asIDBResolvedVarAddr(asIDBVarAddr source) :
        source(source),
        resolved((source.typeId & (asTYPEID_HANDLETOCONST | asTYPEID_OBJHANDLE)) ? *(void **)source.address : source.address)
    {
    }
};

template<>
struct std::hash<asIDBVarAddr>
{
    inline std::size_t operator()(const asIDBVarAddr &key) const
    {
        size_t h = std::hash<int>()(key.typeId);
        asIDBHashCombine(h, std::hash<void *>()(key.address));
        return h;
    }
};

// base type for a variable that can be viewed
// in the debugger. watch & non-watch type views
// store their data slightly differently.
struct asIDBVarViewBase
{
    virtual ~asIDBVarViewBase() { }

    std::string              name;
    std::string_view         type;

    inline asIDBVarViewBase(std::string name, std::string_view type) :
        name(name),
        type(type)
    {
    }

    virtual const asIDBVarAddr &GetID() const = 0;
    virtual struct asIDBVarState &GetState() = 0;
    virtual const asIDBVarState &GetState() const = 0;
    virtual bool IsValid() const = 0;
};

using asIDBVarViewVector = std::vector<struct asIDBVarView>;

// an individual value rendered out by the debugger.
struct asIDBVarValue
{
    bool disabled = false; // render with a different style
    asIDBExpandType expandable = asIDBExpandType::None;
    std::string value; // value to display in a value column or when expanded

    inline asIDBVarValue(const char *v, bool disabled = false, asIDBExpandType expandable = asIDBExpandType::None) :
        disabled(disabled),
        expandable(expandable),
        value(v ? v : "")
    {
    }

    inline asIDBVarValue(std::string v, bool disabled = false, asIDBExpandType expandable = asIDBExpandType::None) :
        disabled(disabled),
        expandable(expandable),
        value(v)
    {
    }
    
    asIDBVarValue(const asIDBVarValue &) = default;
    asIDBVarValue(asIDBVarValue &&) = default;
    asIDBVarValue &operator=(const asIDBVarValue &) = default;
    asIDBVarValue &operator=(asIDBVarValue &&) = default;
    asIDBVarValue() = default;
};

using asIDBVarValueVector = std::vector<asIDBVarValue>;

// a variable displayed in the debugger.
struct asIDBVarState
{
    asIDBVarValue value = {};

    std::unique_ptr<uint8_t[]> stackMemory; // if we're referring to a temporary value and not a handle
                                            // we have to make a copy of the value here since it won't
                                            // be available after the context is called (for getting
                                            // array elements, calling property getters, etc).

    // set when either children or entries have been
    // queried already.
    bool queriedChildren = false;

    // children views; this only matters when
    // value.expandable is asIDBExpandType::Children
    asIDBVarViewVector children;

    // entries; these are special bullet points
    // when value.expandable is asIDBExpandType::Entries
    asIDBVarValueVector entries;
};

// variables can be referenced by different names.
// this lets them retain their proper decl.
struct asIDBVarView : public asIDBVarViewBase
{
    asIDBVarAddr  id;
    asIDBVarState state;

    inline asIDBVarView(std::string name, std::string_view type, asIDBVarAddr id, asIDBVarState &&state) :
        asIDBVarViewBase(name, type),
        id(id),
        state(std::move(state))
    {
    }

    virtual const asIDBVarAddr &GetID() const override;
    virtual asIDBVarState &GetState() override;
    virtual const asIDBVarState &GetState() const override;
    virtual bool IsValid() const override { return true; }
};

// a local, fetched from GetVar
constexpr uint32_t LOCAL_THIS = (uint32_t) -1;

class asIDBVariableContainer;

struct asIDBNamedVariable
{
    asIDBResolvedVarAddr    address;
    std::string             name;
    std::string_view        type;
    std::string             value;
    asIDBVariableContainer  *container = nullptr;
};

struct asIDBVariableSource
{
    asIDBVariableContainer  *container = nullptr;
    size_t                  index = 0;
};

// in the debugger, all variable fetches are deferred.
// this is an interface to a variable that will be
// fetched at some point.
class asIDBVariableContainer
{
public:
    asIDBDebugger       *dbg; // pointer back to debugger
    int64_t             ref_id; // reference to our own variable id.
                                // this is set by the cache.
    asIDBVariableSource source; // the container is a child of this source
    bool cached;

    std::vector<asIDBNamedVariable>     named_variables;

    void Cache();

    asIDBVariableContainer(asIDBDebugger *dbg, int64_t ref_id, asIDBVariableSource source) : dbg(dbg), ref_id(ref_id), source(source), cached(source.container == nullptr) { }
    virtual ~asIDBVariableContainer() { }
};

using asIDBVariableMap = std::unordered_map<int64_t, std::unique_ptr<asIDBVariableContainer>>;

constexpr uint32_t SCOPE_SYSTEM = (uint32_t) -1;

// A scope contains variables.
struct asIDBScope
{
    uint32_t                   offset; // offset in stack fetches (GetVar, etc)
    asIDBVariableContainer     *parameters = nullptr;
    asIDBVariableContainer     *locals = nullptr;
    asIDBVariableContainer     *registers = nullptr; // "temporaries"

    asIDBScope(asUINT offset, asIDBDebugger *dbg, asIScriptFunction *function);

private:
    void CalcLocals(asIDBDebugger *dbg, asIScriptFunction *function, asIDBVariableContainer *container);
};

struct asIDBCallStackEntry
{
    int64_t             id; // unique id during debugging
    std::string         declaration;
    std::string_view    section;
    int                 row, column;
    asIDBScope          scope;
};

using asIDBCallStackVector = std::vector<asIDBCallStackEntry>;

struct asIDBGlobal
{
    bool            isProperty; // global property vs global variable
    uint32_t        offset;
    asIDBVarView    var;
};

class asIDBCache;

// This interface handles evaluation of asIDBVarAddr's.
// It is used when the debugger wishes to evaluate
// the value of, or the children/entries of, a var.
class asIDBTypeEvaluator
{
public:
    // evaluate the given id into a value. this tells
    // the debugger how to display the object.
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const { return {}; }

    // for expandable objects, this is called when the
    // debugger requests it be expanded.
    virtual void Expand(asIDBCache &, const asIDBResolvedVarAddr &id, asIDBVarState &state) const { }

    // for iterable objects, this is called when adding
    // variables to watch that include [n] or [n,n] selectors.
    virtual asIDBVarValue Index(asIDBCache &, const asIDBResolvedVarAddr &id, asIDBVarState &state, size_t iterator, size_t element) const { return {}; }
};

// built-in evaluators you can extend for
// making custom evaluators.

template<typename T>
class asIDBPrimitiveTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &, const asIDBResolvedVarAddr &id) const override
    {
        return { fmt::format("{}", *reinterpret_cast<const T *>(id.source.address)), false };
    }
};

// helper class to deal with foreach iteration.
class asIDBObjectIteratorHelper
{
public:
    asITypeInfo                         *type;
    void                                *obj;
    asIScriptFunction                   *opForBegin, *opForEnd, *opForNext;
    std::vector<asIScriptFunction *>    opForValues;

    asITypeInfo *iteratorType = nullptr;
    int         iteratorTypeId = 0;

    std::string_view    error;

    struct IteratorValue
    {
        const asIDBObjectIteratorHelper   *helper;
        union {
            uint8_t u8;
            uint16_t u16;
            uint32_t u32;
            uint64_t u64;
            float f;
            double d;
            asIScriptObject *obj;
            void *ptr;
        };

        IteratorValue() = delete;

        static IteratorValue FromCtxReturn(const asIDBObjectIteratorHelper *helper, asIScriptContext *ctx)
        {
            IteratorValue v(helper);

            if (helper->iteratorTypeId & asTYPEID_MASK_OBJECT)
            {
                v.ptr = ctx->GetReturnObject();
                helper->type->GetEngine()->AddRefScriptObject(v.ptr, helper->iteratorType);
            }
            else if (helper->iteratorTypeId == asTYPEID_BOOL ||
                     helper->iteratorTypeId == asTYPEID_INT8 ||
                     helper->iteratorTypeId == asTYPEID_UINT8)
                v.u8 = ctx->GetReturnByte();
            else if (helper->iteratorTypeId == asTYPEID_INT16 ||
                     helper->iteratorTypeId == asTYPEID_UINT16)
                v.u16 = ctx->GetReturnWord();
            else if (helper->iteratorTypeId == asTYPEID_INT32 ||
                     helper->iteratorTypeId == asTYPEID_UINT32)
                v.u32 = ctx->GetReturnDWord();
            else if (helper->iteratorTypeId == asTYPEID_INT64 ||
                     helper->iteratorTypeId == asTYPEID_UINT64)
                v.u64 = ctx->GetReturnQWord();
            else if (helper->iteratorTypeId == asTYPEID_FLOAT)
                v.f = ctx->GetReturnFloat();
            else if (helper->iteratorTypeId == asTYPEID_DOUBLE)
                v.d = ctx->GetReturnDouble();

            return v;
        }

        void SetArg(asIScriptContext *ctx, asUINT index) const
        {
            if (helper->iteratorTypeId & asTYPEID_MASK_OBJECT)
                ctx->SetArgObject(index, ptr);
            else if (helper->iteratorTypeId == asTYPEID_BOOL ||
                     helper->iteratorTypeId == asTYPEID_INT8 ||
                     helper->iteratorTypeId == asTYPEID_UINT8)
                ctx->SetArgByte(index, u8);
            else if (helper->iteratorTypeId == asTYPEID_INT16 ||
                     helper->iteratorTypeId == asTYPEID_UINT16)
                ctx->SetArgWord(index, u16);
            else if (helper->iteratorTypeId == asTYPEID_INT32 ||
                     helper->iteratorTypeId == asTYPEID_UINT32)
                ctx->SetArgDWord(index, u32);
            else if (helper->iteratorTypeId == asTYPEID_INT64 ||
                     helper->iteratorTypeId == asTYPEID_UINT64)
                ctx->SetArgQWord(index, u64);
            else if (helper->iteratorTypeId == asTYPEID_FLOAT)
                ctx->SetArgFloat(index, f);
            else if (helper->iteratorTypeId == asTYPEID_DOUBLE)
                ctx->SetArgDouble(index, d);
        }

        ~IteratorValue()
        {
            if (ptr && (helper->iteratorTypeId & asTYPEID_MASK_OBJECT))
                helper->type->GetEngine()->ReleaseScriptObject(obj, helper->iteratorType);
        }

        IteratorValue(const IteratorValue &) :
            helper(helper),
            ptr(ptr)
        {
            if (ptr && (helper->iteratorTypeId & asTYPEID_MASK_OBJECT))
                helper->type->GetEngine()->AddRefScriptObject(obj, helper->iteratorType);
        }

        IteratorValue(IteratorValue &&move) noexcept :
            helper(helper),
            ptr(ptr)
        {
            move.ptr = nullptr;
        }

        IteratorValue &operator=(const IteratorValue &other)
        {
            helper = other.helper;
            ptr = other.ptr;
            if (ptr && (helper->iteratorTypeId & asTYPEID_MASK_OBJECT))
                helper->type->GetEngine()->AddRefScriptObject(obj, helper->iteratorType);
            return *this;
        }
        IteratorValue &operator=(IteratorValue &&move) noexcept
        {
            helper = move.helper;
            ptr = move.ptr;
            move.ptr = nullptr;
            return *this;
        }

    private:
        IteratorValue(const asIDBObjectIteratorHelper *helper) :
            helper(helper),
            ptr(nullptr)
        {
        }
    };

    asIDBObjectIteratorHelper(asITypeInfo *type, void *obj);

    constexpr bool IsValid() const { return opForBegin != nullptr; }
    constexpr explicit operator bool() const { return IsValid(); }
    
    // individual access
    IteratorValue Begin(asIScriptContext *ctx);
    IteratorValue Next(asIScriptContext *ctx, const IteratorValue &val);
    bool End(asIScriptContext *ctx, const IteratorValue &val);

    // O(n) helper for length
    inline size_t CalculateLength(asIScriptContext *ctx)
    {
        size_t length = 0;
        for (auto it = Begin(ctx); !End(ctx, it); length++, it = Next(ctx, it)) ;
        return length;
    }

private:
    bool Validate()
    {
        if (!opForBegin || !opForEnd || !opForNext)
            return false;

        iteratorTypeId = opForBegin->GetReturnTypeId();

        if (!iteratorTypeId)
        {
            error = "bad iterator return type";
            return false;
        }

        if (!(iteratorTypeId & asTYPEID_MASK_OBJECT) &&
            iteratorTypeId > asTYPEID_DOUBLE)
        {
            error = "unsupported iterator type";
            return false;
        }

        iteratorType = opForBegin->GetEngine()->GetTypeInfoById(iteratorTypeId);

        // TODO: more validation

        return true;
    }
};

class asIDBObjectTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual asIDBVarValue Evaluate(asIDBCache &cache, const asIDBResolvedVarAddr &id) const override;
    virtual void Expand(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &state) const override;

protected:
    // convenience function that queries the properties of the given
    // address (and object, if set) of the given type.
    void QueryVariableProperties(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &var) const;
    
    // convenience function that iterates the opFor* of the given
    // address (and object, if set) of the given type. If positive,
    // a specific index will be used.
    void QueryVariableForEach(asIDBCache &cache, const asIDBResolvedVarAddr &id, asIDBVarState &var, int index = -1) const;
};

// This class manages `asIDBTypeEvaluator` instances
// and handles the logic of finding the best
// instance for the given type.
// You can register existing IDs to replace their implementation.
// When a type ID is not explicitly registered, a static evaluator
// will take over. Note that you must register the type ID's
// sequence number, so remove any additional flags (asTYPEID_MASK_OBJECT | asTYPEID_MASK_SEQNBR).
class asIDBTypeEvaluatorMap
{
    std::unordered_map<int, std::unique_ptr<asIDBTypeEvaluator>> evaluators;

    // fetch the evaluator for the given type id.
    const asIDBTypeEvaluator &GetEvaluator(class asIDBCache &, const asIDBResolvedVarAddr &id) const;

public:
    // evaluate the given id into a value. this tells
    // the debugger how to display the object.
    asIDBVarValue Evaluate(class asIDBCache &, const asIDBResolvedVarAddr &id) const;

    // for expandable objects, this is called when the
    // debugger requests it be expanded.
    void Expand(class asIDBCache &, const asIDBResolvedVarAddr &id, asIDBVarState &state) const;

    // Register an evaluator.
    void Register(int typeId, std::unique_ptr<asIDBTypeEvaluator> evaluator);

    // A quick shortcut to make a templated instantiation
    // of T from the given type name.
    template<typename T>
    void Register(asIScriptEngine *engine, const char *name)
    {
        Register(engine->GetTypeInfoByName(name)->GetTypeId(), std::make_unique<T>());
    }
};

// the result of an expression evaluation.
// note that this currently only supports
// storing a chain of valid, non-temporary
// fetches that result in a single value.
struct asIDBExprResult
{
    asIDBVarAddr    idKey;
    asIDBVarState   value;
};

// simple std::expected-like
template<typename T>
struct asIDBExpected
{
private:
    std::variant<std::string_view, T> data;

public:
    constexpr asIDBExpected() :
        data("unknown error")
    {
    }

    constexpr asIDBExpected(const std::string_view v) :
        data(std::in_place_index<0>, v)
    {
    }

    constexpr asIDBExpected(T &&v) :
        data(std::in_place_index<1>, std::move(v))
    {
    }
    
    asIDBExpected(const asIDBExpected<T> &) = default;
    asIDBExpected(asIDBExpected<T> &&) = default;
    asIDBExpected &operator=(const asIDBExpected<T> &) = default;
    asIDBExpected &operator=(asIDBExpected<T> &&) = default;
    
    constexpr bool has_value() const { return data.index() == 1; }
    constexpr explicit operator bool() const { return has_value(); }
    
    constexpr const std::string_view &error() const { return std::get<0>(data); }
    constexpr const T &value() const { return std::get<1>(data); }
    constexpr T &value() { return std::get<1>(data); }
};

// this class holds the cached state of stuff
// so that we're not querying things from AS
// every frame. You should only ever make one of these
// once you have a context that you are debugging.
// It should be destroyed once that context is
// destroyed.
class asIDBCache
{
private:
    asIDBCache() = delete;
    asIDBCache(const asIDBCache &) = delete;
    asIDBCache &operator=(const asIDBCache &) = delete;

public:
    // the main context this cache is hooked to.
    // this will be reset to null if the context
    // is unhooked.
    asIScriptContext *ctx;

    // cache of type id+modifiers to names
    asIDBTypeNameMap type_names;

    // cached call stack
    asIDBCallStackVector call_stack;

    // type evaluators
    asIDBTypeEvaluatorMap evaluators;

    // cached globals
    // TODO
    asIDBVariableContainer *global = nullptr;

    // cached map of variable reference to
    // a variable provider.
    asIDBVariableMap variables;

    // ptr back to debugger
    asIDBDebugger *dbg;

    // pointers to temporary memory, which can be referred
    // to by a asIDBResolvedVarAddr
    std::vector<std::unique_ptr<uint8_t[]>> temp_memory;

    inline asIDBCache(asIDBDebugger *dbg, asIScriptContext *ctx) :
        dbg(dbg),
        ctx(ctx)
    {
        ctx->AddRef();
    }
    
    virtual ~asIDBCache()
    {
        ctx->ClearLineCallback();
        ctx->Release();
    }

    // restore data from the given cache that is
    // being replaced by this one.
    virtual void Restore(asIDBCache &cache);

    // caches all of the global properties in the context.
    virtual void CacheGlobals();

    // caches all of the locals with the specified key.
    virtual void CacheLocals(asIDBScope &scope);

    // cache call stack entries
    virtual void CacheCallstack();

    // called when the debugger has broken and it needs
    // to refresh certain cached entries. This will only refresh
    // the state of active entries.
    virtual void Refresh();

    // get a safe view into a cached type string.
    virtual const std::string_view GetTypeNameFromType(asIDBTypeId id);

    // for the given type + property data, fetch the address of the
    // value that this property points to.
    virtual void *ResolvePropertyAddress(const asIDBResolvedVarAddr &id, int propertyIndex, int offset, int compositeOffset, bool isCompositeIndirect);

    // resolve the given expression to a unique var state.
    // `expr` must contain a resolvable expression; it's a limited
    // form of syntax designed solely to resolve a variable.
    // The format is as follows (curly brackets indicates optional elements; ellipses indicate
    // supporting zero or more entries):
    // var{selector...}
    // `var` must be either:
    // - the name of a local, parameter, class member, or global. if there are multiple
    //   matches, they will be selected in that same defined order.
    // - a fully qualified name to a local, parameter, class member, global, or
    //   `this`. This follows the same rules for qualification that the compiler
    //   does (`::` can be used to refer to the global scope).
    // - a stack variable index, prefixed with &. This can be used to disambiguate
    //   in the rare case where you have a collision in parameters. It can also be
    //   used to select temporaries, if necessary.
    // `selector` must be one or more of the following:
    // - a valid property of the left hand side, in the format:
    //     .name
    // - an iterator index, in the format:
    //     [n{, o}]
    //   Only uint indices are supported. You may also optionally select which
    //   value to retrieve from multiple opValue implementations; if not specified
    //   it will default to zero (that is to say, [0] and [0,0] are equivalent).
    virtual asIDBExpected<asIDBExprResult> ResolveExpression(const std::string_view expr, int stack_index);

    // Resolve the remainder of a sub-expression; see ResolveExpression
    // for the syntax.
    virtual asIDBExpected<asIDBExprResult> ResolveSubExpression(const asIDBResolvedVarAddr &idKey, const std::string_view rest, int stack_index);

    // Create a variable container.
    asIDBVariableContainer *CreateVariableContainer(asIDBVariableSource source = {})
    {
        int64_t next_id = variables.size() + 1;
        return variables.emplace(next_id, std::make_unique<asIDBVariableContainer>(dbg, next_id, source)).first->second.get();
    }
};

struct asIDBBreakpoint
{
    int line;
};

using asIDBSectionBreakpoints = std::vector<asIDBBreakpoint>;

enum class asIDBAction : uint8_t
{
    None,
    StepInto,
    StepOver,
    StepOut,
    Continue
};

// The workspace is contains information about the
// "project" that the debugger is operating within.
// This should be set, otherwise file comparisons
// and such may not work. File paths are always
// stored relatively, because debuggers have different
// ideas on file paths.
struct asIDBWorkspace
{
    std::string             base_path;
    std::set<std::string>   sections;

    std::string PathToSection(const std::string_view v)
    {
        return std::filesystem::relative(v, base_path).generic_string();
    }

    std::string SectionToPath(const std::string_view v)
    {
        return (base_path + '/').append(v);
    }
};

// This is the main class for interfacing with
// the debugger. This manages the debugger thread
// and the 'state' of the debugger itself. The debugger
// only needs to be kept alive if it still has work to do,
// but be careful about destroying the debugger if any
// contexts are still attached to it.
/*abstract*/ class asIDBDebugger
{
public:
    // mutex for shared state, like the cache and breakpoints.
    std::recursive_mutex mutex;

    // next action to perform
    asIDBAction action = asIDBAction::None;
    asUINT stack_size = 0; // for certain actions (like Step Over) we have to know
                           // the size of the old stack.

    // if true, line callback will not execute
    // (used to prevent infinite loops)
    std::atomic_bool internal_execution = false;
    
    // active breakpoints
    std::unordered_map<std::string_view, asIDBSectionBreakpoints> breakpoints;

    // workspace
    asIDBWorkspace workspace;

    // list of engines that can be hooked.
    std::unordered_set<asIScriptEngine *> engines;

    // cache for the current active broken state.
    // the cache is only kept for the duration of
    // a broken state; resuming in any way destroys
    // the cache.
    std::unique_ptr<asIDBCache> cache;

    // current frame offset for use by the cache
    std::atomic_int64_t frame_offset = 0;

    asIDBDebugger() { }
    virtual ~asIDBDebugger() { }

    // hooks the context onto the debugger; this will
    // reset the cache, and unhook the previous context
    // from the debugger. You'll want to call this if
    // HasWork() returns true and you're requesting
    // a new context / executing code from a context
    // that isn't already hooked.
    void HookContext(asIScriptContext *ctx);

    // break on the current context. Creates the cache
    // and then suspends. Note that the cache will
    // add a reference to this context, preventing it
    // from being deleted until the cache is reset.
    void DebugBreak(asIScriptContext *ctx);

    // check if we have any work left to do.
    // it is only safe to destroy asIDBDebugger
    // if this returns false. If it returns true,
    // a context still has a linecallback set
    // using this debugger.
    virtual bool HasWork();

    // debugger operations; these set the next breakpoint,
    // clear the cache context and call Resume.
    virtual void SetAction(asIDBAction new_action);

    // breakpoint stuff
    bool ToggleBreakpoint(std::string_view section, int line);

    // get the source code for the given section
    // of the given module.
    // FIXME: can we move this to cache?
    virtual std::string FetchSource(const char *section) = 0;

protected:
    // called when the debugger is being asked to pause.
    // don't call directly, use DebugBreak.
    virtual void Suspend() = 0;

    // called when the debugger is being asked to resume.
    // don't call directly, use Continue.
    virtual void Resume() = 0;

    // create a cache for the given context.
    virtual std::unique_ptr<asIDBCache> CreateCache(asIScriptContext *ctx) = 0;

    static void LineCallback(asIScriptContext *ctx, asIDBDebugger *debugger);
};
