local P = require 'map_gen.shapes.patterns.patterns'
--local M1 = require 'map_gen.shapes.patterns.maze1'
--local M2 = require 'map_gen.shapes.patterns.maze2'
--local M3 = require 'map_gen.shapes.patterns.maze3'
local MB = require 'map_gen.shapes.patterns.mandelbrot'
--local JI = require 'map_gen.shapes.patterns.jigsawislands'
--local BC = require 'map_gen.shapes.patterns.barcode'
--local Disort = require 'map_gen.shapes.patterns.distort'
local Simple = require 'map_gen.shapes.patterns.simple'
local Transform = require 'map_gen.shapes.patterns.transforms'
--local Island = require 'map_gen.shapes.patterns.islandify'
--local Fractal = require 'map_gen.shapes.patterns.fractal'
local Simplex = require 'map_gen.shapes.patterns.noise'

local Public = {}

function Union(func)
    return Transform.Union(func)
end

function Tile(a, b , c , d, e)
    return Transform.Tile(a, b , c , d, e)
end

function Mandelbrot(func)
    return MB.Mandelbrot(func)
end

function Spiral(x, y)
    return Simple.Spiral(x, y)
end

function Rectangle(a, b , c , d)
    return Simple.Rectangle(a, b, c, d)
end

function NoiseCustom (a)
    return Simplex.NoiseCustom(a)
end

function NoiseExponent(a)
    return Simplex.NoiseExponent(a)
end

local meta = {
    water_colors    = {"blue", "green"},
    -- List of pairs of name of preset and code to generate preset
    pattern_presets = {
            {"spiral", "Union(Spiral(1.3, 0.4), Rectangle(-105, -2, 115, 2))"},
            {"arithmetic spiral", "ArithmeticSpiral(50, 0.4)"},
            {"rectilinear spiral", "Zoom(RectSpiral(), 50)"},
            {"triple spiral", "AngularRepeat(Spiral(1.6, 0.5), 3)"},
            {"crossing spirals", "Union(Spiral(1.4, 0.4), Spiral(1 / 1.6, 0.2))"},
            {"natural archipelago",
                "Union(" ..
                "NoiseCustom({exponent=1.5,noise={0.3,0.4,1,1,1.2,0.8,0.7,0.4,0.3,0.2},land_percent=0.07})," ..
                "NoiseCustom({exponent=1.9,noise={1,1,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.1," ..
                "start_on_land=false,start_on_beach=true}))"},
            {"natural_big_islands",
                "NoiseCustom({exponent=2.3,noise={1,1,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.2})"},
            {"natural_continents",
                "NoiseCustom({exponent=2.4,noise={1,1,1,1,1,1,1,0.6,0.3,0.2},land_percent=0.35})"},
            {"natural_half_land",
                "NoiseCustom({exponent=2,noise={0.5,1,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.5})"},
            {"natural_big_lakes",
                "NoiseCustom({exponent=2.3,noise={0.5,0.8,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.65})"},
            {"natural_medium_lakes",
                "NoiseCustom({exponent=2.1,noise={0.3,0.6,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.86})"},
            {"natural small lakes","NoiseCustom({exponent=1.5,noise={0.05,0.1,0.4,0.7,1,0.7,0.3,0.1},land_percent=0.92})"},
            {"pink_noise_hell", "NoiseExponent({exponent=1,land_percent = 0.35})"},
            {"radioactive", "Union(AngularRepeat(Halfplane(), 3), Circle(32))"},
            {"comb", "Zoom(Comb(), 50)"},
            {"cross", "Cross(50)"},
            {"cross_and_circles", "Union(Cross(20), ConcentricBarcode(30, 60))"},
            {"crossing_bars", "Union(Barcode(nil, 10, 20), Barcode(nil, 20, 50))"},
            {"grid", "Zoom(Grid(), 50)"},
            {"skew_grid", "Zoom(Affine(Grid(), 1, 1, 1, 0), 50)"},
            {"distorted_grid", "Distort(Zoom(Grid(), 30))"},
            {"maze_1_fibonacci", "Tighten(Zoom(Maze1(), 50))"},
            {"maze_2_DLA", "Tighten(Zoom(Maze2(), 50))"},
            {"maze_3_percolation", "Tighten(Zoom(Maze3(0.6), 50))"},
            {"polar_maze_3", "Zoom(AngularRepeat(Maze3(), 3), 50)"},
            {"bridged_maze_3", "IslandifySquares(Maze3(), 50, 10, 4)"},
            {"thin_branching_fractal", "Fractal(1.5, 40, 0.4)"},
            {"mandelbrot", "Tile(Mandelbrot(300), 120, 315, -600, -315)"},
            {"jigsaw_islands", "Zoom(JigsawIslands(0.3), 40)"},
            {"square_bridges", "SquaresAndBridges(64, 32, 4)"},
            {"circle_bridges", "CirclesAndBridges(64, 32, 4)"},
            {"distort_zoom", "Distort(Zoom(Comb(), 32))"},
            {"islandify_squares", "IslandifySquares(Maze3(), 30, 8, 4)"},
            {"union_zoom", "Union(Zoom(Cross(), 16), ConcentricCircles(1.3))"},
            {"Intersection_zoom", "Intersection(Zoom(Maze3(), 32), Zoom(Grid(), 4))"},
            {"union_spiral", "Union(Spiral(1.6, 0.6), Intersection(Zoom(Maze3(0.5, false), 8), Zoom(Grid(), 2)))"},
            {"union_zoom_maze3", "Union(Union(Zoom(Maze3(0.25, false), 31), Zoom(Maze3(0.1, false), 97)), Zoom(Maze3(0.6), 11))"},
            {"union_barcode", "Union(Barcode(10, 5, 20), Barcode(60, 5, 30))"},
            {"union_zoom_jagged", "Union(Zoom(JaggedIslands(0.3), 32), Union(Barcode(0, 6, 50), Barcode(90, 6, 50)))"},
            {"pink noise maze",
                "Intersection(Zoom(Maze2(), 50), NoiseExponent{exponent=1,land_percent=0.8})"},
            {"custom", nil}
    }
}

function Public.preset_by_name(name)
    for _, item in pairs(meta.pattern_presets) do
        if item[1] == name then
            return item[2]
        end
    end
    return nil
end

function Public.evaluate_pattern(map_name)

    local preset = Public.preset_by_name(map_name)
    local pattern
    pattern = assert(load("return (" .. preset .. ")"))()

    if pattern.output == "tilename" then
        return pattern
    elseif pattern.output == "bool" then
        return P.TP(pattern, nil, nil)
    elseif pattern.output == "tileid" then
        return P.TileID2Name(pattern, nil)
    else
        return nil
    end
end

return Public