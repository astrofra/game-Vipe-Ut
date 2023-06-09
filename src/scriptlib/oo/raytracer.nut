

/*!
	@short	Raytracer binding.
*/
class		Raytracer
{
	handle			=	0;

	function		SetScene(scene)
	{	return RaytracerSetScene(handle, scene.GetHandle());	}
	function		Trace(path, width, height)
	{	return RaytracerTrace(handle, path, width, height);	}

	function        SetInterlace(interlaced, even_frame)
	{	RaytracerSetInterlace(handle, interlaced, even_frame);	}
	function        StartInterlacedSequence()
	{	RaytracerStartInterlacedSequence(handle);	}
	function        SetAntialias(enable, sample_count, threshold, jitter)
	{	RaytracerSetAntialias(handle, enable, sample_count, threshold, jitter);	}

	constructor(raytracer)
	{	handle = raytracer;	}
}
