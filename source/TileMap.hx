package;

import haxe.ds.Vector;

class TileMap 
{
	public var width : Int;
	public var height : Int;
	public var tile : Vector<Tiles>;

	public function new(w:Int, h:Int)
	{
		this.width = w;
		this.height = h;
		this.tile = new Vector(w*h);
	}

}