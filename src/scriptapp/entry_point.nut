/*
	VipeUt 2008
*/

Include("scriptlib/nad.nut");

// Application global objects.
g_renderer		<-	EngineGetRenderer(g_engine);
g_mixer			<-	EngineGetMixer(g_engine);

Include("scriptapp/ui.nut");

// Application states.
GameExit		<-	0;
GameOpenCredits	<-	10;
GameIntro		<-	20;
GameTitle		<-	30;
GameDemoMode	<-	40;
GameLevel		<-	50;

g_game_state	<-	GameLevel;

Include("scriptapp/level.nut");

SceneCreateProfiler(g_scene, "prf.nml", "prf");

RendererSetViewport(g_renderer, 0.0, 0.0, g_width, g_height); //, Cm(20.0), Mtr(500.0));
//local	control_word = RendererGetControlWord(g_renderer);
//RendererSetControlWord(g_renderer, control_word & ~(RenderMotionBlur | RenderBloom));


// Application base loop.
while	(g_game_state != GameExit)
{
	switch	(g_game_state)
	{
		case	GameLevel:
			PlayLevel(g_current_level);
			break;
	}
}
