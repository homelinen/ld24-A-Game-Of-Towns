
tiles = null
tileMap = null
TILE_SIZE = null

Init = ->
    # Initialise things

    @setup = ->
        viewport = new Viewport({})
        tiles = new SpriteList
        tile = "img/grass-tile.png"
        TILE_SIZE = 32
        mapWidth = (jaws.width / TILE_SIZE) 
        mapHeight = (jaws.height / TILE_SIZE)

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

    @draw = ->
        Init().draw()
        return
    return @

getTileCorner = (x, y) ->
    # Get the top corner of a cell
    # x xPosition
    # y yPosition
    # Return Object with fields x and y
    xPos = (Math.floor x / TILE_SIZE) * TILE_SIZE
    yPos = (Math.floor y / TILE_SIZE) * TILE_SIZE
    console.log "Corner: #{xPos}, #{yPos}"
    { x: xPos, y: yPos }

    
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

    toString: ->
        return "#{@name}: #{@x}, #{@y}"

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/grass-tile.png")
    jaws.assets.add("img/villager.png")
    #jaws.assets.loadAll()

    jaws.start Init
    return
