# A Game of Towns
#
# Author: Calum Gilchrist
# Website: http://calumgilchrist.co.uk
# 
# Notes: 
#   * The {x, y} object is a vector, and almost always should represent a tile 
#   position not a screen position
#   * Inversely, methods requiring x and y should be screen positions
#

tileMap = null
TILE_SIZE = null

Init = ->
    # Initialise things

    @setup = ->
        viewport = new Viewport({})
        tiles = new SpriteList
        tile = "img/grass-tile.png"
        TILE_SIZE = 32
        mapWidth = getMapWidth() 
        mapHeight = getMapHeight()

        for xPos in [0..mapWidth]
            for yPos in [0..mapHeight]
                tiles.push new Sprite { 
                    image: tile,
                    x: xPos * TILE_SIZE
                    y: yPos * TILE_SIZE
                }

        tileMap = new TileMap { cell_size: [TILE_SIZE,TILE_SIZE] }
        tileMap.push tiles
        createLake(10)

        bushes = []
        for bush in [0..60]
    
            tilePos = getRandPos()
            
            while isCellOccupied getCellPos tilePos
                tilePos = getRandPos()

            bushes.push new Bush(tilePos.x, tilePos.y, 2, 10)

        tileMap.push bushes
        jaws.switchGameState(BuildState)

    @draw = ->
        jaws.clear()
        # tiles.draw()
        for tile in tileMap.all()
            tile.draw()
        return

    return @

BuildState = ->
    # Creation of the village through a map editor
    fps = document.getElementById("fps")
    simulate = true

    @setup = ->
        @maxVillagers = 10
        @villagerLimit = 4
        return

    @update = ->
        if jaws.pressed "left_mouse_button"
            workerPresent = no

            x = jaws.mouse_x
            y = jaws.mouse_y

            tilePos = getTileCorner x, y
            cellPos = getCellPos tilePos
            notOccupied = !isCellOccupied cellPos
            if notOccupied && @villagerLimit > 0  
                # Place a person
                worker = new Worker(tilePos.x, tilePos.y, 10, 5)

                tileMap.push(worker)
                @villagerLimit--

        if jaws.pressed "right_mouse_button"

            tilePos = getTileCorner(jaws.mouse_x, jaws.mouse_y)
            removeAllObjects(tilePos.x, tilePos.y)

        if simulate
            simulate = false
            @villagerLimit = Simulate().step(@villagerLimit)

            if @villagerLimit > @maxVillagers
                @villagerLimit = @maxVillagers
            setTimeout(->
                simulate = true
                return
            , 250)

        fps.innerHTML = "Fps: " + jaws.game_loop.fps
        return

    @draw = ->
        Init().draw()
        return

    @drawHud = ->
        # Graphical Overlay with some information
        makeText
    return @

Simulate = ->
    #Runs a simulation of the villagers

    @step = (vilLim) ->
        # Maybe make a param?
        
        @villPop = 4
        vilLim = @workers(vilLim)


        randPos = getRandPos()
        if isAreaFlammable getCellPos(randPos)
            # Time out on random fires
            fire = new Fire(randPos.x, randPos.y, 10)
            tileMap.push fire
        return vilLim

    @workers = (vilLim)->
        villagerCount = 0
        
        allTiles = tileMap.all()
        for item in allTiles

            if item.name != undefined 
                if item.alive
                    if item.name == "worker"
                        villagerCount++
                        workCount = 0
                        adjacentTiles = getSurroundingTiles(item.x, item.y)
                        for point in adjacentTiles

                            tempTile = tileMap.at(point.x * TILE_SIZE, point.y * TILE_SIZE)
                            # Loop through items at tile
                            for neighbour in tempTile
                                if  neighbour.name == "worker"
                                    workCount++
                                    # In case two workers occupy the same space
                                    break
                                else if neighbour.name == "bush"
                                    item.gather(neighbour)

                        item.update()

                        if workCount >= @villPop
                            # Replace worker with a village
                            removeObject(item.x, item.y, "worker")
                            createVillage(item.x, item.y)
                            vilLim++
                    else if item.name == "bush"
                        item.update()
                    else if item.name == "village"

                        x = item.x
                        y = item.y

                        villages = []
                        adjacentTiles = getSurroundingTiles(x, y)
                        for neighbour in adjacentTiles
                            nTown = getContentsOfType(neighbour, "village")
                            if nTown.length > 0
                                if villages.indexOf nTown[0] < 0
                                    villages.push nTown[0]

                        if villages.length > 1
                            console.log "CHURCH"
                            # Add current village to list as well
                            villages.push item

                            for village in villages
                                removeObject(village.x, village.y, "village")

                            church = new Sprite {
                                image: "img/church.png",
                                x: x,
                                y: y
                            }
                            church.name = "church"
                            church.alive = true
                            church.isFlammable = false
                            tileMap.push church
                                

                    else if item.name == "fire"
                        item.update()

                else
                    # Otherwise dead
                    vname = item.name
                    removeObject(item.x, item.y, vname)

        @totalVillagersPlaced += villagerCount
        if villagerCount < 1 && vilLim < 1
            jaws.switchGameState(GameOver)

        vilLim

    return @
    
