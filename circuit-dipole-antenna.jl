let
    cir = @circuit begin
        i = currentprobe()
        u = voltagesource()
        r = resistor(2.344e+3)
        l = inductor(786.9e-9)
        c = capacitor(5.19e-12)
        rsh = resistor(1e2)
        lsh = inductor(800e-6)
    end

    connect!(cir, (:lsh, 2), (:rsh, 1))
    connect!(cir, (:u, +), (:lsh, 1))
    connect!(cir, (:i, +), (:rsh, 2))
    connect!(cir, (:u, +), (:c, 1))
    connect!(cir, (:c, 2), (:l, 1), (:r, 1))
    connect!(cir, (:i, +), (:l, 2), (:r, 2))
    connect!(cir, (:i, -), (:u, -), :gnd)

    A, B, C, Di, Ei, Fi, Dv, Ev, Fv, Dq, Eq, Fq = matrices(cir, Δt, 1)
    x̄, y, ū, q̄, z = states(B, C, Di, Dq, T=Dual{Float64})
    model = DifferentiableModel(A, B, C, Di, Ei, Fi, Dq, Eq, Fq,
        x̄, y, ū, q̄, z, Dict{String, Any}())
    
    return LinearOnePortElement(model)
end