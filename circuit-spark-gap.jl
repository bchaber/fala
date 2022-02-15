struct SparkGap{T}
    model :: T
    nonlinear_eq :: Function
end

import Base: copy
Base.copy(src::SparkGap) = SparkGap(copy(src.model), src.nonlinear_eq)

let
    cir = @circuit begin
        i = currentprobe()
        v = voltagesource()
        ⚡ = arcchannel()
    end

    connect!(cir, (:v, +), (:i, +))
    connect!(cir, (:i, -), (:⚡, 1))
    connect!(cir, (:v, -), (:⚡, 2), :gnd)

    A, B, C, Di, Ei, Fi, Dv, Ev, Fv, Dq, Eq, Fq = matrices(cir, Δt, 1)
    x̄, y, ū, q̄, z = states(B, C, Di, Dq, T=Dual{Float64})
    model = DifferentiableModel(A, B, C, Di, Ei, Fi, Dq, Eq, Fq,
        x̄, y, ū, q̄, z, Dict{String, Any}(
    "v_break" => bruce(1atm, 1mm),
    "pressure" => 1atm,
    "distance" => 1mm,
    "channel_on" => false,
    "i_min" => 5e-5,
    "Δt" => Δt,
    "∫i²" => 0.0,
    "t_arc" => 0.0,
    "t_over" => 0.0
    ))
    return SparkGap(model, nonlinear_eq)
end