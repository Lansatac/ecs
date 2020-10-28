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

	bool opEquals(const EntityID other) { return id == other.id; }
    bool opEquals(ref const EntityID other) { return id == other.id; }
    bool opEquals(const EntityID other) const { return id == other.id; } 
}
