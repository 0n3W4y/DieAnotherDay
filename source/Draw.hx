package;

class Draw extends Component
{

	public var tileIndex:Int; //index from tileMap;
	public var currentTile:Int; //current tile on tileMap;
	public var isTileChanged:Bool = false; // for global draw;
	public var isDirectionChanged:Bool = false; // for global draw;
	public var phaseCounter:Int = 0;

	private var _inited:Bool = false;
	private var _parentType:String;
	private var _tile:Int;
	

	public function new(parent:Entity, id:String)
	{
		super("Draw", id, parent);
		init();
	}

	private function init():Void
	{
		if (!_inited)
		{
			_parentType = _parent.type;
			_inited = true;
		}
	}

	public function initialize(index:Int, tile:Int):Void
	{
		tileIndex = index;
		currentTile = tile;
		_tile = tile;
	}

	override public function update(time:Float)
	{
		if (_parentType == "Plant")
			grow();

		if (_parentType != "Plant")
			changeTileDirection();
	}

	private function grow():Void // while growing
	{
		var grow:LifeCircle = _parent.getComponent("LifeCircle");
		if (grow.isPhaseChanged)
		{
			currentTile = _tile + grow.getPhase() - 1;
			isTileChanged = true;
			grow.isPhaseChanged = false;
			phaseCounter++;
			return;
		}

		if (grow.isCircleNulled)
		{
			currentTile = _tile; // to 1 phase;
			isTileChanged = true;
			grow.isCircleNulled = false;
			return;
		}


	}

	private function changeTileDirection()
	{
		var move:Move = _parent.getComponent("Move");
		var dir:Int = move.direction;

		currentTile = _tile + dir;
		isDirectionChanged = true;

	}

	public function getTile():Int
	{
		return _tile;
	}

}