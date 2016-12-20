package;

import openfl.display.Sprite;
import openfl.Lib;
import flash.system.System;

class Game 
{
	private var _sceneSystem:SceneSystem;
	private var _entitySystem:EntitySystem;
	private var _gameSystem:GameSystem;
	private var _gameStartingScreen:GameStartingScreen;
	private var _gameOptionScreen:GameOptionScreen;
	private var _mainSprite:Sprite;

	public function new(gameSystem:GameSystem):Void
	{
		_gameSystem = gameSystem;
		_mainSprite = _gameSystem.getMainSprite();
		init();
	}

	private function init():Void
	{
		createSceneSystem();
		createEntitySystem();
	}

	private function createStartingScreen():Void
	{
		_gameStartingScreen = new GameStartingScreen(this);
		_mainSprite.addChild(_gameStartingScreen);
	}

	private function createOptionScreen():Void
	{
		_gameOptionScreen = new GameOptionScreen(this);
		_mainSprite.addChild(_gameOptionScreen);
	}

	private function createSceneSystem():Void
	{
		_sceneSystem = new SceneSystem(this, _mainSprite);
	}

	private function createEntitySystem():Void
	{
		_entitySystem = new EntitySystem(this);
	}


	public function getEntitySystem():EntitySystem
	{
		return _entitySystem;
	}

	public function getSceneSystem():SceneSystem
	{
		return _sceneSystem;
	}

	public function start():Void
	{
		createStartingScreen();
	}

	public function stop():Void
	{

	}

	public function pause():Void
	{
		
	}

	public function exit():Void
	{
		System.exit(0);
	}

	public function switchScreen(screen:String):Void
	{
		if (screen == "Options")
		{
			if ( _gameOptionScreen != null)
				_mainSprite.addChild(_gameOptionScreen);
			else
				createOptionScreen();
		}
		else if (screen == "StartingScreen")
		{
			if (_gameStartingScreen != null)
				_mainSprite.addChild(_gameStartingScreen);
			else
				createStartingScreen();
		}
	}

	public function removeScreen(screen:String):Void
	{
		if (screen == "Options")
		{
			if ( _gameOptionScreen != null)
				_mainSprite.removeChild(_gameOptionScreen);
		}
		else if (screen == "StartingScreen")
		{
			if (_gameStartingScreen != null)
				_mainSprite.removeChild(_gameStartingScreen);
		}
	}

	public function destroyScreen()
	{
		
	}

}