package;

import openfl.display.Sprite;

class SceneSystem
{
	private var _game:Game;
	private var _mainSprite:Sprite;
	private var _scenes:Array<PlayingScene>;
	private var _userInterface:UserInterface;

	public function new(game:Game, mainSprite:Sprite):Void
	{
		_game = game;
		_mainSprite = mainSprite;
		_scenes = new Array();
	}

	private function init():Void
	{
		
	}

	public function createScene():Void
	{
		var newScene:PlayingScene;
		var index:Int;
		var id:String = createId();

		newScene = new PlayingScene(this, 30, id); //30 - fps;
		newScene.init();
		newScene.isOnScreen = true;
		_mainSprite.addChild(newScene);
		_scenes.push(newScene);
			
		if (_userInterface == null)
			createUserInterface();		
		
	}

	private function findSceneOnScreen():PlayingScene
	{
		for (i in 0..._scenes.length)
		{
			if (_scenes[i].isOnScreen)
				return _scenes[i];
		}

		return null;
	}

	public function removeScene(id:String = null, index:Int = -1):Void
	{
		if (index == -1)
		{
			for (i in 0..._scenes.length)
			{
				if (id == _scenes[i].id)
				{
					_mainSprite.removeChild(_scenes[i]);
					_scenes[i].isOnScreen = false;
				}
			}
		}
		else
		{
			_mainSprite.removeChild(_scenes[index]);
			_scenes[index].isOnScreen = false;
		}
		
		
	}

	public function destroyScene(id:String):Void
	{
		//check : if scene we want to delete is on screen
		var removedScene:PlayingScene = findSceneOnScreen();
		if (removedScene.id == id)
		{
			trace("Error on destroyScene, scene is on screen!");
			return;
		}

		for (i in 0..._scenes.length)
		{
			if (id == _scenes[i].id)
			{
				_scenes.splice(i, 1);
			}
		}
		

	}

	public function switchScene(id:String):Void
	{
		var nextScene:PlayingScene = null;

		for (i in 0..._scenes.length)
		{
			if (_scenes[i].id == id)
				nextScene = _scenes[i];
		}
		//check is some scene on screen?
		var sceneOnScreen:PlayingScene = findSceneOnScreen();

		if (sceneOnScreen != null)
		{
			sceneOnScreen.isOnScreen = false;
			_mainSprite.removeChild(sceneOnScreen);
		}

		if (nextScene != null)
		{
			nextScene.isOnScreen = true;
			_mainSprite.addChild(nextScene);
		}
		else
		{
			createScene();
		}

	}

	public function getGame():Game
	{
		return _game;
	}

	public function createUserInterface():Void
	{
		_userInterface = new UserInterface(this);
		_mainSprite.addChild(_userInterface);
	}

	public function getUserInterface():UserInterface
	{
		return _userInterface;
	}

	public function getMainSprite():Sprite
	{
		return _mainSprite;
	}

	public function getCurrentScene():PlayingScene
	{
		var sceneOnScreen:PlayingScene = findSceneOnScreen();
		return sceneOnScreen;
	}

	private function createId():String
	{
		return "0";
	}
}
