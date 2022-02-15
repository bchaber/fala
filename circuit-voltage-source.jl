struct VoltageSource{T}
    model :: T
end

import Base: copy
Base.copy(src::VoltageSource) = VoltageSource(copy(src.model))

let        
    cir = @circuit begin
        i = currentprobe()
        u = voltagesource()
        v = voltagesource()
        l = inductor(1e-12)
        r = resistor(Rs)
    end

    connect!(cir, (:u, +), (:v, -))
    connect!(cir, (:v, +), (:l, 1))
    connect!(cir, (:l, 2), (:r, 1))
    connect!(cir, (:r, 2), (:i, +))
    connect!(cir, (:i, -), :gnd)
    connect!(cir, (:u, -), :gnd)


    A, B, C, Di, Ei, Fi, Dv, Ev, Fv, Dq, Eq, Fq = matrices(cir, Δt, 1)
    x̄, y, ū, q̄, z = states(B, C, Di, Dq, T=Dual{Float64})
    model = DifferentiableModel(A, B, C, Di, Ei, Fi, Dq, Eq, Fq,
        x̄, y, ū, q̄, z, Dict{String, Any}())
    
    return VoltageSource(model)
end