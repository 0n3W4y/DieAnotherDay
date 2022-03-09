package;

import openfl.Vector;
import Coordinates;

import openfl.events.MouseEvent;
import openfl.Assets;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.Lib;
import openfl.display.Sprite;

class PlayingScene extends Sprite
{

	public var isOnScreen:Bool = false;
	public var id:String;


	private var _entitySystem:EntitySystem;
	private var _sceneSystem:SceneSystem;
	
	private var _cols:Int; //x
	private var _rows:Int; //y
	private var _gridFullSize:Int;

	private static var _TILESIZE:Int = 32;

	//tile indexes
	private var _groundTileIndexes:Vector<Array<Int>>;

	//tick control;
	private var _lastTick:Int = 0;
	private var _tickFps:Int;
	private var _timeRatio:Int = 1;
	private var _onPause:Bool = false;

	//layers
	private var _groundTileLayer:Tilemap;
	private var _aboveTileLayer:Tilemap;
	private var _efectsTileLayer:Tilemap;
	private var _charactersTilemap:Tilemap;

	//vectors
	private var _humanoidEntities:Vector<Entity>;
	private var _animalEntities:Vector<Entity>;
	private var _plantEntities:Vector<Entity>;
	private var _gridTileMap:Vector<GameTile>; //logic map;

	//moveScene
	private var _moveRight:Bool = false;
	private var _moveLeft:Bool = false;
	private var _moveUp:Bool = false;
	private var _moveDown:Bool = false;
	private var _dxW:Float; // delta, scene minus current vision frame;
	private var _dxH:Float;
	private var _stageWidth:Int;
	private var _stageHeight:Int;

	//render
	private var _lastSceneX:Float = 0.0;
	private var _lastSceneY:Float = 0.0;
	private var _tilesRenderX:Int;
	private var _tilesRenderY:Int;
	private var _tilesRenderStepX:Int;
	private var _tilesRenderStepY:Int;
	private var _leftTopTile:Coordinates;
	private var _isScaled:Bool = false;
	private var _renderSquareTile:Int = 5; // square 10x10 for render;
	private var _renderSquareArray:Array<Array<Int>> = new Array();



	public function new(sceneSystem:SceneSystem, fps:Int, id:String):Void
	{
		super();
		_sceneSystem = sceneSystem;
		this.id = id;
		_cols = 100;
		_rows = 100;
		_gridFullSize = _cols*_rows;
		_gridTileMap = new Vector(_gridFullSize);
		_humanoidEntities = new Vector(0);
		_animalEntities = new Vector(0);
		_plantEntities = new Vector(0);

		_entitySystem = sceneSystem.getGame().getEntitySystem();

		_stageWidth = Lib.current.stage.stageWidth;
		_stageHeight = Lib.current.stage.stageHeight;

		_tilesRenderX = Math.round(_stageWidth/_TILESIZE);
		_tilesRenderY = Math.round(_stageHeight/_TILESIZE);
		_tilesRenderStepX = Math.round(_tilesRenderX/_renderSquareTile); // how much iteration we need to do in render;
		_tilesRenderStepY = Math.round(_tilesRenderY/_renderSquareTile); // how much iteration we need to do in render;

		_tickFps = Math.round(1/fps * 1000);
	}

	public function init():Void
	{
		// for first step of generation we need to fill floor,
		// then we need to generate liquids, all next functions overwriting who called first
		// so at the end we generate rocks;


		// импортим атлас, заполняем массив индексов для тайлов.
		createGroundTileLayer(); 
		createAboveTileLayer(); //rocks; trees, bushes, grass;walls, beds, and other;
		//createEffectsTileLayer(); //fire, blood, snow, other;
		//createCharacterTiles(); .. all characters, robots, animals, and other;
		//need to create ammunition, dress, weapons, other;


		// создаем логические тайлы
		fillFloorGridMap("Earth");

		generateLake(1, "Water");
		generateVerticalLineRiver(1, "Water");
		generateSolid(1, "Rock", 10, 10);
		generateSolid(1, "Sandstone", 10, 10);
		generateSolid(1, "Marble", 10, 10);
		generateSolid(1, "Granite", 10, 10);
		//generateHorizontalLineRiver();
		//generateAngularRiver();

		// Анализ и распределение индексов тайлов. works only with Abovelayer
		spreadTileIndexes();

		//заполняем нинжий слой тайлами, и скрываем их все.
		fillGroundLayerWithTiles();

		// распеределние Индексов для рендера
		spreadRenderIndexes();

		//переставляем сцену в центр камеры
		moveUItoCenter();

		// открываем квадратные зоны с тайлами, которые попали в видимость
		preStartRender();

		// добавляем ввод данных от юзера
		addInputs();

		//необходимо для правлиьного скейлинга.
		_dxW = -this.width + _stageWidth;
		_dxH = -this.height + _stageHeight;

		// запускаем логику
		addEventListener (Event.ENTER_FRAME, onEnterFrame);

	}

	private function onEnterFrame(e:Event):Void
	{
		var currentTick:Int = Lib.getTimer();
		var dx:Int = (currentTick - _lastTick);

		//global Fps Counter;

		_sceneSystem.getUserInterface().updateGlobalFps(dx);
		render();

		// protection for jumping in time;
		if (dx > _tickFps*2 || dx <= 0)
		{
			dx = _tickFps;
		}

		serviceUpdate(dx);

		if (dx >= _tickFps)
		{
			dx *= _timeRatio;
			if(!_onPause)
				update(dx);

			_lastTick = currentTick;
			
		}	
	}

	private function serviceUpdate(time:Int):Void
	{
		sceneMoving(time);
	}

	private function createCharacter(x:Int, y:Int)
	{
		/*
		var entitySystem = _sceneSystem.getGame().getEntitySystem();
		var character = entitySystem.createEntity("Human", ["Move", "Fight"]);
		var tile:Tile = new Tile(1, x, y);
		_charactersTilemap.addTile(tile);
		var index:Int = _charactersTilemap.getTileIndex(tile);
		character.init(index);
		var comp:Dynamic = character.getComponent("Move");
		comp.speed = 1 + Math.random()*5;
		comp.x = x;
		comp.y = y;
		character.setComponent("Move", comp);

		var aliveEntities:Vector<Entity> = _humanoidEntities[0];
		var arrayIndex:Int = aliveEntities.length;
		if (aliveEntities[0] == null)
			arrayIndex = 0;

		aliveEntities.set(arrayIndex, character);
		*/
	}

	private function createPlant(x:Int, y:Int, index:Int, tile:Int, tType:String):Void
	{
		var type:String = tType;
		var year:Int = Math.floor(Math.random()*100); //  agelimit = 100;
		var growSpeed:Float = 1;
		if (tType == "Raspberries")
			growSpeed = 4;

		var result:Entity = _entitySystem.createEntity(type);

		var component:Dynamic = _entitySystem.createComponent(result, "LifeCircle");
		component.initialize(year, 0, 0, growSpeed, 100, false);
		result.addComponent(component);

		component = _entitySystem.createComponent(result, "Draw");
		component.initialize(index, tile);
		result.addComponent(component);

		var arrayIndex:Int = _plantEntities.length;
		_plantEntities.set(arrayIndex, result);
	}

