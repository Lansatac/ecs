module ecs.entities.componentregistry;

import ecs.entities.component;
import ecs.entities.entity;

 version(unittest) import fluent.asserts;

template ComponentRegistry(ComponentModules...)
{
	@safe
	class Registry
	{
		static foreach(Module; ComponentModules)
		{
			mixin("import " ~ Module ~ ";");
		}

		alias Components = allComponentsInModules!ComponentModules;

		static foreach(ComponentType; Components)
		{		
			mixin(
				"private EntitySignal _on" ~ ComponentType ~ "Added = new EntitySignal;" ~
				"public EntitySignal OnAdded(T:" ~ ComponentType ~ ")()" ~
				"{" ~
					"return _on" ~ ComponentType ~ "Added;" ~
				"}"
			);

			mixin(
				"private ComponentSignal!" ~ ComponentType ~ " _on" ~ ComponentType ~ "Removed = new ComponentSignal!" ~ ComponentType ~ ";" ~
				"public ComponentSignal!" ~ ComponentType ~ " OnRemoved(T:" ~ ComponentType ~ ")()" ~
				"{" ~
					"return _on" ~ ComponentType ~ "Removed;" ~
				"}"
			);

			mixin("private " ~ ComponentType ~ "[EntityID] " ~ ComponentType ~ "Registry;");
			mixin(
				"private ref " ~ ComponentType ~ "[EntityID] " ~ "registryStorage(T : " ~ ComponentType ~ ")()" ~
				"{" ~
					"return " ~ ComponentType ~ "Registry;" ~
				"}"
				);
		}

		public void removeAll(EntityID entity) nothrow
		{
			static foreach(ComponentType; Components)
			{
				mixin("remove!" ~ ComponentType ~ "(entity);");
			}
		}

		void add(TComponent)(EntityID entity, TComponent component) nothrow
		{
			registryStorage!TComponent[entity] = component;
			try
			{
				OnAdded!TComponent.emit(Entity(entity, this));
			}
			catch(Exception){}
		}

		void remove(TComponent)(EntityID entity) nothrow
		{
			auto component = get!TComponent(entity);
			registryStorage!TComponent.remove(entity);
			try
			{
				OnRemoved!TComponent.emit(Entity(entity, this), component);
			}
			catch(Exception){}
		}

		bool has(TComponent)(EntityID entity) nothrow
		{
			return (entity in registryStorage!TComponent) != null;
		}

		TComponent get(TComponent)(EntityID entity)
		{
			return registryStorage!TComponent[entity];
		}

		private TComponent[] getAllComponents(TComponent)()
		{
			import std.range : byValue;
			return registryStorage!TComponent.byValue().array;
		}
	}

	@safe
	struct Entity
	{
		import std.experimental.typecons : Final, makeFinal;

		alias id this;

		this(EntityID id, Registry registry) pure nothrow
		{
			this.id = id;
			this._registry = makeFinal(registry);
		}

		immutable EntityID id;
		private Final!Registry _registry;
		Registry componentRegistry() { return _registry; }

		bool has(TComponent)()
		{
			return _registry.has!TComponent(this);
		}

		Entity add(TComponent)(TComponent component)
		{
			_registry.add(this, component);
			return this;
		}
		Entity remove(TComponent)()
		{
			_registry.remove!TComponent(this);
			return this;
		}
		TComponent get(TComponent)()
		{
			return _registry.get!TComponent(this);
		}

		bool opEquals(const Entity other) { return id == other.id; }
	    bool opEquals(ref const Entity other) { return id == other.id; }
	    bool opEquals(const Entity other) const { return id == other.id; } 
	}

	@trusted // bleh :(
	class EntitySignal
	{
		import std.signals;

		mixin Signal!(Entity);
	}

	@trusted // bleh :(
	class ComponentSignal(TComponent)
	{
		import std.signals;

		mixin Signal!(Entity, TComponent);
	}
}

template allComponentsInModule(string moduleName)
{
	mixin("import " ~ moduleName ~ ";");
	template isComponent(string name)
	{
		import std.traits;
		mixin("
			static if (hasUDA!(" ~ name ~ " , Component))
				enum bool isComponent = true;
			else
				enum bool isComponent = false;");
	}

	template filterComponents(members...)
	{
		import std.meta;
		alias Filter!(isComponent,members) filterComponents;
	}

	mixin("alias filterComponents!(__traits(allMembers, " ~ moduleName ~ ")) allComponentsInModule;");
}

template allComponentsInModules(Modules...)
{
	import std.meta;
	alias allComponentsInModules = staticMap!(allComponentsInModule, Modules);
}

version(unittest)
{
	@Component
	struct TestComponentA
	{
		int a;
		int b;
	}

	@Component
	struct TestComponentB
	{
		string a;
	}

	alias Components = ComponentRegistry!("ecs.entities.componentregistry");
}

@("Add and remove components")
unittest
{
	auto registry = new Components.Registry();

	auto entity = EntityID(1);

	auto componentA = TestComponentA();
	componentA.a = 5;
	componentA.b = 10;

	assert(registry.has!TestComponentA(entity) == false);
	registry.add(entity, componentA);
	assert(registry.has!TestComponentA(entity) == true);
	assert(registry.get!TestComponentA(entity) == componentA);
	registry.remove!TestComponentA(entity);
	assert(registry.has!TestComponentA(entity) == false);


	auto componentB = TestComponentB();
	componentB.a = "some";
	assert(registry.has!TestComponentB(entity) == false);
	registry.add(entity, componentB);
	assert(registry.has!TestComponentB(entity) == true);


	registry.add(entity, componentA);
	registry.add(entity, componentB);
	assert(registry.has!TestComponentA(entity) == true);
	assert(registry.has!TestComponentB(entity) == true);
	registry.removeAll(entity);
	registry.has!TestComponentA(entity).should.equal(false);
	assert(registry.has!TestComponentB(entity) == false);
}

@("listen for add component event")
unittest
{
	auto registry = new Components.Registry();

	@safe
	class Watcher
	{
		this(EntityID entity) { this.entity = entity; }
		EntityID entity;
		bool signalRecieved = false;
		void watch(Components.Entity e)
		{
			assert(e == entity);
			signalRecieved = true;
		}
	}

	auto entity = EntityID(1);
	auto watcher = new Watcher(entity);
	registry.OnAdded!TestComponentA().connect((&watcher.watch));
	registry.add(entity, TestComponentA());
	watcher.signalRecieved.should.equal(true);

	
	watcher.signalRecieved = false;
	registry.add(entity, TestComponentB());
	watcher.signalRecieved.should.equal(false);

}