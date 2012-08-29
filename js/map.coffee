# Functions relating to the Map
#    Copyright (C) 2012  Calum Gilchrist
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact:
#   Email: me@calumgilchrist.co.uk
#   Website: http://calumgilchrist.co.uk
# 

define ['point'], (Point) ->
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

        roundScreenVec: (v) -> 
            # Get the top corner of a cell 
            # x xPosition on the grid
            # y yPosition on the grid
            # Return Object with fields x and y

            xPos = (Math.floor @getTilePosx(v.x)) * @tileSize
            yPos = (Math.floor @getTilePosy(v.y)) * @tileSize
            new Point xPos, yPos

        getScreenFromVec: (pos) ->
            # Get the top corner of a cell
            # pos: Vector 
            pos.mul(@tileSize)

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
                        
                        tiles.push new Point tempx, tempy
                    dy++
                    tempy = y + dy
                dy = -1
                dx++
                tempx = x + dx
            tiles

        getRandomNeighbour: (pos) ->
            neighbours = @getSurroundingCells(pos)

            if neighbours.length > 0
                divisor =  1 / (neighbours.length - 1)

                rand = Math.random()

                index = Math.floor(rand / divisor)

                neighbour = neighbours[index]

                point = (new Point()).setVec(neighbour)
                return point
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

        removeObject: (v, name = "") ->
            # Removes worker at screen vec

            removed = false
            items = @tileMap.at(v.x, v.y)
            count = 0
            if jaws.isArray(items) && items != undefined
                for item in items
                    if item? && item.name == name
                        @tileMap.cells[v.x][v.y].splice(count, 1)
                        removed = true
                    count++
            removed

        removeAllObjects: (v) ->
            # Remove all the objects in the cell at screen 
            # co-ord x, y
            
            x = v.x
            y = v.y
            items = @tileMap.cell(x, y)

            count = 0
            if jaws.isArray(items) && items != undefined
                for item in items
                    if item? && item.name != undefined
                        @tileMap.cells[x][y].splice(count, 1)
                    count++

            return

        getRandPos: ->
            # Get a random Vector
            rx = @getRand @mapWidth
            ry = @getRand @mapHeight
            rx = Math.round(rx) * @tileSize
            ry = Math.round(ry) * @tileSize
            @roundScreenVec new Point(rx, ry)

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
             
            return new Point @getTilePosx(pos.x), @getTilePosy(pos.y) 

        getRandomDirection: ->
            # Returns a vector that represents a direction
            dx = 0
            dy = 0
            while dx == 0 && dy == 0
                if @getRandBoolean() 
                    dx = @getRandomSign()
                else
                    dy = @getRandomSign()
            new Point dx, dy

        getRandomSign: ->
            # Returns either 1 or -1
            if @getRandBoolean()
                num = 1
            else 
                num = -1

        getNextCell: (v) ->
            # Returns a random cell adjacent to the vector
            # Uses Screen co-ordinates

            dir = @getScreenFromVec @getRandomDirection()

            dir.addVec(v)
            dir

        getNextPassableCell: (vCur, depth = 0) ->

            # 4 is the number of adjacent cells
            pos = @getNextCell(vCur)
            if depth < 4
                if !@isCellOccupied(@getCellPos pos)
                    return pos
                else
                    depth += 1
                    return @getNextPassableCell(vCur, depth)
    return Map
