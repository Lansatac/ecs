module tests.componentTests;

import entities.component;
import entities.entity;

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

unittest
{
	import entities.componentRegistry;

	auto registry = new ComponentRegistry!("tests.componentTests");

	auto entity = Entity(0);

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