	private function addInputs():Void
	{
		//addEventListener (MouseEvent.MOUSE_WHEEL, onScroll);
		addEventListener (MouseEvent.CLICK, onMouseClick);
		addEventListener (MouseEvent.MOUSE_MOVE, moveScene);
	}

	private function onMouseClick(e:MouseEvent):Void
	{
		var x:Int = Math.round(e.localX/_TILESIZE);
		var y:Int = Math.round(e.localY/_TILESIZE);

		var result:Entity;


	}

	public function moveUItoCenter():Void
	{
		var x:Float = (this.width - _stageWidth)/2;
		var y:Float = (this.height - _stageHeight)/2;
		this.x -= x;
		this.y -= y;
		_lastSceneX = this.x;
		_lastSceneY = this.y;
	}

	private function fillFloorGridMap(floorName:String):Void
	{	
		for (y in 0..._rows)
		{
			for (x in 0..._cols)
			{
				var tile:GameTile = new GameTile( new Coordinates(x, y), floorName, 5);

				var tileCover:Int = tile.coverType;
				var randomNum:Int = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				var tileIndex:Array<Int> = _groundTileIndexes[tileCover];
				var tilePic:Int = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[y*_rows + x] = tile;
			}		
		}
	}

	private function generateLake(value:Int, kind:String, height:Int = 0, width:Int = 0, minimumLakeWidth:Int = 5, maximumLakeOffset:Int = 3):Void
	{
		if (value <= 0)
		{
			return;
		}
		var currentCoverType:String = kind;
		var lakeHeight:Int = height;
		var lakeWidth:Int = width;
		var minLakeWidth:Int = minimumLakeWidth;
		var lakeOffset:Int = maximumLakeOffset;
		var coverType:Int = 2;

		// lava and water;
		if (kind == "Water")
		{
			currentCoverType = "Shallow";
			coverType = 0;
		}
		else if ( kind == "Lava")
		{
			currentCoverType = "Magma";
			coverType = 1;
		}
		else
		{

		}

		if (height == 0 || width == 0)
		{
			lakeHeight = Math.round(_rows / (value*4)); // 25% of all map - is max;
			lakeWidth = Math.round(_cols / (value*4)); 
		}

		for ( i in 0...value)
		{
			var leftPoint = Math.floor(Math.random()*(_cols - lakeWidth/2)); // если озеро уйдет за пределы сетки. то хотя бы половина останется.
			var topPoint = Math.floor(Math.random()*(_rows - lakeHeight/2));
			var lastLakeWidth = 0;

			for (j in 0...lakeHeight)
			{
				var currentLakeOffset:Int = Math.floor(Math.random()*(lakeOffset + 1));
				var directionLakeOffset:Int = Math.floor(-1 + Math.random()*3); // -1 - left, 0 - center, 1 - right;
				var currentLakeWidth:Int = Math.floor(lastLakeWidth + Math.random()*(lakeWidth - lastLakeWidth + 1));

				if (j != 0)
				{
					var difWidth:Int = Math.round(lastLakeWidth/2 - currentLakeWidth/2);
					leftPoint += difWidth;
					leftPoint += currentLakeOffset*directionLakeOffset;
					topPoint++;
				}

				lastLakeWidth = currentLakeWidth;

				for (k in 0...currentLakeWidth)
				{
					var x:Int = leftPoint + k;
					var y:Int = topPoint;

					if (y >= _rows)
					{
						topPoint = 0;
						y = 0;
					}

					if ( x < 0 )
					{
						x = _cols + k;
					}

					if (x >= _cols && topPoint == _rows - 1)
					{
						y = 0;
						x = x - _cols;
					}
					
					var tile:GameTile = new GameTile( new Coordinates(x, y), kind, 5);

					var tileCover:Int = tile.coverType;
					var randomNum:Int = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
					var tileIndex:Array<Int> = _groundTileIndexes[tileCover];
					var tilePic:Int = tileIndex[randomNum];

					tile.groundTile = tilePic;
					_gridTileMap[y*_rows + x] = tile;

					createFloorAroundTile(tile, currentCoverType);

				}
			}
		}

	}

	private function generateVerticalLineRiver(value:Int, kind:String, width:Int = 0, minimumRiverWidth:Int = 3, maximumRiverOffset:Int = 1):Void
	{
		var riverWidth:Int = width;
		var minRiverWidth:Int = minimumRiverWidth;
		var riverOffset:Int = maximumRiverOffset;
		var currentCoverType:String;
		var coverType:Int;
		var gridSize:Int = _cols * _rows;

		if (width == 0 || minimumRiverWidth == 0)
		{
			riverWidth = Math.round(_cols / (value*10)); //max 10% of map width;
			minRiverWidth = Math.ceil(riverWidth/2); 
		}

		// lava and water;
		if (kind == "Water")
		{
			currentCoverType = "Shallow";
			coverType = 0;
		}
		else
		{
			currentCoverType = "Magma";
			coverType = 1;
		}

		for ( i in 0...value)
		{
			var leftPoint = Math.floor(Math.random()*(_cols - riverWidth/2));
			var lastRiverWidth:Int = riverWidth;

			for (j in 0..._rows)
			{
				var currentRiverOffset:Int = Math.floor(Math.random()*(riverOffset + 1));
				var directionRiverOffset:Int = Math.floor(-1 + Math.random()*3); // -1 - left, 0 - center, 1 - right;
				var currentRiverWidth:Int = Math.floor(Math.random()*3 - 1) + lastRiverWidth;

				if (currentRiverWidth < minRiverWidth)
				{
					currentRiverWidth = minRiverWidth;
				}

				if (currentRiverWidth > riverWidth)
				{
					currentRiverWidth = riverWidth;
				}
				

				if (j != 0)
				{
					var difWidth:Int = Math.round(lastRiverWidth/2 - currentRiverWidth/2);
					leftPoint += difWidth;
					leftPoint += currentRiverOffset*directionRiverOffset;						
				}

				lastRiverWidth = currentRiverWidth;
				

				for (k in 0...currentRiverWidth)
				{
					var x:Int = leftPoint + k;
					var y:Int = j;

					if (  x < 0 || x >= _cols)
					{
						continue;
					}

					var tile:GameTile = new GameTile( new Coordinates(x, y), kind, 5);

					var tileCover:Int = tile.coverType;
					var randomNum:Int = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
					var tileIndex:Array<Int> = _groundTileIndexes[tileCover];
					var tilePic:Int = tileIndex[randomNum];

					tile.groundTile = tilePic;
					_gridTileMap[y*_rows + x] = tile;

					createFloorAroundTile(tile, currentCoverType);

				}
			}
		}
	}

