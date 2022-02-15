using StaticArrays
using LinearAlgebra

struct LinearOnePortElement{T}
    model :: T
end

struct DifferentiableModel{TA, TB, TC, TD, TDQ, TE, TEQ, TF, TFQ, TM}
    # linear
    A :: TA
    B :: TB
    C :: TC
    D :: TD
    E :: TE
    F :: TF
    # nonlinear
    Dq :: TDQ
    Eq :: TEQ
    Fq :: TFQ
    # state
    x̄ :: Matrix{TM}
    y :: Matrix{TM}
    ū :: Matrix{TM}
    q̄ :: Matrix{TM}
    z :: Matrix{TM}
    params :: Dict{String, Any}
end

import Base
Base.copy(src::LinearOnePortElement) = LinearOnePortElement(copy(src.model))

function Base.copy(m::DifferentiableModel)
    A = m.A
    B = m.B
    C = m.C
    D = m.D
    E = m.E
    F = m.F
    Dq, Eq, Fq = m.Dq, m.Eq, m.Fq
    x̄, y, ū, q̄, z = m.x̄, m.y, m.ū, m.q̄, m.z
    return DifferentiableModel(A, B, C, D, E, F,
        Dq, Eq, Fq, copy(x̄), copy(y), copy(ū), copy(q̄), copy(z), copy(m.params))
end

function resetderivatives!(m::DifferentiableModel, ::Matrix{Float64})
    nothing
end

function resetderivatives!(m::DifferentiableModel, ::Matrix{Dual{Float64}})
    m.x̄ .= value.(m.x̄)
    m.y .= value.(m.y)
    m.ū .= value.(m.ū)
    m.q̄ .= value.(m.q̄)
    m.z .= value.(m.z)
    return nothing
end

function step!(m::DifferentiableModel, u)
    resetderivatives!(m, m.y)
    m.ū .= u
    
    m.y .= m.D * m.x̄;
    m.y.+= m.E * m.ū;
 
    m.x̄ .= m.A * m.x̄;
    m.x̄.+= m.B * m.ū;
    
    return m.y
end

function step!(m::DifferentiableModel, u, fnl)
    resetderivatives!(m, m.y)
    m.ū .= u
    
    for _ in 1:10
        m.q̄ .= m.Dq * m.x̄;
        m.q̄.+= m.Eq * m.ū;
        m.q̄.+= m.Fq * m.z;

        fq, dfdq  = fnl(m.q̄, m.params)
        dqdz = m.Fq

        dz = (dfdq * dqdz) \ fq
        m.z.-= dz
    end
    
    m.y .= m.D * m.x̄;
    m.y.+= m.E * m.ū;
    m.y.+= m.F * m.z;
 
    m.x̄ .= m.A * m.x̄;
    m.x̄.+= m.B * m.ū;
    m.x̄.+= m.C * m.z;
    
    return m.y
end

function smatrix(A::Vector; T=Float64)
    n = length(A)
    return n > 0 ? 
        SMatrix{1, n, T, n}(A) : SMatrix{1, n, T, n}(zeros(n, 1))
end

function smatrix(A::Matrix; T=Float64)
    n, m = size(A)
    return n * m > 0 ?
        SMatrix{n, m, T, n*m}(A) : SMatrix{n, 1, T, n}(zeros(n, 1))
end

function matrices(cir, Δt, y)
    M = ACME.model_matrices(cir, Δt)
    A  = M[:a] |> smatrix
    B  = M[:b] |> smatrix
    C  = M[:c] |> smatrix
    
    Di = M[:di][y,:] |> smatrix
    Ei = M[:ei][y,:] |> smatrix
    Fi = M[:fi][y,:] |> smatrix
    
    Dv = M[:dv][y,:] |> smatrix
    Ev = M[:ev][y,:] |> smatrix
    Fv = M[:fv][y,:] |> smatrix
    
    Dq = M[:dq_full] |> smatrix 
    Eq = M[:eq_full] |> smatrix
    Fq = M[:fq] |> smatrix
    return A, B, C, Di, Ei, Fi, Dv, Ev, Fv, Dq, Eq, Fq
end

function states(B, C, Dx, Dq; T=Float64)
    nx = size(Dx, 2)
    ny = size(Dx, 1)
    nq = size(Dq, 1)
    nu = size(B, 2)
    nz = size(C, 2)
    
    x = zeros(T, nx, 1)
    y = zeros(T, ny, 1)
    z = zeros(T, nz, 1)
    q = zeros(T, nq, 1)
    u = zeros(T, nu, 1)
    return x, y, u, q, z
end

