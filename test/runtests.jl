using dukaz
using Test
using Lazy
using DataFrames
using Printf

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

@testset "interval-prob-helpers" begin
    @test copy(Node([(1,),(2,),(3,)]),dims=[1,3,4]).prob == 1//3
    @test dimensions([(1,2),(3,4)]) == 1:2
    @test uniq_size([(1,4),(3,4)],2) == 1
    @test uniq_size([(1,4),(3,4)],1) == 2
    @test intervals(Node([(1,4),(3,4)]), (3,4), [1]) == [Node([(3,4)],prob=1//1, depth=1, split=[(dim=1,range=1:3)])]

    
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

@testset "main" begin

    input = [(25,100),(30,90),(20,90),(35,85), (25,85),(15,85),(105,20),(95,25), (95,15),(90,30),(90,20),(90,10)]
    point = (25,100)

    # @>> begin   
    #      [input...,(20,25)]
    #     #[(30,90),(25,100)]
    #     map(point -> point => depth_map(interval_prob(Node(input), point)))
    #     map(x-> join([x.first,x.second[1].first,map(x-> @sprintf("%.10E",x.second), x.second)...], " & "))
    #     # x-> DataFrame(x)
    #     println
    # end
    
    @>> begin
      [input...,(20,25)]
      map(x->interval_prob(Node(input),x))
      map(mean)
      map(x->convert(AbstractFloat,x))
      @show
    end

    # @>> begin
    #     # input
    #     [(25,100)]
    #     interval_prob(Node(input))
    #     depth_map
    #     map(x -> (x.first, convert(AbstractFloat,x.second)))
    #     @show
    # end
    
    

end
