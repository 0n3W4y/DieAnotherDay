package;

import openfl.display.Sprite;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.geom.Point;

class SceneCharacterActor extends Sprite
{	
	private var _myScene:PlayingScene;
	private var _speed:Float;
	private var _position:Point;
	private var _tilePosition:Point;


	private var _pathToDistenation:Array<Array<Int>>;
	private var _isPathComplete:Bool = false;

	private var _isBusy:Bool = false;

	public function new(scene, imagePath:String)
	{
		super();
		var _myScene = scene;
		var image = new Bitmap (Assets.getBitmapData (imagePath));
		image.smoothing = true;
		addChild (image);
		image.x:Int = 0;
		image.y:Int = 0;
		image.set_width(64.0);
		image.set_height(64.0);
		var gridSize = _myScene.getGridSize();

		_position = new Point(image.x, image.y);
		_tilePosition = new Point(Math.round(image.x/gridSize), MAth.round(image.y/gridSize));

		_speed = 2.0;
	}

	public function update()
	{
		move();

		if (!_isBusy)
		{

		}
	}

	public function createPath(destinationTile:Tiles)
	{
		if (_pathToDistenation.length == 0) // 1, пробуем сделать короткий путь до цели.
		{
			_isPathComplete = false;
			var gridSize:Int = _myScene.getGridSize();
			var tilemap = _myScene.getTileMap();
			var currentPositionX:Int = Math.round(_position.x/gridSize);
			var currentPositionY:Int = Math.round(_position.y/gridSize);
			var currentTile:Tiles = tilemap.tile[currentPositionY*gridSize + currentPositionX];
			calculatePathToDistenation(currentTile:Tiles, destinationTile:Tiles);
		}
		else //2, если не получилось короткий путь. пытаемся анализировать
		{

		}



	}

	private function generateRandomTileDistenation():Tiles
	{
		var gridSize = 200;
		var tileIndex = Math.floor(Math.random()*(gridSize*gridSize + 1));
		var tilemap = _myScene.getTileMap();
		return tilemap[tileIndex];
	}

	private function move()
	{
		if (_isPathComplete && _pathToDistenation.length != 0)
		{
			_isBusy = true;
			var gridSize = _myScene.getGridSize();
			var currentPositionX:Int = Math.round(_position.x/gridSize);
			var currentPositionY:Int = Math.round(_position.y/gridSize);
			var currentPosition:Array<Int> = [currentPositionX, currentPositionY];
			var destination = []

		}
		else
			_isBusy = false;
	}

	private function getDirectionToDestination(currentTile:Tiles, destinationTile:Tiles)
	{
		var result:Array<Int> = new Array();
		var difX = currentTile.getGridPosition().x - destinationTile.getGridPosition().x;
		var difY = currentTile.getGridPosition().y - destinationTile.getGridPosition().y;
		var dirX:Int = 0;
		var dirY:Int = 0;

		if (difX > 0)
			dirX = -1 // left, 1 - right, 0 - no need moving to this coord;
		else if (difX < 0)
			dirX = 1;

		if (difY > 0)
			dirY = -1; // up, 1 - down, 0 - no need moving to this coord;
		else if (difY < 0)
			dirY = 1;

		result = [dirX, dirY];
		return result;

	}

	private function calculatePathToDistenation(currentTile:Tiles, destinationTile:Tiles)
	{
		var gridSize:Int = _myScene.getGridPosition();
		var tilemap:TileMap = _myScene.getTileMap();

		var complete:Bool = false;

		while(!complete)
		{
			var direction = getDirectionToDestination(currentTile, destinationTile);
			var dirX = direction[0];
			var dirY = direction[1];

			if (dirX != 0 && dirY != 0)
			{
				var posX:Int = curentTilePosition[0] + dirX;
				var posY:Int = curentTilePosition[1] + dirY;
				var currentTile:Tiles = tilemap.tile[gridSize*posY + posX];

				if (currentTile.groundType == 0)
				{
					curentTilePosition = [posX, posY];
					_pathToDistenation.push(curentTilePosition);
				}
				else
				{
					complete = true;
					break;
				}
				
			}
			else
			{
				complete = true;
				_isPathComplete = true;
			}
		}

	}

}