
define ['tile', 'map'], (Tile, map) ->
    class Fire extends Tile
        # Fire class, burns everything around it
        
        constructor: (x, y, @heat) ->
            image = "img/fire.png"
            name = "fire"
            flammable = false
            super name, x, y, image, flammable
            
        update: (map) ->
            @burn(map)
            @heat--
            if @heat <= 0
                @alive = false
            else
                @spread(map)

        burn: (map) ->
            pos = map.getPoint(@x, @y)
            if map.isCellOccupied(pos)
                map.removeAllAtVec(pos)
                # Add self back to map
                map.tileMap.push @
            return

        spread: (map) ->
            pos = map.getNextCell(@sprite.x, @sprite.y)

            if pos?
                tile = map.getContentsAt(pos.x, pos.y)
                if tile?
                    if !tile.isFlammable?
                        flammable = false
                    else 
                        flammable = tile.isFlammable

                    if flammable
                        fire = new Fire(pos.x, pos.y, @heat)
                        map.tileMap.push fire
            return

    return Fire
