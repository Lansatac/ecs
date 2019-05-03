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
		Components componentRegistry() { return _registry; }


		bool has(TComponent)()
		{
			return _registry.has!TComponent(this.id);
		}

		Entity add(TComponent)(TComponent component)
		{
			_registry.add(this.id, component);
			return this;
		}
		Entity remove(TComponent)()
		{
			_registry.remove!TComponent(this.id);
			return this;
		}
		TComponent get(TComponent)()
		{
			return _registry.get!TComponent(this.id);
		}
	}

	class Registry
	{

		private Components componentRegistry = new Components();
		public Components ComponentRegistry() { return componentRegistry; }

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
	import entities.component;

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
	alias Entities = EntityRegistry!("entities.entityRegistry");
	auto entities = new Entities.Registry();
	auto entity = entities.create();

	assert(entity.has!TestComponent == false);
	entity.add(TestComponent(5));
	assert(entity.has!TestComponent == true);
	assert(entity.get!(TestComponent).a == 5);


	entity.remove!TestComponent;
	assert(entity.has!TestComponent == false);
}