getTileCorner = (x, y) -> 
    # Get the top corner of a cell 
    # x xPosition on the grid
    # y yPosition on the grid
    # Return Object with fields x and y
    xPos = (Math.floor getTilePosx(x)) * TILE_SIZE
    yPos = (Math.floor getTilePosy(y)) * TILE_SIZE
    { x: xPos, y: yPos }

getScreenFromVec = (pos) ->
    # Get the top corner of a cell
    # pos: Vector 
    x = pos.x * TILE_SIZE
    y = pos.y * TILE_SIZE
    {x: x, y: y}

getSurroundingTiles = (x, y) ->
    x = getTilePosx(x)
    y = getTilePosy(y)
    
    getSurroundingCells {x: x, y: y}

getSurroundingCells = (pos) ->
    # Get tiles for the cell represented by obj:
    # {x, y}

    dx = -1
    dy = -1
    tiles = []

    x = pos.x
    y = pos.y

    mapWidth = getMapWidth()
    mapHeight = getMapHeight()

    tempx = x + dx
    tempy = y + dy
    while dx < 2 && tempx >= 0 && tempx < mapWidth
        while dy < 2 && tempy >= 0 && tempy < mapHeight
            
            if !(tempx == x && tempy == y) && (tempx == x || tempy == y) 
                # Ensure not on a diagonal smf not given point
                
                tiles.push {x: tempx, y: tempy}
            dy++
            tempy = y + dy
        dy = -1
        dx++
        tempx = x + dx
    tiles

getRandomNeighbour = (x, y) ->
    neighbours = getSurroundingTiles(x, y)

    if neighbours.length > 0
        divisor =  1 / (neighbours.length - 1)

        rand = Math.random()

        index = Math.floor(rand / divisor)

        neighbour = neighbours[index]

        return { x: neighbour.x, y: neighbour.y }
    return

isCellOccupied = (pos, tiles = tileMap) ->
    # Decide if the cell is passable

    cell = tiles.cell(pos.x, pos.y)
    if cell?
        for item in cell
            if item.name != undefined && item.name?
                return true
        return false
    else 
        return true

getNeighbours = (pos) ->
    # Return all the named items in a cell

    neighbours = []
    adjacentCells = getSurroundingCells(pos) 
    for neighbour in adjacentCells
        items = tileMap.at(neighbour.x * TILE_SIZE, neighbour.y * TILE_SIZE)
        for item in items
            if item.name != undefined && item.name?
                neighbours.push item

    neighbours

removeObject = (x, y, name = "") ->
    # Removes worker at point

    removed = false
    items = tileMap.at(x, y)
    count = 0
    if jaws.isArray(items) && items != undefined
        for item in items
            if item? && item.name == name
                tileMap.cells[getTilePosx(x)][getTilePosy(y)].splice(count, 1)
                removed = true
            count++
    removed

removeAllObjects = (x, y) ->
    # Remove all the objects in the cell at screen 
    # co-ord x, y
    
    items = tileMap.at(x, y)

    count = 0
    if jaws.isArray(items) && items != undefined
        for item in items
            if item? && item.name != undefined
                tileMap.cells[getTilePosx(x)][getTilePosy(y)].splice(count, 1)
            count++

    return

removeAllAtVec = (pos) ->
    # Remove all objects at given Vector

    pos = getScreenFromVec pos
    removeAllObjects pos.x, pos.y

removeEverything = (pos) ->
    x = pos.x
    y = pos.y
    items = tileMap.at(x, y)
    count = 0
    if jaws.isArray(items) && items != undefined
        for item in items
            if item?
                tileMap.cells[getTilePosx(x)][getTilePosy(y)].splice(count, 1)
            count++

createVillage = (x, y) ->
    if !isCellOccupied(getPoint(x, y))
        village = new Sprite {
            image: "img/village.png",
            x: x,
            y: y
        }
        village.name = "village"
        village.alive = true
        village.isFlammable = true
        tileMap.push(village)
    return

createLake = (size) ->
    pos = getRandPos()

    for i in [0..size]
        cell = getNextPassableCell(pos.x, pos.y)
        if cell?
            break

        pos = getRandPos()

        water = new Water cell.x, cell.y

        tileMap.push water
        pos = cell

    return

getRandPos = ->
    # Get a random Vector
    rx = getRand getMapWidth()
    ry = getRand getMapHeight()
    rx = Math.round(rx) * TILE_SIZE
    ry = Math.round(ry) * TILE_SIZE
    getTileCorner rx, ry

getRand = (mult) ->
    # Get a random integer that is less than the max
    rand = Math.random()
    rand *= mult

getRandBoolean = ->
    rand = Math.random() 
    if rand > 0.5 
        true
    else 
        false

