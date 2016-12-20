package GridTileMap;

class GridTileMap
{
	public var cols:Int;
	public var rows:Int;

	
	private var _scene:Scene;


	public function new(scene:Scene, numCols:Int, numRows:Int )
	{
		cols = numCols;
		rows = numRows;
		_scene = scene;
	}	
}