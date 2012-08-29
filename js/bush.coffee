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

define ['tile', 'map'], (Tile, map) ->

    class Bush extends Tile
        # Food giving object
        # Food int representation of food provided
        constructor: (xPos, yPos, @food, @capacity) ->
            flammable = false
            name = "bush"
            super name, xPos, yPos, "img/bush.png", map, flammable

        gather: (amount) ->
            if (@food - amount) > 0
                @food -= amount
                amount
            else 
                amount = @food
                @food = 0
                @alive = false
                amount

        update: (map) ->
            growth = @capacity / 20
            if (@food + growth) < @capacity
                @food += growth

            @spawn(map)

        spawn: (map) ->
            halfCap = @capacity * 0.2
            if @food > @capacity / 2

                pos = map.getNextPassableCell(@sprite.x, @sprite.y)
                if pos?
                    bush = new Bush( pos.x, pos.y, halfCap, @capacity)
                    @food = halfCap
                    map.tileMap.push bush
            return
    return Bush