	private function generateSolid(value:Int, kind:String, width:Int = 0, height:Int = 0, offset:Int = 1, difference:Int = 2):Void
	{
		var solidWidth:Int = width;
		var solidHeight:Int = height;
		var solidOffset:Int = offset;
		var minDifference:Int = difference;

		if (solidWidth == 0 || solidHeight == 0)
		{
			solidWidth = Math.round(_cols / (value*4)); //25% of map;
			solidHeight = Math.round(_rows / (value*4));
		}

		for ( i in 0...value)
		{
			var leftPoint = Math.floor(Math.random()*(_cols - solidWidth/2)); 
			var topPoint = Math.floor(Math.random()*(_rows - solidHeight/2));
			var lastSolidWidth = 0;

			for (j in 0...solidHeight)
			{
				var currentSolidOffset:Int = Math.floor(Math.random()*(solidOffset + 1));
				var directionSolidOffset:Int = Math.floor(-1 + Math.random()*3); // -1 - left, 0 - center, 1 - right;
				var currentSolidWidth:Int = Math.floor(Math.random()*solidWidth + 1);

				if (j != 0)
				{
					currentSolidWidth = Math.floor(Math.random()*(difference*2 + 1) - difference) + lastSolidWidth;
					var difWidth:Int = Math.round(lastSolidWidth/2 - currentSolidWidth/2);
					leftPoint += difWidth;
					leftPoint += currentSolidOffset*directionSolidOffset;
					topPoint++;
				}

				lastSolidWidth = currentSolidWidth;

				for (k in 0...currentSolidWidth)
				{
					var x:Int = leftPoint + k;
					var y:Int = topPoint;

					if (y >= _rows)
					{
						topPoint = 0;
						y = 0;
					}

					if ( x < 0 )
					{
						x = -x;
					}

					if (x >= _cols && topPoint == _rows - 1)
					{
						y = 0;
						x = x - _cols;
					}

					
					var tile:GameTile = new GameTile( new Coordinates(x, y), kind, 5);

					var tileCover:Int = tile.coverType;
					var randomNum:Int = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
					var tileIndex:Array<Int> = _groundTileIndexes[tileCover];
					var tilePic:Int = tileIndex[randomNum];

					tile.groundTile = tilePic;
					tile.groundType = 1; // cubic type, we r create a rock, it can be mine;
					_gridTileMap[y*_rows + x] = tile;

					//here we need to create Entity(Rock);

					createFloorAroundTile(tile, kind);
				}
			}
		}
	}


	private function generateAngularRiver():Void
	{
		//for future
	}

	private function spreadTileIndexes():Void
	{
		for (y in 0..._rows)
		{
			for (x in 0..._cols)
			{
				var coordIndex:Int = y*_rows + x;
				var tile:GameTile = _gridTileMap[y*_rows + x];

				if (tile.groundType == 1)
				{
					var checkedTiles:Vector<Int> = checkClosestBlockTypeTiles(tile);
					var checkedTilesArray:Array<Int> = new Array();
					for (i in 0...checkedTiles.length)
					{
						 checkedTilesArray.push(checkedTiles[i]);
					}

					//top-left-right-bottom;

				if (compareArrays(checkedTilesArray, [0,0,0,0])) // index 0 - alone;
					{
						_gridTileMap[coordIndex].setIndex(0);
					}
				else if (compareArrays(checkedTilesArray, [0,0,0,1])) //index 11 - alone-top
					{
						_gridTileMap[coordIndex].setIndex(11);
					}
				else if (compareArrays(checkedTilesArray, [0,0,1,0])) //index 12 - alone-right
					{
						_gridTileMap[coordIndex].setIndex(12);
					}
				else if (compareArrays(checkedTilesArray, [0,1,0,0])) //index 10 - alone-left
					{
						_gridTileMap[coordIndex].setIndex(10);
					}
				else if (compareArrays(checkedTilesArray, [1,0,0,0])) //index 13 - alone-bot
					{
						_gridTileMap[coordIndex].setIndex(13);
					}
				else if (compareArrays(checkedTilesArray, [0,0,1,1])) // index 1 - top-left;
					{
						_gridTileMap[coordIndex].setIndex(1);
					}
				else if (compareArrays(checkedTilesArray, [0,1,0,1])) //index 3 - top-right;
					{
						_gridTileMap[coordIndex].setIndex(3);
					}
				else if (compareArrays(checkedTilesArray, [1,0,0,1])) //index 14 - vertical
					{
						_gridTileMap[coordIndex].setIndex(14);
					}
				else if (compareArrays(checkedTilesArray, [0,1,1,1])) // index 2 - top;
					{
						_gridTileMap[coordIndex].setIndex(2);
					}
				else if (compareArrays(checkedTilesArray, [1,0,1,1])) //index 4 - left;
					{
						_gridTileMap[coordIndex].setIndex(4);
					}
				else if (compareArrays(checkedTilesArray, [1,1,1,1])) //index 5 - middle;
					{
						_gridTileMap[coordIndex].setIndex(5);
					}
				else if (compareArrays(checkedTilesArray, [0,1,1,0])) //index 15 - horizontal
					{
						_gridTileMap[coordIndex].setIndex(15);
					}
				else if (compareArrays(checkedTilesArray, [1,1,0,0])) //index 9 - bot-right;
					{
						_gridTileMap[coordIndex].setIndex(9);
					}
				else if (compareArrays(checkedTilesArray, [1,1,1,0])) //index 8 - bot;
					{
						_gridTileMap[coordIndex].setIndex(8);
					}
				else if (compareArrays(checkedTilesArray, [1,0,1,0])) //index 7 - bot-left;
					{
						_gridTileMap[coordIndex].setIndex(7);
					}
				else if (compareArrays(checkedTilesArray, [1,1,0,1])) // index 6 - right;
					{
						_gridTileMap[coordIndex].setIndex(6);
					}

				}
			}
		}
	}

	private function compareArrays(arr1:Array<Int>, arr2:Array<Int>):Bool
	{
		for (i in 0...arr1.length)
		{
			if (arr1[i] != arr2[i])
				return false;
		}

		return true;
	}

	private function checkClosestBlockTypeTiles(tile:GameTile):Vector<Int>
	{
		var tileX:Int = tile.getCoordinates().x;
		var tileY:Int = tile.getCoordinates().y;
		var result:Vector<Int> = new Vector(4);
		var indexCoords:Int;

		indexCoords = (tileY - 1) * _rows + tileX;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var topTile:GameTile = _gridTileMap[indexCoords];
			result.set(0, topTile.groundType);
		}
		else
			result.set(0, 0);

