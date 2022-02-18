struct Dual{T <:Number} <:Number
     v::T
    dv::T
    di::T
end

import Base: +, -, *, /, ^
-(x::Dual)          = Dual(-x.v, -x.dv, -x.di)
+(x::Dual, y::Dual) = Dual( x.v + y.v, x.dv + y.dv, x.di + y.di)
-(x::Dual, y::Dual) = Dual( x.v - y.v, x.dv - y.dv, x.di - y.di)
*(x::Dual, y::Dual) = Dual( x.v * y.v, x.dv * y.v + x.v * y.dv, x.di * y.v + x.v * y.di)
/(x::Dual, y::Dual) = Dual( x.v / y.v,(x.dv * y.v - x.v * y.dv)/y.v^2, (x.di * y.v - x.v * y.di)/y.v^2)
^(x::Dual, y::Float64) = Dual(x.v^y, !iszero(y)* x.dv * y * x.v^(y-1), !iszero(y)* x.di * y * x.v^(y-1))

import Base: abs, sin, cos, tan, exp, log, sqrt, conj, abs2, isless, isapprox
abs(x::Dual)  = Dual(abs(x.v),sign(x.v)*x.dv,sign(x.v)*x.di)
sin(x::Dual)  = Dual(sin(x.v), cos(x.v)*x.dv, cos(x.v)*x.di)
cos(x::Dual)  = Dual(cos(x.v),-sin(x.v)*x.dv,-sin(x.v)*x.di)
tan(x::Dual)  = Dual(tan(x.v), one(x.v)*x.dv + tan(x.v)^2*x.dv, one(x.v)*x.di + tan(x.v)^2*x.di)
exp(x::Dual)  = Dual(exp(x.v), exp(x.v)*x.dv, exp(x.v)*x.di)
log(x::Dual)  = Dual(log(x.v), x.dv/x.v, x.di/x.v)
sqrt(x::Dual) = Dual(sqrt(x.v),.5/sqrt(x.v) * x.dv,.5/sqrt(x.v) * x.di)
conj(x::Dual) = x
abs2(x::Dual) = abs(x) * abs(x)
isless(x::Dual, y::Dual) = x.v < y.v
isless(x::Float64, y::Dual) = x < y.v
isless(x::Dual, y::Float64) = x.v < y
isapprox(x::Dual{Float64}, y::Float64) = x.v ≈ y


import Base: convert, promote_rule
convert(::Type{Dual{T}}, x::Dual) where T = Dual(convert(T, x.v), convert(T, x.dv), convert(T, x.di))
convert(::Type{Dual{T}}, x::Number) where T = Dual(convert(T, x), zero(T), zero(T))
promote_rule(::Type{Dual{T}}, ::Type{R}) where {T,R} = Dual{promote_type(T,R)}

import Base: show
show(io::IO, x::Dual) = print(io, "(", x.v, " + ", x.dv, "ϵv + ", x.di, "ϵi)");
float(x::Dual) = x.v;
float(x::Float64) = x;
dv(x::Dual) = x.dv;
di(x::Dual) = x.di;
dv(x::Float64) = 0.0
di(x::Float64) = 0.0

ϵv = Dual(0., 1., 0.)
ϵi = Dual(0., 0., 1.)