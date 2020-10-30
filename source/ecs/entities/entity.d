module ecs.entities.entity;

@safe
struct EntityID
{
	import std.typecons;
	private ulong id;
	mixin Proxy!id;

	this(ulong id)
	{
		this.id = id;
	}

	bool opEquals()(auto ref const EntityID other) const { return id == other.id; }
}
