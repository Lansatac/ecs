module ecs.systems.handleadded;

import ecs.entities.component.registry;
import ecs.systems.system;

version(unittest) import fluent.asserts;

template HandleAddedSystem(ComponentModules...)
{
	@safe
	abstract class HandleAddedSystem(TComponent) : Updating
	{
		alias Components = ComponentRegistry!(ComponentModules);
		alias Entity = Components.Entity;

		Entity[] added;

		this(Components.Registry registry)
		{
			registry.OnAdded!TComponent.connect(&onAdded);
		}

		private void onAdded(Entity entity)
		{
			added ~= entity;
		}

		final void update(float elapsedTime)
		{
			if(added.length > 0)
			{
				foreach(entity;added)
				{
					handleAdded(entity);
				}
				added.length = 0;
			}
		}

		protected abstract void handleAdded(Entity entity);
	}
}

version(unittest)
{
	import ecs.entities.registry : EntityRegistry;
	import ecs.entities.component.component;

	alias Entities = EntityRegistry!("ecs.systems.handleadded");

	@Component @safe
	struct TestComponent
	{
	}
	
	alias HandleAdded = HandleAddedSystem!("ecs.systems.handleadded");
}

@safe
@("listener systems should handle entities that have components added")
unittest
{
	alias Entity = Entities.Entity;
	auto entities = new Entities.Registry();

	auto entity1 = entities.create;

	@safe
	class ListenerSystem : HandleAdded!TestComponent
	{
		Entity expectedEntity;
		bool handled = false;
		this(Entities.Registry entityRegistry, Entity entity)
		{
			super(entityRegistry.ComponentRegistry);
			expectedEntity = entity;
		}

		override void handleAdded(Entity entity)
		{
			assert(entity == expectedEntity);
			handled = true;
		}
	}
	auto listener = new ListenerSystem(entities, entity1);
	entity1.add(TestComponent());
	assert(listener.handled == false);	//Don't process add until update
	listener.update(0f);
	assert(listener.handled == true);
	listener.handled = false;
	listener.update(0f);				//Don't process the same add again
	assert(listener.handled == false);
}