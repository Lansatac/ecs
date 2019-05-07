module ecs.systems.systemGroup;

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

	void StartUp()
	{
		foreach(initializee;initializing)
		{
			initializee.StartUp();
		}
	}

	void ShutDown()
	{
		foreach(initializee;initializing)
		{
			initializee.ShutDown();
		}
	}

	void Update(float elapsedTime)
	{
		foreach(updatee; updating)
		{
			updatee.Update(elapsedTime);
		}
	}

private:
	Initializing[] initializing;
	Updating[] updating;
}