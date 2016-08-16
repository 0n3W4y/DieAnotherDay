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

	public function new(scene, imagePath:String)
	{
		super();
		var _myScene = scene;
		var image = new Bitmap (Assets.getBitmapData (imagePath));
		image.smoothing = true;
		addChild (image);
	}

	public function update()
	{
		this.x +=1;
		this.y +=1;
		_position = new Point(this.x, this.y);
	}

	public function pathFinding(tile)
	{
		var openList:Array<Tiles> = new Array();
		var closetList:Array<Tiles> = new Array();
		var tileGroundSize:Int = 64;
		var gridSize:Int = 200;
		var tilemap:Vector = _myScene.getTileMap();
		var curentTilePosition:Point = new Point(Math.round(_position.x/tileGroundSize), Math.round(_position.y/tileGroundSize));
		var currentTile:Tiles = tilemap[curentTilePosition.y*gridSize + curentTilePosition.x];
		var distenationTile:Tiles = generateRandomTileDistenation();
	}

	private function generateRandomTileDistenation():Tiles
	{
		var gridSize = 200;
		var tileIndex = Math.floor(Math.random()*(gridSize*gridSize + 1));
		var tilemap = _myScene.getTileMap();
		return tilemap[tileIndex];
	}
}