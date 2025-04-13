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
#include <set>
#include <type_traits>
#include <string>
#include <set>
#include <variant>
#include <mutex>
#include <filesystem>
#include <optional>
#include <memory>
#include "angelscript.h"

#ifdef __cpp_lib_format
#include <format>
namespace fmt = std;
#else
#include <fmt/format.h>
#endif

class asIDBDebugger;

struct asIDBTypeId
{
    int                 typeId = 0;
    asETypeModifiers    modifiers = asTM_NONE;

    constexpr bool operator==(const asIDBTypeId &other) const
    {
        return typeId == other.typeId && modifiers == other.modifiers;
    }
};

template <class T>
inline void asIDBHashCombine(size_t &seed, const T& v)
{
    std::hash<T> hasher;
    seed ^= hasher(v) + 0x9e3779b9 + (seed<<6) + (seed>>2);
}

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

// a resolved reference of a `asIDBVarAddr`.
struct asIDBResolvedVarAddr
{
    asIDBVarAddr    source {};
    void            *resolved = nullptr;

    asIDBResolvedVarAddr() = default;

    constexpr asIDBResolvedVarAddr(asIDBVarAddr source) :
        source(source),
        resolved((source.typeId & (asTYPEID_HANDLETOCONST | asTYPEID_OBJHANDLE)) ? *(void **)source.address : source.address)
    {
    }

