
define ['tile', 'map'], (Tile, map) ->

    class Bush extends Tile
        # Food giving object
        # Food int representation of food provided
        constructor: (xPos, yPos, @food, @capacity) ->
            flammable = false
            name = "bush"
            super name, xPos, yPos, "img/bush.png", map, flammable

        gather: (amount) ->
            if (@food - amount) > 0
                @food -= amount
                amount
            else 
                amount = @food
                @food = 0
                @alive = false
                amount

        update: (map) ->
            growth = @capacity / 20
            if (@food + growth) < @capacity
                @food += growth

            @spawn(map)

        spawn: (map) ->
            halfCap = @capacity * 0.2
            if @food > @capacity / 2

                pos = map.getNextPassableCell(@sprite.x, @sprite.y)
                if pos?
                    bush = new Bush( pos.x, pos.y, halfCap, @capacity)
                    @food = halfCap
                    map.tileMap.push bush
            return
    return Bush
