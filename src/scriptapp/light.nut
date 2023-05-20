	Include("scriptlib/nad.nut");

//----------
class	Light
{

	//------------------------
	function	OnSetup(item)
	//------------------------
	{
		print("Light flickering activated");
	}

	//------------------------
	function	OnUpdate(item)
	//------------------------
	{
		local	pos = Vector(Rand(-20,20),Rand(-20,20),Rand(-20,20));
		ItemSetPosition(item, pos);
	}

}