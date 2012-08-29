# Functions relating to the Map
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
    
    class Point
        constructor: (@x = 0, @y = 0) ->
            return

        setVec: (v) ->
            @x = v.x
            @y = v.y
            return @

        mulLoc: (mul) ->
            # Multiply locla vector points by the scalar mul
            # And return modified value
            @x *= mul
            @y *= mul
            return @

        copy: ->
            # Create a copy of the current vecotr
            new Point(@x, @y)

        mul: (mul) ->
            v = @copy()
            v.mulLoc(mul)
            return v

        addVec: (v) ->
            # Add a vector to a copy
            
            t = @copy()
            t.addLocVec(v)

        addLocVec: (v) ->
            # Add a vector to the current vector
            # Return the new vector, to chain methods
            @x += v.x
            @y += v.y
            return @

        add: (x, y) ->
            # Add the components to the vector
            @x += x
            @y += y
            return @

        toString: ->
            "Point: <#{@x}, #{@y}>"

    return Point
