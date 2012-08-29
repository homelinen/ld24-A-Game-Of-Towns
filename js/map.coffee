# Functions relating to the Map
define [], ->
    class Map
        # Initialise things

        constructor: (screenWidth, screenHeight, @tileSize)->
            tiles = new SpriteList
            tile = "img/grass-tile.png"

            @mapWidth = screenWidth / @tileSize
            @mapHeight = screenHeight / @tileSize

            for xPos in [0..@mapWidth]
                for yPos in [0..@mapHeight]
                    tiles.push new Sprite { 
                        image: tile,
                        x: xPos * @tileSize
                        y: yPos * @tileSize
                    }

            @tileMap = new TileMap { cell_size: [@tileSize,tileSize] }
            @tileMap.push tiles
            return

        getTileCorner: (x, y) -> 
            # Get the top corner of a cell 
            # x xPosition on the grid
            # y yPosition on the grid
            # Return Object with fields x and y
            xPos = (Math.floor @getTilePosx(x)) * @tileSize
            yPos = (Math.floor @getTilePosy(y)) * @tileSize
            { x: xPos, y: yPos }

        getScreenFromVec: (pos) ->
            # Get the top corner of a cell
            # pos: Vector 
            x = pos.x * @tileSize
            y = pos.y * @tileSize
            {x: x, y: y}

        getSurroundingTiles: (x, y) ->
            x = @getTilePosx(x)
            y = @getTilePosy(y)
            
            @getSurroundingCells {x: x, y: y}

        getSurroundingCells: (pos) ->
            # Get tiles for the cell represented by obj:
            # {x, y}

            dx = -1
            dy = -1
            tiles = []

            x = pos.x
            y = pos.y

            tempx = x + dx
            tempy = y + dy
            while dx < 2 && tempx >= 0 && tempx < @mapWidth
                while dy < 2 && tempy >= 0 && tempy < @mapHeight
                    
                    if !(tempx == x && tempy == y) && (tempx == x || tempy == y) 
                        # Ensure not on a diagonal smf not given point
                        
                        tiles.push {x: tempx, y: tempy}
                    dy++
                    tempy = y + dy
                dy = -1
                dx++
                tempx = x + dx
            tiles

        getRandomNeighbour: (x, y) ->
            neighbours = @getSurroundingTiles(x, y)

            if neighbours.length > 0
                divisor =  1 / (neighbours.length - 1)

                rand = Math.random()

                index = Math.floor(rand / divisor)

                neighbour = neighbours[index]

                return { x: neighbour.x, y: neighbour.y }
            return

        isCellOccupied: (pos, tiles = @tileMap) ->
            # Decide if the cell is passable

            cell = tiles.cell(pos.x, pos.y)
            if cell?
                for item in cell
                    if item.name != undefined && item.name?
                        return true
                return false
            else 
                return true

        getNeighbours: (pos) ->
            # Return all the named items in a cell

            neighbours = []
            adjacentCells = @getSurroundingCells(pos) 
            for neighbour in adjacentCells
                items = @tileMap.at(neighbour.x * @tileSize, neighbour.y * @tileSize)
                for item in items
                    if item.name != undefined && item.name?
                        neighbours.push item

            neighbours

        removeObject: (x, y, name = "") ->
            # Removes worker at point

            removed = false
            items = @tileMap.at(x, y)
            count = 0
            if jaws.isArray(items) && items != undefined
                for item in items
                    if item? && item.name == name
                        @tileMap.cells[@getTilePosx(x)][@getTilePosy(y)].splice(count, 1)
                        removed = true
                    count++
            removed

        removeAllObjects: (x, y) ->
            # Remove all the objects in the cell at screen 
            # co-ord x, y
            
            items = @tileMap.at(x, y)

            count = 0
            if jaws.isArray(items) && items != undefined
                for item in items
                    if item? && item.name != undefined
                        @tileMap.cells[@getTilePosx(x)][@getTilePosy(y)].splice(count, 1)
                    count++

            return

        removeAllAtVec: (pos) ->
            # Remove all objects at given Vector

            pos = @getScreenFromVec pos
            @removeAllObjects pos.x, pos.y

        removeEverything: (pos) ->
            x = pos.x
            y = pos.y
            items = @tileMap.at(x, y)
            count = 0
            if jaws.isArray(items) && items != undefined
                for item in items
                    if item?
                        cellPos = @getCellPos(pos)
                        @tileMap.cells[pos.x][pos.y].splice(count, 1)
                    count++
            return 

        getRandPos: ->
            # Get a random Vector
            rx = @getRand @mapWidth
            ry = @getRand @mapHeight
            rx = Math.round(rx) * @tileSize
            ry = Math.round(ry) * @tileSize
            @getTileCorner rx, ry

        getRand: (mult) ->
            # Get a random integer that is less than the max
            rand = Math.random()
            rand *= mult

        getRandBoolean: ->
            rand = Math.random() 
            if rand > 0.5 
                true
            else 
                false

        getContentsAt: (x, y) ->
            @getContentsOfCell @getPoint(x, y)

        getContentsOfCell: (pos) ->
            # Retrieve the top object in the cell
             
            contents = @tileMap.cell(pos.x, pos.y)
            for item in contents
                if item.name?
                    return item
            return

        getContentsOfType: (pos, type) ->
            
            match = []
            contents = @tileMap.cell(pos.x, pos.y)
            for item in contents
                if item.name == type
                    match.push item

            match

        getTilePosx: (x) -> 
            x = @getTileComp(x)
            x = @getPosInLimits(x, @mapWidth)
            x

        getTilePosy: (y) ->
            y = @getTileComp(y)
            y = @getPosInLimits(y, @mapHeight)
            y

        getTileComp: (comp)  ->
            # Transform the given screen position to a tile position
            comp / @tileSize

        isAreaFlammable: (pos) ->
            # Checks if the area around position is flammable 
            # enough for a fire to catch

            neighbours = @getNeighbours(pos)
            count = 0

            for neighbour in neighbours
                if neighbour.isFlammable != undefined && neighbour.isFlammable
                    count++

            minFlammableNeighbours = 4
            return count >= minFlammableNeighbours

        getPosInLimits: (point, max) ->
            if point < 0
                point = 0
            else if point >= max
                point = max
            point

        getCellPos: (pos) ->
            # Get the Vector for a cell position
             
            return { x: @getTilePosx(pos.x), y: @getTilePosy(pos.y) }

        getPoint: (x, y) ->
            # Returns a vector representing the cell co-ordinates of x and y
            return { x: @getTilePosx(x), y: @getTilePosy(y) }

        makePoint: (x, y) ->
            { x: x, y: y }

        getRandomDirection: ->
            # Returns a vector that represents a direction
            dx = 0
            dy = 0
            while dx == 0 && dy == 0
                if @getRandBoolean() 
                    dx = @getRandomSign()
                else
                    dy = @getRandomSign()
            @makePoint(dx, dy)

        getRandomSign: ->
            # Returns either 1 or -1
            if @getRandBoolean()
                num = 1
            else 
                num = -1

        getNextCell: (curX, curY) ->
            # Returns a random cell adjacent to the 

            dir = @getRandomDirection()
            x = dir.x * @tileSize
            y = dir.y * @tileSize

            pos = @getTileCorner(x + curX, y + curY)
            pos

        getNextPassableCell: (curX, curY, depth = 0) ->

            # 4 is the number of adjacent cells
            pos = @getNextCell(curX, curY)
            if depth < 4
                cellPos = @getPoint(pos.x, pos.y)
                if !@isCellOccupied(cellPos)
                    return pos
                else
                    depth += 1
                    return @getNextPassableCell(curX, curY, depth)
    return Map
