	Include("scriptlib/nad.nut");

try
{	if (g_render_noshader == 1)
		print("GameManager :: g_render_noshader = 1");	
}
catch(e)
{
	g_render_noshader <- 0;
	print("GameManager :: g_render_noshader = 0");
}

g_game_state <-	-1;

//-----------------
class	GameManager
//-----------------
{

	vectrex_boot_timeout		= 0.0;
	
	vectrex_static_channel		= 0;
	vectrex_sfx_channel			= 0;
	vectrex_static_sfx			= 0;
	vectrex_boot_sfx			= 0;

	//------------------------
	function	OnSetup(item)
	//------------------------
	{

		//	Video emulation
		if (g_render_noshader == 1)
			g_render_noshader = true;
		else
			g_render_noshader = false;

		ItemSetInvisible(SceneFindItem(g_scene, "screen"), g_render_noshader);
		ItemSetInvisible(SceneFindItem(g_scene, "screen_no_shader"), !g_render_noshader);

		ItemSetInvisible(SceneFindItem(g_scene, "screen_menu"), g_render_noshader);
		ItemSetInvisible(SceneFindItem(g_scene, "screen_menu_no_shader"), !g_render_noshader);

		SceneSetCurrentCamera(g_scene, ItemCastToCamera(SceneFindItem(g_scene, "camera_menu")));

		//	Audio emulation
		vectrex_static_channel = MixerChannelLock(g_mixer);
		MixerChannelSetLoopMode(g_mixer, vectrex_static_channel, LoopRepeat); //LoopNone

		vectrex_sfx_channel = MixerChannelLock(g_mixer);
		MixerChannelSetLoopMode(g_mixer, vectrex_sfx_channel, LoopNone); //LoopNone

		vectrex_static_sfx = EngineLoadSound(g_engine, "sfx/sfx_vectrex_static.wav");
		vectrex_boot_sfx = EngineLoadSound(g_engine, "sfx/sfx_vectrex_boot_jingle.wav");

		MixerChannelSetGain(g_mixer, vectrex_static_channel, 0.5);
		MixerChannelStart(g_mixer, vectrex_static_channel, vectrex_static_sfx);	

		//	Boot emulation
		vectrex_boot_timeout = 0;

		//	Game logic
		g_game_state = -1;

		print("GameManager :: OnSetup() done");
	}

	//------------------------
	function	OnUpdate(item)
	{
		KeyboardUpdate();
		vectrex_boot_timeout++;

		if ((g_game_state == -1) && (vectrex_boot_timeout > 60))
		{
			ItemSetInvisible(SceneFindItem(g_scene, "front"), true);
			MixerChannelSetGain(g_mixer, vectrex_sfx_channel, 1.0);
			MixerChannelStart(g_mixer, vectrex_sfx_channel, vectrex_boot_sfx);	
			g_game_state = 0;
		}

		// Get keyboard thrust
		if (KeyboardSeekFunction(DeviceKeyPress, KeySpace))
		{
			if (g_game_state == 0)
			{
				g_game_state = 0.5;
				vectrex_boot_timeout = 0;
				ItemSetInvisible(SceneFindItem(g_scene, "front"), false);
			}
		}

		if (g_game_state == 0.5 && (vectrex_boot_timeout > 20))
		{
			g_race_manager_instance.start_countdown = g_clock;
			g_race_manager_instance.PlayStartRaceSfx();
			g_game_state = 1;

			SceneSetCurrentCamera(g_scene, ItemCastToCamera(SceneFindItem(g_scene, "camera")));
			ItemSetInvisible(SceneFindItem(g_scene, "front"), true);
		}
	}

}