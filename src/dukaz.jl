module dukaz
using Lazy

export Node, add, interval_prob, prob, interval_prob_rec, depth_map, mean

add(x,y) = x + y

struct Node
    data
    prob
    depth
end

prob(node::Node, tups, point) = Node(
    tups[2][1] <= point ? tups[2] : tups[1], 
    node.prob * (tups[2][1]-last(tups[1]))/(last(node.data)-node.data[1]),
    node.depth+1
)

interval_prob(node::Node, point) = 
    length(node.data) == 1 ? node : @>>begin
    range(2,length(node.data)) 
    map(x->(node.data[1:x-1],node.data[x:length(node.data)])) 
    map(tup -> interval_prob(prob(node,tup, point), point))
    reduce(hcat)
end


depth_map(nodes, f=sum) = 
    @>>begin
        nodes
        groupby(x-> x.depth)
        collect
        sort(by = x ->x[1])
        map(pair -> pair.first => f(pair.second))
end


mean(nodes) = 
    @>>begin
        nodes
        groupby(x-> x.depth)
        collect
        sort(by = x ->x[1])
        map(pair -> pair.first => sum(getfield.(pair.second, :prob)))
end

interval_prob_rec(nodes, point) = begin
    length(node.data) == 1 ? node : begin
      map(node -> interval_prob_rec(node,point), interval_prob(node, point))
    end
end

end
