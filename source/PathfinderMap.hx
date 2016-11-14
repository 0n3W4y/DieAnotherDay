package;

import pathfinder.IMap;
import haxe.ds.Vector;

class PathfinderMap implements IMap

{   
    public var rows( default, null ):Int;
    public var cols( default, null ):Int;
    private var _myScene:PlayingScene;

    public function new( p_cols:Int, p_rows:Int, scene:PlayingScene )
    {
        cols = p_cols;
        rows = p_rows;
        _myScene = scene;
        trace (_myScene);
        var tiles = _myScene.getTileMap();
        trace (tiles);

        // create an array of tiles, and determine if they are walkable or obstructed
    }

    public function isWalkable( p_x:Int, p_y:Int ):Bool
    {
        /*
        var tilemap = _myScene.getTileMap();
        var currentTile = tilemap.tile[p_y * cols + p_x];
        if (currentTile.groundType == 0)
            return true;
        else
            return false;
        */
        return true;

    }

}