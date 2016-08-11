package;

class Tile 
{
	public var groundType;
	public var blockType;
	public var blockHp;
	public var coverType;
	public var effect;

	public function new(type)
	{
		//for test 3 ground types, earth and rocks, rocks have a block, 
		if (type == "Rock") 
			createRockTile();
		else if (type == "Earth")
			createEarthTile();
		else
			createWaterTile();
	}

	private function createRockTile()
	{
		groundType = "rock";
		blockType = "cubic";
		blockHp = 500;
		coverType = "rock";
		effect = "roof";
	}

	private function createErathTile()
	{
		groundType = "earth";
		blockType = "flat";
		blockHp = -1;
		coverType = "earth";
		effect = "grass";
	}

	private function createWaterTile()
	{
		groundType = "water";
		blockType = "flat";
		blockHp = -1;
		coverType = "water";
		effect = "water";
	}
}