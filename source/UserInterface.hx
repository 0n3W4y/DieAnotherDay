package;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flash.text.TextFormatAlign;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.Assets;

import openfl.display.FPS;
import haxe.Timer;

import openfl.events.MouseEvent;

class UserInterface extends Sprite
{

	public var isInited = false;

	private var _scene:PlayingScene;
	private var _sceneSystem:SceneSystem;

	//globalInGameTime
	private var _day:Int;
	private var _month:Int;
	private var _year:Int;
	private var _minutes:Int;
	private var _hours:Int;
	private var _monthTextFormat:Array<String> = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	private var _tickCounter:Int;
	private var _timeTexField:TextField;
	private var _yearTextField:TextField;

	//fps meter
	private var _gameFpsTextField:TextField;
	private var _globalFpsTextField:TextField;
	private var _gameFps:Int = 0;
	private var _gameCacheCount:Int = 0;
	private var _gameTimes:Array<Float>;
	private var _globalFps:Int = 0;
	private var _globalCacheCount:Int = 0;
	private var _globalTimes:Array <Float>;


	public function new(sceneSystem:SceneSystem):Void
	{
		super();

		_sceneSystem = sceneSystem;
		_scene = _sceneSystem.getCurrentScene();

		_day = 0;
		_month = 0;
		_year = 0;
		_minutes = 0;
		_hours = 0;
		_tickCounter = 0;

		_globalTimes = new Array();
		_gameTimes = new Array();

		init();
	}

	private function init():Void
	{
		createTimeMaster();
		createFpsMeters();

		addInputs();

		isInited = true;

	}

	public function initialize(minutes:Int = 0, hours:Int = 0, day:Int = 0, month:Int = 0, year:Int = 0, tickCounter:Int = 0):Void
	{
		_day = day;
		_month = month;
		_year = year;
		_minutes = minutes;
		_hours = hours;
		_tickCounter = tickCounter;
	}

	private function addInputs():Void
	{

	}

	private function createTimeMaster():Void
	{
		createMasterTimeButtons();
		createGlobalTime();
	}

	public function update(time:Int):Void
	{
		updateGlobalTime(time);
		updateGameFpsMeter(time);
	}

	private function createGlobalTime():Void
	{
		var textFormat:TextFormat = new TextFormat("Arial", 18, 0x000000);
		textFormat.bold = true;
		textFormat.align = TextFormatAlign.RIGHT;

		_timeTexField = new TextField();
		_timeTexField.width = 80;
		_timeTexField.height = 30;
		_timeTexField.x = (Lib.current.stage.stageWidth - _timeTexField.width) / 2 + 520;
		_timeTexField.y = (Lib.current.stage.stageHeight - _timeTexField.height) / 2 + 270;
		_timeTexField.defaultTextFormat = textFormat;
		_timeTexField.selectable = false;
		_timeTexField.text = "   00:00";
		addChild(_timeTexField);


		_yearTextField = new TextField();
		_yearTextField.width = 120;
		_yearTextField.height = 30;
		_yearTextField.x = (Lib.current.stage.stageWidth - _yearTextField.width) / 2 + 600;
		_yearTextField.y = (Lib.current.stage.stageHeight - _yearTextField.height) / 2 + 270;
		_yearTextField.defaultTextFormat = textFormat;
		_yearTextField.selectable = false;
		_yearTextField.text = "1 Jan 0000";
		addChild(_yearTextField);
	}

