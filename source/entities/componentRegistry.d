module entities.componentRegistry;

import entities.component;
import entities.entity;


@safe
class ComponentRegistry(ModuleNames...)
{
	static foreach(Module; ModuleNames)
	{
		mixin("import " ~ Module ~ ";");
	}

	alias Components = allComponentsInModules!ModuleNames;

	static foreach(ComponentType; Components)
	{
		mixin(
			"public void add(EntityID entity, " ~ ComponentType ~ " component)" ~
			"{" ~
				"addComponent(entity, component, " ~ ComponentType ~ "Registry);" ~
			"}"
		);

		mixin(
			"public void remove" ~ ComponentType ~ "(EntityID entity)" ~
			"{" ~
				"removeComponent(entity, " ~ ComponentType ~ "Registry);" ~
			"}"
		);

		mixin(
			"public bool has" ~ ComponentType ~ "(EntityID entity)" ~
			"{" ~
				"return hasComponent(entity, " ~ ComponentType ~ "Registry);" ~
			"}"
		);
	
		mixin(
			"public " ~ ComponentType ~ " get" ~ ComponentType ~ "(EntityID entity)" ~
			"{" ~
				"return getComponent(entity, " ~ ComponentType ~ "Registry);" ~
			"}"
		);
	
		mixin(
			"public " ~ ComponentType ~ "[] getAll" ~ ComponentType ~ "(EntityID entity)\n" ~
			"{" ~
				"return getAllComponents!" ~ ComponentType ~ "(" ~ ComponentType ~ "Registry);" ~
			"}"
		);

		mixin("" ~ ComponentType ~ "[EntityID] " ~ ComponentType ~ "Registry;");
	}



	public void removeAll(EntityID entity)
	{
		static foreach(ComponentType; Components)
		{
			mixin("removeComponent(entity, " ~ ComponentType ~ "Registry);");
		}
	}

	private void addComponent(TComponent)(EntityID entity, TComponent component, ref TComponent[EntityID] storage)
	{
		storage[entity] = component;
	}

	private void removeComponent(TComponent)(EntityID entity, ref TComponent[EntityID] storage)
	{
		storage.remove(entity);
	}

	private bool hasComponent(TComponent)(EntityID entity, ref TComponent[EntityID] storage)
	{
		return (entity in storage) != null;
	}

	private TComponent getComponent(TComponent)(EntityID entity, ref TComponent[EntityID] storage)
	{
		return storage[entity];
	}

	private TComponent[] getAllComponents(TComponent)(ref TComponent[EntityID] storage)
	{
		import std.range;
		return storage.byValue().array;
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
}

unittest
{
	auto registry = new ComponentRegistry!("entities.componentRegistry");

	auto entity = EntityID(1);

	auto componentA = TestComponentA();
	componentA.a = 5;
	componentA.b = 10;

	assert(registry.hasTestComponentA(entity) == false);
	registry.add(entity, componentA);
	assert(registry.hasTestComponentA(entity) == true);
	assert(registry.getTestComponentA(entity) == componentA);
	registry.removeTestComponentA(entity);
	assert(registry.hasTestComponentA(entity) == false);


	auto componentB = TestComponentB();
	componentB.a = "some";
	assert(registry.hasTestComponentB(entity) == false);
	registry.add(entity, componentB);
	assert(registry.hasTestComponentB(entity) == true);


	registry.add(entity, componentA);
	registry.add(entity, componentB);
	assert(registry.hasTestComponentA(entity) == true);
	assert(registry.hasTestComponentB(entity) == true);
	registry.removeAll(entity);
	assert(registry.hasTestComponentA(entity) == false);
	assert(registry.hasTestComponentB(entity) == false);
}