    template<typename T>
    T *ResolveAs() const
    {
        return reinterpret_cast<T *>(resolved);
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

// a variable for the debugger.
struct asIDBVariable
{
    using Ptr = std::shared_ptr<asIDBVariable>;
    using WeakPtr = std::weak_ptr<asIDBVariable>;
    using Set = std::unordered_set<Ptr>;
    using Vector = std::vector<WeakPtr>;
    using Map = std::unordered_map<int64_t, WeakPtr>;

    WeakPtr       ptr;
    asIDBDebugger &dbg;

    asIDBResolvedVarAddr       address;
    std::string                name;
    std::string                ns = "::";
    std::string                value;
    std::string_view           typeName;
    std::unique_ptr<uint8_t[]> stackData {};
    WeakPtr                    owner {};
    
    bool evaluated = false;
    bool expanded = false;

    asIDBVariable(asIDBDebugger &dbg) :
        dbg(dbg)
    {
    }

    const Vector &Children() const { return children; }
    void MakeExpandable();
    void PushChild(WeakPtr ptr);
    int64_t RefId() const { return ref_id.value_or(0); }

    Ptr CreateChildVariable(std::string name, std::string ns, asIDBResolvedVarAddr address, std::string_view typeName);

    void Evaluate();
    void Expand();

private:
    // if ref_id is set, the variable has children.
    // call asIDBCache::LinkVariable to set this.
    std::optional<int64_t>     ref_id {};
    Vector                     children;
};

// a local, fetched from GetVar
constexpr uint32_t SCOPE_SYSTEM = (uint32_t) -1;

// A scope contains variables.
struct asIDBScope
{
    uint32_t           offset; // offset in stack fetches (GetVar, etc)
    asIDBVariable::Ptr parameters;
    asIDBVariable::Ptr locals;
    asIDBVariable::Ptr registers; // "temporaries"

    std::unordered_map<uint32_t, asIDBVariable::WeakPtr> local_by_index;
    asIDBVariable::WeakPtr this_ptr;

    asIDBScope(asUINT offset, asIDBDebugger &dbg, asIScriptFunction *function);

private:
    void CalcLocals(asIDBDebugger &dbg, asIScriptFunction *function, asIDBVariable::Ptr &container);
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

class asIDBCache;

// This interface handles evaluation of asIDBVarAddr's.
// It is used when the debugger wishes to evaluate
// the value of, or the children/entries of, a var.
class asIDBTypeEvaluator
{
public:
    // evaluate the given variable.
    virtual void Evaluate(asIDBVariable::Ptr var) const { }

    // for expandable objects, this is called when the
    // debugger requests it be expanded.
    virtual void Expand(asIDBVariable::Ptr var) const { }
#if 0
    // for iterable objects, this is called when adding
    // variables to watch that include [n] or [n,n] selectors.
    virtual asIDBVariable Index(asIDBCache &, const asIDBVarAddr &id, asIDBVarState &state, size_t iterator, size_t element) const { return {}; }
#endif
};

// built-in evaluators you can extend for
// making custom evaluators.
template<typename T>
class asIDBPrimitiveTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override;
};

// helper class to deal with foreach iteration.
class asIDBObjectIteratorHelper
{
public:
    asIDBDebugger                       &dbg;
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

    asIDBObjectIteratorHelper(asIDBDebugger &dbg, asITypeInfo *type, void *obj);

    constexpr bool IsValid() const { return opForBegin != nullptr; }
    constexpr explicit operator bool() const { return IsValid(); }
    
    // individual access
    IteratorValue Begin(asIScriptContext *ctx) const;
    void Value(asIScriptContext *ctx, const IteratorValue &val, size_t index) const;
    IteratorValue Next(asIScriptContext *ctx, const IteratorValue &val) const;
    bool End(asIScriptContext *ctx, const IteratorValue &val) const;

    // O(n) helper for length
    size_t CalculateLength(asIScriptContext *ctx) const;

private:
    bool Validate();
};

class asIDBObjectTypeEvaluator : public asIDBTypeEvaluator
{
public:
    virtual void Evaluate(asIDBVariable::Ptr var) const override;

    virtual void Expand(asIDBVariable::Ptr var) const override;

protected:
    // convenience function that queries the properties of the given
    // address (and object, if set) of the given type.
    void QueryVariableProperties(asIDBVariable::Ptr var) const;

    // convenience function that iterates the opFor* of the given
    // address (and object, if set) of the given type. If positive,
    // a specific index will be used.
    void QueryVariableForEach(asIDBVariable::Ptr var, int index = -1) const;
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
    
public:
    // fetch the evaluator for the given type id.
    const asIDBTypeEvaluator &GetEvaluator(class asIDBCache &, const asIDBResolvedVarAddr &id) const;

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

    constexpr asIDBExpected(const T &v) :
        data(std::in_place_index<1>, v)
    {
    }

    constexpr asIDBExpected(asIDBExpected<void> &&v);
    
    asIDBExpected(const asIDBExpected<T> &) = default;
    asIDBExpected(asIDBExpected<T> &&) = default;
    asIDBExpected &operator=(const asIDBExpected<T> &) = default;
    asIDBExpected &operator=(asIDBExpected<T> &&) = default;

    constexpr asIDBExpected &operator=(const T &v)
    {
        return *this = asIDBExpected<T>(v);
    }

    constexpr asIDBExpected &operator=(T &&v)
    {
        return *this = asIDBExpected<T>(v);
    }
    
    constexpr bool has_value() const { return data.index() == 1; }
    constexpr explicit operator bool() const { return has_value(); }
    
    constexpr const std::string_view &error() const { return std::get<0>(data); }
    constexpr const T &value() const { return std::get<1>(data); }
    constexpr T &value() { return std::get<1>(data); }
};

template<>
struct asIDBExpected<void>
{
private:
    std::string_view err;

public:
    constexpr asIDBExpected() :
        err("unknown error")
    {
    }

    constexpr asIDBExpected(const std::string_view v) :
        err(v)
    {
    }

    constexpr const std::string_view &error() const { return err; }
};

template<typename T>
constexpr asIDBExpected<T>::asIDBExpected(asIDBExpected<void> &&v) :
    data(std::in_place_index<0>, v.error())
{
}
 
template<class E> 
asIDBExpected(E) -> asIDBExpected<void>;

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
    asIDBVariable::Ptr globals;

    // cached set of variables
    asIDBVariable::Set variables;

    // cached map of var IDs to their variable.
    asIDBVariable::Map variable_refs;

    // ptr back to debugger
    asIDBDebugger &dbg;

    // pointers to temporary memory, which can be referred
    // to by a asIDBResolvedVarAddr
    std::vector<std::unique_ptr<uint8_t[]>> temp_memory;

    inline asIDBCache(asIDBDebugger &dbg, asIScriptContext *ctx) :
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
    virtual asIDBExpected<asIDBVariable::WeakPtr> ResolveExpression(std::string_view expr, std::optional<int> stack_index);
    
    // Resolve the remainder of a sub-expression; see ResolveExpression
    // for the syntax.
    virtual asIDBExpected<asIDBVariable::WeakPtr> ResolveSubExpression(asIDBVariable::WeakPtr var, const std::string_view rest);

    // Create a variable container. Generally you don't call
    // this directly, unless you need a blank variable.
    asIDBVariable::Ptr CreateVariable()
    {
        asIDBVariable::Ptr ptr = std::make_shared<asIDBVariable>(dbg);
        ptr->ptr = ptr;
        return *variables.emplace(ptr).first;
    }
};

struct asIDBBreakpoint
{
    int                line;
    std::optional<int> column;
};

using asIDBSectionBreakpoints = std::vector<asIDBBreakpoint>;

// TODO: class/namespace specifier
using asIDBSectionFunctionBreakpoints = std::unordered_set<std::string>;

enum class asIDBAction : uint8_t
{
    None,
    StepInto,
    StepOver,
    StepOut,
    Continue
};
    
struct asIDBLineCol
{
    int line, col;

