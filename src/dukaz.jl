module dukaz
using Lazy

export Node, add, interval_prob, prob, interval_prob_rec, depth_map, mean, struct_eq, split_data, checksame

add(x,y) = x + y

struct Node
    data
    prob ::Rational
    depth
end


Base.:(==)(first::Node, second::Node) = 
 return first.data == second.data && 
 first.prob == second.prob && 
 first.depth == second.depth


prob(node::Node, tups, point, dim=1) = begin
    if tups === nothing 
        return nothing
    end
    @show tups, dim
    Node(
        tups.right[1][dim] <= point[dim] ? tups.right : tups.left,
        node.prob * (first(tups.right)[dim]-last(tups.left)[dim])/(last(tups.right)[dim]-first(tups.left)[dim]),
        node.depth+1
    )
end

# checksame(split_data, dim) = begin
#     prevL = map(x->x[dim],split_data[1])
#     prevR = map(x->x[dim],split_data[2])
#     (length(prevL) > 1 && length(prevL) != length(unique(prevL))) || (length(prevR) > 1 && length(prevR) != length(unique(prevR))) ? 1 : 0
# end

checksame(left, right, dim) = begin
    dimL = map(x->x[dim],left)
    dimR = map(x->x[dim],right)
    length(findall(in(dimL),dimR)) > 0
end

split_data(data, sp, dim = 1) = 
    @>>begin
    data
    sort(by = x -> x[dim])
    data -> Split(data[1:sp-1], data[sp:length(data)])
    res -> checksame(res.left, res.right, dim) ? nothing : res
end

struct Split
    left
    right
end

interval_prob(node, point, dim=1) = begin
    if isnothing(node)
        return nothing
    end
    length(node.data) == 1 ? [node] : @>>begin
    range(2,length(node.data)) 
    Iterators.map(sp-> ( split_data(node.data, sp, 1), split_data(node.data, sp, 2) ) )
    #reduce(vcat)
    # pokracuj tu
    x -> (println(collect(x)); x)
    Iterators.flatmap(tup -> (reduce(vcat,interval_prob(prob(node,first(tup), point, 1), point,1)), reduce(vcat,interval_prob(prob(node, last(tup), point, 2), point,2))))
    collect
    # reduce(vcat)
end
end


depth_map( nodes, f= x -> getproperty.(x,:prob) |> sum) =
    @>>begin
        nodes
        groupby(x-> x.depth)
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

interval_prob_rec(nodes, point) = begin
    length(node.data) == 1 ? node : begin
      map(node -> interval_prob_rec(node,point), interval_prob(node, point))
    end
end

end
