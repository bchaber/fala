struct WhitneyTriangleElement end
struct WhitneyRectangleElement end
struct Nabla end
Ni = Nj = WhitneyTriangleElement()
Ni = Nj = WhitneyRectangleElement()
∇ = Nabla();

function meshgrid(x, y)
   X = [x for _ in y, x in x]
   Y = [y for y in y, _ in x]
   X, Y
end

function whitney(::WhitneyTriangleElement, λ, ∇λ)
    w = zeros(3, 2)
    @. w[1, :] = λ[1] * ∇λ[2] - λ[2] * ∇λ[1]  
    @. w[2, :] = λ[1] * ∇λ[3] - λ[3] * ∇λ[1] 
    @. w[3, :] = λ[2] * ∇λ[3] - λ[3] * ∇λ[2]  
    return w
end

function whitney(::WhitneyRectangleElement, hx, hy)
    w = zeros(4, 2)
    w[1, :] .= [1. - hy,      0.]
    w[2, :] .= [     0.,     +hx]
    w[3, :] .= [    -hy,      0.]
    w[4, :] .= [     0., hx - 1.]
    return w
end

function evaluate(elem::WhitneyTriangleElement, e, dof_e1, XX, YY)
    global LOCALEDGENODES
    global ELEMENT_EDGES
    global NODE_COORD
    global NUM_ELEMS
    global NUM_DOFS
    global ELEMENTS
    global EDGES
    vec_field = zeros(length(XX), length(YY), 2)
    dofs_tri  = zeros(Float64, 3)
    for ii = 1:length(XX)
        for jj = 1:length(YY)
          point_found = false
          # Get coordinates for this point 
          xc = XX[ii]
          yc = YY[jj]
          for i_elem = 1:NUM_ELEMS
            trinodes = ELEMENTS[i_elem, :]
            x1 = NODE_COORD[trinodes[1],1]
            y1 = NODE_COORD[trinodes[1],2]
            x2 = NODE_COORD[trinodes[2],1]
            y2 = NODE_COORD[trinodes[2],2]
            x3 = NODE_COORD[trinodes[3],1]
            y3 = NODE_COORD[trinodes[3],2]
            D  = inv([x1 x2 x3
                      y1 y2 y3
                      1. 1. 1.]);
            # Find bounding rectangle
            xlower = min(x1, x2, x3)
            xupper = max(x1, x2, x3)
            ylower = min(y1, y2, y3)
            yupper = max(y1, y2, y3)
            # Check if point lies inside bounding rectangle
            if (xlower <= xc <= xupper) && (ylower <= yc <= yupper)
              λ = simplex2D(i_elem, xc, yc)
              ϵ = 1e-4
              if (0.0 - ϵ <= λ[1] <= 1.0 + ϵ) &&
                 (0.0 - ϵ <= λ[2] <= 1.0 + ϵ) &&
                 (0.0 - ϵ <= λ[3] <= 1.0 + ϵ)
                # This point lies in or on this element. 
                edges = ELEMENT_EDGES[i_elem, 1:3];
                # Get global dof's associated with this triangle.
                # if 0, then prescribed
                dof_e1_tri = dof_e1[edges[1:3]]
                # Now get the global dof associated with the local edge.
                for k_edge = 1:3
                  if dof_e1_tri[k_edge] > 0
                    dofs_tri[k_edge] = e[dof_e1_tri[k_edge]];
                  else
                    dofs_tri[k_edge] = 0.0; # prescribed
                  end
                end
                b = D[:,1]
                c = D[:,2]
                a = D[:,3]
                ∇λ = [[b[1], c[1]],
                      [b[2], c[2]],
                      [b[3], c[3]]]
                w = whitney(elem, λ, ∇λ);
                vec_field[ii, jj, :] .=  dofs_tri[1] .* w[1, :] .+
                                         dofs_tri[2] .* w[2, :] .+
                                         dofs_tri[3] .* w[3, :]
                point_found = true;
                break
              end
            end
          end
          if point_found == false
              println("Oops! Point ($xc, $yc) not found!")
          end
        end
    end
    return vec_field
end

function evaluate(elem::WhitneyRectangleElement, e, dof, XX, YY, nx, ny, lx, ly, el2ed, el2edd)
    vec_field = zeros(length(XX), length(YY), 2)
    dofs_quad = zeros(Float64, 4)
    for ii = 1:length(XX)
        for jj = 1:length(YY)
            xc = XX[ii]
            yc = YY[jj]
            
            fx, fy = 1. + xc/lx, 1. + yc/ly
            ix, iy = floor(Int64, fx), floor(Int64, fy)
            i_elem = (iy - 1)nx + ix
            hx, hy = fx - ix, fy - iy
            edges = el2ed[i_elem, 1:4]
            eddir = el2edd[i_elem, 1:4]
            
            for k_edge = 1:4
                if dof[edges[k_edge]] > 0
                    dofs_quad[k_edge] = e[dof[edges[k_edge]]] * eddir[k_edge];
                else
                    dofs_quad[k_edge] = 0.0; # prescribed
                end
            end
            # Now get the global dof associated with the local edge.
            w = whitney(elem, hx, hy);
            vec_field[ii, jj, :] .=  dofs_quad[1] .* w[1, :] .+
                                     dofs_quad[2] .* w[2, :] .+
                                     dofs_quad[3] .* w[3, :] .+
                                     dofs_quad[4] .* w[4, :]
        end
    end
    return vec_field
end