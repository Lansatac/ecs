module ecs.entities.registry;

import ecs.entities.entity;
import ecs.entities.component.registry;

version(unittest) import fluent.asserts;

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

@("creating entities should have unique IDs")
unittest
{
	alias Entities = EntityRegistry!();
	auto entities = new Entities.Registry();

	const auto entity1 = entities.create();
	const auto entity2 = entities.create();
	
	assert(entity1.id != entity2.id);
}

@("adding components to entities should add component")
unittest
{
	alias Entities = EntityRegistry!("ecs.entities.registry");

	auto entities = new Entities.Registry();
	auto entity = entities.create();

	entity.has!TestComponent.should.equal(false);
	entity.add(TestComponent(5));
	assert(entity.has!TestComponent == true);
	assert(entity.get!(TestComponent).a == 5);


	entity.remove!TestComponent;
	assert(entity.has!TestComponent == false);
}

@("destroying entity should remove components")
unittest
{
	alias Entities = EntityRegistry!("ecs.entities.registry");

	auto entities = new Entities.Registry();
	auto entity = entities.create();

	entity.add(TestComponent(5));
	entities.destroy(entity);

	entity.has!TestComponent.should.equal(false);
}