module ecs.entities.entityRegistry;

import ecs.entities.entity;
import ecs.entities.componentRegistry;

template EntityRegistry(ComponentModules...)
{
	alias Components = ComponentRegistry!(ComponentModules);
	alias Entity = Components.Entity;

	@safe
	class Registry
	{
		private Components.Registry componentRegistry = new Components.Registry();
		public Components.Registry ComponentRegistry() { return componentRegistry; }

		Entity create()
		{
			return Entity(EntityID(nextID++), componentRegistry);
		}

		void destroy(EntityID entity)
		{
			componentRegistry.removeAll(entity);
		}

	private:
		ulong nextID = 1;
	}
}

version(unittest)
{
	import ecs.entities.component;

	@Component
	struct TestComponent
	{
		int a;
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

unittest
{
	alias Entities = EntityRegistry!("ecs.entities.entityRegistry");
	auto entities = new Entities.Registry();
	auto entity = entities.create();

	assert(entity.has!TestComponent == false);
	entity.add(TestComponent(5));
	assert(entity.has!TestComponent == true);
	assert(entity.get!(TestComponent).a == 5);


	entity.remove!TestComponent;
	assert(entity.has!TestComponent == false);
}


unittest
{
	alias Entities = EntityRegistry!("ecs.entities.entityRegistry");
	auto entities = new Entities.Registry();
	auto entity = entities.create();

	entity.add(TestComponent(5));
	assert(entity.has!TestComponent == true);

	entities.destroy(entity);
	assert(entity.has!TestComponent == false);
}