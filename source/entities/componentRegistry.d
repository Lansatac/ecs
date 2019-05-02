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
			"public void add(Entity entity, " ~ ComponentType ~ " component)" ~
			"{" ~
				"addComponent(entity, component, " ~ ComponentType ~ "Registry);" ~
			"}"
		);

		mixin(
			"public void remove" ~ ComponentType ~ "(Entity entity)" ~
			"{" ~
				"removeComponent(entity, " ~ ComponentType ~ "Registry);" ~
			"}"
		);

		mixin(
			"public bool has" ~ ComponentType ~ "(Entity entity)" ~
			"{" ~
				"return hasComponent(entity, " ~ ComponentType ~ "Registry);" ~
			"}"
		);
	
		mixin(
			"public " ~ ComponentType ~ " get" ~ ComponentType ~ "(Entity entity)" ~
			"{" ~
				"return getComponent(entity, " ~ ComponentType ~ "Registry);" ~
			"}"
		);
	
		mixin(
			"public " ~ ComponentType ~ "[] getAll" ~ ComponentType ~ "(Entity entity)\n" ~
			"{" ~
				"return getAllComponents!" ~ ComponentType ~ "(" ~ ComponentType ~ "Registry);" ~
			"}"
		);

		mixin("" ~ ComponentType ~ "[Entity] " ~ ComponentType ~ "Registry;");
	}



	public void removeAll(Entity entity)
	{
		static foreach(ComponentType; Components)
		{
			mixin("removeComponent(entity, " ~ ComponentType ~ "Registry);");
		}
	}

	private void addComponent(TComponent)(Entity entity, TComponent component, ref TComponent[Entity] storage)
	{
		storage[entity] = component;
	}

	private void removeComponent(TComponent)(Entity entity, ref TComponent[Entity] storage)
	{
		storage.remove(entity);
	}

	private bool hasComponent(TComponent)(Entity entity, ref TComponent[Entity] storage)
	{
		return (entity in storage) != null;
	}

	private TComponent getComponent(TComponent)(Entity entity, ref TComponent[Entity] storage)
	{
		return storage[entity];
	}

	private TComponent[] getAllComponents(TComponent)(ref TComponent[Entity] storage)
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