	Include("scriptlib/nad.nut");

try
{	__DEFINE_AI_TRACKS_LOADED__ = 1;	}
catch(e)
{
	__DEFINE_AI_TRACKS_LOADED__ <- 1;

	SceneLoadAIPath(g_scene, "tracks/firestar/tracks.nms");
}

g_main_player_instance	<-	0;

g_pad		<-	0;
device_list	<-	[];
//device_list	= GetDeviceList(DeviceTypeGame);

if (device_list.len())
	g_pad = DeviceNew(device_list[0].id);

KeyboardSetKeyBounceFilter(KeyLeftArrow, true);
KeyboardSetKeyBounceFilter(KeyRightArrow, true);
KeyboardSetKeyBounceFilter(KeySpace, true);

//EngineSetFixedDeltaFrame(g_engine, 1.0 / 120.0);
//EngineSetClockScale(g_engine, 1.0 / 2.0);

//-----------------------------
function	MakeTriangleWave(i)
//-----------------------------
// 1 ^   ^
//   |  / \
//   | /   \
//   |/     \
//   +-------->
// 0    0.5    1
{
	local 	s = Sign(i);
	i = Abs(i);

	if (i < 0.5)
		return (s * i * 2.0);
	else
		return (s * (1.0 - (2.0 * (i - 0.5))));
}