	private function updateGlobalTime(time:Int):Void
	{
		_tickCounter += time;
		if (_tickCounter >= 1000)
		{
			_minutes++;
			_tickCounter -= 1000; //prevent loss of time;
			if (_minutes == 59)
			{
				_hours++;
				_minutes = 0;
				if (_hours == 23)
				{
					_day++;
					_hours = 0;
					if (_day == 29)
					{
						_month++;
						_day = 0;
						if (_month == 11)
						{
							_year++;
							_month = 0;
						}
					}

					var textDay:String = (_day + 1) + "";
					var monthText:String = _monthTextFormat[_month];
					var yearTxt:String = _year + "";
					if (_year <= 9)
						yearTxt = "000" + _year;
					else if (_year <= 99)
						yearTxt = "00" + _year;
					else if (_year <= 999)
						yearTxt = "0" + _year;

					var yearText:String = textDay + " " + monthText + " " + yearTxt;
					_yearTextField.text = yearText;
				}
			}

		var textMinutes:String = _minutes + "";
		if (_minutes <= 9)
			textMinutes = "0" + _minutes;

		var textHours:String = _hours + "";
		if (_hours <= 9)
			textHours = "0" + _hours;

		var ratio:Int = _sceneSystem.getCurrentScene().getTimeRatio();
		var timeRatio:String = "";
		if (ratio > 1)
		{
			timeRatio = "x" + ratio + " ";
		}


		var timeText:String = timeRatio + " " + textHours + ":" + textMinutes;
		_timeTexField.text = timeText;

		}
		
	}

	private function createFpsMeters():Void
	{
		var textFormat:TextFormat = new TextFormat("Arial", 14, 0x000000);
		textFormat.bold = true;
		textFormat.align = TextFormatAlign.CENTER;

		_gameFpsTextField = new TextField();
		_gameFpsTextField.width = 100;
		_gameFpsTextField.height = 20;
		_gameFpsTextField.background = true;
		_gameFpsTextField.backgroundColor = 0xffffff;
		_gameFpsTextField.x = (Lib.current.stage.stageWidth - _gameFpsTextField.width) / 2 - 600;
		_gameFpsTextField.y = (Lib.current.stage.stageHeight - _gameFpsTextField.height) / 2 - 370;
		_gameFpsTextField.defaultTextFormat = textFormat;
		_gameFpsTextField.selectable = false;
		_gameFpsTextField.text = "Game FPS: 00";
		addChild(_gameFpsTextField);


		_globalFpsTextField = new TextField();
		_globalFpsTextField.width = 110;
		_globalFpsTextField.height = 20;
		_globalFpsTextField.background = true;
		_globalFpsTextField.backgroundColor = 0xffffff;
		_globalFpsTextField.x = (Lib.current.stage.stageWidth - _globalFpsTextField.width) / 2 - 600;
		_globalFpsTextField.y = (Lib.current.stage.stageHeight - _globalFpsTextField.height) / 2 - 350;
		_globalFpsTextField.defaultTextFormat = textFormat;
		_globalFpsTextField.selectable = false;
		_globalFpsTextField.text = "Global FPS: 00";
		addChild(_globalFpsTextField);
	}

	private function updateGameFpsMeter(time):Void
	{
		var currentTime = Timer.stamp ();
		_gameTimes.push (currentTime);
		
		while (_gameTimes[0] < currentTime - 1) {
			
			_gameTimes.shift ();
			
		}
		
		var currentCount = _gameTimes.length;
		_gameFps = Math.round ((currentCount + _gameCacheCount) / 2);
		
		if (currentCount != _gameCacheCount /*&& visible*/) {
			
			_gameFpsTextField.text = "Game FPS: " + _gameFps;
			
		}
		
		_gameCacheCount = currentCount;		
	}		

