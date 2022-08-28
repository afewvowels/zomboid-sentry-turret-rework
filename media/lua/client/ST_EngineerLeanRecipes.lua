function ST_EngineerLearnSentries()
	local player = getPlayer();
	if not player then return end
	if player:getDescriptor():getProfession() ~= "engineer" then return end
	if not player:isRecipeKnown("Make Pistol Turret") then
		print("Engineer learn pistol turret");
		player:learnRecipe("Make Pistol Turret");
	end
	if not player:isRecipeKnown("Make Shotgun Turret") then
		print("Engineer learn shotgun turret");
		player:learnRecipe("Make Shotgun Turret");
	end
	if not player:isRecipeKnown("Make Sniper Turret") then
		print("Engineer learn sniper turret");
		player:learnRecipe("Make Sniper Turret");
	end
end

Events.OnGameStart.Add(ST_EngineerLearnSentries)