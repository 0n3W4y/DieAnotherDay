package;

import openfl.display.Sprite;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.geom.Point;
import openfl.events.MouseEvent;

import pathfinder.Pathfinder;
import pathfinder.Coordinate;
import pathfinder.EHeuristic;
import pathfinder.Node;


class SceneCharacterActor extends Sprite
{	
	private var _myScene:PlayingScene;
	private var _speed:Float;
	private var _position:Point;
	private var _tilePosition:Point;
	private var _gridSize:Int;

	private var _path = new Array();
	private var _isReachDestinationPoint:Bool = true;

	private var _image:Bitmap;
	private var _charFrame:Bitmap;
	private var _pathFinderMap:PathfinderMap;
	private var _pathFinder:Pathfinder;
	private var _destinationDot:Sprite;

	private var _isBusy:Bool = false;
	private var _isHaveaFrame:Bool = false;


	public function new(scene, imagePath:String)
	{
		super();
		var _myScene = scene;
		_image = new Bitmap (Assets.getBitmapData (imagePath));
		_image.smoothing = true;
		addChild (_image);
		_image.x = 0;
		_image.y = 0;
		_gridSize = _myScene.getGridSize();

		_position = new Point(_image.x, _image.y);
		_tilePosition = new Point(Math.floor(_image.x/32), Math.floor(_image.y/32));

		_speed = 4.0;

		createPathFinder();

		addEventListener( MouseEvent.CLICK, onClick );

		//isTileWalkable(0,0);

	}

	public function update()
	{
		if (!_isBusy)
		{
			move();
		}

		if (_isReachDestinationPoint)
		{
			generateRnadomPoint();
			if (_destinationDot != null)
			{
				removeChild(_destinationDot);
			}
		}

		if (_isHaveaFrame)
		{
			updateCharFrame();
		}
	}

	private function updateCharFrame()
	{
		_charFrame.x = _image.x;
		_charFrame.y = _image.y;
	}

	private function createPath(x:Int, y:Int)
	{
		_isBusy = true;
		var tilePosX:Int = Math.round(_tilePosition.x);
		var tilePosY:Int =  Math.round(_tilePosition.y);
		var l_startNode = new Coordinate( tilePosX, tilePosY ); //  The starting node
		var l_destinationNode = new Coordinate( x, y ); // The destination node
		var l_heuristicType = EHeuristic.PRODUCT; // The method of A Star used
		var l_isDiagonalEnabled = true; // Set to false to ensure only up, left, down, right movements are allowed
		var l_isMapDynamic = false; // Set to true to force fresh lookups from IMap.isWalkable() for each node's isWalkable property (e.g. for a dynamically changing map)
		var l_path = _pathFinder.createPath( l_startNode, l_destinationNode, l_heuristicType, l_isDiagonalEnabled, l_isMapDynamic );

		for ( i in l_path )
		{
			_path.push(i);
		}

		_isBusy = false;
		_isReachDestinationPoint = false;

	}

	private function move()
	{
		
		if (_path.length > 0)
		{
			var nextPosition = _path[0];
			var directionX = 0;
			var directionY = 0;

			if (_tilePosition.x - nextPosition.x < 0)
				directionX = 1;
			else if (_tilePosition.x - nextPosition.x > 0)
				directionX = -1;

			if (_tilePosition.y - nextPosition.y < 0)
				directionY = 1;
			else if (_tilePosition.y - nextPosition.y > 0)
				directionY = -1;

			_image.x += _speed*directionX;
			_image.y += _speed*directionY;

			_position = new Point(_image.x, _image.y);
			_tilePosition = new Point(Math.floor(_image.x/32), Math.floor(_image.y/32)); //32 - tilesize;

			if (_tilePosition.x == nextPosition.x && _tilePosition.y == nextPosition.y)
				_path.splice(0, 1);

		}
		else
			_isReachDestinationPoint = true;

		
	}

	private function createPathFinder()
	{
		_pathFinderMap = new PathfinderMap(_gridSize, _gridSize, this);
		_pathFinder = new Pathfinder(_pathFinderMap);
	}

	private function generateRnadomPoint()
	{
		var destinationX:Int = Math.floor(Math.random()*(_gridSize +1));
		var destinationY:Int = Math.floor(Math.random()*(_gridSize +1));



		createPath(destinationX, destinationY);
	}

	public function isTileWalkable(x:Int, y:Int):Bool
	{
		return true;
	}

	public function onClick(e:MouseEvent)
	{
		if (!_isHaveaFrame)
		{
			_charFrame = new Bitmap (Assets.getBitmapData ("assets/images/char_frame.png"));
			addChild (_charFrame);
			updateCharFrame();
			_isHaveaFrame = true;

			if (!_isReachDestinationPoint)
			{
				var destinationTile = _path[_path.length-1];
				//var tileSize = _myScene.getTileSize();
				var tileSize = 32;
				var dotPositionX = destinationTile.x*tileSize;
				var dotPositionY = destinationTile.y*tileSize;

				_destinationDot = new Sprite();
				_destinationDot.graphics.beginFill(0xFF0000);
				_destinationDot.graphics.drawRect(0,0,10,10);
				_destinationDot.graphics.endFill();

				_destinationDot.x = dotPositionX + tileSize/2;
				_destinationDot.y = dotPositionY + tileSize/2;

				addChild(_destinationDot);
			}

		}
		else
		{
			removeChild(_charFrame);
			_isHaveaFrame = false;
			if (_destinationDot != null)
			{
				removeChild(_destinationDot);
			}
		}

		
	}
}
