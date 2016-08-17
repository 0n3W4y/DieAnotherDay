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
	private var _lastPosition:Point;
	private var _pathToDistenation:Array<Point>;

	private var _isBusy:Bool = false;


	public function new(scene, imagePath:String)
	{
		super();
		var _myScene = scene;
		var image = new Bitmap (Assets.getBitmapData (imagePath));
		image.smoothing = true;
		addChild (image);
		image.x = 0;
		image.y = 0;
		image.set_width(64.0);
		image.set_height(64.0);

		_position = new Point(0, 0);

		_speed = 2.0;
	}

	public function update()
	{
		move();

		if (!_isBusy)
		{

		}
	}

	public function pathFinding(tile:Tiles)
	{
		var openList:Array<Tiles> = new Array();
		var closetList:Array<Tiles> = new Array();
		var tileSize:Int = 64;
		var gridSize:Int = 200;
		var tilemap = _myScene.getTileMap();
		var curentTilePosition:Point = new Point(Math.round(_position.x/tileSize), Math.round(_position.y/tileSize));
		var destinationTilePosition:Point = tile.getGridPosition(); 
		var direction:Point;

		var difX = curentTilePosition.x - destinationTilePosition.x;
		var difY = curentTilePosition.y - destinationTilePosition.y;
		var dirX:Int = 0;
		var dirY:Int = 0;

		if (difX > 0)
			dirX = -1 // left, 1 - right, 0 - no need moving to this coord;
		else if (difX < 0)
			dirX = 1;

		if (difY > 0)
			dirY = -1;
		else if (difY < 0)
			dirY = 1;

		direction = new Point(dirX, dirY);

		var nextPositionToMove:Point =  new Point(curentTilePosition.x - direction.x, curentTilePosition.y - direction.y);
		var tileOnNextPositionToMove:Tiles = tilemap[gridSize*nextPositionToMove.y + nextPositionToMove.x];

		if (tileOnNextPositionToMove.groundType == 0)
			_pathToDistenation.push(nextPositionToMove);
		else
		{
			//try to find new path from last point and block this direction;
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

	}
}