	private function createMasterTimeButtons():Void
	{
		var pauseButton:Bitmap = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button_pause.png"));
		pauseButton.smoothing = true;
		addChild (pauseButton);

		var pabText = new TextField();
        pabText.width =  pauseButton.width*0.1;
        pabText.height = pauseButton.height*0.1;
        pabText.selectable = false;
        addChild(pabText);
        pauseButton.scaleX = 0.1;
    	pauseButton.scaleY = 0.1;

        pabText.addEventListener( MouseEvent.CLICK, onClickPause );

        pauseButton.x = (Lib.current.stage.stageWidth - pauseButton.width) / 2 + 550;
        pauseButton.y = (Lib.current.stage.stageHeight - pauseButton.height) / 2 + 300;
        pabText.x = (Lib.current.stage.stageWidth - pabText.width) / 2 + 550;
        pabText.y = (Lib.current.stage.stageHeight - pabText.height) / 2 + 300;

        

        var playButton:Bitmap = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button_play_x1.png"));
        playButton.smoothing = true;
		addChild (playButton);

		var plbText = new TextField();
        plbText.width =  playButton.width*0.1;
        plbText.height = playButton.height*0.1;
        plbText.selectable = false;
        addChild(plbText);
        playButton.scaleX = 0.1;
        playButton.scaleY = 0.1;

		plbText.addEventListener( MouseEvent.CLICK, onClickPlay );

		playButton.x = (Lib.current.stage.stageWidth - playButton.width) / 2 + 590;
        playButton.y = (Lib.current.stage.stageHeight - playButton.height) / 2 + 300;
        plbText.x = (Lib.current.stage.stageWidth - plbText.width) / 2 + 590;
        plbText.y = (Lib.current.stage.stageHeight - plbText.height) / 2 + 300;

        

        var speedUpButton:Bitmap = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button_play_speedup.png"));
        speedUpButton.smoothing = true;
		addChild (speedUpButton);

		var subText = new TextField();
        subText.width =  speedUpButton.width*0.1;
        subText.height = speedUpButton.height*0.1;
        subText.selectable = false;
        addChild(subText);
        speedUpButton.scaleX = 0.1;
        speedUpButton.scaleY = 0.1;

		subText.addEventListener( MouseEvent.CLICK, onClickSpeedUp );

		speedUpButton.x = (Lib.current.stage.stageWidth - speedUpButton.width) / 2 + 630;
        speedUpButton.y = (Lib.current.stage.stageHeight - speedUpButton.height) / 2 + 300;
        subText.x = (Lib.current.stage.stageWidth - subText.width) / 2 + 630;
        subText.y = (Lib.current.stage.stageHeight - subText.height) / 2 + 300;
        

        var speedDownButton:Bitmap = new Bitmap (Assets.getBitmapData ("assets/images/buttons/button_play_speeddown.png"));
        speedDownButton.smoothing = true;
		addChild (speedDownButton);

		var sdbText = new TextField();
        sdbText.width =  speedDownButton.width*0.1;
        sdbText.height = speedDownButton.height*0.1;
        sdbText.selectable = false;
        addChild(sdbText);
        speedDownButton.scaleX = 0.1;
        speedDownButton.scaleY = 0.1;

		sdbText.addEventListener( MouseEvent.CLICK, onClickSpeedDown );

		speedDownButton.x = (Lib.current.stage.stageWidth - speedDownButton.width) / 2 + 510;
        speedDownButton.y = (Lib.current.stage.stageHeight - speedDownButton.height) / 2 + 300;
        sdbText.x = (Lib.current.stage.stageWidth - sdbText.width) / 2 + 510;
        sdbText.y = (Lib.current.stage.stageHeight - sdbText.height) / 2 + 300;
        

	}

	private function onClickPause(e:MouseEvent):Void
	{
		var scene:PlayingScene = _sceneSystem.getCurrentScene();
		scene.pause();
	}

	private function onClickPlay(e:MouseEvent):Void
	{
		var scene:PlayingScene = _sceneSystem.getCurrentScene();
		scene.unPause();
		scene.setTimeRatio(0);
	}

	private function onClickSpeedUp(e:MouseEvent):Void
	{
		var scene:PlayingScene = _sceneSystem.getCurrentScene();
		scene.unPause();
		scene.setTimeRatio(1);
	}

	private function onClickSpeedDown(e:MouseEvent):Void
	{
		var scene:PlayingScene = _sceneSystem.getCurrentScene();
		scene.unPause();
		scene.setTimeRatio(-1);
	}

	public function updateGlobalFps(time:Int):Void
	{
		var currentTime = Timer.stamp ();
		_globalTimes.push (currentTime);
		
		while (_globalTimes[0] < currentTime - 1) {
			
			_globalTimes.shift ();
			
		}
		
		var currentCount = _globalTimes.length;
		_globalFps = Math.round ((currentCount + _globalCacheCount) / 2);
		
		if (currentCount != _globalCacheCount /*&& visible*/) {
			
			_globalFpsTextField.text = "Global FPS: " + _globalFps;
			
		}
		
		_globalCacheCount = currentCount;		
	}

}