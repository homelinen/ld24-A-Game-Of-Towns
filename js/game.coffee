# A Game of Towns Utilises JawsJs and is a Conway's Game of Life sim
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

define [
    'worker', 
    'water',
    'gameOver',
    'fire',
    'bush',
    'map'
    ], (Worker, Water, GameOver, Fire, Bush, Map)->
    # Creation of the village through a map editor
    fps = document.getElementById("fps")
    simulate = true

    @setup = ->
        @maxVillagers = 10
        @villagerLimit = 4
        @map = new Map(jaws.width, jaws.height, 32)

        bushes = []
        for bush in [0..60]
    
            tilePos = @map.getRandPos()
            
            while @map.isCellOccupied @map.getCellPos tilePos
                tilePos = @map.getRandPos()

            bushes.push new Bush(tilePos.x, tilePos.y, 2, 10)

        @map.tileMap.push bushes
        return

    @update = ->
        if jaws.pressed "left_mouse_button"
            workerPresent = no

            x = jaws.mouse_x
            y = jaws.mouse_y

            tilePos = @map.getTileCorner x, y
            cellPos = @map.getCellPos tilePos
            notOccupied = !map.isCellOccupied cellPos
            if notOccupied && @villagerLimit > 0  
                # Place a person
                worker = new Worker(tilePos.x, tilePos.y, 10, 5)

                @map.tileMap.push(worker)
                @villagerLimit--

        if jaws.pressed "right_mouse_button"

            tilePos = @map.getTileCorner(jaws.mouse_x, jaws.mouse_y)
            @map.removeAllObjects(tilePos.x, tilePos.y)

        if simulate
            simulate = false
            stepSimulator()

            if @villagerLimit > @maxVillagers
                @villagerLimit = @maxVillagers
            setTimeout(->
                simulate = true
                return
            , 250)

        fps.innerHTML = "Fps: " + jaws.game_loop.fps
        return

    @draw = ->
        jaws.clear()
        # tiles.draw()
        for tile in @map.tileMap.all()
            tile.draw()
        return

    @drawHud = ->
        # Graphical Overlay with some information
        makeText

    stepSimulator = ->
        # Maybe make a param?
        
        @villPop = 4
        workers()

        randPos = @map.getRandPos()
        if @map.isAreaFlammable @map.getCellPos(randPos)
            # Time out on random fires
            fire = new Fire(randPos.x, randPos.y, 10)
            @map.tileMap.push fire
        return

    workers = ()->
        villagerCount = 0
        
        allTiles = @map.tileMap.all()
        for item in allTiles

            if item.name != undefined 
                if item.alive
                    if item.name == "worker"
                        villagerCount++
                        workCount = 0
                        adjacentTiles = @map.getSurroundingTiles(item.x, item.y)
                        for point in adjacentTiles

                            tempTile = @map.tileMap.cell(point.x, point.y)
                            # Loop through items at tile
                            for neighbour in tempTile
                                if  neighbour.name == "worker"
                                    workCount++
                                    # In case two workers occupy the same space
                                    break
                                else if neighbour.name == "bush"
                                    item.gather(neighbour)

                        item.update(map)

                        if workCount >= @villPop
                            # Replace worker with a village
                            @map.removeObject(item.x, item.y, "worker")
                            createVillage(item.x, item.y)
                            @villagerLimit++
                    else if item.name == "bush"
                        item.update(map)
                    else if item.name == "village"

                        x = item.x
                        y = item.y

                        villages = []
                        adjacentTiles = @map.getSurroundingTiles(x, y)
                        for neighbour in adjacentTiles
                            nTown = @map.getContentsOfType(neighbour, "village")
                            if nTown.length > 0
                                if villages.indexOf nTown[0] < 0
                                    villages.push nTown[0]

                        if villages.length > 1
                            console.log "CHURCH"
                            # Add current village to list as well
                            villages.push item

                            for village in villages
                                @map.removeObject(village.x, village.y, "village")

                            church = new Sprite {
                                image: "img/church.png",
                                x: x,
                                y: y
                            }
                            church.name = "church"
                            church.alive = true
                            church.isFlammable = false
                            @map.tileMap.push church
                                

                    else if item.name == "fire"
                        item.update(map)

                else
                    # Otherwise dead
                    vname = item.name
                    @map.removeObject(item.x, item.y, vname)

        @totalVillagersPlaced += villagerCount
        if villagerCount < 1 && villagerLimit < 1
            jaws.switchGameState(GameOver)

    return @
    
    createVillage = (x, y) ->
        if !map.isCellOccupied(@map.getPoint(x, y))
            village = new Sprite {
                image: "img/village.png",
                x: x,
                y: y
            }
            village.name = "village"
            village.alive = true
            village.isFlammable = true
            @map.tileMap.push(village)
        return

    createLake = (size) ->
        pos = @map.getRandPos()

        for i in [0..size]
            cell = @map.getNextPassableCell(pos.x, pos.y)

            pos = @map.getRandPos()

            water = new Water cell.x, cell.y

            @map.tileMap.push water
            pos = cell

        return

    return @
