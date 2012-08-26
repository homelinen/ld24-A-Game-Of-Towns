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

        bushes = []
        for bush in [0..10]
    
            tilePos = getRandPos()
            
            bushes.push new Bush(tilePos.x, tilePos.y, 5, 20)

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
    simulator = null

    @setup = ->
        @maxVillagers = 10
        @villagerLimit = 4
        return

    @update = ->
        if jaws.pressed "left_mouse_button"
            workerPresent = no

            for tile in tileMap.at(jaws.mouse_x, jaws.mouse_y)
                if tile.name == "worker"
                    workerPresent = yes
                    break

            if !workerPresent && @villagerLimit > 0  
                tilePos = getTileCorner(jaws.mouse_x, jaws.mouse_y)
                # Place a person
                worker = new Worker(tilePos.x, tilePos.y, 10, 5)

                tileMap.push(worker)
                @villagerLimit--

        if jaws.pressed "right_mouse_button"

            tilePos = getTileCorner(jaws.mouse_x, jaws.mouse_y)
            console.log tileMap.at(tilePos.x, tilePos.y)
            removeAllObjects(tilePos.x, tilePos.y)

        if pressed("enter") || pressed "s"

            @villagerLimit = Simulate().step(@villagerLimit)

            if @villagerLimit > @maxVillagers
                @villagerLimit = @maxVillagers

        if pressed("d")
            console.log "Debug"
            found = false
            for x in [0..99]
                for y in [0..99]
                    tile = tileMap.cell(x, y)
                    for item in tile
                        if item.name != undefined
                            console.log "Name: #{item.name}"
                            found = true
                    if found 

                        console.log "Point: <#{x}, #{y}>"
                        found = false

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
                            createVillage(item.x, item.y)
                            removeObject(item.x, item.y, "worker")
                            vilLim++
                    else if item.name == "bush"
                        item.update()
                    else if item.name == "village"
                        getNeighbours(item.x, item.y)

                else
                    # Otherwise dead
                    vname = item.name
                    removeObject(item.x, item.y, vname)

        @totalVillagersPlaced += villagerCount
        if villagerCount < 1 && vilLim < 1
            jaws.switchGameState(GameOver)

        vilLim

    return @

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

getTileCorner = (x, y) ->
    # Get the top corner of a cell
    # x xPosition
    # y yPosition
    # Return Object with fields x and y
    xPos = (Math.floor getTilePosx(x)) * TILE_SIZE
    yPos = (Math.floor getTilePosy(y)) * TILE_SIZE
    { x: xPos, y: yPos }

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

isCellOccupied = (pos) ->
    # Decide if the cell is passable

    cell = tileMap.cell(pos.x, pos.y)
    for item in cell
        if item.name != undefined && item.name?
            return true
    return false

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
    # Remove all the objects in a cell
    
    items = tileMap.at(x, y)

    count = 0
    if jaws.isArray(items) && items != undefined
        for item in items
            if item? && item.name != undefined
                tileMap.cells[getTilePosx(x)][getTilePosy(y)].splice(count, 1)
            count++

    return

createVillage = (x, y) ->
    if !isCellOccupied(getPoint(x, y))
        village = new Sprite {
            image: "img/village.png",
            x: x,
            y: y
        }
        village.name = "village"
        village.alive = true
        tileMap.push(village)
    return

getRandPos = ->
    getTileCorner getRand(jaws.width), getRand(jaws.height)

getRand = (max) ->
    rand = Math.random()
    mult = 10
    while rand * mult < max
        rand *= mult

    rand

getRandBoolean = ->
    rand = Math.random() 
    if rand > 0.5 
        true
    else 
        false

getTilePosx = (x) -> 
    x = getTilePos(x)
    x = getPosInLimits(x, getMapWidth())
    x

getTilePosy = (y) ->

    y = getTilePos(y)
    y = getPosInLimits(y, getMapHeight())
    y

getPosInLimits = (point, max) ->
    if point < 0
        point = 0
    else if point >= max
        point = max
    point

getTilePos = (pos) ->
    pos / TILE_SIZE

getPoint = (x, y) ->
    return { x: getTilePosx(x), y: getTilePosy(y) }

getMapWidth = ->
    jaws.width / TILE_SIZE
getMapHeight = ->
    jaws.height / TILE_SIZE

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
        @maxFood = @foodEaten
        @lastDx = 0
        @lastDy = 0
    
    draw: ->
        @sprite.draw()

    update: ->
        @eat()
        @walk()
        return

    move: (x, y)->
        if @alive
            # Move player


            x *= TILE_SIZE
            y *= TILE_SIZE

            pos =  getTileCorner(x + @sprite.x, @sprite.y + y)

            if !isCellOccupied(pos)
                # Discard old player
                removeObject(@sprite.x, @sprite.y, "worker")

                @sprite.moveTo(pos.x, pos.y)
                @x = @sprite.x
                @y = @sprite.y
                tileMap.push @

        return

    walk: ->
        dx = 0
        dy = 0
        while dx == 0 && dy == 0
            if getRandBoolean() 
                if getRandBoolean()
                    dx = 1
                else
                    dx = -1

            else
                if getRandBoolean()
                    dy = 1
                else 
                    dy = -1

        @move(dx, dy)
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

            pos = getRandomNeighbour(@x, @y)
            if pos? && !isCellOccuped(pos)
                bush = new Bush( pos.x * TILE_SIZE, pos.y * TILE_SIZE, halfCap, @capacity)
                @food = halfCap
                tileMap.push bush
        return

    draw: ->
        @sprite.draw()

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/grass-tile.png")
    jaws.assets.add("img/villager.png")
    jaws.assets.add("img/village.png")
    jaws.assets.add("img/bush.png")
    #jaws.assets.loadAll()

    jaws.start Init
    return
