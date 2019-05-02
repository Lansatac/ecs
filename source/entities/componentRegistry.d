module entities.componentRegistry;

import entities.component;
import entities.entity;


@safe
class ComponentRegistry(ModuleNames...)
{
	static foreach(Module; ModuleNames)
	{
		mixin("import " ~ Module ~ ";");

		template StaticFilter(alias Pred, T...)
		{
			import std.meta;
		    static if (T.length == 0)
		        alias AliasSeq!() StaticFilter;
		    else static if (Pred!(T[0]))
		        alias AliasSeq!(T[0], StaticFilter!(Pred, T[1 .. $])) StaticFilter;
		    else
		        alias StaticFilter!(Pred, T[1 .. $]) StaticFilter;
		}

		template isComponent(string name)
		{
			import std.traits;
		mixin("
		      static if (hasUDA!(" ~ name ~ " , Component))
		          enum bool isComponent = true;
		      else
		        enum bool isComponent = false;");
		}

		template extractComponents(string moduleName, members...)
		{
		    alias StaticFilter!(isComponent,members) extractComponents;
		}

		template components(string moduleName)
		{
		    mixin("alias extractComponents!(moduleName, __traits(allMembers, " ~
		moduleName ~ ")) components;");
		}

		alias Components = components!Module;

		static foreach(ComponentType; Components)
		{
			mixin(
				"public void add(Entity entity, " ~ ComponentType ~ " component)" ~
				"{" ~
					"addComponent(entity, component, " ~ ComponentType ~ "registry);" ~
				"}"
			);

			mixin(
				"public void remove" ~ ComponentType ~ "(Entity entity)" ~
				"{" ~
					"removeComponent(entity, " ~ ComponentType ~ "registry);" ~
				"}"
			);

			mixin(
				"public bool has" ~ ComponentType ~ "(Entity entity)" ~
				"{" ~
					"return hasComponent(entity, " ~ ComponentType ~ "registry);" ~
				"}"
			);
		
			mixin(
				"public " ~ ComponentType ~ " get" ~ ComponentType ~ "(Entity entity)" ~
				"{" ~
					"return getComponent(entity, " ~ ComponentType ~ "registry);" ~
				"}"
			);
		
			mixin(
				"public " ~ ComponentType ~ "[] getAll" ~ ComponentType ~ "(Entity entity)\n" ~
				"{" ~
					"return getAllComponents!" ~ ComponentType ~ "(" ~ ComponentType ~ "registry);" ~
				"}"
			);

			mixin("" ~ ComponentType ~ "[Entity] " ~ ComponentType ~ "registry;");
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