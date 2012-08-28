require.config({
    paths: {
        jaws: 'libs/jaws'
    }
})

require ['jaws', 'game'], (Game) ->
    
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

        jaws.start Game
        return
