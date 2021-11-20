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
end

function step!(m::DifferentiableModel, u, f=nothing, df=nothing)
    m.ū .= u
    if !isnothing(f)
        for _ in 1:500
            m.q̄ .= m.Dq * m.x̄;
            m.q̄.+= m.Eq * m.ū;
            m.q̄.+= m.Fq * m.z;

            fq   =  f(m.q̄) # should be 0.0
            dfdq = df(m.q̄)
            dqdz = m.Fq

            dz = (dfdq * dqdz) \ fq
            m.z.-= dz
        end; println("Norm after nonlinear iterations: ", norm(f(m.q̄)))
    end
    
    m.y .= m.D * m.x̄;
    m.y.+= m.E * m.ū;
    if !isnothing(f) m.y.+= m.F * m.z; end
 
    m.x̄ .= m.A * m.x̄;
    m.x̄.+= m.B * m.ū;
    if !isnothing(f) m.x̄.+= m.C * m.z; end
end