module ecs.systems.group;

import ecs.systems.system;

final class SystemGroup : Initializing, Updating
{
	SystemGroup Add(Initializing system)
	{
		initializing ~= system;

		return this;
	}

	SystemGroup Add(Updating system)
	{
		updating ~= system;

		return this;
	}

	void startUp()
	{
		foreach(initializee;initializing)
		{
			initializee.startUp();
		}
	}

	void shutDown()
	{
		foreach(initializee;initializing)
		{
			initializee.shutDown();
		}
	}

	void update(float elapsedTime)
	{
		foreach(updatee; updating)
		{
			updatee.update(elapsedTime);
		}
	}

private:
	Initializing[] initializing;
	Updating[] updating;
}