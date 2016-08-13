package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.Lib;
import openfl.text.TextField;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;


class WelcomeScene extends Sprite
{

	private var _myGame:Game;
	private var _startGameButton:Sprite;

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

	}

	private function createButtons()
	{
		_startGameButton = new Sprite();
		_startGameButton.graphics.beginFill( 0xFF0000 );
        _startGameButton.graphics.drawRoundRect( 0, 0, 180, 40, 10, 10 );
        _startGameButton.graphics.endFill();
        addChild(_startGameButton);

        var startGameButtonTextFormat:TextFormat = new TextFormat("Verdana", 18, 0xffffff, true);
		startGameButtonTextFormat.align = TextFormatAlign.CENTER;

        var startGameButtonText = new TextField();
        startGameButtonText.width = 180;
        startGameButtonText.height = 40;
        startGameButtonText.defaultTextFormat = startGameButtonTextFormat;
        startGameButtonText.text = "Start";
        startGameButtonText.selectable = false;
        addChild(startGameButtonText);

        startGameButtonText.addEventListener( MouseEvent.CLICK, onClick );

        startGameButtonText.x = (Lib.current.stage.stageWidth - startGameButtonText.width) / 2 + 400;
        startGameButtonText.y = (Lib.current.stage.stageHeight - startGameButtonText.height) / 2 + 210;

        _startGameButton.x = (Lib.current.stage.stageWidth - _startGameButton.width) / 2 + 400;
        _startGameButton.y = (Lib.current.stage.stageHeight - _startGameButton.height) / 2 + 200;
	}

	private function onClick( event:MouseEvent )
    {
    	_startGameButton.graphics.clear();
    	_startGameButton.graphics.beginFill(0x00aa00);
    	//_startGameButton.graphics.drawRoundRect( 0, 0, 180, 40, 10, 10 );
    	_startGameButton.graphics.endFill();

        //go to game and start playing Scene;
        _myGame.toPlayingScene();
    }
}