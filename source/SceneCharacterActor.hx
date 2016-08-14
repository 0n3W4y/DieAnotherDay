package;

import openfl.display.Sprite;
import openfl.Assets;
import openfl.display.Bitmap;

class SceneCharacterActor extends Sprite
{
	public function new(imagePath:String)
	{
		super();

		var image = new Bitmap (Assets.getBitmapData (imagePath));
		image.smoothing = true;
		addChild (image);
	}

	public function update()
	{
		this.x +=1;
		this.y +=1;
	}
}