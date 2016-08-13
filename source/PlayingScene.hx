package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.Assets;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.geom.Rectangle;


import Math;

class PlayingScene extends Sprite
{	
	private var _myGame:Game;
	private var _tileMap:TileMap;	

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
		//createTilesheet();
	}

	private function createLevelGround()
	{
		var gridSize:Int = 200;

		var ground:String = "earth";
		generateMapGrid(gridSize, ground);

		var liquid:String = "water";
		var liquidType:Int = 1; // 0 - lake, 1 - river, -1 - no water;
		generateLiquids(gridSize, liquid, liquidType);

		var kind:String = "stone";
		var kindValue:Int = 4; // возможно не стоит брать больше чем girdSize/rocksMaxSize,  в противном случае, камни займут всю карту, и более тоого, будет ошибка
		generateRocks(gridSize, kind, kindValue);

	}

	private function generateMapGrid(size:Int, ground:String)
	{
		_tileMap = new TileMap(size, size);
		fillFloor(ground);
	}

	private function generateRocks(size:Int, kind:String, value:Int)
	{
		var gridSize = size;

		//here we can control how many rocks in our scene, and how it big, right now i made rocks by default options;
		var rocksMaxSize:Int = 25;
		var rocksMinSize:Int = 5;

		if (gridSize/value <= rocksMaxSize)
			return trace("error with generate rocks");

		for (i in 0...value)
		{
			var currentRockSizeY = Math.floor(Math.random()*(rocksMaxSize - rocksMinSize + 1) + rocksMinSize);
			var lastLeftPoint = Math.floor(Math.random()*(gridSize - rocksMinSize + 1));
			var firstTopPoint = Math.floor(Math.random()*(gridSize - rocksMaxSize + 1));

			for (y in 0...currentRockSizeY)
			{
				var currentRockSizeX = Math.floor(Math.random()*(rocksMaxSize - rocksMinSize + 1) + rocksMinSize);
				var rockOffset = Math.floor(Math.random()*3); // 0 - left, 1 - center, 2 - right

				if (y == 0)
					rockOffset = 1;

				if (rockOffset == 0)
					lastLeftPoint -= 1;
				else if (rockOffset == 2)
					lastLeftPoint += 1;

				for ( x in 0...currentRockSizeX)
				{
					if (y*gridSize + lastLeftPoint + x >= y*gridSize)
						_tileMap.tile[y*gridSize + lastLeftPoint + x] = new Tiles(kind);

					if (gridSize - lastLeftPoint < x )
						break;
				}
			}
		}
	}

	private function generateLiquids(size:Int, liquid:String, type:Int)
	{
		var gridSize = size;

		if (type == 1) // generate river. Right now i made line river across all map, in future i'll do random river with angle;
		{
			//in future can use % of all ground if we want to generate climate, so we can control how many water in this level
			// right now i take min parametrs for test my generator;

			var riverMaxSize:Int = 10;
			var riverMinSize:Int = 5;
			var riverSize:Int = Math.floor(Math.random()*(riverMaxSize - riverMinSize + 1) + riverMinSize);

			// generate river width; we can control river width with max and min values, and move it to map with iteration;
			// i'll draw river at left to right;

			// in future i can draw beach zone on left and right side of river;

			var lastLeftPoint:Int = Math.floor(Math.random()*(gridSize - riverSize + 1));

			for ( y in 0...gridSize)
			{
				var riverOffset:Int = Math.floor(Math.random()*3); // 0 - left, 1 - center, 2 - right
				
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
					_tileMap.tile[y*gridSize + lastLeftPoint + x] = new Tiles(liquid);

					// if my point in the right end of map, we can end river or break some errors;
					if (gridSize - lastLeftPoint < x )
						break;
				}
			}
		}
		else
		{
			var kind:String = "water";
			var value:Int = 2;
			generateRocks(size, kind, value);
		}
	}

	private function fillFloor(ground:String)
	{

		for (i in 0..._tileMap.tile.length)
		{
			_tileMap.tile[i] = new Tiles(ground);
		}

	}
/*
	private function createTilesheet()
	{
		var tilesBitmapData:BitmapData = Assets.getBitmapData("assets/images/ground_tile.png");
		var tileset = new Tileset(tilesBitmapData);
		tileset.addRect(new Rectangle(0, 0, 64, 64)); //grass, earth 0
		tileset.addRect(new Rectangle(64, 0, 64, 64)); //water 1
		tileset.addRect(new Rectangle(128, 0, 64, 64)); //rocks 2
		tileset.addRect(new Rectangle(192, 0, 64, 64)); //sand 3
		tileset.addRect(new Rectangle(256, 0, 64, 64)); //desert 4

		var tilemap = new Tilemap(200, 200);
		var layer = new TilemapLayer(tileset);

		for (row in 0...gridSize)
		{
			for (cell in 0...gridSize)
			{
				var tile = _tileMap.tile[gridSize*row + cell];
				var tilePic = tile.groundType;
				layer.addTile (new Tile (tilePic, cell*gridSize, row*gridSize));
			}
		}

		tilemap.addLayer(layer);
		addChild(tilemap);
	}
	*/
}