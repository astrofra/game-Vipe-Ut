	Include("scriptlib/nad.nut");

try
{	__DEFINE_AI_TRACKS_LOADED__ = 1;	}
catch(e)
{
	__DEFINE_AI_TRACKS_LOADED__ <- 1;

	SceneLoadAIPath(g_scene, "tracks/firestar/tracks.nms");
}

g_race_manager_instance	<-	0;

//-----------------
class	RaceManager
//-----------------
{
	tracks			= 	0;
	motion_len		=	0;
	track_idx		=	2;

	bonus_item		=	0;

	start_countdown =	0;

	total_lap		=	0.0;
	lap_counter		=	0.0;

	sfx_lap			=	0;
	sfx_speech_channel
					=	0;

	sfx_start		=	0;

	bgm_channel		=	0;
	bg_music		=	0;
	
	//------------------------
	function	OnSetup(item)
	//------------------------
	{
		tracks = array(5,0);
		motion_len = array(5,0);

		for (local n = 0; n < 5; n++)
		{
			tracks[n] = SceneFindAIPath(g_scene, "track_" + n);
			if (AIPathIsValid(tracks[n]))
			{
				print("Found track #" + n);
				print("Track length = " + MotionGetLength(AIPathGetMotion(tracks[n])));
				motion_len[n] = MotionGetLength(AIPathGetMotion(tracks[n]));
				
				local	g_item = SceneFindItem(g_scene, "start_line_" + n);
				local	g_pos = MotionEvaluatePosition(AIPathGetMotion(tracks[n]), motion_len[n] + 1.0);
				ItemSetPosition(g_item, g_pos);
			}
		}

		//	Bonus
		bonus_item = array(3,0);

		for(local	n = 0; n < 3; n++)
		{
			local	bonus = SceneFindItem(g_scene, "bonus_" + n);
			bonus_item.append(bonus);
			ItemSetCommandList(bonus, "torotation 0.0,0,0,0; torotation 3.0,0,360.0,0; next;");
		}

		//	Audio

		local	max_lap_sfx = 7;
		sfx_lap = array(max_lap_sfx,0);

		for (local n = 0; n < max_lap_sfx; n++)
			sfx_lap[n] = EngineLoadSound(g_engine, "sfx/sfx_lap_" + n + ".wav");

		sfx_speech_channel = MixerChannelLock(g_mixer);
		MixerChannelSetLoopMode(g_mixer, sfx_speech_channel, LoopNone); //LoopNone
		sfx_start = EngineLoadSound(g_engine, "sfx/sfx_start_0.wav");

		bgm_channel = MixerChannelLock(g_mixer);
		MixerChannelSetLoopMode(g_mixer, bgm_channel, LoopRepeat); //LoopNone
		bg_music = EngineLoadSound(g_engine, "musics/rez-subatomic_16.wav");

		g_race_manager_instance = ItemGetScriptInstance(item);
		print("RaceManager :: OnSetup() done");

		//StartMusic();
	}

	//----------------------------
	function	PlayStartRaceSfx()
	{	
		MixerChannelSetGain(g_mixer, sfx_speech_channel, 0.15);
		MixerChannelStart(g_mixer, sfx_speech_channel, sfx_start);	
	}

	//----------------------
	function	StartMusic()
	{	
		StopMusic();
		MixerChannelSetGain(g_mixer, bgm_channel, 0.15);
		MixerChannelStart(g_mixer, bgm_channel, bg_music);	
	}

	//----------------------
	function	StopMusic()
	{	MixerChannelStop(g_mixer, bgm_channel);	}

	//-------------------------
	function	LapCount(speed)
	//-------------------------
	{

		if (g_game_state == 3)
			return;

		//	Lap
		total_lap += speed;

		if (total_lap > motion_len[track_idx])
		{
			// Increment lap
			total_lap -= motion_len[track_idx];
			lap_counter++;

			if (lap_counter >= sfx_lap.len())
			{
				ItemSetInvisible(SceneFindItem(g_scene, "osd_race_finished"), false);
				g_game_state = 3;
				return;
			}

			//	Audio feedback
			print("Lap #" + lap_counter);
			MixerChannelStart (g_mixer, g_main_player_instance.sfx_special_channel , sfx_lap[lap_counter%(sfx_lap.len() + 1)]);
		}
	}

	//------------------------
	function	OnUpdate(item)
	//------------------------
	{
		
		if (g_game_state == 1)
		{
			if (g_clock - start_countdown > SecToTick(Sec(3.6)))
			{
				StartMusic();
				g_game_state = 2;
			}
		}
		
	}

}