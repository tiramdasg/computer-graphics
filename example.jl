using StaticArrays, Plots
using LinearAlgebra
gr()

# Types required for basic ray generation
abstract type Camera end

mutable struct SimpleCamera <: Camera
    nx::Int
    ny::Int
end

pixelNumber(camera::Camera) = (camera.nx,camera.ny)

# Types for basic ray intersection
mutable struct Ray
    origin::SVector{3,Float32}
    direction::SVector{3,Float32}
end

origin(ray::Ray) = ray.origin
direction(ray::Ray) = ray.direction

function generateRay(camera::SimpleCamera, i::Integer, j::Integer)
    # calculate origin and direction of the ray

    return Ray(origin,direction)
end


using Test
@testset "Ray generation" begin
  testRay1 = generateRay(SimpleCamera(500,500),252,252)
  testRay2 = generateRay(SimpleCamera(500,500),1,1)
  @test isapprox(origin(testRay1),Float32[0.006000042, -0.006000042, 1.0])
  @test isapprox(direction(testRay1),Float32[0.0, 0.0, -1.0])
  @test isapprox(origin(testRay2),Float32[-0.998, 0.998, 1.0])
  @test isapprox(direction(testRay2),Float32[0.0, 0.0, -1.0])
end;



abstract type AbstractScene end
abstract type SceneObject end

mutable struct Scene <: AbstractScene
    sceneObjects::Vector{SceneObject}
end

# first SceneObject
mutable struct Sphere <: SceneObject
    center::SVector{3,Float32}
    radius::Float32
end

center(sphere::Sphere) = sphere.center
radius(sphere::Sphere) = sphere.radius


function intersect(ray::Ray, scene::Scene)
    oc = ray.origin - scene.center
    a = dot(ray.direction, ray.direction)
    b = 2.0 * dot(oc, ray.direction)
    c = dot(oc, oc) - scene.radius^2
    discriminant = b^2 - 4.0 * a * c
    if discriminant < 0
        # No intersection
        return nothing
    else
        t1 = (-b - sqrt(discriminant)) / (2.0 * a)
        t2 = (-b + sqrt(discriminant)) / (2.0 * a)
        return (true, t1, t2)
    end
end

function hitShader(ray::Ray, scene::Scene)
    for object in scene.sceneObjects
        if intersect(ray, object.scene)
            return 1.0f0
        end
    end
    return 0.0f0
end

# Test using @testset macro
@testset "Basic shader" begin
    # test scene
    sphere1 = Sphere(Float32[0.5, 0, 0], 0.25f0)
    sphere2 = Sphere(Float32[-0.5, 0, -1], 0.25f0)
    scene1 = Scene(SceneObject[sphere1, sphere2])

    testRay1 = Ray(Float32[0, 0, 0], normalize(Float32[0, 0, -1]))
    testRay2 = Ray(Float32[0, 0, 0], normalize(Float32[0, 0, -1]))

    # test
    @test hitShader(testRay1, scene1) == 0.0f0
    @test hitShader(testRay2, scene1) == 1.0f0
end;








