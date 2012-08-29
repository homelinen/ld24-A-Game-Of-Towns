
define ['tile', 'map'], (Tile, map) ->
    class Water extends Tile
        
        constructor: (x, y) ->
            image = "img/water.png"
            name = "water"
            flammable = false
            super name, x, y, image, flammable

    return Water
