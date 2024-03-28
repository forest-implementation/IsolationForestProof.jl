#!/usr/bin/env raku

class Node {
    has $.data;
    has $.prob;
    has $.depth;

    multi method COERCE (Capture $c) { Node.new: |$c }
}


multi prob (Node() $_, @ (@first,@second), $point) {
    Node.new(
        data  => @second.head ≤ $point ?? @second !! @first,
        prob  => .prob * (@second.head-@first.tail)/(.data.tail - .data.head),
        depth => .depth +1,
    )
}

multi interval-prob (Node() $node where *.data.elems == 1, $point ) {
    take $node
}

multi interval-prob (Node() $n (:@data, :$prob, :$depth), $point) {
   my $length := @data.elems;

   1 ..^ $length
   andthen .map: { @data.head($_), @data.skip($_) }\
   andthen .map: {interval-prob(prob($n, $_, $point), $point)}
}


multi MAIN (Bool :test($)!) {
    use Test;
    is interval-prob($_,1), $_    with Node.new( :data((1,)),:1prob, :1depth);
    is-deeply interval-prob(\(data => (1,2,3), :1prob,:0depth ),1), (((1,).Seq,(2,3).Seq),((1,2).Seq,(3,).Seq));

    done-testing;
}


multi MAIN() {
    #.say for interval-prob(\( data => (1,2,3,5), :1prob,:0depth ),4).flat;
    put '---';
    gather interval-prob(\( data => (15,20,25,30,35,85,90,95,105), :1prob,:0depth ),25).flat
    andthen .classify: *.depth, :as(*.prob)
    andthen .nodemap: *.sum
    andthen .sort
    #andthen .map: { .key * .value }\
    #andthen .sum
    andthen .map: *.say
}
