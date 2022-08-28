if isClient() then return end

ST_WorldTurretsList = {};
ST_TurretPistolAmmos = {"Bullets9mm", "Bullets45", "Bullets44", "Bullets38"};
ST_TurretShotgunAmmos = {"ShotgunShells"};
ST_TurretSniperAmmos = {"223Bullets", "308Bullets", "556Bullets", };
ST_TurretAmmoTypes = {["TurretPistol"]=ST_TurretPistolAmmos, ["TurretShotgun"]=ST_TurretShotgunAmmos, ["TurretSniper"]=ST_TurretSniperAmmos};
ST_TurretReloadSecondes = {["TurretPistol"]=0.3, ["TurretShotgun"]=0.3, ["TurretSniper"]=0.3};
ST_TurretShootingRadius = {["TurretPistol"]=13, ["TurretShotgun"]=9, ["TurretSniper"]=15};
ST_TurretShootingSound = {["TurretPistol"]="ST_PistolShoot", ["TurretShotgun"]="ST_ShotgunShoot", ["TurretSniper"]="ST_SniperShoot"};
ST_TurretShootingDamage = {["TurretPistol"] = {1.5,2.0}, ["TurretShotgun"] = {2.0,2.5}, ["TurretSniper"] = {2.0,3.0}};
ST_TurretShootingSoundRadius = {["TurretPistol"]=999, ["TurretShotgun"]=999, ["TurretSniper"]=999};
ST_ZombieHitReactions = {"HeadLeft", "HeadRight", "HeadTop", "Uppercut"}

-- when a object add to the world, check if it's a turret(Thumpable)
function ST_OnTurretPlaced(turret)
	if not turret then return end
	if instanceof(turret, "IsoThumpable") then
		local turretSquare = turret:getSquare();
		ST_OnLoadTurretSquare(turretSquare);
	end
end

-- if the square has a turret and the turret is not on the list, add to the list.
function ST_OnLoadTurretSquare(turretSquare)
	if not turretSquare then return end
	local turret = ST_CheckSquareHasTurret(turretSquare);
	if turret then
		if ST_CheckTurretSquareNotInList(turretSquare) then
			table.insert(ST_WorldTurretsList, ST_GetSquareTable(turretSquare))
			print("Adds an new turret square to the list: "..tostring(turretSquare:getX())..","..tostring(turretSquare:getY())..","..tostring(turretSquare:getZ()));
		end
	end
end

-- check if the square has a turret
function ST_CheckSquareHasTurret(turretSquare)
	if not turretSquare then return end
	local squareObjects = turretSquare:getObjects();
	for i = 0, squareObjects:size()-1 do
		local obj = squareObjects:get(i);
		local itemContainer = obj:getContainer();
		if itemContainer ~= nil then
			local containerType = itemContainer:getType();
			if string.sub(containerType, 1, 6) == "Turret" then
				--print("Turret Detected: "..containerType);
				return obj
			end
		end
	end
end

-- check if the turret's square is in the list
function ST_CheckTurretSquareNotInList(turretSquare)
	if not turretSquare then
		print("ST_CheckTurretSquareNotInList get invalid square");
		return
	end
	local squareTable = ST_GetSquareTable(turretSquare);
	local notInList = true;
	for k,v in ipairs(ST_WorldTurretsList) do
    if v.x == squareTable.x and v.y == squareTable.y and v.z == squareTable.z then
    	notInList = false;
    	print("Turret already in list");
    	break
    end
	end
	return notInList
end

-- get the square table for the list
function ST_GetSquareTable(square)
	if not square then return end
	local squareTable = {x = square:getX(), y = square:getY(), z = square:getZ()};
	return squareTable
end

-- every tick, check if the square in the list still has the turret or not
function ST_CheckTurretStillExist()
	for k,v in ipairs(ST_WorldTurretsList) do
		local square = getCell():getOrCreateGridSquare(v.x, v.y, v.z);
		--print("start checking square in list: "..tostring(v.x)..","..tostring(v.y)..","..tostring(v.z));
		if not square then
			print("The square in the list is not valid for some reason.");
			return
		end
		local turret = ST_CheckSquareHasTurret(square);
		if turret == nil then
			print("The list has an non-exist turret square, remove it");
			table.remove (ST_WorldTurretsList, k);
		else
			ST_TurretUpdate(turret);
		end
	end
