Config = {}

Config.JobMessage = "No tienes permitido entrar" -- Message when you don't have the job to access

Config.PromptEnter = "Entrar"   -- Enter button text.
Config.PromptExit = "Salir" --Exit button text.

Config.VarStringEnter = "Entrada a: " -- Text before the name of the enter house
Config.VarStringExit = "Salida de: " -- Text before the name of the exit house

Config.Locations = { 
    [1] = {
        name = "Sala tortura",    --  Location name
        enterPos = vector3(2859.97, -1195.58, 49.18),   -- Position of enter prompt and enter spawn
        exitPos = vector3(2857.80, -1195.87, 48.89), -- Position of exit prompt and exit spawn
        exit = true,    -- Enable exit prompt (true) or remove exit prompt(false), if you can leave tents by walking through the wall, wall has collision bugs.
        job = false,    -- Jobs to enter {"job1","job2"} , or false for no job.
        blip = {enable = false, sprite = 0},    -- Enable o disable blip (true/false) and sprite (hash blip).
    },
	
	[2] = {
		name = "Casa 1 Blackwater", --  Location name
		enterPos = vector3(-909.38,-1366.80,45.60), -- Position of enter prompt and enter spawn
		exitPos = vector3(-909.48,-1368.50,45.67),  -- Position of exit prompt and exit spawn
        exit = true,    -- Enable exit prompt (true) or remove exit prompt(false), if you can leave tents by walking through the wall, wall has collision bugs.
		job = {"sheriff"},  -- Jobs to enter {"job1","job2"} , or false for no job.
		blip = {enable = true, sprite = 2305242038},    -- Enable o disable blip (true/false) and sprite (hash blip).
    },

}
