using SparseArrays, LinearAlgebra

n = 5
m = 5

maxPile(n, m) = fill(3, n, m)

pileOver(a, b) = a .+ b

function toppleSize!(a, i, j)
    n, m = size(a)
    a[i,j] = a[i,j] - 4
    if i > 1
        a[i-1,j] = a[i-1,j] + 1
    end
    if i < n
        a[i+1,j] = a[i+1,j] + 1
    end
    if j > 1
        a[i,j-1] = a[i,j-1] + 1
    end
    if j < m
        a[i,j+1] = a[i,j+1] + 1
    end
end

function topplePile!(a)
    done = false
    allTopples  = 0
    while !done
        count = 0
        n, m = size(a)
        for i = 1:n
            for j = 1:m
                if a[i,j] > 3
                    toppleSize!(a, i, j)
                    count = count + 1
                end
            end
        end
        allTopples = allTopples + count
        done = count == 0
    end
    println(allTopples, " toppled.")
    a
end

addPiles(a,b) = topplePile!(pileOver(a,b))

function findId(a)
    aa = copy(a)
    last = aa
    found = false
    count = 0
    while !found
        count = count + 1
        next = addPiles(last, aa)
        if next == a
            println(count)
            return last
        end
        last = next
    end
end

# Δ = A - D
function Δ(n, m)
    # x, y are coordinates in Δ
    xs = Array{Int64, 1}()
    ys = Array{Int64, 1}()
    vals = Array{BigInt, 1}()
    # coordinates in pile
    for col = 1:n
        for row = 1:m
            # A
            push!(xs,  (row-1)*n+col)
            push!(ys,  (row-1)*n+col)
            push!(vals, 4)
            # D
            rowNeighbour = row - 1
            if rowNeighbour > 0
                push!(xs,  (rowNeighbour-1)*n+col)
                push!(ys,  (row-1)*n+col)
                push!(vals, -1)
                push!(xs,  (row-1)*n+col)
                push!(ys,  (rowNeighbour-1)*n+col)
                push!(vals, -1)
            end
            rowNeighbour = row + 1
            if rowNeighbour < m
                push!(xs,  (rowNeighbour-1)*n+col)
                push!(ys,  (row-1)*n+col)
                push!(vals, -1)
                push!(xs,  (row-1)*n+col)
                push!(ys,  (rowNeighbour-1)*n+col)
                push!(vals, -1)
            end
            colNeighbour = col - 1
            if colNeighbour > 0
                push!(xs,  (row-1)*n+colNeighbour)
                push!(ys,  (row-1)*n+col)
                push!(vals, -1)
                push!(xs,  (row-1)*n+col)
                push!(ys,  (row-1)*n+colNeighbour)
                push!(vals, -1)
            end
            colNeighbour = col + 1
            if colNeighbour < n
                push!(xs,  (row-1)*n+colNeighbour)
                push!(ys,  (row-1)*n+col)
                push!(vals, -1)
                push!(xs,  (row-1)*n+col)
                push!(ys,  (row-1)*n+colNeighbour)
                push!(vals, -1)
            end
        end
    end
    # If an index i,j occures more than once,
    # sparse(..) defaults to adding the values, we need max?
    #    println(vals)
    sparse(xs, ys, vals, n*m, n*m, max)
end


b(n,m) = sum(Matrix(Δ(n, m)), dims = 1)

# should for any graph
# seems to do only for n x n
function bij_any(n,m)
    bb = b(n,m)
    r = zeros(Int64,n,m)
    for i in 1:n
        for j in 1:m
            r[i,j] = bb[(i-1)*m+j]
        end
    end
    r
end


function bij(n,m)
    r = zeros(Int64,n,m)
    for i in 1:m
        r[1, i] = r[1,i] + 1
        r[n, i] = r[n,i] + 1
    end
    for j in 1:n
        r[j, 1] = r[j,1] + 1
        r[j, m] = r[j,m] + 1
    end
    r
end

