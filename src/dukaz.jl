module dukaz
using Lazy
using BigRationals
using DataFrames

export Node, interval_prob, prob, depth_map, mean, split_data, checksame, copy, dimensions, uniq_size, intervals


struct Node
    data ::Vector{Union{Number,NTuple}}
    prob ::BigRational
    depth::Int64
    split::Vector
    Node(data; prob =BigRational(1,1), depth = 0, split = UnitRange[] ) = new(data,prob,depth,split)
end


Base.:(==)(first::Node, second::Node) = 
 return first.data == second.data && 
 first.prob == second.prob && 
 first.depth == second.depth &&
 first.split == second.split


prob(node::Node, tups, point, dim=1) ::Node = begin
    (node.data[1] |> length) == 3  && @show dim, node.split
    Node(
        first(tups.right)[dim] <= point[dim] ? tups.right : tups.left,
        prob  = node.prob * (first(tups.right)[dim]-last(tups.left)[dim])/(last(tups.right)[dim]-first(tups.left)[dim]),
        depth = node.depth+1,
        split = [node.split...,(dim = dim, range = last(tups.left)[dim]:first(tups.right)[dim])]
    )
end


checksame(left, right, dim) = begin
    last(left)[dim] == first(right)[dim]
end

split_data(data, sp, dim = 1)::Union{NamedTuple{(:left, :right)},Missing} =
    @>>begin
    data
    sort(by = x -> x[dim])
    data -> (left=data[1:sp-1], right =data[sp:length(data)])
    res -> checksame(res.left, res.right, dim) ? missing : res
end

    Base.copy(node::Node;dims ) = @>> begin
    Node(
        node.data,
        prob = node.prob * 1 // length(dims),
        depth = node.depth,
        split = node.split
    )
end

dimensions(data) = 1:length(data[1])

uniq_size(data, dim) = @>> begin
    data
    map( x-> x[dim] )
    Set()
    length 
end

intervals(node, point, filtered_dims) = @>> begin
    filtered_dims
    map(dim -> interval_prob(copy(node, dims=filtered_dims), point, dim))
    reduce(vcat, init=[])
end

interval_prob(node::Node, point) = length(node.data) == 1 ?  [node] : @>> begin
    dimensions(node.data)
    filter(dim -> uniq_size(node.data, dim) > 1)
    intervals(node, point)
end

interval_prob(node::Node, point, dim::Number) = @>> begin
    2:length(node.data)
    map(sp ->  split_data(node.data, sp, dim) )
    skipmissing
    map(tup -> interval_prob(prob(node,tup, point, dim), point))
    reduce(vcat, init=[])
end


depth_map( nodes, f= x -> getproperty.(x,:prob) |> sum) = @>>begin
        nodes
        Lazy.groupby(x-> x.depth)
        collect
        map(pair -> pair.first => pair.second |> f )
        sort(by = x -> x.first)
end


mean(nodes) = 
    @>>begin
        nodes
        depth_map()
        map( x-> x.first * x.second )
        sum
end


end
