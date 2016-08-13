package;

class Tiles
{
	public var groundType:Int;
	public var blockType:Int;
	public var blockHp:Int;
	public var coverType:Int;
	public var effect:Int;

	public function new(type)
	{
		if (type == "earth")
			createEarthTile();
		else if (type == "stone")
			createRockTile();
		else if (type == "water")
			createWaterTile();
		else
		{

		}

	}

	private function createRockTile()
	{
		groundType = 2; // 0 -earth, 2 - rock, 1 - water;
		blockType = 2; // 1- flat, 2 cubic;
		blockHp = 500; // -1 - no hp
		coverType = 2; // 0 - earth, 2- rock, 1 - water
		effect = 0; // 0 - no effects;
	}

	private function createEarthTile()
	{
		groundType = 0;
		blockType = 1;
		blockHp = -1;
		coverType = 0;
		effect = 0;
	}

	private function createWaterTile()
	{
		groundType = 1;
		blockType = 1;
		blockHp = -1;
		coverType = 1;
		effect = 0;
	}
}