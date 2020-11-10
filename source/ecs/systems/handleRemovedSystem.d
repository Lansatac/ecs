module ecs.systems.handleremovedsystem;

import ecs.entities.componentregistry;
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

		final void Update(float elapsedTime)
		{
			if(removed.length > 0)
			{
				foreach(removedEntity;removed)
				{
					HandleRemoved(removedEntity.Entity, removedEntity.Component);
				}
				removed.length = 0;
			}
		}

		protected abstract void HandleRemoved(Entity entity, TComponent component);
	}
}

version(unittest)
{
	import ecs.entities.component;

	@Component
	struct TestComponent
	{
	}
}

@safe
@("Removed system should dispatch remove events")
unittest
{
	import ecs.entities.entityRegistry : EntityRegistry;

	alias Entities = EntityRegistry!("ecs.systems.handleremovedsystem");
	alias HandleRemoved = HandleRemovedSystem!("ecs.systems.handleremovedsystem");
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
		
		override void HandleRemoved(Entity entity, TestComponent component)
		{
			assert(entity == expectedEntity);
			handled = true;
		}
	}
	auto listener = new ListenerSystem(entities, entity1);
	entity1.add(TestComponent());
	entity1.remove!TestComponent;
	assert(listener.handled == false);
	listener.Update(0f);
	assert(listener.handled == true);
}