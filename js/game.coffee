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

    @setup = ->
        @villagerLimit = 4
        return

    @update = ->
        if jaws.pressed "left_mouse_button"
            workerPresent = no

            console.log @villagerLimit
            for tile in tileMap.at(jaws.mouse_x, jaws.mouse_y)
                if tile.name == "worker"
                    workerPresent = yes
                    break

            if !workerPresent && @villagerLimit > 0  
                tilePos = getTileCorner(jaws.mouse_x, jaws.mouse_y)
                # Place a person
                worker = new Worker(tilePos.x, tilePos.y, 50, 5)

                tileMap.push(worker)
                @villagerLimit--

        if jaws.pressed "right_mouse_button"

            tilePos = getTileCorner(jaws.mouse_x, jaws.mouse_y)
            removeObject(tilePos.x, tilePos.y, "worker")

        if pressed("enter") || pressed "s"

            for i in [0]
                console.log "Step"
                @villagerLimit = Simulate(@villerLimit).step()

        fps.innerHTML = "Fps: " + jaws.game_loop.fps
        return

    @draw = ->
        Init().draw()
        return
    return @

Simulate = ->
    #Runs a simulation of the villagers

    @step = ->
        # Maybe make a param?
        
        @villPop = 4
        @workers()

    @workers = ->
        vilLim = 0
        for villager in tileMap.all()

            if villager.name != undefined 
                if villager.alive
                    if villager.name == "worker"
                        workCount = 0
                        adjacent = getSurroundingTiles(villager.x, villager.y)
                        for point in adjacent

                            tempTile = tileMap.at(point.x * TILE_SIZE, point.y * TILE_SIZE)
                            # Loop through items at tile
                            for item in tempTile
                                if  item.name == "worker"
                                    workCount++
                                    # In case two workers occupy the same space
                                    break
                                else if item.name == "bush"
                                    villager.gather(item)

                        villager.update()

                        if workCount >= @villPop
                            village = new Sprite {
                                image: "img/village.png",
                                x: villager.x,
                                y: villager.y
                            }
                            village.name = "village"
                            village.alive = true
                            tileMap.push(village)

                            removeObject(villager.x, villager.y, "worker")
                            vilLim++
                    else if villager.name == "bush"
                        villager.update()
                        halfCap = villager.capacity * 0.2
                        if villager.food > villager.capacity / 2

                            pos = getRandomNeighbour(villager.x, villager.y)
                            if pos? && !isNearObject(pos)
                                bush = new Bush( pos.x * TILE_SIZE, pos.y * TILE_SIZE, halfCap, villager.capacity)
                                villager.food = halfCap
                                tileMap.push bush
                else
                    vname = villager.name
                    removeObject(villager.x, villager.y, vname)
        vilLim

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

isNearObject = (pos)->
    neighbours = getSurroundingCells(pos) 
    for neighbour in neighbours
        items = tileMap.at(neighbour.x * TILE_SIZE, neighbour.y * TILE_SIZE)
        for item in items
            if item.name != undefined && item.name?
                true
    false

removeObject = (x, y, name = "") ->
    # Removes worker at point

    items = tileMap.at(x, y)
    count = 0
    if jaws.isArray(items) && items != undefined
        for item in items
            if item? && item.name == name
                tileMap.cells[getTilePosx(x)][getTilePosy(y)].splice(count, 1)
            count++
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

            # Discard old player
            removeObject(@sprite.x, @sprite.y, "worker")

            x *= TILE_SIZE
            y *= TILE_SIZE

            pos =  getTileCorner(x + @sprite.x, @sprite.y + y)

            @sprite.moveTo(pos.x, pos.y)
            @x = @sprite.x
            @y = @sprite.y
            tileMap.push @

        return

    walk: ->
        if (!isNearObject( getPoint(@sprite.x, @sprite.y) ))
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
                console.log "Starved"
                @alive = false

        if @foodEaten > @maxFood * 0.8
            pos = getRandomNeighbour(@x, @y)
            if pos? && !isNearObject(pos)
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
        growth = @capacity / 25
        if (@food + growth) < @capacity
            @food += growth

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
