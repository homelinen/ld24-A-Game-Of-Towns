
define ['tile', 'map'], (Tile, map) ->
    class Fire extends Tile
        # Fire class, burns everything around it
        
        constructor: (x, y, @heat) ->
            image = "img/fire.png"
            name = "fire"
            flammable = false
            super name, x, y, image, flammable
            
        update: () ->
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
