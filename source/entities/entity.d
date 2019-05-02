module entities.entity;

@safe
struct Entity
{
	this(ulong id)
	{
		this.id = id;
	}

	//bool opEquals(ref const Entity entity) const pure nothrow {
	//	return this.id == entity.id;
	//}

	//size_t toHash() const pure nothrow
	//{
	//	return cast(size_t)id;
	//}

private:
	immutable ulong id;
}
