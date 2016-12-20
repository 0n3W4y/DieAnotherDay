package;

import Coordinates;

class Move extends Component
{
	public var speed:Float;
	public var coordinates:Coordinates;
	public var x:Float;
	public var y:Float;
	public var direction:Int; //0 - bottom, 1 - left, 2- right, 3- top;
	private var _isInited:Bool = false;
	private var _tileSize:Int;

	public function new(parent:Entity, id:String):Void
	{
		super("Move", id, parent);
		init();
	}

	private function init():Void
	{
		if (!_isInited)
		{
			coordinates = new Coordinates(0, 0);
			speed = 1.0;
			_isInited = true;
			x = 0.0;
			y = 0.0;
			direction = 0; // default - bottom direction
			_tileSize = _parent.getTileSize();

		}
		
	}

	public function initialize(coords:Coordinates, newSpeed:Float):Void
	{
		speed = newSpeed;
		x = coords.x;
		y = coords.y;
		coordinates.x = coords.x;
		coordinates.y = coords.y;

	}

	override public function update(time:Float):Void
	{
		updateCoords();
		updateDirection();
	}

	private function updateCoords():Void
	{
		coordinates.x = Math.floor(x/_tileSize);
		coordinates.y = Math.floor(y/_tileSize);
	}

	private function updateDirection():Void
	{
		//direction 0 - bottom, 1 - left 2 - right 3 - top;
	}
}