d(n,m) = numerator(det(Matrix(Δ(n, m)).//1))


#=

julia> @time id1 = findId(maxPile(1,1))
4
  0.000090 seconds (19 allocations: 992 bytes)
1×1 Array{Int64,2}:
 0

julia> @time id2 = findId(maxPile(2,2))
2
  0.000067 seconds (18 allocations: 1.172 KiB)
2×2 Array{Int64,2}:
 2  2
 2  2

julia> @time id3 = findId(maxPile(3,3))
16
  0.000086 seconds (31 allocations: 3.219 KiB)
3×3 Array{Int64,2}:
 2  1  2
 1  0  1
 2  1  2

julia> @time id4 = findId(maxPile(4,4))
2
  0.000067 seconds (16 allocations: 1.172 KiB)
4×4 Array{Int64,2}:
 2  3  3  2
 3  2  2  3
 3  2  2  3
 2  3  3  2

julia> @time id5 = findId(maxPile(5,5))
104
  0.000213 seconds (118 allocations: 30.172 KiB)
5×5 Array{Int64,2}:
 2  3  2  3  2
 3  2  1  2  3
 2  1  0  1  2
 3  2  1  2  3
 2  3  2  3  2

julia> @time id6 = findId(maxPile(6,6))
58
  0.000220 seconds (73 allocations: 21.969 KiB)
6×6 Array{Int64,2}:
 2  1  3  3  1  2
 1  2  2  2  2  1
 3  2  2  2  2  3
 3  2  2  2  2  3
 1  2  2  2  2  1
 2  1  3  3  1  2

julia> @time id7 = findId(maxPile(7,7))
544
  0.010790 seconds (561 allocations: 265.219 KiB)
7×7 Array{Int64,2}:
 2  1  3  2  3  1  2
 1  2  2  1  2  2  1
 3  2  2  1  2  2  3
 2  1  1  0  1  1  2
 3  2  2  1  2  2  3
 1  2  2  1  2  2  1
 2  1  3  2  3  1  2

julia> @time id8 = findId(maxPile(8,8))
1802
  0.045013 seconds (1.82 k allocations: 1.074 MiB)
8×8 Array{Int64,2}:
 0  2  1  3  3  1  2  0
 2  2  3  3  3  3  2  2
 1  3  2  2  2  2  3  1
 3  3  2  2  2  2  3  3
 3  3  2  2  2  2  3  3
 1  3  2  2  2  2  3  1
 2  2  3  3  3  3  2  2
 0  2  1  3  3  1  2  0

julia> @time id9 = findId(maxPile(9,9))
146248
  2.098239 seconds (146.26 k allocations: 102.654 MiB, 0.58% gc time)
9×9 Array{Int64,2}:
 0  2  1  3  2  3  1  2  0
 2  2  3  3  2  3  3  2  2
 1  3  2  2  1  2  2  3  1
 3  3  2  2  1  2  2  3  3
 2  2  1  1  0  1  1  2  2
 3  3  2  2  1  2  2  3  3
 1  3  2  2  1  2  2  3  1
 2  2  3  3  2  3  3  2  2
 0  2  1  3  2  3  1  2  0

julia> @time id10 = findId(maxPile(10,10))
179786
  3.453807 seconds (179.80 k allocations: 153.628 MiB, 0.29% gc time)
10×10 Array{Int64,2}:
 2  3  3  0  3  3  0  3  3  2
 3  2  2  1  2  2  1  2  2  3
 3  2  2  3  3  3  3  2  2  3
 0  1  3  2  2  2  2  3  1  0
 3  2  3  2  2  2  2  3  2  3
 3  2  3  2  2  2  2  3  2  3
 0  1  3  2  2  2  2  3  1  0
 3  2  2  3  3  3  3  2  2  3
 3  2  2  1  2  2  1  2  2  3
 2  3  3  0  3  3  0  3  3  2


julia> @time id11 = findId(maxPile(11,11))
7889840
223.714248 seconds (7.89 M allocations: 7.995 GiB, 0.57% gc time)
11×11 Array{Int64,2}:
 2  3  3  0  3  2  3  0  3  3  2
 3  2  2  1  2  1  2  1  2  2  3
 3  2  2  3  3  2  3  3  2  2  3
 0  1  3  2  2  1  2  2  3  1  0
 3  2  3  2  2  1  2  2  3  2  3
 2  1  2  1  1  0  1  1  2  1  2
 3  2  3  2  2  1  2  2  3  2  3
 0  1  3  2  2  1  2  2  3  1  0
 3  2  2  3  3  2  3  3  2  2  3
 3  2  2  1  2  1  2  1  2  2  3
 2  3  3  0  3  2  3  0  3  3  2

julia> @time id12 = findId(maxPile(12,12))
11517430
431.803468 seconds (11.52 M allocations: 13.387 GiB, 0.93% gc time)
12×12 Array{Int64,2}:
 2  1  3  3  0  3  3  0  3  3  1  2
 1  2  3  3  2  3  3  2  3  3  2  1
 3  3  0  2  3  3  3  3  2  0  3  3
 3  3  2  2  2  2  2  2  2  2  3  3
 0  2  3  2  2  2  2  2  2  3  2  0
 3  3  3  2  2  2  2  2  2  3  3  3
 3  3  3  2  2  2  2  2  2  3  3  3
 0  2  3  2  2  2  2  2  2  3  2  0
 3  3  2  2  2  2  2  2  2  2  3  3
 3  3  0  2  3  3  3  3  2  0  3  3
 1  2  3  3  2  3  3  2  3  3  2  1
 2  1  3  3  0  3  3  0  3  3  1  2


=#

#=
Notes:

p6, Lemma 2.9

delta: delta[i] = d_i ??
not stable! (???)

p8

Let sigma = 2 delta - 2

now stabilise(sigma) <= delta - 1

thus

sigma - stabilize(sigma) >= delta - 1

thus sigma - stabilise(sigma) is accessible

I = stabilise(sigma - stabilise(sigma))


=#

# Holroyd, Levine, M´esz´aros, Peres, Propp and Wilson
# "Chip-Firing and Rotor-Routing on Directed Graphs", p8
# may I take any delta???
function findId(n,m)
    δ = fill(4,n,m) - bij(n,m) #maxPile(n,m)
    # σ = 2δ - 2
    σ = pileOver(pileOver(δ, δ), fill(-2,n,m))
    s1 = topplePile!(copy(σ))
    s2 = pileOver(σ, -1 .* s1)
    topplePile!(s2)
end
