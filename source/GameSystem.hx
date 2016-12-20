package;

import openfl.display.Sprite;

class GameSystem
{
	private var _mainSprite:Sprite;
	private var _game:Game;

	public function new(mainSprite:Sprite):Void
	{
		_mainSprite = mainSprite;
		init();
	}

	private function init():Void
	{
		createGame();
		_game.start();
	}

	private function createGame():Void
	{
		_game = new Game(this);
	}

	public function getMainSprite():Sprite
	{
		return _mainSprite;
	}

	public function switchGame(gameName:String):Void
	{
		//for future;
	}	

}
