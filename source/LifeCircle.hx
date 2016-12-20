package;

class LifeCircle extends Component
{
	public var year:Int;
	public var month:Int;
	public var day:Float;
	public var ageLimit:Int;
	public var growingSpeed:Float;
	public var isReachedAgeLimit:Bool;
	public var isPhaseChanged:Bool = false; //for component draw!
	public var isCircleNulled:Bool = false;

	private var _phase:Int; // 1 - start, 2 - grow a little, 3 - strong age, 4 - old age ( almost ready);
	private var _isInited:Bool = false;
	private var _tickCounter:Int = 0;


	public function new(parent:Entity, id:String):Void
	{
		super("LifeCircle", id, parent);
		init();
	}

	private function init():Void
	{
		if(!_isInited)
		{
			year = 0;
			month = 0;
			day = 0.0;
			growingSpeed = 0.001;
			isReachedAgeLimit = false;
			ageLimit = 100;
			_isInited = true;
			_phase = 1;
		}
		
	}

	public function initialize(newAge:Int, newMonth:Int, newDay:Float, growSpeed:Int, ageLmt:Int, dead:Bool = false):Void
	{
		year = newAge;
		month = newMonth;
		day = newDay;
		growingSpeed = growSpeed/1000;
		isReachedAgeLimit = dead;
		ageLimit = ageLmt;

		for (i in 0...3)
		{
			changePhase();
		}

	}

	override public function update(time:Float):Void
	{
		if (!isReachedAgeLimit)
		{
			growing(time);
		}
		
	}

	private function growing(time:Float)
	{
		day += time*growingSpeed;
		if (day >= 30)
		{
			day -= 30;
			month++;
			if (month >= 12)
			{
				month = 0;
				year++;
				changePhase();
				if (year >= ageLimit)
				{
					isReachedAgeLimit = true;
					year = ageLimit;
					day = 0.0;
				}
			}
		}
	}

	private function changePhase():Void
	{
		if (_phase != 4)
		{
			if (year > 25*_phase) // each 25 age we change tile and growing phase;
			{
				_phase++;
				isPhaseChanged = true;
			}
				
		}

	}

	public function getPhase():Int
	{
		return _phase;
	}

	public function nullCircle():Void
	{
		year = 0;
		month = 0;
		day = 0.0;
		isReachedAgeLimit = false;
		_phase = 1;
		isCircleNulled = true;
	}
}