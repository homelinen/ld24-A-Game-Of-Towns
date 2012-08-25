
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
                worker = new Worker(tilePos.x, tilePos.y)

                console.log "Added worker"
                tileMap.push(worker)

        if pressed("enter") || pressed "s"
            console.log "Simulate"
            jaws.switchGameState(Simulate)

    @draw = ->
        Init().draw()
        return
    return @

Simulate = ->
    #Runs a simulation of the villagers

    @setup = ->
        @villPop = 3
        return

    @update = ->
        # Have villagers do shit?
        for object in tileMap.all()
            workCount = 0
            if object.name == "worker"
                adjacent = getSurroundingTiles(object.x, object.y)
                for point in adjacent

                    tempTile = tileMap.cell(point.x, point.y)
                    # Loop through items at tile
                    for item in tempTile
                        if  item.name == "worker"
                            workCount++
                if workCount >= @villPop
                    tileMap.push(new Sprite {
                        image: "img/village.png",
                        x: object.x,
                        y: object.y
                    })
                    items = tileMap.cells[getTilePos(object.x)][getTilePos(object.y)]
                    count = 0
                    for item in items
                        if item.name == "worker"
                            break
                        count++
                    items.slice(count, 1)

        if pressed "d"
            console.log tileMap.all()
        return
        
    @draw = ->
        Init().draw()
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

getTilePos = (pos) -> 
    pos / TILE_SIZE


getMapWidth = ->
        jaws.width / TILE_SIZE
getMapHeight = ->
        jaws.height / TILE_SIZE

class Worker
    constructor: (xPos, yPos) ->
        @alive = true
        @sprite = new Sprite {
             image: "img/villager.png",
             x: xPos,
             y: yPos
        }
        @x = @sprite.x
        @y = @sprite.y
        @name = "worker"
    
    draw: ->
        @sprite.draw()

    update: ->
        # Horrible duplication
        @x = sprite.x
        @y = sprite.y

    move: (x, y)->
        # Move player
        @sprite.move(x, y)
        @x = x
        @y = y



    toString: ->
        return "#{@name}: #{@x}, #{@y}"

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/grass-tile.png")
    jaws.assets.add("img/villager.png")
    jaws.assets.add("img/village.png")
    #jaws.assets.loadAll()

    jaws.start Init
    return
