using StaticArrays
using LinearAlgebra

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
    x̄ :: TM
    y :: TM
    ū :: TM
    q̄ :: TM
    z :: TM
    params :: Dict{String, Any}
end

function step!(m::DifferentiableModel, u, f_nonlin=nothing, f_after=nothing)
    m.ū .= u
    if !isnothing(f_nonlin)
        for _ in 1:500
            m.q̄ .= m.Dq * m.x̄;
            m.q̄.+= m.Eq * m.ū;
            m.q̄.+= m.Fq * m.z;

            fq, dfdq  =  f_nonlin(m.q̄, m.params)
            dqdz = m.Fq

            dz = (dfdq * dqdz) \ fq
            m.z.-= dz
        end; println("Norm after nonlinear iterations: ", norm(f_nonlin(m.q̄, m.params)))
        f_after(m.q̄, m.params)
    end
    
    m.y .= m.D * m.x̄;
    m.y.+= m.E * m.ū;
    if !isnothing(f_nonlin) m.y.+= m.F * m.z; end
 
    m.x̄ .= m.A * m.x̄;
    m.x̄.+= m.B * m.ū;
    if !isnothing(f_nonlin) m.x̄.+= m.C * m.z; end
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

