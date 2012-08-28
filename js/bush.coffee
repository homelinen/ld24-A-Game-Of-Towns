
define ['map'], (map) ->
    class Bush
        # Food giving object
        # Food int representation of food provided
        constructor: (xPos, yPos, @food, @capacity) ->
            @sprite = new Sprite {
                image: "img/bush.png",
                x: xPos,
                y: yPos
                }
            @alive = true
            @x = @sprite.x
            @y = @sprite.y
            @name = "bush"
            @isFlammable = yes

        gather: (amount) ->
            if (@food - amount) > 0
                @food -= amount
                amount
            else 
                amount = @food
                @food = 0
                @alive = false
                amount

        update: ->
            growth = @capacity / 20
            if (@food + growth) < @capacity
                @food += growth

            @spawn()

        spawn: ->
            halfCap = @capacity * 0.2
            if @food > @capacity / 2

                pos = getNextPassableCell(@sprite.x, @sprite.y)
                if pos?
                    bush = new Bush( pos.x, pos.y, halfCap, @capacity)
                    @food = halfCap
                    tileMap.push bush
            return

        draw: ->
            @sprite.draw()
            
    return Bush
