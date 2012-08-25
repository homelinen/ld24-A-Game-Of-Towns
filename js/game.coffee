
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
        for bush in [0..4]
    
            tilePos = getTileCorner getRand(jaws.width), getRand(jaws.height)
            console.log "Pos: " + tilePos + "Rand: " + Math.random()
            
            bushes.push new Bush(tilePos.x, tilePos.y, 5)

        tileMap.push bushes
        jaws.switchGameState(BuildState)

    @draw = ->
        jaws.clear()
        # tiles.draw()
        for tile in tileMap.all()
            tile.draw()

    return @

BuildState = ->
    # Creation of the village through a map editor

    @setup = ->
        return

    @update = ->
        if jaws.pressed("left_mouse_button")
            console.log "Click: #{jaws.mouse_x}, #{jaws.mouse_y}"

            for tile in tileMap.at(jaws.mouse_x, jaws.mouse_y)
                if tile.name == "worker"
                    workerPresent = yes

            if !workerPresent
                tilePos = getTileCorner(jaws.mouse_x, jaws.mouse_y)
                # Place a person
                worker = new Worker(tilePos.x, tilePos.y, 50, 10)

                console.log "Added worker"
                tileMap.push(worker)

        if pressed("enter") || pressed "s"
            console.log "Simulate"

            for i in [0..5]
                Simulate().step()

    @draw = ->
        Init().draw()
        return
    return @

Simulate = ->
    #Runs a simulation of the villagers

    @step = ->
        # Maybe make a param?
        
        @villPop = 3
        @workers()

    @workers = ->
        console.log "Work"
        # Have villagers do shit?
        for villager in tileMap.all()
            workCount = 0
            if villager.name == "worker"
                if villager.alive
                    adjacent = getSurroundingTiles(villager.x, villager.y)
                    for point in adjacent

                        tempTile = tileMap.cell(point.x, point.y)
                        # Loop through items at tile
                        for item in tempTile
                            if  item.name == "worker"
                                workCount++
                            else if item.name == "bush"
                                villager.gather(item)

                    villager.update()

                    if workCount >= @villPop
                        tileMap.push(new Sprite {
                            image: "img/village.png",
                            x: villager.x,
                            y: villager.y
                        })
                        removeWorker(villager.x, villager.y)
                else
                    console.log "Villager died #{villager.x}, #{villager.y} Food: #{villager.food}"
                    removeWorker(villager.x, villager.y)
        return

    return @

getTileCorner = (x, y) ->
    # Get the top corner of a cell
    # x xPosition
    # y yPosition
    # Return Object with fields x and y
    xPos = (Math.floor getTilePos(x)) * TILE_SIZE
    yPos = (Math.floor getTilePos(y)) * TILE_SIZE
    console.log "Corner: #{xPos}, #{yPos}"
    { x: xPos, y: yPos }

getSurroundingTiles = (x, y) ->
    x = getTilePos(x)
    y = getTilePos(y)
    
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
        tempx = x + dx
        while dy < 2 && tempy >= 0 && tempy < mapHeight
            tempy = y + dy
            
            if tempx == x || tempy == y
                # Ensure not on a diagonal
                
                tiles.push {x: tempx, y: tempy}
            dy++
        dy = -1
        dx++
    tiles

removeWorker = (x, y) ->
    # Removes worker at point

    items = tileMap.cells[getTilePos(x)][getTilePos(y)]
    count = 0
    for item in items
        if item.name == "worker"
            break
        count++
    tileMap.cells[getTilePos(x)][getTilePos(y)].splice(count, 1)

getRand = (max) ->
    rand = Math.random()
    mult = 10
    while rand * mult < max
        rand *= mult

    rand

getTilePos = (pos) -> 
    pos / TILE_SIZE

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
    
    draw: ->
        @sprite.draw()

    update: ->
        # Horrible duplication
        @eat()

    move: (x, y)->
        # Move player
        @sprite.move(x, y)
        @x = x
        @y = y

    gather: (bush) ->
        @food += bush.gather @carryWeight - @curWeight
        @curWeight = 0
        
    eat: ->
        @foodEaten -= 1

        if @foodEaten < 1
            if @food > 0
                foodConsumed = 1
                @foodEaten += 2 * foodConsumed
                @food -= foodConsumed
                @curWeight -= foodConsumed

            if @food <= 0
                console.log "Starved"
                @alive = false

    toString: ->
        return "#{@name}: #{@x}, #{@y}"

class Bush
    # Food giving object
    # Food int representation of food provided
    constructor: (xPos, yPos, @food) ->
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
