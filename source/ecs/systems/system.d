module ecs.systems.system;

import ecs.entities.entity;

interface Initializing
{
	void StartUp();
	void ShutDown();
}

interface Updating
{
	void Update(float elapsedTime);
}