getContentsAt = (x, y) ->
    getContentsOfCell getPoint(x, y)

getContentsOfCell = (pos) ->
    # Retrieve the top object in the cell
     
    contents = tileMap.cell(pos.x, pos.y)
    for item in contents
        if item.name?
            return item
    return

getContentsOfType = (pos, type) ->
    
    match = []
    contents = tileMap.cell(pos.x, pos.y)
    for item in contents
        if item.name == type
            match.push item

    match

getTilePosx = (x) -> 
    x = getTileComp(x)
    x = getPosInLimits(x, getMapWidth())
    x

getTilePosy = (y) ->
    y = getTileComp(y)
    y = getPosInLimits(y, getMapHeight())
    y

getTileComp = (comp)  ->
    # Transform the given screen position to a tile position
    comp / TILE_SIZE

isAreaFlammable = (pos) ->
    # Checks if the area around position is flammable 
    # enough for a fire to catch

    neighbours = getNeighbours(pos)
    count = 0

    for neighbour in neighbours
        if neighbour.isFlammable != undefined && neighbour.isFlammable
            count++

    minFlammableNeighbours = 4
    return count >= minFlammableNeighbours

getPosInLimits = (point, max) ->
    if point < 0
        point = 0
    else if point >= max
        point = max
    point

getCellPos = (pos) ->
    # Get the Vector for a cell position
     
    return { x: getTilePosx(pos.x), y: getTilePosy(pos.y) }

getPoint = (x, y) ->
    # Returns a vector representing the cell co-ordinates of x and y
    return { x: getTilePosx(x), y: getTilePosy(y) }

makePoint = (x, y) ->
    { x: x, y: y }

getMapWidth = ->
    jaws.width / TILE_SIZE
getMapHeight = ->
    jaws.height / TILE_SIZE

getRandomDirection = ->
    # Returns a vector that represents a direction
    dx = 0
    dy = 0
    while dx == 0 && dy == 0
        if getRandBoolean() 
            dx = getRandomSign()
        else
            dy = getRandomSign()
    makePoint(dx, dy)

getRandomSign = ->
    # Returns either 1 or -1
    if getRandBoolean()
        num = 1
    else 
        num = -1

getNextCell = (curX, curY)->
    # Returns a random cell adjacent to the 

    dir = getRandomDirection()
    x = dir.x * TILE_SIZE
    y = dir.y * TILE_SIZE

    pos =  getTileCorner(x + curX, y + curY)
    pos

getNextPassableCell = (curX, curY, depth = 0) ->

    # 4 is the number of adjacent cells
    pos = getNextCell(curX, curY)
    if depth < 4
        cellPos = getPoint(pos.x, pos.y)
        if !isCellOccupied(cellPos)
            return pos
        else
            depth += 1
            return getNextPassableCell(curX, curY, depth)

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

class Water
    
    constructor: (x, y) ->
        @sprite = new Sprite {
            image: "img/water.png",
            x: x,
            y: y,
        }
        @name = "water"
        @alive = true

        @x = @sprite.x
        @y = @sprite.y
        @isFlammable = false

    draw: ->
        @sprite.draw()

GameOver = ->
    # Game over menu State

    items = null
    itemIndex = 0
    @setup = ->
        items = [
            { title: "Game Over", state: null },
            { title: "Restart", state: Init }
        ]
        itemIndex = 0
        
        # Key bindings
        jaws.on_keydown(["down", "s"], -> 
            if itemIndex + 1 < items.length
                itemIndex++
        )
        jaws.on_keydown(["up", "w"], ->
            if itemIndex - 1 >= 0
                itemIndex--
        )
        jaws.on_keydown(["enter", "space", "e"], ->
            item = items[itemIndex]
            if item.state?
                jaws.switchGameState(item.state)
        )
        return

    @draw = ->
        jaws.context.clearRect(0, 0, jaws.width, jaws.height)

        grad = jaws.context.createLinearGradient(
            0, jaws.height,
            0, 0
        )

        grad.addColorStop(0.0, "#222")
        grad.addColorStop(1.0, "#e4e4e4")
        jaws.context.fillStyle = grad
        jaws.context.fillRect(0, 0, jaws.width, jaws.height)

        # Font setup
        jaws.context.font = "5em sans-serif"
        jaws.context.lineWidth = 2
        jaws.context.textAlign = "center"

        i = 0
        while i < items.length

            colour = if i == itemIndex then "Red" else "Black"
            jaws.context.fillStyle = colour
            jaws.context.fillText(items[i].title, jaws.width / 2, (200 + 100 * i))
            i++

        return
    return @ 

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/grass-tile.png")
    jaws.assets.add("img/villager.png")
    jaws.assets.add("img/village.png")
    jaws.assets.add("img/bush.png")
    jaws.assets.add("img/fire.png")
    jaws.assets.add("img/water.png")
    jaws.assets.add("img/church.png")
    #jaws.assets.loadAll()

    jaws.start Init
    return
