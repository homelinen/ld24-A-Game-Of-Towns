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

define ['tile', 'point', 'map'], (Tile, Point, map) ->
    class Fire extends Tile
        # Fire class, burns everything around it
        
        constructor: (x, y, @heat) ->
            image = "img/fire.png"
            name = "fire"
            flammable = false
            deletable = false
            super name, x, y, image, flammable, deletable
            
        update: (map) ->
            @burn(map)
            @heat--
            if @heat <= 0
                @alive = false
            else
                @spread(map)

        burn: (map) ->
            pos = map.getCellPos(new Point(@x, @y))
            if map.isCellOccupied(pos)
                map.removeAllObjects(pos)
                # Add self back to map
                map.tileMap.push @
            return

        spread: (map) ->
            point = map.getCellPos(new Point(@x, @y))
            cell = map.getNextCell(point)
            if cell?
                pos = map.getScreenFromVec cell
                tile = map.getContentsOfCell(cell)
                if tile?
                    if !tile.isFlammable?
                        flammable = false
                    else 
                        flammable = tile.isFlammable

                    if flammable
                        fire = new Fire(pos.x, pos.y, @heat)
                        map.tileMap.push fire
            return

    return Fire
