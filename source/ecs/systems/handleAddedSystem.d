module ecs.systems.handleAddedSystem;

import ecs.entities.componentRegistry;
import ecs.systems.system;

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
	import ecs.entities.component;

	@Component @safe
	struct TestComponent
	{
	}
}

@safe
unittest
{
	import ecs.entities.entityRegistry;

	alias Entities = EntityRegistry!("ecs.systems.handleAddedSystem");
	alias HandleAdded = HandleAddedSystem!("ecs.systems.handleAddedSystem");
	alias Entity = Entities.Entity;
	auto entities = new Entities.Registry();

	auto entity1 = entities.create;
	auto entity2 = entities.create;

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