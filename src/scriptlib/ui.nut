/*
	nEngine	SQUIRREL binding API.
	Copyright 2005~2008 Emmanuel Julien.
*/


//-----------------------------------
function    WindowCenterPivot(window)
{
	local   size = WindowGetSize(window);
	WindowSetPivot(window, size.x * 0.5, size.y * 0.5);
}
