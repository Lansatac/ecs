module entities.entityRegistry;

import entities.entity;
import entities.componentRegistry;

template EntityRegistry(ComponentModules...)
{
	alias Components = ComponentRegistry!(ComponentModules);

	struct Entity
	{
		this(EntityID id, Components registry)
		{
			this.id = id;
			this._registry = registry;
		}

		immutable EntityID id;
		private Components _registry;
		Components registry() { return _registry; }

	}

	class Registry
	{

		private Components registry = new Components();

		Entity create()
		{
			return Entity(EntityID(nextID++), registry);
		}

		void destroy(EntityID entity)
		{
			registry.removeAll(entity);
		}

	private:
		ulong nextID = 1;
	}
}

unittest
{
	alias Entities = EntityRegistry!();
	auto entities = new Entities.Registry();

	auto entity1 = entities.create();
	auto entity2 = entities.create();
	
	assert(entity1.id != entity2.id);
}