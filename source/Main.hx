package;

import openfl.display.Sprite;

class Main extends Sprite {
	
	private var _gameSystem:GameSystem;
	private var _isCreated:Bool = false;
	
	public function new():Void
	{
		super();
		
		init();
	}
	private function init():Void
	{
		if(!_isCreated) createGameSystem();
	}

	private function createGameSystem():Void
	{
		_gameSystem = new GameSystem(this);
		_isCreated = true;
	}
	
}