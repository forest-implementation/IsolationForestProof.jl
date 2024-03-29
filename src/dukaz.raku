#!/usr/bin/env raku

class Node {
    has $.data;
    has $.prob;
    has $.depth;
    has @.split=();
    multi method COERCE (Capture $c) { Node.new: |$c }
}


multi prob (Node() $_, @ (@first,@second), $point) {
    my @nd := @second.head ≤ $point ?? @second !! @first;

    Node.new(
        data  => @nd,
        prob  => .prob * (@second.head-@first.tail)/(.data.tail - .data.head),
        depth => .depth +1,
        split => (|.split, @first.tail..@second.head),
    )
}

multi interval-prob (Node() $node, $point, Bool :$novelty = False, :&dod where {$node.data.elems <= 1 + $novelty} = &take   ) {
    dod $node
}

multi interval-prob (Node() $n, $point, :$novelty = False, :&dod = &take) {
   my $length := $n.data.elems;

   1 ..^ $length
   andthen .map: { $n.data.head($_), $n.data.skip($_) }\
   andthen .map: { |interval-prob(prob($n, $_, $point), $point, :$novelty,:&dod)}
}


multi MAIN (Bool :test($)!) {
    use Test;
    is  interval-prob($_,1,novelty => False,:dod(&item)), $_    with Node.new( :data((1,)),:1prob, :1depth);
    is-deeply interval-prob(\(data => (1,2,3), :1prob,:0depth ),1,:novelty,:dod(&item)), (((1,).Seq,(2,3).Seq),((1,2).Seq,(3,).Seq));

    done-testing;
}


multi MAIN() {
    #.say for interval-prob(\( data => (1,2,3,5), :1prob,:0depth ),4).flat;
    gather interval-prob(\( data => (15,20,25,30,35,85,90,95,105), :1prob,:0depth),25,:!novelty,:dod(&take))
    #andthen .classify: *.depth, :as(*.prob)
    #andthen .nodemap: *.sum
    #andthen .sort
    #andthen .map: { .key * .value }\
    #andthen .sum
    andthen .map: *.say
}
