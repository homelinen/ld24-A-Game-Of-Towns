
tiles = null
tileMap = null
Init = ->
    # Initialise things

    @setup = ->
        tiles = new SpriteList
        tile = "img/grass-tile.png"
        tileSize = 32
        mapWidth = (jaws.width / tileSize) 
        mapHeight = (jaws.height / tileSize)

        for xPos in [0..mapWidth]
            for yPos in [0..mapHeight]
                tiles.push new Sprite { 
                    image: tile,
                    x: xPos * tileSize
                    y: yPos * tileSize
                }

        tileMap = new TileMap { cell_size: [tileSize,tileSize] }
        tileMap.push tiles

        jaws.switchGameState(BuildState)

    @draw = ->
        jaws.clear()
        tiles.draw()

    return @

BuildState = ->
    # Creation of the village through a map editor

    @setup = ->
        console.log "Tiles: " + tiles
        # console.log tileMap
        return

    @update = ->
        if jaws.pressed("left_mouse_button")
            console.log "Click: #{jaws.mouse_x}, #{jaws.mouse_y}"
            # Place a person
            console.log "In cell: #{tileMap.at(jaws.mouse_x, jaws.mouse_y)}"
            tileMap.pushToCell(jaws.mouse_x, jaws.mouse_y, new Worker())

    @draw = ->
        Init().draw()
        return
    return @


jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/grass-tile.png")
    #jaws.assets.loadAll()

    jaws.start Init
    return
