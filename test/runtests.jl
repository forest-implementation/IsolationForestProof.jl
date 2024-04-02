using dukaz
using Test
using Lazy

@testset "dukaz.jl" begin
    # Write your tests here.

    @test add(5,5) == 10
    @test interval_prob(Node((1,),1, 1),1).depth == 1
    @test getfield.(interval_prob(Node((1,2,3),1, 0),2), :data) == [(2,) (2,)]
    points = [15,20,25,30,35,85,90,95,105]
    # @test interval_prob(Node(points, 1, 0), 25)
    @test depth_map(interval_prob(Node((1,2,3),1, 0),2), length) == [2 => 2]
    @test depth_map(interval_prob(Node(points,1, 0),25), length) == [2 => 2, 3 => 18, 4 => 70, 5 => 150, 6 => 180, 7 => 112, 8 => 28]
    @test getfield.(take(interval_prob(Node(points,1, 0),25),5), :depth) == [3,4,4,5,4]

    #predtim: 2 => predtim:pocet node splnujici podminku
    #pak: 2 => soucet prob nodes splnujici podminku
    # [2 => 2, 3 => 18, 4 => 70, 5 => 150, 6 => 180, 7 => 112, 8 => 28]
    
    @test mean(interval_prob(Node(points,1, 0),35)) == 0 
end
