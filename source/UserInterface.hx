package;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flash.text.TextFormatAlign;
import openfl.Lib;

class UserInterface extends Sprite
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

		var startGameButtonTextFormat:TextFormat = new TextFormat("Verdana", 40, 0xffffff, true);
		startGameButtonTextFormat.align = TextFormatAlign.CENTER;
		
		var newTextField = new TextField();
		newTextField.width = 600;
        newTextField.height = 200;
        newTextField.x = 200;
        newTextField.y = 200;
        newTextField.defaultTextFormat = startGameButtonTextFormat;
        newTextField.text = "Hello, use WASD to move";
        newTextField.selectable = false;
        addChild(newTextField);

	}

	public function update()
	{

	}
	
}