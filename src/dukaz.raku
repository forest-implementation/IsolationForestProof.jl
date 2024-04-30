#!/usr/bin/env raku
use v6.e.PREVIEW;

class Node {
    has $.data;
    has $.prob;
    has $.depth;
    has @.split=();
    multi method COERCE (Capture $c) { Node.new: |$c }
}


multi prob (Node() $_, @ (@first,@second), :$point, :$dim) {
    my @nd := @second.head.[$dim] ≤ $point[$dim] ?? @second !! @first;
    #@nd = Empty  if @nd».[$dim].squish == 1 and .data > 1;

    Node.new(
        data  => @nd,
        prob  => .prob * (@second.head.[$dim]-@first.tail.[$dim])/(@second.tail.[$dim] - @first.head.[$dim]),
        depth => .depth +1,
        split => (|.split, $dim => @first.tail[$dim]..@second.head[$dim]),
                  #(|.split, @nd),
    )
}

multi interval-prob (Node() $node, :$point, Bool :$novelty = False, :&dod where {$node.data.elems ≤ 1} = &item  ) {
    dod $node;
}

multi split-data (+data,:$dim!) {
   my @data = data.classify(*.[$dim]).sort;

   1 ..^ @data.elems
   andthen .map: { @data.head($_).map( *.value.Slip), @data.skip($_).map: *.value.Slip }
}

multi interval-prob (Node() $n, :$point, :$novelty = False, :&dod = &item) {
    my $dimensions = $n.data.head.elems;
    my $red-dims = (^$dimensions).grep( -> $dim { $n.data»[$dim].Set > 1  }).elems;

    ^$dimensions
    andthen .map: -> $dim {
        |split-data($n.data, :$dim).map: -> $st {
            |interval-prob(prob($n.clone( prob => $n.prob/$red-dims), $st, :$point, :$dim), :$point, :$novelty,:&dod)
        };
    }
}

multi depth-map ( +nodes,  :&f = &sum ) {
    nodes
    andthen .classify: *.depth, :as(*.prob)
    andthen .nodemap: &f
    andthen .sort
}

multi expected-value (+mix) {
    mix
    andthen .map: { .key * .value }\
    andthen .sum
}

multi MAIN (Bool :test($)!) {
    use Test;
    is  interval-prob(\( :data((1,)),:1prob, :1depth),:1point).depth,1;
    is-deeply interval-prob(\(data => (1,2,3), :1prob,:0depth ),:2point)».data, ((2,),(2,));

    with 15,20,25,30,35,85,90,95,105 -> +points {
       is interval-prob(
           \( data => points, :1prob,:0depth),
           :25point
       ).&depth-map(:f(*.elems)), (
            2 =>   2,
            3 =>  18,
            4 =>  70,
            5 => 150,
            6 => 180,
            7 => 112,
            8 => 28,
       );

       is interval-prob(
           \( data => points, :1prob,:0depth),
           :25point
       ).head(5)».depth, (3,4,4,5,4);

       is interval-prob(
           \( data => points, :1prob,:0depth),
           :35point
       ).&depth-map.&expected-value, 1571/462;
    }

   with [25,100],[30,90],[20,90] -> +point {
       is interval-prob(\(data => point, :1prob, :0depth), :point([30,90]))».prob, (1/8,1/8,1/4,1/2);
       is interval-prob(\(data => point, :1prob, :0depth), :point([30,90])).&depth-map, (1=> 1/4, 2=>3/4);
       is interval-prob(\(data => point, :1prob, :0depth), :point([30,90])).&depth-map.&expected-value, (1*1/4+2*3/4);
   };

    done-testing;
}

multi MAIN() {
    my @point := [25,100],[30,90],[20,90],[35,85], [25,85],[15,85],[105,20],[95,25], [95,15],[90,30],[90,20],[90,10];
    #my @point := 15,20,25,30,35,85,90,95,105;
        #.say for interval-prob(\( data => (1,2,3,5), :1prob,:0depth ),4).flat;
    @point
    andthen (
	|(interval-prob \( data => $_, :1prob,:0depth),:point([25,20])),
    )
    #andthen .classify: *.depth , :as(*.prob)
    #andthen .nodemap: *.sum
    #andthen .sort
    #andthen .snitch
    #andthen .map: { .key *.value }\
    #andthen .sum
    andthen .map: *.say
}
