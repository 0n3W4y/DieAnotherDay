package;

import Coordinates;

class GameTile 
{
	//GroundTypes: 0-flat, 1-cubic;
	public var groundType:Int;

	//BlockTypes: 0-Liquids, 1-Grounds, 2-Solids, 3-Contsructs;
	public var blockType:Int;

	// -1 - infinity;
	public var blockHealth:Int;

	//CoverTypes: 
	//Liquids: 0-Water, 1-Lava; 2-oil, 3-9 - empty;
	//Grounds: 10-Earth, 11-Dirt, 12-Sand, 13-Shallow, 14-19 - empty;
	//Solids: 20-Rock, 21-Marble, 22-Sandstone; 23-Granite; 24-29 - empty;
	//Other: 30-Wood; 31-39 empty;
	public var coverType:Int; 

	//Effects:
	//Liquid: 1-9 - empty;
	//Ground: 11-Wet(rainy), 12-Blood, 13-Fire, 14-19 - empty;
	//Solid: 21-Iron, 22-Bronze, 23-Gold, 24-Coal, 26-29 - empty;
	public var effect:Int; 


	//for draw and remove tiles;
	public var groundTileLayerIndex:Int;
	public var groundTile:Int;

	public var renderSquareIndex:Int;

	//index:
	//1-top-left; 2-top; 3-top-right; 4-left; 5-middle; 6-right; 7-botom-left; 8-bottom; 9-bottom-right; 
	//10-aloneLeft, 11-aloneTop; 12-aloneRight 13-aloneBottom; 0-alone; 14 - vertical, 15 - horizontal;
	private var _index:Int; //need for solids and walls, maybe for roadfloor;


	private var _gridCoordinates:Coordinates;

	public function new(coords:Coordinates, name:String, index:Int):Void
	{
		_gridCoordinates = coords;
		init(name, index); 
	}

	public function getIndex():Int{ return _index; }
	public function setIndex(index:Int):Void{ _index = index; }

	private function init(name:String, index:Int)
	{
		if (name == "Earth")
			createBlock(index, 0, 1, -1, 10, 0);
		else if (name == "Water")
			createBlock(index, 0, 0, -1, 0, 0);
		else if (name == "Rock")
			createBlock(index, 0, 2, -1, 20, 0);
		else if (name == "Shallow")
			createBlock(index, 0, 1, -1, 13, 0);
		else if (name == "Sand")
			createBlock(index, 0, 1, -1, 12, 0);
		else if (name == "Sandstone")
			createBlock(index, 0, 2, -1, 22, 0);
		else if (name == "Marble")
			createBlock(index, 0, 2, -1, 21, 0);
		else if (name == "Granite")
			createBlock(index, 0, 2, -1, 23, 0);
	}

	private function createBlock(index:Int, gType:Int, bType:Int, blockHp:Int, cType:Int, blockEffect:Int):Void
	{
		_index = index;
		groundType = gType;
		blockType = bType;
		blockHealth = blockHp;
		coverType = cType;
		effect = blockEffect;
	}

	public function getCoordinates():Coordinates
	{
		return _gridCoordinates;
	}
}