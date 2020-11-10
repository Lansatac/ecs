module ecs.systems.system;

import ecs.entities.entity;

interface Initializing
{
	void startUp();
	void shutDown();
}

interface Updating
{
	void update(float elapsedTime);
}