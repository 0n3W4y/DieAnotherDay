package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.Lib;

import Math;

class PlayingScene extends Sprite
{	
	private var _myGame:Game;
	private var _entity:Array<Tile>;
	private var _tileMap:TileMap;
	private var _tileDataGround:Array<Tile>;

	private var _maxSceneWidth:Int = 400; // cause 200 map size;
	private var _maxSceneHeight:Int = 400;

	// 0 - earth, 1 - water, 2 - rocks;

	public function new(game)
	{
		super();
		_myGame = game;
		init();
	}

	private function init()
	{
		createLevel();
	}

	private function createLevel()
	{
		createLevelGround();
	}

	private function createLevelGround()
	{
		var gridSize = 200;

		var ground = "earth";
		generateMapGrid(gridSize, ground);

		var liquid = "water";
		var liquidType= 1; // 0 - lake, 1 - river, -1 - no water;
		generateLiquids(gridSize, liquid, liquidType);

		var kind = "stone";
		var kindValue = 4;
		generateRocks(gridSize, kind, value);

		trace(_tileMap.tile);

	}

	private function generateMapGrid(size:Int, ground:String)
	{
		_tileMap = new TileMap(size, size);
		fillFloor(ground);
	}

	private function generateRocks(size:Int, kind:String, value:Int)
	{
		var gridSize = size;
	}

	private function generateWater(size:Int, liquid:String, type:Int)
	{
		var gridSize = size;

		if (type == 1) // generate river. Right now i made line river across all map, in future i'll do random river with angle;
		{
			//in future can use % of all ground if we want to generate climate, so we can control how many water in this level
			// right now i take min parametrs for test my generator;

			var riverMaxSize = 10;
			var riverMinSize = 5;
			var riverSize = Math.floor(Math.random()*(riverMaxSize - riverMinSize + 1) + riverMinSize);

			// generate river width; we can control river width with max and min values, and move it to map with iteration;
			// i'll draw river at left to right;

			// in future i can draw beach zone on left and right side of river;

			var lastLeftPoint = Math.floor(Math.random()*(gridSize - riverSize + 1));

			for ( y in 0...gridSize)
			{
				var riverOffset = Math.floor(Math.random()*3); // 0 - left, 1 - center, 2 - right
				
				// future: we can do angle river with chanse about 20%
				// var riverDirection = Math.round((Math.random()*2)*100)/100);
				// if we have riverDirection > 0.8 we can try to turn it to left or right;

				if (y == 0)
					riverOffset = 1;

				if (riverOffset == 0)
					lastLeftPoint -= 1;
				else if (riverOffset == 2)
					lastLeftPoint += 1;

			
				//we can use random variables of riverSize here;

				for ( x in 0...riverSize)
				{
					_tileMap.tile[y*gridSize + lastLeftPoint + x] = new Tile(liquid);

					// if my point in the right end of map, we can end river or break some errors;
					if (gridSize - lastLeftPoint < x )
						break;
				}
			}
		}
		else
		{

		}
	}

	private function fillFloor(ground:String)
	{

		for (i in 0..._tileMap.tile.length)
		{
			_tileMap.tile[i] = new Tile(ground);
		}

	}
}