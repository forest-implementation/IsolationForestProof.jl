using dukaz
using Test

@testset "dukaz.jl" begin
    # Write your tests here.

    @test add(5,5) == 10
    @test interval_prob(Node((15, 20, 25, 30, 35, 85, 90, 95, 105),1, 0),25) == 0
end
