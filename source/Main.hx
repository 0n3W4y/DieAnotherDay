package;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.Lib;

class Main extends Sprite {
	
	private var game:Game;
	private var isCreated:Bool = false;
	
	public function new () 
	{
		super ();
		
		init();
		
	}
	private function init()
	{
		if(!isCreated) createGame();
	}

	private function createGame()
	{
		game = new Game(this);
		isCreated = true;
	}
	
}