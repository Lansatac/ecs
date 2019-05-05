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
}
