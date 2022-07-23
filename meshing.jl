# find edges in the mesh
function triedgemake()
    global EDGES
    global NODE_EDGES
    global ELEMENTS
    global ELEMENT_EDGES
    global NUM_ELEMS
    global NUM_NODES
    global NUM_EDGES
    global LOCALEDGENODES
    NODE_EDGES = Dict{Tuple{Int64, Int64}, Int64}()
    EDGES = zeros(Int64, 3NUM_ELEMS, 2)
    EDGES[1, :] = [ELEMENTS[1,1], ELEMENTS[1,2]]
    EDGES[2, :] = [ELEMENTS[1,1], ELEMENTS[1,3]]
    EDGES[3, :] = [ELEMENTS[1,2], ELEMENTS[1,3]]
    ELEMENT_EDGES = zeros(Int64, NUM_ELEMS, 3)
    ELEMENT_EDGES[1,1] = 1
    ELEMENT_EDGES[1,2] = 2
    ELEMENT_EDGES[1,3] = 3
    TEMPEDGES = zeros(Int64, 2)
    edge_counter = 3
    
    for ielem = 2:NUM_ELEMS
       for jedge = 1:3
         TEMPEDGES .= [ELEMENTS[ielem, LOCALEDGENODES[jedge,1]],
                       ELEMENTS[ielem, LOCALEDGENODES[jedge,2]]]
         sort!(TEMPEDGES)
         new_edge = true
         for kedge = 1:edge_counter
           if TEMPEDGES == EDGES[kedge, :]
             new_edge = false
             ELEMENT_EDGES[ielem, jedge] = kedge
             break
           end
         end
         if new_edge
           edge_counter = edge_counter + 1
           EDGES[edge_counter, :] .= TEMPEDGES
           ELEMENT_EDGES[ielem, jedge] = edge_counter
         end
       end
    end
    NUM_EDGES = edge_counter
    EDGES = EDGES[1:NUM_EDGES, :] # trim EDGES matrix
    for iedge = 1:NUM_EDGES
        n = sort(EDGES[iedge, :])
        NODE_EDGES[n[1], n[2]] = +iedge
        NODE_EDGES[n[2], n[1]] = -iedge
    end
    return nothing
end

# Generates mesh for a rectangular domain using right triangles
function trimesh(a, b, Nx, Ny)
    global NODE_COORD
    global ELEMENTS
    global EDGES
    global NUM_NODES
    global NUM_ELEMS
    global NUM_EDGES

    NUM_ELEMS = 2 * Nx * Ny
    ELEMENTS = zeros(Int64, NUM_ELEMS, 3)
    for jj = 1:Ny
        for ii = 1:Nx
            elem_offset = 2Nx   *(jj-1)
            node_offset = (Nx+1)*(jj-1)
            ELEMENTS[ii + elem_offset,:] = [ii + node_offset, ii + 1 + node_offset, ii + Nx + 1 + node_offset]
            ELEMENTS[ii + elem_offset + Nx,:] = [ii + 1 + node_offset, ii + Nx + 1 + node_offset, ii + Nx + 2 + node_offset]
        end
    end
   
    NUM_NODES = (Nx+1)*(Ny+1)
    NODE_COORD = zeros(Float64, NUM_NODES, 2)
    Δx = a/Nx
    Δy = b/Ny
    counter = 1
    for jj = 1:(Ny+1)
        for ii = 1:(Nx+1)
            NODE_COORD[counter, :] = [(ii-1)*Δx, (jj-1)*Δy]
            counter = counter + 1
        end
    end
    return nothing
end

# Generates mesh for a rectangular domain using quads
function quadmesh(a, b, Nx, Ny)
    global NUM_NODES
    global NUM_ELEMS
    global NUM_EDGES
    
    NUM_EDGES = 2(Nx*Ny) + Nx + Ny
    NUM_ELEMS = Nx * Ny
    el2edd = repeat([+1 +1 -1 -1], NUM_ELEMS)
    el2ed = zeros(Int64, NUM_ELEMS, 4)
    for jj = 1:Ny
        for ii = 1:Nx
            kk = (jj-1)Nx + ii
            el2ed[kk, :]  .= [ii, ii+Nx+1, ii+Nx+1+Nx, ii+Nx]
            el2ed[kk, :] .+= (jj-1) * (Nx + Nx + 1)
        end
    end
   
    return el2ed, el2edd
end