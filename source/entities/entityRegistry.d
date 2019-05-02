module entities.entityRegistry;

import entities.entity;

class EntityRegistry
{
	Entity create()
	{
		return Entity(nextID++);
	}

private:
	ulong nextID = 1;
}