module entities.entityRegistry;

import entities.entity;

class EntityRegistry(ComponentModules...)
{
	alias Registry = ComponentRegistry!(ComponentModules);

	private Registry registry = new Registry();

	Entity create()
	{
		return Entity(nextID++);
	}

	void destroy(Entity entity)
	{
		registry.removeAll(entity);
	}

private:
	ulong nextID = 1;
}