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

require ['libs/jaws', 'game'], ( Game ) ->
    
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
