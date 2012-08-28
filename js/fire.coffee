
define ['map'], (map) ->
    class Fire
        # Fire class, burns everything around it
        
        constructor: (x, y, @heat) ->
            @sprite = new Sprite {
                image: "img/fire.png",
                x: x,
                y: y
            }
            @x = @sprite.x
            @y = @sprite.y
            @name = "fire"
            @alive = yes
            @isFlammable = false
            
        update: ->
            @burn()
            @heat--
            if @heat <= 0
                @alive = false
            else
                @spread()

        burn: ->
            pos = getPoint(@x, @y)
            if isCellOccupied(pos)
                removeAllAtVec(pos)
                # Add self back to map
                tileMap.push @
            return

        spread: ->
            pos = getNextCell(@sprite.x, @sprite.y)

            if pos?
                tile = getContentsAt(pos.x, pos.y)
                if tile?
                    if !tile.isFlammable?
                        flammable = false
                    else 
                        flammable = tile.isFlammable

                    if flammable
                        fire = new Fire(pos.x, pos.y, @heat)
                        tileMap.push fire
            return

        draw: ->
            @sprite.draw()
            return
    return Fire