end

-- Update the turret, reload, attack, consume ammo.
function ST_TurretUpdate(turret)
	if not turret then return end
	local turretType = turret:getContainer():getType()
  if turretType == "TurretShotgun" then
    if turret:getModData().corpseTimer == nil then
      turret:getModData().corpseTimer = 12.0
    elseif turret:getModData().corpseTimer > 0.0 then
      turret:getModData().corpseTimer = turret:getModData().corpseTimer - getGameTime():getRealworldSecondsSinceLastUpdate()
    elseif turret:getModData().corpseTimer <= 0.0 then
      turret:getModData().corpseTimer = 12.0
      local count = 0
      local xxx = turret:getX()
      local yyy = turret:getY()
      local square
      for xx = -20, 20 do
        for yy = -20, 20 do
          square = getCell():getGridSquare(xxx + xx, yyy + yy, 0)

          local objects = square:getStaticMovingObjects()

          for index = 0, objects:size() - 1 do
            local corpse = objects:get(index)
            if instanceof(corpse, "IsoDeadBody") then
              count = count + 1
            end
          end
        end
      end
      getPlayer():Say(tostring(count))
      if count > 800 then
        local xxx = turret:getX()
        local yyy = turret:getY()
        local square
        for xx = -20, 20 do
          for yy = -20, 20 do
            square = getCell():getGridSquare(xxx + xx, yyy + yy, 0)

            local objects = square:getStaticMovingObjects()

            for index = objects:size() - 1, 0, -1 do
              local corpse = objects:get(index)
              if instanceof(corpse, "IsoDeadBody") then
                square:removeCorpse(corpse, false)
              end
            end
          end
        end
      end
    end
  end


	if turret:getModData().STreloadtime == nil then
		turret:getModData().STreloadtime = 0.0;
	end
	if turret:getModData().STreloadtime > 0.0 then
	turret:getModData().STreloadtime = turret:getModData().STreloadtime - getGameTime():getRealworldSecondsSinceLastUpdate();
		return
	end
	if turret:getModData().STreloadtime <= 0.0 then
		-- local ammo = ST_GetAmmoInTurret(turret);
		-- if not ammo then
		-- 	--print("Turret can't find any right ammo inside");
		-- 	turret:getModData().STreloadtime = ST_TurretReloadSecondes[turret:getContainer():getType()] + ZombRandFloat(0.0, 0.3);
		-- 	return
		-- end
		local tableSquares = ST_GetTableTurretRange(turret);
		local target = ST_TurretFindTarget(tableSquares);
		if not target then
			--print("Turret doesn't find a target in it's range");
			turret:getModData().STreloadtime = ST_TurretReloadSecondes[turret:getContainer():getType()] + ZombRandFloat(0.0, 0.3);
			return
		end
		ST_TurretShooting(turret, target);
		-- turret:getContainer():Remove(ammo);
		turret:getModData().STreloadtime = ST_TurretReloadSecondes[turret:getContainer():getType()] + ZombRandFloat(0.0, 0.3);
	end
end

