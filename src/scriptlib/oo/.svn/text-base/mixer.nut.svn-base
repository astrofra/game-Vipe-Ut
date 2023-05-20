

/*!
	@short	Mixer binding.
*/
class		Mixer
{
	handle			=	0;

	function        SoundStart(sound)
	{	MixerSoundStart(handle, sound.GetHandle());	}
	function        ChannelStart(channel, sound)
	{	MixerChannelStart(handle, channel, sound.GetHandle());	}

	function		GetHandle()
	{	return handle;	}
	constructor(h)
	{	handle = h;	}
}
