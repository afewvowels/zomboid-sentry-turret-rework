function ST_ReceiveServerCommand(STmodule, STcommand, STargs)
	if STmodule ~= "STmodule" then         
		return
  end
  if STcommand == "STplayworldsound" then
  	local sString = STargs["soundString"];
  	local square = getCell():getOrCreateGridSquare(STargs["x"], STargs["y"], STargs["z"]);
  	if square then
  		print("Receive server command, start play world sound");
  		getSoundManager():PlayWorldSound(sString, square, 0, 4, 1.0, false);
  	end
  end
end

Events.OnServerCommand.Add(ST_ReceiveServerCommand)