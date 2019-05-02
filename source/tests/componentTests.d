module tests.componentTests;

import entities.component;
import entities.entity;

@Component struct TestComponentA
{
	int a;
	int b;
}


@Component struct TestComponentB
{
	string a;
}

unittest
{
	import entities.componentRegistry;

	auto registry = new ComponentRegistry!("tests.componentTests");

	auto entity = Entity(0);

	auto component = TestComponentA();
	component.a = 5;
	component.b = 10;

	assert(registry.hasTestComponentA(entity) == false);
	registry.add(entity, component);
	assert(registry.hasTestComponentA(entity) == true);
	assert(registry.getTestComponentA(entity) == component);
	registry.removeTestComponentA(entity);
	assert(registry.hasTestComponentA(entity) == false);


	auto componentB = TestComponentB();
	componentB.a = "some";
	assert(registry.hasTestComponentB(entity) == false);
}

//void main()
//{

//}