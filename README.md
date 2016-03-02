# NullableUtils

[![Build Status](https://travis-ci.org/davidagold/NullableUtils.jl.svg?branch=master)](https://travis-ci.org/davidagold/NullableUtils.jl)
[![codecov.io](http://codecov.io/github/davidagold/NullableUtils.jl/coverage.svg?branch=master)](http://codecov.io/github/davidagold/NullableUtils.jl?branch=master)
<!-- [![Coverage Status](https://coveralls.io/repos/davidagold/NullableUtils.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/davidagold/NullableUtils.jl?branch=master) -->

This package is not currently registered. It can still be installed by calling
```julia
julia> Pkg.clone("https://github.com/davidagold/NullableUtils.jl.git")
```
NullableUtils provides utilities for working with `Nullable` objects in the Julia language. In particular, it provides a macro -- `@lift` -- that can be used to call a function `f` on an argument signature of `(Nullable{U1}, Nullable{U2}, ..., Nullable{Un})` if there exists a method of `f` defined for an argument signature of `(U1, U2, ..., Un)`. This can be useful if one needs to apply such an `f` to a collection of `Nullable` arguments but `f` has no method for argument signatures of `(Nullable{U1}, Nullable{U2}, ..., Nullable{Un})`. Calling `@lift f(x, y) T`, where `x, y` are `Nullable` objects will return an empty `Nullable{T}` if either `x` or `y` are null and otherwise return `Nullable(f(get(x), get(y)))`. Consider the following example:

```julia
julia> using NullableUtils

julia> f(x::Int, y::Int) = x * y
f (generic function with 1 method)

julia> x = Nullable(5); y = Nullable(5); z = Nullable{Int}();

julia> f(x, y)
ERROR: MethodError: no method matching f(::Nullable{Int64}, ::Nullable{Int64})
 in eval(::Module, ::Any) at ./boot.jl:267

julia> @lift f(x, y) Int
Nullable{Int64}(25)

julia> @lift f(x, z) Int
Nullable{Int64}()
```

The actual code that `@lift` splices into the AST can be examined by using `macroexpand`:

```julia
julia> macroexpand(:( @lift f(x, y) Int ))
quote  # /Users/David/.julia/v0.5/NullableUtils/src/liftmacro.jl, line 18:
    if isnull(y) || isnull(x) # /Users/David/.julia/v0.5/NullableUtils/src/liftmacro.jl, line 19:
        Nullable{Int}()
    else  # /Users/David/.julia/v0.5/NullableUtils/src/liftmacro.jl, line 21:
        Nullable(f(get(x),get(y)))
    end
end
```

Thought, he behavior of `@lift` is simplest when the function call to be lifted is simplest, arbitrarily complex function calls can be passed to the macro:

```julia
julia> macroexpand(:( @lift f(x, g(z, y)) + h(z) Int ))
quote  # /Users/David/.julia/v0.5/NullableUtils/src/liftmacro.jl, line 18:
    if (isnull(y) || isnull(z)) || isnull(x) # /Users/David/.julia/v0.5/NullableUtils/src/liftmacro.jl, line 19:
        Nullable{Int}()
    else  # /Users/David/.julia/v0.5/NullableUtils/src/liftmacro.jl, line 21:
        Nullable(f(get(x),g(get(z),get(y))) + h(get(z)))
    end
end
```

Work on support for `if` blocks is in the works.
