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
import openfl.events.MouseEvent;
import openfl.events.Event;
import flash.events.KeyboardEvent;
import openfl.geom.Point;


import Math;

class PlayingScene extends Sprite
{	
	private var _myGame:Game;
	private var _tileMap:TileMap;
	private var _userInterface:UserInterface;
	private var _gridSize:Int; // want to create always square;

	private var _maxSceneWidth:Int;
	private var _maxSceneHeight:Int;

	private var _groundTileLayer:Tilemap;
	private var _groundEffectsTileLayer:Tilemap;
	private var _characterTileLayer:Tilemap;

	private var _entities = new Array();

	// 0 - earth, 1 - water, 2 - rocks;

	public function new(game)
	{
		super();
		_myGame = game;
		init();
	}

	private function init()
	{
		_gridSize = 200;
		_maxSceneWidth = _gridSize + 50;
		_maxSceneHeight = _gridSize + 50;

		createLevel();
		addInputs();
		createUserInterface();
		addEventListener (Event.ENTER_FRAME, onEnterFrame);
	}

	private function addInputs()
	{
		addEventListener (MouseEvent.MOUSE_WHEEL, onScroll);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	private function createUserInterface()
	{
		_userInterface = new UserInterface(this);
		addChild(_userInterface);
	}

	private function createLevel()
	{
		createLevelGround();
		createLevelGroundTileLayer();
		//createLevelGroundEffectsLayer();
		createCharacterLayer();
	}

	private function createLevelGround()
	{
		var ground:String = "earth";
		generateMapGrid(ground);

		var liquid:String = "water";
		var liquidType:Int = 1; // 0 - lake, 1 - river, -1 - no water;
		generateLiquids(liquid, liquidType);

		var kind:String = "stone";
		var kindValue:Int = 4; // возможно не стоит брать больше чем girdSize/rocksMaxSize,  в противном случае, камни займут всю карту, и более тоого, будет ошибка
		generateRocks(kind, kindValue);

	}

	private function generateMapGrid(ground:String)
	{
		_tileMap = new TileMap(_gridSize, _gridSize); // layer for use data
		fillFloor(ground);
	}

	private function generateRocks(kind:String, value:Int)
	{
		//here we can control how many rocks in our scene, and how it big, right now i made rocks by default options;
		var rocksMaxSize:Int = 40;
		var rocksMinSize:Int = 25;

		if (_gridSize/value <= rocksMaxSize)
			return trace("error with generate rocks");

		for (i in 0...value)
		{
			var currentRockSizeY:Int = Math.floor(Math.random()*(rocksMaxSize - rocksMinSize + 1) + rocksMinSize);
			var lastLeftPoint:Int = Math.floor(Math.random()*(_gridSize - rocksMinSize + 1));
			var firstTopPoint:Int = 200 * Math.floor(Math.random()*(_gridSize - rocksMaxSize + 1));

			var currentRockMaxSize:Int = rocksMaxSize;
			var currentRockMinSize:Int = rocksMinSize;
			var lastSizeX:Int = 0;

			for (y in 1...currentRockSizeY+1)
			{
				var currentRockSizeX = Math.floor(Math.random()*(currentRockMaxSize - currentRockMinSize + 1) + currentRockMinSize);
				var rockOffset:Int = Math.floor(Math.random()*3); // 0 - left, 1 - center, 2 - right
				firstTopPoint += _gridSize;
				
				if (y > 1)
					lastLeftPoint += Math.round((lastSizeX - currentRockSizeX)/2);

				if (y == 1)
					rockOffset = 1;

				if (rockOffset == 0)
					lastLeftPoint -= 1;
				else if (rockOffset == 2)
					lastLeftPoint += 1;

				for ( x in 0...currentRockSizeX)
				{
					if (y*_gridSize + lastLeftPoint + x >= y*_gridSize)
					{
						var previousTile = _tileMap.tile[firstTopPoint + lastLeftPoint + x - 1];
						var currentTile = _tileMap.tile[firstTopPoint + lastLeftPoint + x];
						var nextTile = _tileMap.tile[firstTopPoint + lastLeftPoint + x + 1];

						if ((previousTile.groundType == 2 || previousTile.groundType == 0) && currentTile.groundType == 0 && nextTile.groundType == 1 || previousTile.groundType == 1 && currentTile.groundType == 0 && nextTile.groundType == 0 || currentTile.groundType == 1)
						{

						}
						else
						{
							var gridPosition = new Point(x, y);
							_tileMap.tile[firstTopPoint + lastLeftPoint + x] = new Tiles(kind, gridPosition);
						}
					}

					if (_gridSize - lastLeftPoint <= x )
						break;
				}

				currentRockMaxSize = currentRockSizeX + 3;
				currentRockMinSize = currentRockSizeX - 3;
				lastSizeX = currentRockSizeX;
			}
		}
	}

	private function generateLiquids(liquid:String, type:Int)
	{
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

			var lastLeftPoint:Int = Math.floor(Math.random()*(_gridSize - riverSize + 1));

			for ( y in 0..._gridSize)
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
					var gridPosition = new Point(x, y);
					_tileMap.tile[y*_gridSize + lastLeftPoint + x] = new Tiles(liquid, gridPosition);

					// if my point in the right end of map, we can end river or break some errors;
					if (_gridSize - lastLeftPoint <= x )
						break;
				}
			}
		}
		else
		{
			var kind:String = "water";
			var value:Int = 2;
			generateRocks(kind, value);
		}
	}

	private function fillFloor(ground:String)
	{

		for (y in 0..._gridSize)
		{
			for (x in 0..._gridSize)
			{
				var gridPosition = new Point(x, y);
				_tileMap.tile[y*_gridSize + x] = new Tiles(ground, gridPosition);
			}
			
		}

	}

	private function createLevelGroundTileLayer()
	{
		var tileSize = 64;

		var tilesBitmapData:BitmapData = Assets.getBitmapData("assets/images/ground_tile.png");
		var tilesBitmapDataRectangles = new Array();
		var tileset = new Tileset(tilesBitmapData);
		tileset.addRect(new Rectangle(0, 0, 64, 64)); //grass, earth 0
		tileset.addRect(new Rectangle(64, 0, 64, 64)); //water 1
		tileset.addRect(new Rectangle(128, 0, 64, 64)); //rocks 2
		tileset.addRect(new Rectangle(192, 0, 64, 64)); //sand 3
		tileset.addRect(new Rectangle(256, 0, 64, 64)); //desert 4

		_groundTileLayer = new Tilemap(_gridSize*tileSize, _gridSize*tileSize, tileset);
		

		for (row in 0..._gridSize)
		{
			for (cell in 0..._gridSize)
			{
				var tile = _tileMap.tile[_gridSize*row + cell];
				var tilePic = tile.groundType;
				_groundTileLayer.addTile (new Tile (tilePic, cell*tileSize, row*tileSize));
			}
		}

		addChild(_groundTileLayer);
	}

	private function createCharacterLayer()
	{
		var newChar = new SceneCharacterActor(this, "assets/images/char.png");
		//addChild(newChar);
		_entities.push(newChar);
	}

	private function onEnterFrame(e:Event)
	{
		_userInterface.update();
		for (entity in _entities)
			entity.update();
	}

	public function getUserInterface():Sprite
	{
		return _userInterface;
	}

	public function getTileMap():Array<Tiles>
	{
		return _tileMap.tile;
	}

	public function getGridSize():Int
	{
		return _gridSize;
	}

	private function onScroll(e:MouseEvent)
	{
		if (e.delta > 0)
       	{	
       		this.scaleX += 0.1;
       		this.scaleY += 0.1;
       	}
    	else if (e.delta < 0)
    	{
    		if (this.scaleX >= 0.2)
    		{
    			this.scaleX -= 0.1;
        		this.scaleY -= 0.1;
    		}        	
    	}
	}

	private function onKeyUp(e:KeyboardEvent)
	{
		/*
		if (e.keyCode == 87) //w
			//_moveSceneUp = false;

		if (e.keyCode == 65) //a
			//_moveSceneLeft = false;

		if (e.keyCode == 68) //d
			//_moveSceneRight = false;

		if (e.keyCode == 83) //s
			//_moveSceneDown = false;
		*/
	}

	private function onKeyDown(e:KeyboardEvent)
	{
		if (e.keyCode == 87) //w
		{
			this.y += 50/root.scaleX;
		}
		else if (e.keyCode == 65) //a
		{
			this.x += 50/root.scaleX;
		}
		else if (e.keyCode == 68) //d
		{
			this.x -= 50/root.scaleX;
		}
		else if (e.keyCode == 83) //s
		{
			this.y -= 50/root.scaleX;
		}


	}


	
}