define ['tile', 'map'], (Tile, map) ->
    class Worker extends Tile
        constructor: (xPos, yPos, @carryWeight, @food) ->
            image = "img/villager.png"
            name = "worker"
            flammable = false
            super name, xPos, yPos, image, flammable

            @curWeight = @food
            @foodEaten = 2 * @food
            @maxFood = @foodEaten
            @lastDx = 0
            @lastDy = 0
        
        update: (map) ->
            @eat(map)
            @move(map)
            return

        move: (map) ->
            if @alive
                # Move player

                cell = map.getNextPassableCell(@sprite.x, @sprite.y)
                if cell?
                    map.removeObject(@sprite.x, @sprite.y, "worker")

                    @sprite.moveTo(cell.x, cell.y)
                    @x = @sprite.x
                    @y = @sprite.y
                    map.tileMap.push @

            return

        gather: (bush) ->
            if @curWeight < @carryWeight
                gathered = bush.gather @carryWeight - @curWeight
                @curWeight += gathered
                @food += gathered
            
        eat: (map) ->
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
                pos = map.getRandomNeighbour(@x, @y)
                if pos? && !map.isCellOccupied(pos)
                    @food = @food / 3
                    pos = map.getScreenFromVec(pos)
                    worker = new Worker(pos.x, pos.y, @carryWeight, @food)

                    map.tileMap.push worker

        toString: ->
            return "#{@name}: #{@x}, #{@y}"

    return Worker
