package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.Assets;
import openfl.Lib;
import openfl.text.TextField;
import openfl.events.MouseEvent;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.display.Sprite;


class GameStartingScreen extends Sprite
{
	
	private var _startGameButton:Bitmap;
	private var _exitGameButton:Bitmap;
	private var _exitGameButtonPushed:Bitmap;
	private var _startGameButtonPushed:Bitmap;
    private var _optionsGameButton:Bitmap;
    private var _optionsGameButtonPushed:Bitmap;
    private var _game:Game;

	public function new(game):Void
	{
		super();
        _game = game;
        init();

	}

	public function init():Void
	{
		createBackgroundPic();
		createButtons();	
	}

	private function createBackgroundPic():Void
	{
		var bitmap = new Bitmap (Assets.getBitmapData ("assets/images/dadlogo.png"));
		addChild (bitmap);

		bitmap.x = (Lib.current.stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (Lib.current.stage.stageHeight - bitmap.height) / 2;

	}

	private function createButtons():Void
	{
		//start game button
		createStartButton();

    	//exit game button;
    	createExitButton();

    	//options game button;
    	createOptionsButton();

    	//load game button;
    	//createLoadButon();

	}

    private function createStartButton():Void
    {
    	_startGameButton = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button.png"));
    	_startGameButtonPushed = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button-pushed.png"));
		_startGameButton.smoothing = true;
		addChild (_startGameButton);

        var startGameButtonTextFormat:TextFormat = new TextFormat("Verdana", 28, 0xffffff, true);
        startGameButtonTextFormat.align = TextFormatAlign.CENTER;

        var startGameButtonText = new TextField();
        startGameButtonText.width = 180;
        startGameButtonText.height = 40;
        startGameButtonText.defaultTextFormat = startGameButtonTextFormat;
        startGameButtonText.text = "Start";
        startGameButtonText.selectable = false;
        addChild(startGameButtonText);

        startGameButtonText.addEventListener( MouseEvent.CLICK, onClickStartButton );
        startGameButtonText.addEventListener( MouseEvent.MOUSE_OVER, mouseOverStartButton );
        startGameButtonText.addEventListener( MouseEvent.MOUSE_OUT, mouseOutStartButton );

        startGameButtonText.x = (Lib.current.stage.stageWidth - startGameButtonText.width) / 2 + 400;
        startGameButtonText.y = (Lib.current.stage.stageHeight - startGameButtonText.height) / 2 + 200;

        _startGameButton.x = (Lib.current.stage.stageWidth - _startGameButton.width) / 2 + 400;
        _startGameButton.y = (Lib.current.stage.stageHeight - _startGameButton.height) / 2 + 200;
        _startGameButtonPushed.x = (Lib.current.stage.stageWidth - _startGameButton.width) / 2 + 400;
        _startGameButtonPushed.y = (Lib.current.stage.stageHeight - _startGameButton.height) / 2 + 200;
    }

    private function createOptionsButton():Void
    {
    	_optionsGameButton = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button.png"));
    	_optionsGameButtonPushed = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button-pushed.png"));
		_optionsGameButton.smoothing = true;
		addChild (_optionsGameButton);

        var optionGameButtonTextFormat:TextFormat = new TextFormat("Verdana", 28, 0xffffff, true);
        optionGameButtonTextFormat.align = TextFormatAlign.CENTER;

        var optionsGameButtonText = new TextField();
        optionsGameButtonText.width = 180;
        optionsGameButtonText.height = 40;
        optionsGameButtonText.defaultTextFormat = optionGameButtonTextFormat;
        optionsGameButtonText.text = "Options";
        optionsGameButtonText.selectable = false;
        addChild(optionsGameButtonText);

         optionsGameButtonText.addEventListener( MouseEvent.CLICK, onClickOptionButton );
         optionsGameButtonText.addEventListener( MouseEvent.MOUSE_OVER, mouseOverOptionsButton );
         optionsGameButtonText.addEventListener( MouseEvent.MOUSE_OUT, mouseOutOptionsButton );

        optionsGameButtonText.x = (Lib.current.stage.stageWidth - optionsGameButtonText.width) / 2 + 400;
        optionsGameButtonText.y = (Lib.current.stage.stageHeight - optionsGameButtonText.height) / 2 + 250;

        _optionsGameButton.x = (Lib.current.stage.stageWidth - _optionsGameButton.width) / 2 + 400;
        _optionsGameButton.y = (Lib.current.stage.stageHeight - _optionsGameButton.height) / 2 + 250;
        _optionsGameButtonPushed.x = (Lib.current.stage.stageWidth - _optionsGameButton.width) / 2 + 400;
        _optionsGameButtonPushed.y = (Lib.current.stage.stageHeight - _optionsGameButton.height) / 2 + 250;
    }

    private function createExitButton():Void
    {
        _exitGameButton = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button.png"));
        _exitGameButtonPushed = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button-pushed.png"));
        _exitGameButton.smoothing = true;
        addChild (_exitGameButton);

        var exitGameButtonTextFormat:TextFormat = new TextFormat("Verdana", 28, 0xffffff, true);
        exitGameButtonTextFormat.align = TextFormatAlign.CENTER;

        var exitGameButtonText = new TextField();
        exitGameButtonText.width = 180;
        exitGameButtonText.height = 40;
        exitGameButtonText.defaultTextFormat = exitGameButtonTextFormat;
        exitGameButtonText.text = "Exit";
        exitGameButtonText.selectable = false;
        addChild(exitGameButtonText);

         exitGameButtonText.addEventListener( MouseEvent.CLICK, onClickExitButton );
         exitGameButtonText.addEventListener( MouseEvent.MOUSE_OVER, mouseOverExitButton );
         exitGameButtonText.addEventListener( MouseEvent.MOUSE_OUT, mouseOutExitButton );

        exitGameButtonText.x = (Lib.current.stage.stageWidth - exitGameButtonText.width) / 2 + 400;
        exitGameButtonText.y = (Lib.current.stage.stageHeight - exitGameButtonText.height) / 2 + 300;

        _exitGameButton.x = (Lib.current.stage.stageWidth - _exitGameButton.width) / 2 + 400;
        _exitGameButton.y = (Lib.current.stage.stageHeight - _exitGameButton.height) / 2 + 300;
        _exitGameButtonPushed.x = (Lib.current.stage.stageWidth - _exitGameButton.width) / 2 + 400;
        _exitGameButtonPushed.y = (Lib.current.stage.stageHeight - _exitGameButton.height) / 2 + 300;
    }

    private function onClickOptionButton (event:MouseEvent):Void
    {
        _game.switchScreen("Options");
    }

	private function onClickStartButton ( event:MouseEvent ):Void
    {
        _game.removeScreen("StartingScreen");
        _game.getSceneSystem().switchScene("PlayingScene");
    }

    private function onClickExitButton( event:MouseEvent):Void
    {
    	_game.exit();
    }

    private function mouseOverStartButton(event:MouseEvent):Void
    {
    	changeButton(_startGameButton, _startGameButtonPushed);
    }

    private function mouseOutStartButton(event:MouseEvent):Void
    {
    	changeButton(_startGameButtonPushed, _startGameButton);
    }

      private function mouseOverExitButton(event:MouseEvent):Void
    {
        changeButton(_exitGameButton, _exitGameButtonPushed);
    }

    private function mouseOutExitButton(event:MouseEvent):Void
    {
        changeButton(_exitGameButtonPushed, _exitGameButton);
    }

    private function mouseOverOptionsButton(event:MouseEvent):Void
    {
        changeButton(_optionsGameButton, _optionsGameButtonPushed);
    }

    private function mouseOutOptionsButton(event:MouseEvent):Void
    {
        changeButton(_optionsGameButtonPushed, _optionsGameButton);
    }

    private function changeButton(button:Bitmap, newButton:Bitmap):Void
    {
    	var index:Int = getChildIndex(button);
    	removeChild(button);
    	addChildAt(newButton, index);
    }

}
