local Public = {}

Public.meta = {
    water_colors    = {"blue", "green"},
    -- List of pairs of name of preset and code to generate preset
    pattern_presets = {
            {"spiral", "Union(Spiral(1.3, 0.4), Rectangle(-105, -2, 115, 2))"},
            {"arithmetic spiral", "ArithmeticSpiral(50, 0.4)"},
            {"rectilinear spiral", "Zoom(RectSpiral(), 50)"},
            {"triple spiral", "AngularRepeat(Spiral(1.6, 0.5), 3)"},
            {"crossing spirals", "Union(Spiral(1.4, 0.4), Spiral(1 / 1.6, 0.2))"},
            {"natural archipelago",
                -- "NoiseCustom({exponent=1.5,noise={0.3,0.4,1,1,1.2,0.8,0.7,0.4,0.3,0.2},land_percent=0.13})"},
                "Union(" ..
                "NoiseCustom({exponent=1.5,noise={0.3,0.4,1,1,1.2,0.8,0.7,0.4,0.3,0.2},land_percent=0.07})," ..
                "NoiseCustom({exponent=1.9,noise={1,1,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.1," ..
                "start_on_land=false,start_on_beach=true}))"},
            {"natural big islands",
                "NoiseCustom({exponent=2.3,noise={1,1,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.2})"},
            {"natural continents",
                "NoiseCustom({exponent=2.4,noise={1,1,1,1,1,1,1,0.6,0.3,0.2},land_percent=0.35})"},
            {"natural half land",
                "NoiseCustom({exponent=2,noise={0.5,1,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.5})"},
            {"natural big lakes",
                "NoiseCustom({exponent=2.3,noise={0.5,0.8,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.65})"},
            {"natural medium lakes",
                "NoiseCustom({exponent=2.1,noise={0.3,0.6,1,1,1,1,0.7,0.4,0.3,0.2},land_percent=0.86})"},
            {"natural small lakes",
                -- "NoiseCustom({exponent=1.8,noise={0.2,0.3,0.4,0.6,1,1,0.7,0.4,0.3,0.2},land_percent=0.96})"},
                "NoiseCustom({exponent=1.5,noise={0.05,0.1,0.4,0.7,1,0.7,0.3,0.1},land_percent=0.92})"},
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
    for _, item in ipairs(Public.meta.pattern_presets) do
        if item[1] == name then
            return item[2]
        end
    end
    return nil
end

return Public