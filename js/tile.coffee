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

define ['map'], (Map) ->
    
    class Tile
        # Represents a Tile on the map
        #
        constructor: (name, xPos, yPos, image, flammable) ->
            # name The name for the tile
            # xPos x co-ord on the screen for the object
            # yPos y co-ord
            # image Path to the image for the sprite
            # map The map object, needed for certain functions

            @sprite = new Sprite {
                image: image,
                x: xPos,
                y: yPos
                }

            @alive = true
            @x = @sprite.x
            @y = @sprite.y
            @name = name
            @isFlammable = flammable
            return

        draw: ->
            @sprite.draw()

    return Tile
