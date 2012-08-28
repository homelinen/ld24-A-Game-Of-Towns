
define ['map'], (map) ->
    class Water
        
        constructor: (x, y) ->
            @sprite = new Sprite {
                image: "img/water.png",
                x: x,
                y: y,
            }
            @name = "water"
            @alive = true

            @x = @sprite.x
            @y = @sprite.y
            @isFlammable = false

        draw: ->
            @sprite.draw()
    return Water
