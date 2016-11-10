package;

import pathfinder.IMap;

class PathfinderMap implements IMap

{   
    public var rows( default, null ):Int;
    public var cols( default, null ):Int;

    public function new( p_cols:Int, p_rows:Int )
    {
        cols = p_cols;
        rows = p_rows;
        // create an array of tiles, and determine if they are walkable or obstructed
    }

    public function isWalkable( p_x:Int, p_y:Int ):Bool
    {
       return true;
    }

}