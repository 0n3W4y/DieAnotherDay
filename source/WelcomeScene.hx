package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.Lib;

class WelcomeScene extends Sprite
{

	private var _myGame:Game;

	public function new(game)
	{
		super();
		_myGame = game;
		init();
	}

	private function init()
	{
		createBackgroundPic();
		createButtons();	
	}

	private function createBackgroundPic()
	{
		var bitmap = new Bitmap (Assets.getBitmapData ("assets/images/dadlogo.png"));
		addChild (bitmap);

		bitmap.x = (Lib.current.stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (Lib.current.stage.stageHeight - bitmap.height) / 2;

		trace("this.width = " + this.width );

		
	}
	private function createButtons()
	{

	}
}