module ecs.systems.handleaddedsystem;

import ecs.entities.componentregistry;
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

		final void Update(float elapsedTime)
		{
			if(added.length > 0)
			{
				foreach(entity;added)
				{
					HandleAdded(entity);
				}
				added.length = 0;
			}
		}

		protected abstract void HandleAdded(Entity entity);
	}
}

version(unittest)
{
	import ecs.entities.entityRegistry : EntityRegistry;
	import ecs.entities.component;

	alias Entities = EntityRegistry!("ecs.systems.handleaddedsystem");

	@Component @safe
	struct TestComponent
	{
	}
	
	alias HandleAdded = HandleAddedSystem!("ecs.systems.handleaddedsystem");
}

@("listener systems should handle entities that have components added")
@safe
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

		override void HandleAdded(Entity entity)
		{
			assert(entity == expectedEntity);
			handled = true;
		}
	}
	auto listener = new ListenerSystem(entities, entity1);
	entity1.add(TestComponent());
	assert(listener.handled == false);	//Don't process add until update
	listener.Update(0f);
	assert(listener.handled == true);
	listener.handled = false;
	listener.Update(0f);				//Don't process the same add again
	assert(listener.handled == false);
}