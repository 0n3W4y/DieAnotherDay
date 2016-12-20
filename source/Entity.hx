package;

import openfl.Vector;

class Entity
{
	public var type:String;
	public var subType:String;
	public var race:String;
	public var id:String;

	private var _tileSize:Int;
	private var _components:Vector<Dynamic>;
	private var _componentsNew:Vector<Component>;


	public function new(type:String, race:String, subType:String, id:String, tileSize:Int):Void
	{
		_components = new Vector(0);
		this.type = type;
		this.subType = subType;
		this.id = id;
		this.race = race;
		this._tileSize = tileSize;
		init();
	}

	public function init():Void
	{
		
	}

	public function getComponent(componentName:String):Dynamic
	{
		for ( i in 0..._components.length)
		{
			if (componentName == _components[i].name)
				return _components[i];
		}

		return null;
	}

	public function setComponent(component:Component):Void
	{
		for ( i in 0..._components.length)
		{
			if (component.name == _components[i].name)
				_components[i] = component;
		}
	}

	public function addComponent(component:Component):Void
	{
		
		if (component.getParent() == null)
			component.setParent(this);
		
		var index:Int = _components.length;

		for ( i in 0..._components.length)
		{
			if (_components[i] != null && component.name == _components[i].name)
			{
				setComponent(component);
				return;
			}
		}

		for (j in 0..._components.length)			
		{
			if (_components[j] == null)
			{
				index = j;
				break;
			}
		}
	
		_components.set(index, component);
	}

	public function removeComponent(componentName:String):Void
	{
		for ( i in 0..._components.length)
		{
			if (componentName == _components[i].name)
				_components[i] = null;
		}
	}

	public function update(time:Float):Void
	{
		for (i in 0..._components.length)
			_components[i].update(time);
	}

	public function getTileSize():Int
	{
		return _tileSize;
	}
	
}