		indexCoords = tileY * _rows + tileX - 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var leftTile:GameTile = _gridTileMap[indexCoords];
			result.set(1, leftTile.groundType);

		}
		else
			result.set(1, 0);

		indexCoords = tileY * _rows + tileX + 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var rightTile:GameTile = _gridTileMap[indexCoords];
			result.set(2, rightTile.groundType);
		}
		else
			result.set(2, 0);

		indexCoords = (tileY + 1) * _rows + tileX;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var bottomTile:GameTile = _gridTileMap[indexCoords];
			result.set(3, bottomTile.groundType);
		}
		else
			result.set(3, 0);

		return result;

	}

	private function spreadRenderIndexes()
	{
		var renderIndexCols:Int = 0;
		var renderIndexRows:Int = 0;
		var yRatio:Int = 0;
		var xRatio:Int = 0;
		var gridRatio:Int = 0;
		var arraySquareTileIndex:Int = 0;

		for (i in 0..._rows)
		{

			if (renderIndexRows == _renderSquareTile)
			{
				yRatio++;
				renderIndexRows = 0;
			}

			renderIndexRows++;
			xRatio = yRatio * gridRatio;

			if (_renderSquareArray[xRatio] == null)
				_renderSquareArray[xRatio] = new Array();

			for (j in 0..._cols)
			{
				if (renderIndexCols == _renderSquareTile)
				{
					xRatio++;
					renderIndexCols = 0;

					if (_renderSquareArray[xRatio] == null)
						_renderSquareArray[xRatio] = new Array();

				}

				var tile:GameTile = _gridTileMap[i*_rows + j];
				var groundIndex:Int = tile.groundTileLayerIndex;
				tile.renderSquareIndex = xRatio;
				_renderSquareArray[xRatio].push(groundIndex);

				renderIndexCols++;

			}

			if (gridRatio == 0)
				gridRatio = xRatio + 1;

			renderIndexCols = 0;
		}
	}

	private function createGroundTileLayer():Void 
	{
		//так как из этйо функции нет никаких присвоений кроме нижней карты тайлов, то я использовал арреи.
		//влиять будет только на загрузку уровня. Не на сам процесс игры.

		var tilesBitmapData:BitmapData = Assets.getBitmapData("assets/images/level/groundLayer.png");
		//var tilesBitmapDataRectangles = new Array();
		var tileset:Tileset = new Tileset(tilesBitmapData);

		_groundTileIndexes = new Vector(24); // 24-is a max here;
		//CoverTypes: 
		//Liquids: 0-Water, 1-Lava; 2-oil, 3-9 - empty;
		//Grounds: 10-Earth, 11-Dirt, 12-Sand, 13-Shallow, 14-19 - empty;
		//Solids: 20-Rock, 21-Marble, 22-Sandstone; 23-Granite; 24-29 - empty;
		//Other: 30-Wood; 31-39 empty;

		//water
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*0, _TILESIZE, _TILESIZE)); //water 0
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*0, _TILESIZE, _TILESIZE)); //water 1
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*0, _TILESIZE, _TILESIZE)); //water 2
		_groundTileIndexes.set(0, [0,1,2]); // # covertypes;

		//lava
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*1, _TILESIZE, _TILESIZE)); //lava 3
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*1, _TILESIZE, _TILESIZE)); //lava 4
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*1, _TILESIZE, _TILESIZE)); //lava 5
		_groundTileIndexes.set(1, [3,4,5]);

		//oil
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*2, _TILESIZE, _TILESIZE)); //oil 6
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*2, _TILESIZE, _TILESIZE)); //oil 7
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*2, _TILESIZE, _TILESIZE)); //oil 8
		_groundTileIndexes.set(2, [6,7,8]);

		//earth
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*1, _TILESIZE, _TILESIZE)); //earth 9
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*1, _TILESIZE, _TILESIZE)); //earth 10
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*1, _TILESIZE, _TILESIZE)); //earth 11
		_groundTileIndexes.set(10, [9,10,11]);

		//dirt
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*3, _TILESIZE, _TILESIZE)); //dirt 12
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*3, _TILESIZE, _TILESIZE)); //dirt 13
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*3, _TILESIZE, _TILESIZE)); //dirt 14
		_groundTileIndexes.set(11, [12,13,14]);

		//sand
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*0, _TILESIZE, _TILESIZE)); //sand 15
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*0, _TILESIZE, _TILESIZE)); //sand 16
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*0, _TILESIZE, _TILESIZE)); //sand 27
		_groundTileIndexes.set(12, [15,16,17]);

		//shallow
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*3, _TILESIZE, _TILESIZE)); //shallow 18
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*3, _TILESIZE, _TILESIZE)); //shallow 19
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*3, _TILESIZE, _TILESIZE)); //shallow 20
		_groundTileIndexes.set(13, [18,19,20]);

		//rock
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*2, _TILESIZE, _TILESIZE)); //rock 21
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*2, _TILESIZE, _TILESIZE)); //rock 22
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*2, _TILESIZE, _TILESIZE)); //rock 23
		_groundTileIndexes.set(20, [21,22,23]);

		//marble
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*5, _TILESIZE, _TILESIZE)); //marble 24
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*5, _TILESIZE, _TILESIZE)); //marble 25
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*5, _TILESIZE, _TILESIZE)); //marble 26
		_groundTileIndexes.set(21, [24,25,26]);

		//sandstone
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*4, _TILESIZE, _TILESIZE)); //sandstone 27
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*4, _TILESIZE, _TILESIZE)); //sandstone 28
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*4, _TILESIZE, _TILESIZE)); //sandstone 29
		_groundTileIndexes.set(22, [27,28,29]);

		//granite
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*4, _TILESIZE, _TILESIZE)); //granite 30
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*4, _TILESIZE, _TILESIZE)); //granite 31
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*4, _TILESIZE, _TILESIZE)); //granite 32
		_groundTileIndexes.set(23, [30,31,32]);

		
		_groundTileLayer = new Tilemap(_cols*_TILESIZE, _rows*_TILESIZE, tileset);

		addChild(_groundTileLayer);
	}

	private function createAboveTileLayer():Void
	{
		var tilesBitmapData:BitmapData = Assets.getBitmapData("assets/images/level/aboveLayer.png");
		//var tilesBitmapDataRectangles = new Array();
		var tileset:Tileset = new Tileset(tilesBitmapData);

		//1-top-left; 2-top; 3-top-right; 4-left; 5-middle; 6-right; 7-botom-left; 8-bottom; 9-bottom-right; 
		//10-aloneLeft, 11-aloneTop; 12-aloneRight 13-aloneBottom; 0-alone; 14 - vertical, 15 - horizontal;

		//rock
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*5, _TILESIZE, _TILESIZE)); //alone 0
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top-left 1
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 2
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top-right 3
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*1, _TILESIZE, _TILESIZE)); //left 4
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*1, _TILESIZE, _TILESIZE)); //middle 5
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*1, _TILESIZE, _TILESIZE)); //right 6
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*2, _TILESIZE, _TILESIZE)); //bottom-left 7
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*2, _TILESIZE, _TILESIZE)); //bottom 8
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*2, _TILESIZE, _TILESIZE)); //bottom-right 9
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*4, _TILESIZE, _TILESIZE)); //alone-left 10
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*3, _TILESIZE, _TILESIZE)); //alone-top 11
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*4, _TILESIZE, _TILESIZE)); //alone-right 12
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*5, _TILESIZE, _TILESIZE)); //alone-bottom 13
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*3, _TILESIZE, _TILESIZE)); //vertical 14
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*3, _TILESIZE, _TILESIZE)); //horizontal 15

		//marble
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*5, _TILESIZE, _TILESIZE)); //alone 16
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top-left 17
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 18
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top-right 19
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*1, _TILESIZE, _TILESIZE)); //left 20
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*1, _TILESIZE, _TILESIZE)); //middle 21
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*1, _TILESIZE, _TILESIZE)); //right 22
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*2, _TILESIZE, _TILESIZE)); //bottom-left 23
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*2, _TILESIZE, _TILESIZE)); //bottom 24
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*2, _TILESIZE, _TILESIZE)); //bottom-right 25
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*4, _TILESIZE, _TILESIZE)); //alone-left 26
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*3, _TILESIZE, _TILESIZE)); //alone-top 27
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*4, _TILESIZE, _TILESIZE)); //alone-right 28
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*5, _TILESIZE, _TILESIZE)); //alone-bottom 29
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*3, _TILESIZE, _TILESIZE)); //vertical 30
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*3, _TILESIZE, _TILESIZE)); //horizontal 31

		//Sandstone
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*11, _TILESIZE, _TILESIZE)); //alone 32
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*6, _TILESIZE, _TILESIZE)); //top-left 33
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*6, _TILESIZE, _TILESIZE)); //top 34
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*6, _TILESIZE, _TILESIZE)); //top-right 35
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*7, _TILESIZE, _TILESIZE)); //left 36
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*7, _TILESIZE, _TILESIZE)); //middle 37
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*7, _TILESIZE, _TILESIZE)); //right 38
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*8, _TILESIZE, _TILESIZE)); //bottom-left 39
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*8, _TILESIZE, _TILESIZE)); //bottom 40
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*8, _TILESIZE, _TILESIZE)); //bottom-right 41
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*10, _TILESIZE, _TILESIZE)); //alone-left 42
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*9, _TILESIZE, _TILESIZE)); //alone-top 43
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*10, _TILESIZE, _TILESIZE)); //alone-right 44
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*11, _TILESIZE, _TILESIZE)); //alone-bottom 45
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*9, _TILESIZE, _TILESIZE)); //vertical 46
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*9, _TILESIZE, _TILESIZE)); //horizontal 47

		//Granite
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*11, _TILESIZE, _TILESIZE)); //alone 48
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*6, _TILESIZE, _TILESIZE)); //top-left 49
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*6, _TILESIZE, _TILESIZE)); //top 50
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*6, _TILESIZE, _TILESIZE)); //top-right 51
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*7, _TILESIZE, _TILESIZE)); //left 52
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*7, _TILESIZE, _TILESIZE)); //middle 53
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*7, _TILESIZE, _TILESIZE)); //right 54
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*8, _TILESIZE, _TILESIZE)); //bottom-left 55
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*8, _TILESIZE, _TILESIZE)); //bottom 56
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*8, _TILESIZE, _TILESIZE)); //bottom-right 57
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*10, _TILESIZE, _TILESIZE)); //alone-left 58
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*9, _TILESIZE, _TILESIZE)); //alone-top 59
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*10, _TILESIZE, _TILESIZE)); //alone-right 60
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*11, _TILESIZE, _TILESIZE)); //alone-bottom 61
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*9, _TILESIZE, _TILESIZE)); //vertical 62
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*9, _TILESIZE, _TILESIZE)); //horizontal 63

		//grass
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*2, _TILESIZE, _TILESIZE)); // 64;
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*2, _TILESIZE, _TILESIZE)); // 65;
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*2, _TILESIZE, _TILESIZE)); // 66;

		//tree
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*1, _TILESIZE, _TILESIZE)); // phase 67;
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*0, _TILESIZE, _TILESIZE*2)); // phase 68;
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*0, _TILESIZE, _TILESIZE*2)); // phase 69;
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*0, _TILESIZE, _TILESIZE*2)); // phase 70;

		//bush
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*3, _TILESIZE, _TILESIZE)); //phase 71;
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*3, _TILESIZE, _TILESIZE)); // phase 72;
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*3, _TILESIZE, _TILESIZE)); // phase 73;
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*3, _TILESIZE, _TILESIZE)); // phase 74;

		_aboveTileLayer = new Tilemap(_cols*_TILESIZE, _rows*_TILESIZE, tileset);

		for (y in 0..._rows)
		{
			for (x in 0..._cols)
			{
				var tile:GameTile = _gridTileMap[y*_rows + x];
				var tileGroundType:Int = tile.groundType;
				var tileIndex:Int = tile.getIndex();
				var tileBlockType:Int = tile.blockType;
				var tileCoverType:Int = tile.coverType;
				var ratio:Int;

				if (tileGroundType == 1 && tileBlockType == 2)
				{
					ratio = tileCoverType - 20; //all solids starts at 20 and ends at 29; if need a walls, they r starts at 30 and end at _inf_;
					var index:Int = ratio*16 + tileIndex;
					_aboveTileLayer.addTile (new Tile (index, x*_TILESIZE, y*_TILESIZE));
				}

				if (tileGroundType == 0 && tileCoverType == 10)
				{
					var randomNum:Int = Math.floor(Math.random()*21); // -1 - nothing, 0-1 - grass, 2-3 - tree, 4 - bush
					if (randomNum >= 5 && randomNum <= 12)
					{
						var rNum:Int =  Math.floor(Math.random()*3); 
						var grassIndex:Int = rNum + 64; // 64 - 65 - 66, for 3 random tiles;
						_aboveTileLayer.addTile (new Tile (grassIndex, x*_TILESIZE, y*_TILESIZE));
					}
					else if (randomNum >= 13 && randomNum <= 19)
					{
						var treeIndex:Int = 67; // 0  phase;
						var treeTile:Tile = new Tile (treeIndex, x*_TILESIZE, y*_TILESIZE);
						_aboveTileLayer.addTile(treeTile);
						var treeTileIndex:Int = _aboveTileLayer.getTileIndex(treeTile);
						createPlant(x, y, treeTileIndex, treeIndex, "Birch");
					}

					else if (randomNum == 20)
					{
						var bushIndex:Int = 71; // 0  phase;
						var bushTile:Tile = new Tile (bushIndex, x*_TILESIZE, y*_TILESIZE);
						_aboveTileLayer.addTile(bushTile);
						var bushTileIndex:Int = _aboveTileLayer.getTileIndex(bushTile);
						createPlant(x, y, bushTileIndex, bushIndex, "Raspberries");
					}
				}

			}
		}

		addChild(_aboveTileLayer);

	}

	private function createCharacterTiles():Void
	{
		var tilesBitmapData:BitmapData = Assets.getBitmapData("assets/images/characters/actor.png");
		var tilesBitmapDataRectangles = new Array();
		var tileset:Tileset = new Tileset(tilesBitmapData);

		//mans sprites:
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 0
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 1
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 2
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 3

		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 4
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 5
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 6
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 7

		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 8
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 9
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 10
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 11

		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 12
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 13
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 14
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 15

		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 16
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 17
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 18
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 19

		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 20
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 21
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 22
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 23

		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 24
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 25
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 26
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 27

		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 28
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 29
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 30
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 31

		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 32
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 33
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 34
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 35

		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 36
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 37
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 38
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 39

		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 40
		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 41
		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 42
		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 43

		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 44
		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 45
		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 46
		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 47

		//womens sprite:

		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 48
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 49
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 50
		tileset.addRect(new Rectangle(_TILESIZE*0, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 51

		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 52
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 53
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 54
		tileset.addRect(new Rectangle(_TILESIZE*1, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 55

		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 56
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 57
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 58
		tileset.addRect(new Rectangle(_TILESIZE*2, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 59

		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 60
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 61
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 62
		tileset.addRect(new Rectangle(_TILESIZE*3, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 63

		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 64
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 65
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 66
		tileset.addRect(new Rectangle(_TILESIZE*4, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 67

		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 68
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 69
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 70
		tileset.addRect(new Rectangle(_TILESIZE*5, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 71

		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 72
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 73
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 74
		tileset.addRect(new Rectangle(_TILESIZE*6, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 75

		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 76
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 77
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 78
		tileset.addRect(new Rectangle(_TILESIZE*7, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 79

		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 80
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 81
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 82
		tileset.addRect(new Rectangle(_TILESIZE*8, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 83

		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 84
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 85
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 86
		tileset.addRect(new Rectangle(_TILESIZE*9, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 87

		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 88
		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 89
		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 90
		tileset.addRect(new Rectangle(_TILESIZE*10, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 91

		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*4, _TILESIZE, _TILESIZE)); //top 92
		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*5, _TILESIZE, _TILESIZE));//left 93
		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*6, _TILESIZE, _TILESIZE)); //right 94
		tileset.addRect(new Rectangle(_TILESIZE*11, _TILESIZE*7, _TILESIZE, _TILESIZE)); //bottom 95

		//monsters sprite:

		tileset.addRect(new Rectangle(_TILESIZE*12, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 96
		tileset.addRect(new Rectangle(_TILESIZE*12, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 97
		tileset.addRect(new Rectangle(_TILESIZE*12, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 98
		tileset.addRect(new Rectangle(_TILESIZE*12, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 99

		tileset.addRect(new Rectangle(_TILESIZE*13, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 100
		tileset.addRect(new Rectangle(_TILESIZE*13, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 101
		tileset.addRect(new Rectangle(_TILESIZE*13, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 102
		tileset.addRect(new Rectangle(_TILESIZE*13, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 103

		tileset.addRect(new Rectangle(_TILESIZE*14, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 104
		tileset.addRect(new Rectangle(_TILESIZE*14, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 105
		tileset.addRect(new Rectangle(_TILESIZE*14, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 106
		tileset.addRect(new Rectangle(_TILESIZE*14, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 107

		tileset.addRect(new Rectangle(_TILESIZE*15, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 108
		tileset.addRect(new Rectangle(_TILESIZE*15, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 109
		tileset.addRect(new Rectangle(_TILESIZE*15, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 110
		tileset.addRect(new Rectangle(_TILESIZE*15, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 111

		tileset.addRect(new Rectangle(_TILESIZE*16, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 112
		tileset.addRect(new Rectangle(_TILESIZE*16, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 113
		tileset.addRect(new Rectangle(_TILESIZE*16, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 114
		tileset.addRect(new Rectangle(_TILESIZE*16, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 115

		tileset.addRect(new Rectangle(_TILESIZE*17, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 116
		tileset.addRect(new Rectangle(_TILESIZE*17, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 117
		tileset.addRect(new Rectangle(_TILESIZE*17, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 118
		tileset.addRect(new Rectangle(_TILESIZE*17, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 119

		tileset.addRect(new Rectangle(_TILESIZE*18, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 120
		tileset.addRect(new Rectangle(_TILESIZE*18, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 121
		tileset.addRect(new Rectangle(_TILESIZE*18, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 122
		tileset.addRect(new Rectangle(_TILESIZE*18, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 123

		tileset.addRect(new Rectangle(_TILESIZE*19, _TILESIZE*0, _TILESIZE, _TILESIZE)); //top 124
		tileset.addRect(new Rectangle(_TILESIZE*19, _TILESIZE*1, _TILESIZE, _TILESIZE));//left 125
		tileset.addRect(new Rectangle(_TILESIZE*19, _TILESIZE*2, _TILESIZE, _TILESIZE)); //right 126
		tileset.addRect(new Rectangle(_TILESIZE*19, _TILESIZE*3, _TILESIZE, _TILESIZE)); //bottom 127


		_charactersTilemap = new Tilemap(_cols*_TILESIZE, _rows*_TILESIZE, tileset);
		addChild(_charactersTilemap);

		for (y in 0..._rows)
		{
			for (x in 0..._cols)
			{
				var tile:GameTile = _gridTileMap[y*_rows + x];
				var tileGroundType = tile.groundType;
				var tileCover:Int = tile.coverType;

				var randomNum:Int = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				var tileIndex:Array<Int> = _groundTileIndexes[tileCover];
				var tilePic:Int = tileIndex[randomNum];

				_groundTileLayer.addTile (new Tile (tilePic, x*_TILESIZE, y*_TILESIZE));

			}
		}

	}

	private function createFloorAroundTile(tile:GameTile, kind:String)
	{
		var y:Int = tile.getCoordinates().y;
		var x:Int = tile.getCoordinates().x;
		var tileCoverType:Int = tile.coverType;
		var tileBlockType:Int = tile.blockType;
		var tileGroundType:Int = tile.groundType;
		var indexCoords:Int;
		var currentCoverType:String = kind;
		var tile:GameTile;
		var tileCover:Int;
		var randomNum:Int;
		var tileIndex:Array<Int>;
		var tilePic:Int;

		indexCoords = y * _rows + x - 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var leftTile:GameTile = _gridTileMap[indexCoords];
			if (leftTile.coverType != tileCoverType && leftTile.blockType != 2)
			{
				tile = new GameTile(leftTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}

		indexCoords = y * _rows - _rows + x - 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var leftTopTile:GameTile = _gridTileMap[indexCoords];
			if (leftTopTile.coverType != tileCoverType && leftTopTile.blockType != 2)
				{
					tile = new GameTile(leftTopTile.getCoordinates(), currentCoverType, 5);

					tileCover = tile.coverType;
					randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
					tileIndex = _groundTileIndexes[tileCover];
					tilePic = tileIndex[randomNum];
					tile.groundTile = tilePic;

					_gridTileMap[indexCoords] = tile;
				}
		}

		indexCoords = y * _rows - _rows + x;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var topTile:GameTile = _gridTileMap[indexCoords];
			if (topTile.coverType != tileCoverType && topTile.blockType != 2)
			{
				tile = new GameTile(topTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}

		indexCoords = y * _rows - _rows + x + 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var rightTopTile:GameTile = _gridTileMap[indexCoords];
			if (rightTopTile.coverType != tileCoverType && rightTopTile.blockType != 2)
			{
				tile = new GameTile(rightTopTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}

		indexCoords = y * _rows + x + 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var rightTile:GameTile = _gridTileMap[indexCoords];
			if (rightTile.coverType != tileCoverType && rightTile.blockType != 2)
			{
				tile = new GameTile(rightTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}

		indexCoords = y * _rows + _rows + x + 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var rightBottomTile:GameTile = _gridTileMap[indexCoords];
			if (rightBottomTile.coverType != tileCoverType && rightBottomTile.blockType != 2)
			{
				tile = new GameTile(rightBottomTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}

		indexCoords = y * _rows + _rows + x;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var bottomTile:GameTile = _gridTileMap[indexCoords];
			if (bottomTile.coverType != tileCoverType && bottomTile.blockType != 2)
			{
				tile = new GameTile(bottomTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}

		indexCoords = y * _rows + _rows + x - 1;
		if (indexCoords >= 0 && indexCoords < _gridFullSize)
		{
			var leftBottomTile:GameTile = _gridTileMap[indexCoords];
			if (leftBottomTile.coverType != tileCoverType && leftBottomTile.blockType != 2)
			{
				tile = new GameTile(leftBottomTile.getCoordinates(), currentCoverType, 5);

				tileCover = tile.coverType;
				randomNum = Math.floor(Math.random()*(2 + 1)); //0, 1, 2 - cause we have 3 variants of each ground type;
				tileIndex = _groundTileIndexes[tileCover];
				tilePic = tileIndex[randomNum];
				tile.groundTile = tilePic;

				_gridTileMap[indexCoords] = tile;
			}
		}
	}

	

	

	private function update(dx:Int):Void
	{
		for (i in 0..._humanoidEntities.length)
		{
			if (_humanoidEntities[i] != null)
			{
				_humanoidEntities[i].update(dx);
				updateCharacterMap(_humanoidEntities[i]);
			}
			
		}

		for (j in 0..._animalEntities.length)
		{
			if (_animalEntities[j] != null)
			{
				_animalEntities[j].update(dx);
				updateCharacterMap(_animalEntities[j]);
			}
			
		}

		for (k in 0..._plantEntities.length)
		{
			if (_plantEntities[k] != null)
			{
				_plantEntities[k].update(dx);
				updateAboveLayer(_plantEntities[k]);
			}
			
		}
	
		_sceneSystem.getUserInterface().update(dx);
		
	}


	private function updateCharacterMap(entity:Entity)
	{
		/*
		var tile:Tile = _charactersTilemap.getTileAt(entity.getTileIndex());
		var coords:Dynamic = entity.getComponent("Move");
		tile.x = coords.x;
		tile.y = coords.y;
		_charactersTilemap.addTileAt(tile, entity.getTileIndex());
		*/

	}

	private function updateAboveLayer(entity:Entity)
	{
		var draw:Draw = entity.getComponent("Draw");
		if (draw.isTileChanged)
		{
			var tileIndex:Int = draw.tileIndex;
			var nextTile:Int = draw.currentTile;
			var tile:Tile = _aboveTileLayer.getTileAt(tileIndex);
			tile.id = nextTile;
			if (entity.race == "Tree" && 1 == draw.phaseCounter)
			{
				tile.y -= _TILESIZE;
			}
			_aboveTileLayer.addTileAt(tile, tileIndex);
			draw.isTileChanged = false;
		}
	}

	private function render():Void
	{
		var x:Float = this.x;
		var y:Float = this.y;
		var dx:Int = Math.round((x - _lastSceneX)/_TILESIZE);
		var dy:Int = Math.round((y - _lastSceneY)/_TILESIZE);
		var absDx:Float = Math.abs(dx);
		var absDy:Float = Math.abs(dy);
		var newX:Int = Math.round(-x/_TILESIZE);
		var newY:Int = Math.round(-y/_TILESIZE);

		if (_isScaled)
		{
			renderTileGroundMapOnScale(dx, dy, newX, newY);
			_isScaled = false;
			_lastSceneX = this.x;
			_lastSceneY = this.y;
			return;
		}

		if (absDx >= _renderSquareTile || absDy >= _renderSquareTile)
		{
			renderGroundTileMap(dx, dy, newX, newY);
			_lastSceneX = this.x;
			_lastSceneY = this.y;
		}
		
	}

	private function renderTileGroundMapOnScale(dx:Int, dy:Int, x:Int, y:Int):Void
	{	
		// scale up
		if (dx > 0)
		{
			for (i in 0..._tilesRenderStepY + 3)
			{
				for (j in 0..._tilesRenderStepX + 3)
				{
					var gridIndex:Int = (y - _renderSquareTile + i*_renderSquareTile)*_rows + x + j*_renderSquareTile - _renderSquareTile;
					var newX:Int = x + j*_renderSquareTile - _renderSquareTile;
					var newY:Int = (y - _renderSquareTile + i*_renderSquareTile);

					if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
					{
						var tile:GameTile = _gridTileMap[gridIndex];
						var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

						var squareArray:Array<Int> = _renderSquareArray[renderIndex];
						var renderTileRenderIndex:Int = squareArray[0];
						var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); 

						if (!currentTile.visible)
						{
							for (j in 0...squareArray.length)
							{
								renderTileRenderIndex = squareArray[j];
								currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex); // j - индекс тайла который в этом квадрате
								currentTile.visible = true;
							}
						}
					} 				
				}
			}
		}
		else
		{

		}

		
	}

	private function fillGroundLayerWithTiles():Void
	{
		for (i in 0..._rows)
		{
			for (j in 0..._cols)
			{
				var tile:GameTile = _gridTileMap[i*_rows + j];
				var tilePic:Int = tile.groundTile;
				var newTile:Tile = new Tile (tilePic, j*_TILESIZE, i*_TILESIZE);
				newTile.visible = false;
				_groundTileLayer.addTile (newTile);
				var groundIndex:Int =  _groundTileLayer.getTileIndex(newTile);
				tile.groundTileLayerIndex = groundIndex;
			}
		}
	}

	private function preStartRender():Void
	{
		var x:Int = Math.floor(-this.x/_TILESIZE);
		var y:Int = Math.floor(-this.y/_TILESIZE);

		for (i in 0..._tilesRenderStepY + 3)
		{
			for (j in 0..._tilesRenderStepX + 3)
			{
				var gridIndex:Int = (y - _renderSquareTile + i*_renderSquareTile)*_rows + x + j*_renderSquareTile - _renderSquareTile;
				var newX:Int = x + j*_renderSquareTile - _renderSquareTile;
				var newY:Int = (y - _renderSquareTile + i*_renderSquareTile);

				var tile:GameTile = _gridTileMap[gridIndex];
				var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

				for (k in 0..._renderSquareArray[renderIndex].length)
				{
					var tileRenderIndex:Int = _renderSquareArray[renderIndex][k];
					var currentTile:Tile = _groundTileLayer.getTileAt(tileRenderIndex); // k - индекс тайла который в этом квадрате
					currentTile.visible = true;
				}				
			}
		}
	}

	private function renderGroundTileMap(dx:Int, dy:Int, x:Int, y:Int):Void
	{
		if (dy > 0)
		{
			for (i in 0..._tilesRenderStepX + 3) 
			{
				// добавляем зоны сверху.
				var gridIndex:Int = (y - _renderSquareTile*2)*_rows + x  + i*_renderSquareTile;
				var newX:Int = x  + i*_renderSquareTile;
				var newY:Int = y - _renderSquareTile;

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{

					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); 

					if (!currentTile.visible)
					{
						for (j in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[j];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex); // j - индекс тайла который в этом квадрате
							currentTile.visible = true;
						}
					}


				}
				// убираем зоны снизу
				gridIndex = (y + _tilesRenderY + _renderSquareTile*2)*_rows + x + i*_renderSquareTile;
				newX = x + i*_renderSquareTile;
				newY = (y + _tilesRenderY + _renderSquareTile*2);

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{
					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); // k - индекс тайла который в этом квадрате

					if(currentTile.visible)
					{
						for (k in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[k];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex);
							currentTile.visible = false;
						}
					}
				}
			}
		}
		else
		{
			for (i in 0..._tilesRenderStepX + 3) 
			{
				// добавляем зоны снизу.
				var gridIndex = (y + _tilesRenderY + _renderSquareTile)*_rows + x + i*_renderSquareTile - _renderSquareTile;
				var	newX:Int = x + i*_renderSquareTile - _renderSquareTile;
				var	newY:Int = (y + _tilesRenderY + _renderSquareTile);

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{

					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); 

					if (!currentTile.visible)
					{
						for (j in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[j];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex); // j - индекс тайла который в этом квадрате
							currentTile.visible = true;
						}
					}


				}
				// убираем зоны сверху
				gridIndex = (y - _renderSquareTile*3)*_rows + x  + i*_renderSquareTile;
				newX = x  + i*_renderSquareTile;
				newY = y - _renderSquareTile*2;

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{
					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); // k - индекс тайла который в этом квадрате

					if(currentTile.visible)
					{
						for (k in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[k];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex);
							currentTile.visible = false;
						}
					}
				}
			}
		}


		if (dx > 0)
		{
			
			for (i in 0..._tilesRenderStepY + 3) 
			{
				// отображаем зоны слева
				var gridIndex:Int = (y + i*_renderSquareTile - _renderSquareTile*2)*_rows + x - _renderSquareTile;
				var newX:Int = x - _renderSquareTile;
				var newY:Int = (y + i*_renderSquareTile);

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{

					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); 

					if (!currentTile.visible)
					{
						for (j in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[j];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex); // j - индекс тайла который в этом квадрате
							currentTile.visible = true;
						}
					}


				}
				// убираем зоны справа
				gridIndex = (y + i*_renderSquareTile - _renderSquareTile)*_rows + x + _tilesRenderX + _renderSquareTile*2;
				newX = x + _tilesRenderX + _renderSquareTile*2;
				newY = (y + i*_renderSquareTile);

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{
					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); // k - индекс тайла который в этом квадрате

					if(currentTile.visible)
					{
						for (k in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[k];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex);
							currentTile.visible = false;
						}
					}
				}
			}

		}
		else
		{
			
			for (i in 0..._tilesRenderStepY + 3) 
			{
				// отображаем зоны справа
				var gridIndex = (y + i*_renderSquareTile - _renderSquareTile*2)*_rows + x + _tilesRenderX + _renderSquareTile;
				var newX:Int = x + _tilesRenderX + _renderSquareTile;
				var newY:Int = (y + i*_renderSquareTile);

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{

					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); 

					if (!currentTile.visible)
					{
						for (j in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[j];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex); // j - индекс тайла который в этом квадрате
							currentTile.visible = true;
						}
					}


				}
				// убираем зоны слева
				gridIndex = (y + i*_renderSquareTile - _renderSquareTile)*_rows + x - _renderSquareTile*2;
				newX = x - _renderSquareTile*2;
				newY = (y + i*_renderSquareTile);

				if (gridIndex < _gridFullSize && gridIndex < (newY + 1)*_rows && gridIndex >= 0)
				{
					var tile:GameTile = _gridTileMap[gridIndex];
					var renderIndex:Int = tile.renderSquareIndex; // находим к какому из квадратов принадлежит данный тайл

					var squareArray:Array<Int> = _renderSquareArray[renderIndex];
					var renderTileRenderIndex:Int = squareArray[0];
					var currentTile:Tile = _groundTileLayer.getTileAt(renderTileRenderIndex); // k - индекс тайла который в этом квадрате

					if(currentTile.visible)
					{
						for (k in 0...squareArray.length)
						{
							renderTileRenderIndex = squareArray[k];
							currentTile = _groundTileLayer.getTileAt(renderTileRenderIndex);
							currentTile.visible = false;
						}
					}
				}
			}
		}
	}

	public function getCharacterTileMap():Tilemap
	{
		return _charactersTilemap;
	}

	public function setTimeRatio(value:Int):Void
	{
		if (value == 0)
			_timeRatio = 1;
		else if (value == -1)
		{
			if (_timeRatio != 1)
				_timeRatio = Math.round(_timeRatio/2);
		}
		else
		{
			if (_timeRatio < 16)
				_timeRatio *= 2;
		}
			

	}

	public function pause():Void
	{
		if (_onPause)
			_onPause = false;
		else
			_onPause = true;

	}

	private function onScroll(e:MouseEvent):Void
	{
		var lastDxW = _dxW;
       	var lastDxH = _dxH;

		if (e.delta > 0)
       	{	
       		this.scaleX += 0.1;
       		this.scaleY += 0.1;
       		_dxW = -this.width + _stageWidth;
       		_dxH = -this.height + _stageHeight;
       		lastDxW = (lastDxW - _dxW)/2;
       		lastDxH = (lastDxH - _dxH)/2;
       		this.x -= lastDxW;
       		this.y -= lastDxH;
       		_tilesRenderStepX = Math.round(_tilesRenderStepX/this.scaleX);
			_tilesRenderStepY = Math.round(_tilesRenderStepY/this.scaleY);
			_tilesRenderX = Math.round(_tilesRenderX/this.scaleX);
			_tilesRenderY = Math.round(_tilesRenderY/this.scaleY);
			_isScaled = true;
       		
       	}
    	else if (e.delta < 0)
    	{
    		if (this.scaleX >= 0.4)
    		{
    			this.scaleX -= 0.2;
        		this.scaleY -= 0.2;
       			_dxW = -this.width + _stageWidth;
       			_dxH = -this.height + _stageHeight;
       			lastDxW = (lastDxW - _dxW)/2;
       			lastDxH = (lastDxH - _dxH)/2;
        		this.x -= lastDxW;
        		this.y -= lastDxH;
        		_tilesRenderStepX = Math.round(_tilesRenderStepX/this.scaleX);
				_tilesRenderStepY = Math.round(_tilesRenderStepY/this.scaleY);
				_tilesRenderX = Math.round(_tilesRenderX/this.scaleX);
				_tilesRenderY = Math.round(_tilesRenderY/this.scaleY);
				
				_isScaled = true;
    		}        	
    	}
	}

	public function unPause():Void
	{
		if (_onPause)
			_onPause = false;
	}

	public function getTimeRatio():Int
	{
		return _timeRatio;
	}

	private function sceneMoving(time:Int):Void
	{
		
		if (_moveRight)
		{	
			if (this.x < 0)
				this.x += 0.4 * time * this.scaleX;
		}

		if (_moveLeft)
		{
			if (this.x > _dxW)
			this.x -= 0.4 * time * this.scaleX;
		}

		if (_moveUp)
		{
			if (this.y > _dxH)
				this.y -= 0.4 * time * this.scaleY;
		}

		if (_moveDown)
		{	
			if (this.y < 0)
				this.y += 0.4 * time * this.scaleY;
		}


	}

	

	private function moveScene(e:MouseEvent):Void
	{
		if (e.stageX <= 2)
			_moveRight = true;
		else
			_moveRight = false;

		if (e.stageX >= Lib.current.stage.stageWidth - 2)
			_moveLeft = true;
		else
			_moveLeft = false;

		if (e.stageY <= 2)
			_moveDown = true;
		else
			_moveDown = false;

		if (e.stageY >= Lib.current.stage.stageHeight - 2)
			_moveUp = true;
		else
			_moveUp = false;
	}
}