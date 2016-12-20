package;

import openfl.display.Sprite;

class Scene extends Sprite
{

	public var isOnScreen:Bool = false;

	private var _name:String;
	private var _sceneSystem:SceneSystem;


	public function new(sceneSystem:SceneSystem, name:String)
	{
		super();
		_sceneSystem = sceneSystem;
		_name = name;
	}

	public function getName():String
	{
		return _name;
	}

	public function init():Void
	{

	}

}