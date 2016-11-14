package;

import openfl.display.Sprite;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.geom.Point;

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

	private var _image:Bitmap;


	private var _pathToDistenation:Array<Array<Int>>;
	private var _isPathComplete:Bool = false;

	private var _isBusy:Bool = false;

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
		_tilePosition = new Point(Math.round(_image.x/_gridSize), Math.round(_image.y/_gridSize));

		_speed = 4.0;
	}

	public function update()
	{
		move();

		if (!_isBusy)
		{

		}
	}

	private function createPath()
	{

	}

	private function move()
	{
		_position = new Point(_image.x, _image.y);
		_tilePosition = new Point(Math.round(_image.x/_gridSize), Math.round(_image.y/_gridSize));

		_image.x += _speed;
		_image.y += _speed;
	}
}