    constexpr bool operator<(const asIDBLineCol &o) const { return line == o.line ? col < o.col : line < o.line; }
};

using asIDBSectionSet = std::set<std::string, std::less<>>;
using asIDBEngineSet = std::unordered_set<asIScriptEngine *>;
using asIDBPotentialBreakpointMap = std::unordered_map<std::string_view, std::set<asIDBLineCol, std::less<>>>;

// The workspace is contains information about the
// "project" that the debugger is operating within.
// This should be set, otherwise file comparisons
// and such may not work. File paths are always
// stored relatively, because debuggers have different
// ideas on file paths.
struct asIDBWorkspace
{
    // base path for the workspace
    std::string     base_path;

    // sections that this workspace is working with
    asIDBSectionSet sections;

    // list of engines that can be hooked.
    asIDBEngineSet engines;

    // map of breakpoint positions
    asIDBPotentialBreakpointMap potential_breakpoints;

    asIDBWorkspace(std::string_view base_path, std::initializer_list<asIScriptEngine *> engines) :
        base_path(base_path)
    {
        for (auto &engine : engines)
            if (engine)
                this->engines.insert(engine);

        CompileScriptSources();
        CompileBreakpointPositions();
    }

    virtual void AddSection(std::string_view section)
    {
        if (auto it = sections.find(section); it == sections.end())
            sections.insert(std::string(section));
    }

    virtual std::string PathToSection(const std::string_view v) const
    {
        return std::filesystem::relative(v, base_path).generic_string();
    }

    virtual std::string SectionToPath(const std::string_view v) const
    {
        return (base_path + '/').append(v);
    }

    void CompileScriptSources();
    void CompileBreakpointPositions();
};

using asIDBBreakpointMap = std::unordered_map<std::string_view, asIDBSectionBreakpoints>;

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

    // workspace
    asIDBWorkspace *workspace;
    
    // active breakpoints
    asIDBBreakpointMap breakpoints;

    // active function breakpoints
    asIDBSectionFunctionBreakpoints function_breakpoints;

    // cache for the current active broken state.
    // the cache is only kept for the duration of
    // a broken state; resuming in any way destroys
    // the cache.
    std::unique_ptr<asIDBCache> cache;

    // current frame offset for use by the cache
    std::atomic_int64_t frame_offset = 0;

    asIDBDebugger(asIDBWorkspace *workspace) :
        workspace(workspace)
    {
    }

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

template<typename T>
/*virtual*/ void asIDBPrimitiveTypeEvaluator<T>::Evaluate(asIDBVariable::Ptr var) const /*override*/
{
    var->value = fmt::format("{}", *var->address.ResolveAs<const T>());
}