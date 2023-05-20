	Include("scriptlib/nad.nut");

try
{	g_enemy_table = [];	}
catch(e)
{	g_enemy_table <- [];	}

//-----------
class	Enemy
//-----------
{
	tracks			= 	0;
	track_idx		=	2;

	index			=	0;

	max_speed		=	Mtrs(3.0);
	speed			=	0.0;
	dt_speed		=	0.0;

	acceleration	=	0.01;
	motion_pos		=	0.0;

	item_mesh		=	0;

	pos				=	Vector(0,0,0);
	ship_pos		=	Vector(0,0,0);
	banking_angle	=	0.0;

	sfx_channel		=	0;
	sfx_engine		=	0;
	swap_channel	=	0;

	motion_len		=	0;
	motion_offset	=	0.0;
	speed_factor	=	100.0;
	accel_factor	=	100.0;

	has_collision	=	false;
	collision_timeout
					= 0.0;

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
				motion_len[n] = MotionGetLength(AIPathGetMotion(tracks[n]));
			}
		}

		item_mesh = SceneFindItemChild(g_scene, item, "enemy_mesh");

		speed		=	0.0;
		dt_speed		=	0.0;

		has_collision	=	false;
		collision_timeout	= 0.0;

		motion_pos	=	motion_offset;
		
		ship_pos	= Vector(0,0,0);
		acceleration = Lerp((accel_factor / 100.0), 0.001, 0.01);

		EvaluateTrackPosition(item);

		index = g_enemy_table.len();
		g_enemy_table.append(ItemGetScriptInstance(item));
		print("Registering enemy #" + index);
	}

	//--------------------
	function	GetSpeed()
	{	return (speed);	}

	//--------------------
	function	SetSpeed(new_speed)
	{	speed = new_speed;	}

	//--------------------------------------
	function	OnUpcomingCollision(item, with_item)
	{

		if (g_main_player_instance.exploded)
			return;

		if (has_collision)
		{
			if ((g_clock - collision_timeout) > SecToTick(Sec(0.1)))
				has_collision = false;
			else
				return;
		}

		local	with_item_name = ItemGetName(with_item);

		switch (with_item_name)
		{
			case "ship_mesh" :
				if (g_main_player_instance.autopilot)	// If autopilot in ON, hide collisions.
					return;

				g_main_player_instance.TakeDamage();
				has_collision = true;
				collision_timeout = g_clock;
				
				//	Are we behind, or before ?
				local	enemy_vector = ItemGetMatrix(item_mesh).GetRow(2).Normalize();
				local	player_vector = ItemGetWorldPosition(g_main_player_instance.item_mesh) - ItemGetWorldPosition(item_mesh);
				player_vector = player_vector.Normalize();
				local	player_enemy_dot = player_vector.Dot(enemy_vector);

				local player_bounce_factor;
				local enemy_bounce_factor;

				if (player_enemy_dot < 0.0)
				{
					player_bounce_factor = -0.25;
					enemy_bounce_factor = 0.45;
				}
				else
				{
					player_bounce_factor = 0.75;
					enemy_bounce_factor = -0.45;
				}

				//	Player behind, enemy before
				g_main_player_instance.SetSpeed(g_main_player_instance.GetSpeed() * player_bounce_factor);
				g_main_player_instance.ShowCollisionFeedBack();
				speed *= enemy_bounce_factor;
			break;
		}
	}

	//------------------------
	function	OnUpdate(item)
	//------------------------
	{
		if (g_game_state != 2)
			return;

		speed = Lerp(acceleration, speed, max_speed * (speed_factor / 100.0));
		dt_speed = speed * g_dt_frame * 60.0;

		SwarmBehavior(item);
		EvaluateTrackPosition(item);
		UpdateEngineSfx();

		//print("jx = " + jx + ", jz = " + jz + ", speed = " + speed);
	}

	//-----------------------------------------
	function	IsPositionEmpty(target_pos, target_track_idx)
	//-----------------------------------------
	{
		local	is_empty = true;
		return (is_empty);
	}

	//----------------------------------
	function	SelectTrack(track_index)
	//----------------------------------
	{
		print("SelectTrack(" + track_index + ");");
		track_idx = track_index;
	}

	//-------------------------------
	function	ChangeToRandomTrack()
	//-------------------------------
	{	
		local	new_track;
		do
		{
			new_track = Irand(0,10)%5;
			print("new_track = " + new_track);
		}
		while (new_track == track_idx);

		SelectTrack(new_track);	
	}

	//--------------------------
	function	SwarmBehavior(item)
	{
		//	Enemies keep waiting for the player if he's behind
		//	When taken over, enemies left behind the player are
		//	respawn far ahead, on a different track.
		if (g_main_player_instance != 0)
		{
			if (g_main_player_instance.IsFullThrottle())
			{
				local player_motion_pos	= g_main_player_instance.GetMotionPosition();
				local enemy_motion_pos	= motion_pos; //%motion_len[track_idx];

				// Quantize motion positions to smooth the differences between the tracks
				player_motion_pos = ((player_motion_pos / 10.0).tointeger()) * 10.0;
				enemy_motion_pos = ((enemy_motion_pos / 10.0).tointeger()) * 10.0;

				local player_to_enemy_dist = Abs(enemy_motion_pos - player_motion_pos); // / motion_len;

				if (player_to_enemy_dist > 100.0)
				{
					if (player_motion_pos < enemy_motion_pos)
					{
						//	Player is Behind
						speed_factor = Max(50.0 + Rand(-15,25), speed_factor * 0.5);
					}
					else
					{
						//	Player is Before
						speed_factor = Min(90.0 + Rand(-5,5), speed_factor * 0.9);
						motion_pos = g_main_player_instance.GetMotionPosition() + 200.0 + Rand(0,150);
						ChangeToRandomTrack();
					}
				}
			}
		}
	}


	//---------------------------
	function	UpdateEngineSfx()
	//---------------------------
	{
	}


	//-------------------------------------
	function	EvaluateTrackPosition(item)
	//-------------------------------------
	{

		//	---- Ship position on main track
		local	current_track;

		current_track = AIPathGetMotion(tracks[track_idx]);
		
		motion_pos += dt_speed;

		//if (motion_pos > MotionGetLength(current_track))
		//	motion_pos -= MotionGetLength(current_track);

		pos	= MotionEvaluatePosition(current_track, motion_pos);

		local	look_ahead = Vector(0,0,0);

		for (local n = 0; n < 10; n++)
				look_ahead  += MotionEvaluatePosition(current_track, (motion_pos + 2.5 * (n - 1.5))%motion_len[track_idx]);

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

		//for (local n = 0; n < 4; n++)
		//	ItemSetPosition(SceneFindItem(g_scene, "gizmo_" + n), c_probe[n]);

		// ---- Calculate the curvature amount
		local	curve_amount = EulerFromDirection((c_probe[3] - c_probe[2]).Normalize()).y - EulerFromDirection((c_probe[1] - c_probe[0]).Normalize()).y;
		local	lateral_inertia = Clamp(curve_amount * Abs(speed) * -1.0, -1.0, 1.0);

		curve_amount *= -60.0;
		curve_amount = Clamp(curve_amount, -60.0, 60.0);

		if (Abs(banking_angle - curve_amount) < 40.0)
			banking_angle = Lerp(0.25, banking_angle, curve_amount);

		local	ship_rot = Vector(0,0,Deg(banking_angle * Pow((Abs(speed) / max_speed), 0.5)));
	
		//	Move & rotate the ship
		ItemSetPosition(item_mesh, ship_pos);
		ItemSetRotation(item_mesh, ship_rot);

	}

}