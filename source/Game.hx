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

	public function toWellcomeScreen()
	{

	}

	public function toPlayingScene()
	{
		trace("I'm work");
	}

	public function toOptions()
	{

	}
}