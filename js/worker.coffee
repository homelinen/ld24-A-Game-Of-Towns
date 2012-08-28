define ['map'], (map) ->
    class Worker
        constructor: (xPos, yPos, @carryWeight, @food) ->
            @alive = true
            @sprite = new Sprite {
                 image: "img/villager.png",
                 x: xPos,
                 y: yPos
            }
            @x = @sprite.x
            @y = @sprite.y
            @name = "worker"
            @curWeight = @food
            @foodEaten = 2 * @food
            @isFlammable = true
            @maxFood = @foodEaten
            @lastDx = 0
            @lastDy = 0
        
        draw: ->
            @sprite.draw()

        update: ->
            @eat()
            @move()
            return

        move: ->
            if @alive
                # Move player

                cell = getNextPassableCell(@sprite.x, @sprite.y)
                if cell?
                    removeObject(@sprite.x, @sprite.y, "worker")

                    @sprite.moveTo(cell.x, cell.y)
                    @x = @sprite.x
                    @y = @sprite.y
                    tileMap.push @

            return

        gather: (bush) ->
            if @curWeight < @carryWeight
                gathered = bush.gather @carryWeight - @curWeight
                @curWeight += gathered
                @food += gathered
            
        eat: ->
            @foodEaten -= 1

            if @foodEaten < @maxFood
                if @food > 0
                    foodConsumed = 1
                    @foodEaten += 3 * foodConsumed
                    @food -= foodConsumed
                    @curWeight -= foodConsumed

                if @foodEaten <= 0
                    @alive = false

            if @foodEaten > @maxFood * 0.8
                pos = getRandomNeighbour(@x, @y)
                if pos? && !isCellOccupied(pos)
                    @food = @food / 3
                    worker = new Worker(pos.x * TILE_SIZE, pos.y * TILE_SIZE, @carryWeight, @food)

                    tileMap.push worker

        toString: ->
            return "#{@name}: #{@x}, #{@y}"

    return Worker
