package;

class Stats extends Component
{
	public var headHealth:Float;
	public var torsoHealth:Float;
	public var leftHandHealth:Float;
	public var rightHandHealth:Float;
	public var leftLegHealth:Float;
	public var rightLegHealth:Float;

	public var strength:Float;
	public var agility:Float;
	public var endurance:Float;
	public var charisma:Float;
	public var luck:Float;
	public var intellegence:Float;

	private var _headHealth:Float;
	private var _torsoHealth:Float;
	private var _leftHandHealth:Float;
	private var _rightHandHealth:Float;
	private var _leftLegHealth:Float;
	private var _rightLegHealth:Float;

	private var _strength:Float;
	private var _agility:Float;
	private var _endurance:Float;
	private var _charisma:Float;
	private var _luck:Float;
	private var _intellegence:Float;

	private var _isInited:Bool = false;

	public function new(parent:Entity, id:String):Void
	{
		super("Stats", id, parent);
		init();
	}

	private function init():Void
	{
		if(!_isInited)
		{
			headHealth = _headHealth = 10.0;
			torsoHealth = _torsoHealth = 10.0;
			leftHandHealth = _leftHandHealth = 10.0;
			rightHandHealth = _rightHandHealth = 10.0;
			leftLegHealth = _leftLegHealth = 10.0;
			rightLegHealth = _rightLegHealth = 10.0;

			strength = _strength = 5.0;
			agility = _agility = 5.0;
			endurance = _endurance = 5.0;
			charisma = _charisma = 5.0;
			luck = _luck = 5.0;
			intellegence = _intellegence = 5.0;

			_isInited = true;
		}
	}

	public function initialize(headHP:Float, torsoHP:Float, lhHP:Float, rhHP:Float, llHP:Float, rlHP:Float, str:Float, agi:Float, end:Float, cha:Float, lck:Float, int:Float):Void
	{
		headHealth = headHP;
		torsoHealth = torsoHP;
		leftHandHealth = lhHP;
		rightHandHealth = rhHP;
		leftLegHealth = llHP;
		rightLegHealth = rlHP;

		strength = str;
		agility = agi;
		endurance = end;
		charisma = cha;
		luck = lck;
		intellegence = int;
	}

	public function getHealth(name:String):Float
	{
		if (name == "Head")
			return _headHealth;
		else if (name == "Torso")
			return _torsoHealth;
		else if (name == "LeftHand")
			return _leftHandHealth;
		else if (name == "RightHand")
			return _rightHandHealth;
		else if (name == "LEftLeg")
			return _leftLegHealth;
		else if (name == "RightLeg")
			return _rightLegHealth;
		else
			return 0.0;
	}

	public function getStat(name:String):Float
	{
		if (name == "STR")
			return _strength;
		else if (name == "AGI")
			return _agility;
		else if (name == "END")
			return _endurance;
		else if (name == "CHA")
			return _charisma;
		else if (name == "LCK")
			return _luck;
		else if (name == "INT")
			return _intellegence;
		else
			return 0.0;
	}
}