-- Turret attacking zombies
function ST_TurretShooting(turret, target)
	local turretType = turret:getContainer():getType();
	local soundString = ST_TurretShootingSound[turretType]..tostring(ZombRand(3));
	local sound = getSoundManager(): PlayWorldSound(soundString, turret:getSquare(), 0, 4, 1.0, false);
	--sound:setVolume(1.0);
	target:startMuzzleFlash();
	local targetTable = {};
	table.insert(targetTable, target);
	if turretType == "TurretShotgun" then
		-- if turret is shotgun, hit multiple targets.
		local centerSquare = target:getCurrentSquare();
		for x=centerSquare:getX()-3, centerSquare:getX()+3 do
			for y=centerSquare:getY()-3, centerSquare:getY()+3 do
				local v = getCell():getOrCreateGridSquare(x, y, centerSquare:getZ());
				if v then
					for i=v:getMovingObjects():size(),1,-1 do
						local tTarget = v:getMovingObjects():get(i-1);
						if instanceof(tTarget, "IsoZombie") then
							if tTarget:isDead() == false then
								table.insert(targetTable, tTarget);
								break
							end
						end
					end
				end
			end
		end
	end
  local kills = getPlayer():getZombieKills()
	for k,sTarget in ipairs(targetTable) do
		addSound(turret, turret:getSquare():getX(), turret:getSquare():getY(), turret:getSquare():getZ(), ST_TurretShootingSoundRadius[turretType], 300);
		--print(turretType.." hit a target!");
		local hitReact = ZombRand(5)+1;
		if hitReact < 5 then
			sTarget:setHitReaction(ST_ZombieHitReactions[hitReact]);
		else
			sTarget:setStaggerBack(true);
		end
		sTarget:addRandomBloodDirtHolesEtc();
		local minDamage = ST_TurretShootingDamage[turretType][1];
		local maxDamage = ST_TurretShootingDamage[turretType][2];
		sTarget:addBlood(maxDamage+ZombRandFloat(0.0,1.0));
		sTarget:applyDamageFromVehicle(minDamage, maxDamage);
    kills = kills + 1
	end
  getPlayer():setZombieKills(kills)
end

-- Shuffle table in lua
function ST_TableShuffle(tInput)
    local tReturn = {};
    for i = #tInput, 1, -1 do
        local j = ZombRand(i)+1;
        tInput[i], tInput[j] = tInput[j], tInput[i];
        table.insert(tReturn, tInput[i]);
    end
    return tReturn
end

-- Turret find a target in the range
function ST_TurretFindTarget (squareTable)
	local target = nil;
	local sTable = ST_TableShuffle(squareTable);
	for k,v in ipairs(sTable) do
		if v then
			for i=v:getMovingObjects():size(),1,-1 do
				local tTarget = v:getMovingObjects():get(i-1);
				if instanceof(tTarget, "IsoZombie") then
					if tTarget:isDead() == false then
						target = tTarget;
						break
					end
				end
			end
		end
		if target then break end
	end
	return target
end

-- Calculate the squares for the turret range
function ST_GetTableTurretRange(turret)
	local squareTable = {};
	local tSquare = turret:getSquare();
	if not tSquare then return end
	local tX = tSquare:getX();
	local tY = tSquare:getY();
	local tZ = tSquare:getZ();
	local tType = turret:getContainer():getType();
	local radius = ST_TurretShootingRadius[tType];
	local facing = ST_GetTurretFacing(turret);
	local minX = tX - radius;
	local maxX = tX + radius;
	local minY = tY - radius;
	local maxY = tY + radius;
	if facing == "S" then
		minY = tY;
	elseif facing == "E" then
		minX = tX;
	elseif facing == "N" then
		maxY = tY;
	elseif facing == "W" then
		maxX = tX;
	end
	for x=minX, maxX do
		for y=minY, maxY do
			local LOSTestResults = LosUtil.lineClear(turret:getCell(), tX, tY, tZ, x, y, tZ, false);
			local tLOS = tostring(LOSTestResults);
			if tLOS == "Clear" or tLOS == "ClearThroughOpenDoor" or tLOS == "ClearThroughWindow" then
				local sLOS = getCell():getOrCreateGridSquare(x, y, tZ);
				if sLOS then
					table.insert(squareTable, sLOS);
				end
			end
		end
	end
	return squareTable
end

-- get turret direction, return "S", "E", "N", "W"
function ST_GetTurretFacing(turret)
	local properties = turret:getProperties()
	local facing	= tostring(properties:Val("Facing"));
	return facing
end

-- check and return if the turret has the right ammo inside
function ST_GetAmmoInTurret(turretobj)
	local turret = turretobj:getContainer();
	local ammo = nil;
	local ammoTable = ST_TurretAmmoTypes[turret:getType()];
	for key,value in ipairs(ammoTable) do
		ammo = turret:getItemFromType(value);
		if ammo then
			--print("find right ammo: "..value);
			break
		end
	end
	return ammo
end

Events.OnObjectAdded.Add(ST_OnTurretPlaced)
Events.LoadGridsquare.Add(ST_OnLoadTurretSquare)
Events.OnTick.Add(ST_CheckTurretStillExist)