//------------
class	Player
//------------
{
	tracks			= 	0;
	track_idx		=	2;
	motion_len		=	0;
	total_lap		=	0;
	lap_counter		=	0;
	energy 			=	9.0;
	exploded		=	false;

	current_rail	=	2;
	rails			=	0;

	max_speed		=	Mtrs(3.0);
	speed			=	0.0;
	dt_speed	=	0.0;
	motion_pos		=	0.0;

	speed_up		=	0.0;
	speed_up_vfx	=	0.0;
	collision_vfx	=	0.0;

	main_item		=	0;
	item_camera		=	0;
	item_mesh		=	0;

	camera_y_angle	=	0.0;

	pos				=	Vector(0,0,0);
	ship_pos		=	Vector(0,0,0);
	banking_angle	=	0.0;

	sfx_channel		=	0;
	sfx_voice_over	=	0;
	sfx_engine		=	0;
	swap_channel	=	0;
	sfx_special_channel	= 0;
	sfx_boost		=	0;
	sfx_missiles	=	0;
	sfx_autopilot	=	0;
	sfx_autopilot_off	= 0;
	sfx_quake		=	0;
	sfx_powerup		=	0;
	sfx_collision	=	0;
	collision_sfx_index	= 0;
	sfx_explosion	=	0;

	hit_bonus		=	false;
	hit_bonus_timeout	= 0.0;

	autopilot		=	false;
	autopilot_timeout	=	0.0;
	autopilot_off	= 	false;

	enemy_scan_index	=	0;

	strafe_timeout	=	0;

	//------------------------
	function	OnSetup(item)
	//------------------------
	{
		main_item = item;

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
			}
		}

		rails = array(5,0);
		for (local n = 0; n < 5; n++)
			rails[n] = SceneFindItemChild(g_scene, item, "rail_" + n);

		item_mesh = SceneFindItemChild(g_scene, item, "ship_mesh");
		item_camera = SceneFindItemChild(g_scene, item, "camera_pos");

		speed		=	0.0;
		speed_up	=	0.0;
		speed_up_vfx	=	0.0;
		collision_vfx	=	0.0;
		dt_speed	=	0.0;

		motion_pos	=	0.0;
		total_lap		=	0;
		lap_counter		=	0;

		collision_sfx_index = 0;

		current_rail = 	2;

		hit_bonus		=	false;
		hit_bonus_timeout	= 0.0;

		autopilot		=	false;
		autopilot_timeout = 0.0;
		autopilot_off	= 	false;
		
		ship_pos	= Vector(0,0,0);

		//	audio
		sfx_channel	=	array(2,0);
		sfx_engine	=	array(2,0);

		for (local n = 0; n < 2; n++)
		{
			sfx_channel[n] = MixerChannelLock(g_mixer);
			MixerChannelSetLoopMode(g_mixer, sfx_channel[0], LoopRepeat);
			sfx_engine[n] = EngineLoadSound(g_engine, "sfx/sfx_engine_" + n + ".wav");
		
			MixerChannelSetGain(g_mixer, sfx_channel[n], 0.00001);
			MixerChannelStart(g_mixer, sfx_channel[n], sfx_engine[n]);
		}

		sfx_special_channel = MixerChannelLock(g_mixer);
		sfx_voice_over = sfx_special_channel; //MixerChannelLock(g_mixer);

		sfx_boost = EngineLoadSound(g_engine, "sfx/sfx_booster.wav");
		sfx_missiles = EngineLoadSound(g_engine, "sfx/sfx_missiles.wav");
		sfx_quake = EngineLoadSound(g_engine, "sfx/sfx_quake.wav");
		sfx_powerup = EngineLoadSound(g_engine, "sfx/sfx_power_up.wav");
		sfx_autopilot = EngineLoadSound(g_engine, "sfx/sfx_autopilot.wav");
		sfx_autopilot_off = EngineLoadSound(g_engine, "sfx/sfx_autopilot_off.wav");
		sfx_explosion = EngineLoadSound(g_engine, "sfx/sfx_blow_up.wav");

		sfx_collision = array(3,0);
		for (local n = 0; n < 3; n++)
			sfx_collision[n] = EngineLoadSound(g_engine, "sfx/sfx_collision_" + n + ".wav");

		strafe_timeout = g_clock;

		g_main_player_instance = ItemGetScriptInstance(item);

		ItemSetInvisible(SceneFindItem(g_scene, "osd_autopilot_off"), true);
		ItemSetInvisible(SceneFindItem(g_scene, "osd_race_finished"), true);
		ShowExplosion(false);

		print("Player :: g_main_player_instance = " + g_main_player_instance);
		print("Player :: OnSetup() done");
	}

	//--------------------------
	function	IsFullThrottle()
	//--------------------------
	{
		if (speed > max_speed * 0.35)
			return (true);
		else
			return (false);
	}

	//--------------------
	function	GetSpeed()
	{	return (speed);	}

	//-----------------------------
	function	SetSpeed(new_speed)
	{	speed = new_speed;	}

	//-----------------------------
	function	GetMotionPosition()
	{	return (motion_pos); }

	//---------------------------
	function	GetCurrentTrack()
	{	return (current_rail);	}

	//----------------------
	function	TakeDamage()
	{
		energy -= 0.5;
		UpdateEnergyGauge()
		if (energy <= 0)
			Explode();
	}

	//-------------------
	function	PowerUp()
	{
		energy += 1.0;
		if (energy > 9.0)
			energy = 9.0;
		UpdateEnergyGauge()
	}

	//-----------------------------
	function	UpdateEnergyGauge()
	{
		for(local n = 0; n < 9; n++)
		{
			local current_energy_barr = SceneFindItem(g_scene, "power_barr_" + n);
			ItemSetInvisible(current_energy_barr, (n < energy ? false : true));
		}
	}

	//-----------------------------
	function	ShowExplosion(flag)
	{
		for (local n = 0; n < 2; n++)
			ItemSetInvisible(SceneFindItemChild(g_scene, item_mesh, "explosion_" + n), !flag);
		ItemSetInvisible(item_mesh, flag);
	}

	//-------------------
	function	Explode()
	{
		exploded = true;

		//	Audio
		MixerChannelSetGain(g_mixer, sfx_channel[0], 0.15);
		MixerChannelSetPitch(g_mixer, sfx_channel[0], 1.0);
		MixerChannelSetLoopMode(g_mixer, sfx_channel[0], LoopNone);
		MixerChannelStart(g_mixer, sfx_channel[0], sfx_explosion);

		MixerChannelSetGain(g_mixer, sfx_channel[1], 0.15);
		MixerChannelSetPitch(g_mixer, sfx_channel[1], 0.5);
		MixerChannelSetLoopMode(g_mixer, sfx_channel[1], LoopNone);
		MixerChannelStart(g_mixer, sfx_channel[1], sfx_explosion);

		//	Vfx
		local expl = SceneFindItemChild(g_scene, item_mesh, "explosion_0");
		ItemSetCommandList(expl, "torotation 0.0,0,0,0; torotation 3.0,360.0,0,0; next;");

		local expl = SceneFindItemChild(g_scene, item_mesh, "explosion_1");
		ItemSetCommandList(expl, "torotation 0.0,45.0,0,45.0; torotation 1.25,45.0,360.0,45.0; next;");

		ItemSetCommandList(item_mesh, "toscale 0.0,0.75,0.75,0.75; toscale 0.025,1.0,1.0,1.0;toscale 0.05,0.75,0.75,0.75;toscale 3.0,0,0,0;");

		ShowExplosion(true);
	}

	//---------------------------------
	function	ShowCollisionFeedBack()
	{
		collision_vfx = 0.75;
		collision_sfx_index = (++collision_sfx_index)%3;

		MixerChannelSetGain(g_mixer, sfx_special_channel, 0.30);
		MixerChannelStart(g_mixer, sfx_special_channel, sfx_collision[collision_sfx_index]);
	}

	//---------------------------------
	function	EnableBonus(bonus_type)
	{
		switch (bonus_type)
		{
			case "speedup":
				speed_up = max_speed * 0.5;
				speed_up_vfx = 1.0;
				print("Speed Up !!!");
				MixerChannelSetGain(g_mixer, sfx_special_channel, 0.30);
				MixerChannelStart(g_mixer, sfx_special_channel, sfx_boost);
				break;

			case "bonus_0":	//	Missiles
				MixerChannelSetGain(g_mixer, sfx_voice_over, 0.30);
				MixerChannelStart(g_mixer, sfx_special_channel, sfx_missiles);
				break;

			case "bonus_1":	//	Power Up
				PowerUp();
				MixerChannelSetGain(g_mixer, sfx_voice_over, 0.30);
				MixerChannelStart(g_mixer, sfx_special_channel, sfx_powerup);
				break;

			case "bonus_2":	//	Autopilot
				autopilot = true;
				autopilot_timeout = g_clock;

				MixerChannelSetGain(g_mixer, sfx_voice_over, 0.30);
				MixerChannelStart(g_mixer, sfx_special_channel, sfx_autopilot);
				break;
		}
	}

	//---------------------
	function	AutoPilot()
	{
		
		local enemy_found = false;
		local current_enemy_query;
		local player_enemy_dist;
		
		for(enemy_scan_index = 0; enemy_scan_index < g_enemy_table.len(); enemy_scan_index++)
		{
			current_enemy_query = g_enemy_table[enemy_scan_index];
			player_enemy_dist = current_enemy_query.motion_pos - motion_pos;

			if ((current_enemy_query.track_idx == current_rail) && (player_enemy_dist > 1.0) && (player_enemy_dist < 35.0))
			{
				enemy_found = true;
				break;
			}
		}

		if (enemy_found)
		{
			if (current_rail < 2)
				return (1.0);

			if (current_rail > 2)
				return (-1.0);

			if (current_rail == 2)
				return ((Irand(0,100) < 50 ? -1.0 : 1.0));

			speed *= 0.5;
		}
		
		return (0.0);
	}

	//---------------------------------------
	function	OnTrigger(item, trigger_item)
	//---------------------------------------
	{
		if (exploded)
			return;

		if (g_game_state == 3)
			return;

		local	trigger_name = ItemGetName(trigger_item);
		print("trigger_name = " + trigger_name);

		switch (trigger_name)
		{
			case "speed_up_trigger" :
				if (current_rail != 2)
					EnableBonus("speedup");
			break;

			case "bonus_trigger" :
				if ((current_rail == 2) && (hit_bonus == false))
				{
					hit_bonus = true;
					hit_bonus_timeout = g_clock;
					EnableBonus("bonus_" + Irand(0,3).tostring());
				}
			break;
		}
	}


	//--------------------------
	function	UpdateCameraFx()
	//--------------------------
	{
		local	camera_shake_vfx = MakeTriangleWave(Pow(speed_up_vfx + collision_vfx, 4.0));
		ItemSetPosition(item_camera, Vector(0,0, Mtr(2.0 * camera_shake_vfx + 5.0 * Rand(-0.25, 0.25) * camera_shake_vfx)));
		//CameraSetFov(SceneGetCurrentCamera(g_scene), Deg(34.5000 + 10.0 * speed_up_shake_vfx));
	}

	//------------------------
	function	RotateCamera()
	{
		camera_y_angle += Deg(25.0) * g_dt_frame;
		ItemSetRotation(SceneFindItemChild(g_scene, item_camera, "camera_pos_rotation"), Vector(0, camera_y_angle, 0)); 
	}

	//------------------------
	function	OnUpdate(item)
	//------------------------
	{

		local 	jz 	= 0.0,
				jx	= 0.0;
	
		if (g_game_state == 3)
		{
			RotateCamera();
		}
	
		if (g_game_state == 2)
		{
				
			if	(g_pad != 0)
			{
				DeviceUpdate(g_pad);

				// Get pad thrust
				jz = DevicePoolFunction(g_pad, DeviceAxisZ);
				jz = (jz - 32767.0) / -32767.0;

				if (jz < 0.0)
					jz *= 2.0;

				// Get pad direction
				jx = DevicePoolFunction(g_pad, DeviceAxisX);
				jx = (jx - 32767.0) / 32767.0; 
			}
			else
			{
				KeyboardUpdate();

				// Get keyboard thrust
				if (KeyboardSeekFunction(DeviceKeyPress, KeyUpArrow))
					jz = 1.0;
				else	{
					if (KeyboardSeekFunction(DeviceKeyPress, KeyDownArrow))
						jz = -2.0;
					else
						jz = 0.0;
				}

				// Get keyboard direction
				if (KeyboardSeekFunction(DeviceKeyPress, KeyLeftArrow))
					jx = -1.0;
				else	{
					if (KeyboardSeekFunction(DeviceKeyPress, KeyRightArrow))
						jx = 1.0;
					else
						jx = 0.0;
				}
			}		

			//	Bonus

			if (hit_bonus)
			{
				if (g_clock - hit_bonus_timeout > SecToTick(Sec(2.0)))
					hit_bonus = false;
			}

			if (autopilot)
			{
				local	autopilot_jx = AutoPilot();
				jx = autopilot_jx;

				if ( (g_clock - autopilot_timeout > SecToTick(Sec(9.0))) && (!autopilot_off) )
				{
					MixerChannelSetGain(g_mixer, sfx_special_channel, 0.30);
					MixerChannelStart(g_mixer, sfx_special_channel, sfx_autopilot_off);

					ItemSetInvisible(SceneFindItem(g_scene, "osd_autopilot_off"), false);
					//ItemSetCommandList(SceneFindItem(g_scene, "osd_autopilot_off"),	"toalpha 0.0, 0.0;nop 0.25;toalpha 0.0, 1.0;nop 1.0;next;");

					autopilot_off = true;
				}

				if (g_clock - autopilot_timeout > SecToTick(Sec(12.0)))
				{
					autopilot = false;
					autopilot_off = false;
					ItemSetInvisible(SceneFindItem(g_scene, "osd_autopilot_off"), true);
				}
			}


			if (!exploded)
			{
				if (jx < 0.0)
					StrafeLeft();
				else { if (jx > 0.0) 
						StrafeRight(); }
				
				speed_up = Max(0.0, speed_up - g_dt_frame * 60.0);	
				speed = Clamp(speed + ((jz - 0.25 + Pow(speed_up, 2.0)) * max_speed * g_dt_frame * 0.25), 0.0, max_speed + speed_up);
				dt_speed = speed * g_dt_frame * 60.0;

				speed_up_vfx = Max(0.0, speed_up_vfx - g_dt_frame * 0.25);
				collision_vfx = Max(0.0, collision_vfx - g_dt_frame * 0.45);

				UpdateCameraFx();
				UpdateEngineSfx();
				AutoPilot();
			}
			else
				speed = Max(0.0, speed - max_speed * g_dt_frame * 60.0);
		}

		EvaluateTrackPosition(item);

		if ((g_race_manager_instance != 0) && (g_game_state == 2) && (!exploded))
			g_race_manager_instance.LapCount(dt_speed);

		//print("jx = " + jx + ", jz = " + jz + ", speed = " + speed);
	}

	//----------------------
	function	StrafeLeft()
	{	current_rail = Max(0, --current_rail); strafe_timeout = g_clock;	}

	//-----------------------
	function	StrafeRight()
	{	current_rail = Min(4, ++current_rail); strafe_timeout = g_clock;	}

	//---------------------------
	function	UpdateEngineSfx()
	//---------------------------
	{
		local	thrust_level = Min(1.0, (abs(speed).tofloat() / (max_speed.tofloat() * 2.0)) + speed_up_vfx * 0.125 + 0.15);
		local	thrust_pitch = abs(speed) / (max_speed.tofloat()) + speed_up_vfx * 0.25 + 1.0;

		swap_channel = 1 - swap_channel;

		//MixerChannelStart(g_mixer, sfx_channel[swap_channel], sfx_engine[swap_channel]);
		MixerChannelSetGain(g_mixer, sfx_channel[swap_channel], thrust_level * 0.125 + 0.001);
		MixerChannelSetPitch(g_mixer, sfx_channel[swap_channel], thrust_pitch);
	}

	//-------------------------------------
	function	EvaluateTrackPosition(item)
	//-------------------------------------
	{
		//	---- Ship position on main track
		local	current_track = AIPathGetMotion(tracks[track_idx]);
		motion_pos += dt_speed;

		pos = MotionEvaluatePosition(current_track, (motion_pos)%motion_len[track_idx]);

		local	look_ahead = Vector(0,0,0);

		for (local n = 0; n < 10; n++)
			look_ahead += MotionEvaluatePosition(current_track, (motion_pos + 2.5 * (n - 1.5))%motion_len[track_idx]);
		look_ahead = look_ahead.MulReal(0.1);
		//look_ahead.y = look_ahead.y * 0.25 + pos.y * 0.75;

		ItemSetPosition(item, pos);		
		ItemSetRotation(item, EulerFromDirection((look_ahead - pos).Normalize()));

		// ---- Ship mesh

		// ---- Anticipate turns & evaluate inertia banking
		local	c_probe = array(4,0);

		// ---- Probe the track, meters ahead
		c_probe[0] = MotionEvaluatePosition(current_track, (motion_pos - 2.0)%motion_len[track_idx]);
		c_probe[1] = MotionEvaluatePosition(current_track, (motion_pos + 2.0)%motion_len[track_idx]);
		c_probe[2] = MotionEvaluatePosition(current_track, (motion_pos + 20.0)%motion_len[track_idx]);
		c_probe[3] = MotionEvaluatePosition(current_track, (motion_pos + 30.0)%motion_len[track_idx]);

		// ---- Calculate the curvature amount
		local	curve_amount = EulerFromDirection((c_probe[3] - c_probe[2]).Normalize()).y - EulerFromDirection((c_probe[1] - c_probe[0]).Normalize()).y;
		local	lateral_inertia = Clamp(curve_amount * (speed / max_speed) * -1.0, -1.0, 1.0);

		curve_amount *= -60.0;
		curve_amount = Clamp(curve_amount, -60.0, 60.0);

		if (Abs(banking_angle - curve_amount) < 40.0)
			banking_angle = Lerp(0.25, banking_angle, curve_amount);

		// ---- Force ship strafing is inertia is above a certain threshold
/*		if ((g_clock - strafe_timeout) > SecToTick(Sec(1.0)))
		{
			if (lateral_inertia < -0.35)
				StrafeLeft();
			else { if (lateral_inertia > 0.35) 
					StrafeRight(); }
		}*/

		//	handle strafing
		local	target_rail_pos = ItemGetPosition(rails[current_rail]);

		local	dt_lerp = Lerp(RangeAdjust(g_dt_frame, 0.0048, 0.0225, 0.0, 1.0), 0.975, 0.9);
		ship_pos = ship_pos.Lerp(dt_lerp, target_rail_pos);

		//	Calculate the banking angle, given the strafing amount
		local	ship_bank = Min(1.0, (ship_pos.x - target_rail_pos.x) / 2.0);
		ship_bank = MakeTriangleWave(ship_bank) * 45.0;

		local	ship_rot = Vector(0,0,Deg(ship_bank + banking_angle * Pow((speed / max_speed), 0.5)));
	
		//	Move & rotate the ship
		ItemSetPosition(item_mesh, ship_pos);
		ItemSetRotation(item_mesh, ship_rot);

		// ---- Camera

		look_ahead = Vector(0,0,0);
		for (local n = 0; n < 10; n++)
			look_ahead += MotionEvaluatePosition(current_track, (motion_pos + 5.0 * n)%motion_len[track_idx]);
		look_ahead = look_ahead.MulReal(0.1);

		ItemSetTarget(item_camera, look_ahead);	

	}

}