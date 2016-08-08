package;

class Game 
{

	private var currentScene:Dynamic;
	private var _mainSprite:Main;

	public function new(mainSprite)
	{
		_mainSprite = mainSprite;
		init();
	}

	public function init()
	{
		
		currentScene  = new WelcomeScene(this);
		_mainSprite.addChild(currentScene);

	}

	public function toWellcomeScreen()
	{

	}

	public function toGame()
	{
		
	}

	public function toOptions()
	{
		
	}
}