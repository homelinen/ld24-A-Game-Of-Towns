
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
