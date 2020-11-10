module ecs.systems.handleremoved;

import ecs.entities.component.registry;
import ecs.systems.system;

version(unittest) import fluent.asserts;

template HandleRemovedSystem(ComponentModules...)
{
	@safe
	abstract class HandleRemovedSystem(TComponent) : Updating
	{
		import std.typecons;

		alias Components = ComponentRegistry!(ComponentModules);
		alias Entity = Components.Entity;

		Tuple!(Entity, "Entity", TComponent, "Component")[] removed;

		this(Components.Registry registry)
		{
			registry.OnRemoved!TComponent.connect(&onRemoved);
		}

		private void onRemoved(Entity entity, TComponent component)
		{
			removed ~= tuple!("Entity", "Component")(entity, component);
		}

		final void update(float elapsedTime)
		{
			if(removed.length > 0)
			{
				foreach(removedEntity;removed)
				{
					handleRemoved(removedEntity.Entity, removedEntity.Component);
				}
				removed.length = 0;
			}
		}

		protected abstract void handleRemoved(Entity entity, TComponent component);
	}
}

version(unittest)
{
	import ecs.entities.component.component;

	@Component
	struct TestComponent
	{
	}
}

@safe
@("Removed system should dispatch remove events")
unittest
{
	import ecs.entities.registry : EntityRegistry;

	alias Entities = EntityRegistry!("ecs.systems.handleremoved");
	alias HandleRemoved = HandleRemovedSystem!("ecs.systems.handleremoved");
	alias Entity = Entities.Entity;
	auto entities = new Entities.Registry();

	auto entity1 = entities.create;

	class ListenerSystem : HandleRemoved!TestComponent
	{
		Entity expectedEntity;
		bool handled = false;
		this(Entities.Registry entityRegistry, Entity entity)
		{
			super(entityRegistry.ComponentRegistry);
			expectedEntity = entity;
		}
		
		override void handleRemoved(Entity entity, TestComponent component)
		{
			assert(entity == expectedEntity);
			handled = true;
		}
	}
	auto listener = new ListenerSystem(entities, entity1);
	entity1.add(TestComponent());
	entity1.remove!TestComponent;
	assert(listener.handled == false);
	listener.update(0f);
	assert(listener.handled == true);
}