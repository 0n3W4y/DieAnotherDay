package;

class Game 
{

	private var _currentScene:Dynamic;
	private var _mainSprite:Main;
	private var _allScenes:Array<Dynamic>;

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

		var welcomeScene = new WelcomeScene(this);
		_currentScene = welcomeScene;
		_mainSprite.addChild(welcomeScene);

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

		var playingScene = new PlayingScene(this);
		_currentScene = playingScene;
		_mainSprite.addChild(playingScene);
	}

	public function toOptionScene()
	{

	}

	public function toScene(scene)
	{
		
	}
}