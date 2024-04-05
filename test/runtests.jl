using dukaz
using Test
using Lazy

@testset "one-dim" begin
    # Write your tests here.


    @test getfield.(interval_prob(Node([1,],depth= 1),1), :depth) == [1]
    @test getfield.(interval_prob(Node([1, 2, 3]),2), :data) == [[2], [2]]

    points = [15, 20, 25, 30, 35, 85, 90, 95, 105]
    #@test interval_prob(Node(points, 1, 0), 25) == 2
    @test depth_map(interval_prob(Node([1, 2, 3]),2), length) == [2 => 2]
    @test depth_map(interval_prob(Node(points),25), length) == [2 => 2, 3 => 18, 4 => 70, 5 => 150, 6 => 180, 7 => 112, 8 => 28]
    @test getfield.(take(interval_prob(Node(points),25),5), :depth) == [3,4,4,5,4]
    #@test getfield.(take(interval_prob(Node(points),25),5), :split) == [3,4,4,5,4]

    #predtim: 2 => predtim:pocet node splnujici podminku
    #pak: 2 => soucet prob nodes splnujici podminku
    # [2 => 2, 3 => 18, 4 => 70, 5 => 150, 6 => 180, 7 => 112, 8 => 28]
    
    @test prob(Node([1, 2, 3]), (left = [1], right =[2, 3]), 3) == Node([2,3], prob = 1//2, depth = 1, split = [(dim=1, range = 1:2),])
    
    @test mean(interval_prob(Node(points),35)) == 1571//462;
end

@testset "two-dims" begin
    morepoints = [(20,90), (25,100),(30,90)]
    @test prob(Node(morepoints), (left = [(20,90)], right =[(25,100), (30,90)]), (30,90)) ==
        Node([(25,100), (30,90)], prob = 1//2, depth = 1,split=[(dim=1, range = 20:25),])
    
    @test split_data(morepoints, 2, 1) == (left = [(20,90),], right = [(25,100),(30,90)])
    @test split_data(morepoints, 2, 2) |> ismissing
    @test split_data(morepoints, 3, 2) == (left = [(20, 90), (30, 90)], right = [(25, 100)])
    
    @test getfield.(interval_prob(Node([(0,25,90),(0,30,90)]),(0,30,90)), :split) == [[(dim =2, range= 25:30)]]
    @test getfield.(interval_prob(Node(morepoints),(30,90)),:split) == [
        [(dim=1, range = 20:25), (dim=1, range=25:30)],
        [(dim=1, range = 20:25), (dim=2, range=90:100)],
        [(dim=1, range = 25:30)],
        [(dim=2, range = 90:100), (dim=1, range=20:30)],
    ]

    @test getfield.(interval_prob(Node([(0,25,90),(0,30,90)]),(0,30,90)), :prob) == [1//1]
    @test getfield.(interval_prob(Node(morepoints),(30,90)), :prob) == [1//8,1//8,1//4,1//2]
    @test checksame([(20,90),], [(25,90),(30,100)], 2) == true
    @test checksame([(20,90),], [(25,90),(30,100)], 1) == false

    #@test getfield.(interval_prob(Node(morepoints),(30,90)), :prob) == [[(2,)], [(2,)]]
end
