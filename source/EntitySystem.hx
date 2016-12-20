package;



class EntitySystem
{
	private var _game:Game;

	public function new(game:Game)
	{
		_game = game;
	}

	public function init():Void
	{

	}

	public function createEntity(entity:String, components:Array<String> = null):Entity
	{
		var type:String;
		var race:String = entity;
		var subType:String;
		var tileSize:Int = 32; // default;

		if (entity == "Human" || entity == "Goblin")
		{
			subType = "Man"; // or Woman;
			type = "Humaniod";
		}
		else if (entity == "Birch")
		{
			type = "Plant";
			race = "Tree";
			subType = entity;
		}
		else if (entity == "Raspberries")
		{
			type = "Plant";
			race = "Bush";
			subType = entity;
		}
		else
			return null;

		var id:String = createId();
		var result:Entity = new Entity(type, race, subType, id, tileSize);

		if (components != null)
		{
			for ( i in 0...components.length)
			{
				var component:Component = createComponent(result, components[i]);
				result.addComponent(component);
			}
		}
		return result;
	}

	public function createComponent(entity:Entity, componentName:String):Component
	{
		var id:String = createId();
		if (componentName == "Move")
			return new Move(entity, id);
		else if (componentName == "LifeCircle")
			return new LifeCircle(entity, id);
		else if (componentName == "Stats")
			return new Stats(entity, id);
		else if (componentName == "Draw")
			return new Draw(entity, id);
		else
			return null;
	}

	private function createId():String
	{
		return "0";
	}
}