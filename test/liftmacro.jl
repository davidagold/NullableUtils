module TestLiftMacro

using NullableUtils
using Base.Test

f(x::Int, y::Int) = x * y
x = Nullable(5)
y = Nullable(5)
z = Nullable{Int}()
u = Nullable('a')

@test isequal((@lift f(x, y) Int), Nullable(25))
a = @lift f(x, z) Int
@test a.isnull == true
@test typeof(a).parameters[1] == Int
@test_throws MethodError @lift f(x, Nullable(5)) Int
@test_throws MethodError @lift f(x, u) Int

e = NullableUtils._lift(:( f(x, y) ), Int)
@test e.args[2].head == :if
@test e.args[2].args[1].head == :||

end # module TestLiftMacro
