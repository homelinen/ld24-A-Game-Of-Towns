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

define [], ->
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
