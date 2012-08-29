
define ['map'], (Map) ->
    
    class Tile
        # Represents a Tile on the map
        #
        constructor: (name, xPos, yPos, image, flammable) ->
            # name The name for the tile
            # xPos x co-ord on the screen for the object
            # yPos y co-ord
            # image Path to the image for the sprite
            # map The map object, needed for certain functions

            @sprite = new Sprite {
                image: image,
                x: xPos,
                y: yPos
                }

            @alive = true
            @x = @sprite.x
            @y = @sprite.y
            @name = name
            @isFlammable = flammable
            return

        draw: ->
            @sprite.draw()

    return Tile
