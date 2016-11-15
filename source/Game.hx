package;

import openfl.display.Sprite;

class Game 
{

	private var _currentScene:Dynamic;
	private var _mainSprite:Main;
	private var _allScenes:Array<Sprite>;
	private var _userInterface:UserInterface;

	public function new(mainSprite)
	{
		_mainSprite = mainSprite;
		init();
	}

	public function init()
	{
		_allScenes = new Array();
		//create some starting scenes like options, load, etc;
		_currentScene  = new WelcomeScene(this);
		_mainSprite.addChild(_currentScene);
		_allScenes.push(_currentScene);

	}

	public function toWelcomeScene()
	{
		if (_currentScene != WelcomeScene)
			_mainSprite.removeChild(_currentScene);

		for (i in 0..._allScenes.length)
		{
			var scene = _allScenes[i];
			if (Std.is(scene, WelcomeScene))
			{
				_currentScene = scene;
				_mainSprite.addChild(scene);
				return;
			}
		}

		_currentScene = new WelcomeScene(this);
		_mainSprite.addChild(_currentScene);

	}

	public function toPlayingScene()
	{

		if (_currentScene != PlayingScene)
			_mainSprite.removeChild(_currentScene);

		for (i in 0..._allScenes.length)
		{
			var scene = _allScenes[i];
			if (Std.is(scene, PlayingScene))
			{
				_currentScene = scene;
				_mainSprite.addChild(scene);
				return;
			}
		}

		_currentScene = new PlayingScene(this);
		_mainSprite.addChild(_currentScene);

		if (_userInterface == null)
		{
			_userInterface = new UserInterface(this);
			_mainSprite.addChild(_userInterface);
		}
		
	}

	public function toOptionScene()
	{

	}

	public function toScene(scene)
	{
		
	}

	public function getUI()
	{
		return _userInterface;
	}
}