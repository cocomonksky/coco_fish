Citizen.CreateThread(function() ----Mercy Kill RDR2
    Citizen.InvokeNative(0x39363DFD04E91496, PlayerId(), true) 
    while true do
        Wait(2)
        local player = PlayerPedId()
        local horse = Citizen.InvokeNative(0x4C8B59171957BCF7, player)
        if horse ~= nil then
            local playerCoords = GetEntityCoords(player)
            local horsecoords = GetEntityCoords(horse)
            local holding = Citizen.InvokeNative(0xD806CD2A4F2C2996, player)
            local quality = Citizen.InvokeNative(0x31FEF6A20F00B963, holding)
            local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, horsecoords.x, horsecoords.y, horsecoords.z, 0)
            if 2 > dist then
                local model = GetEntityModel(holding)
                
            end
        end
    end
end)

local sideSaddleActive
local currentAnim
local shouldDisableDismount = false

local function IsPedFullyOnMount(ped, p1)
	return Citizen.InvokeNative(0x95CBC65780DE7EB1, ped, p1)
end

local function GetPedCurrentHeldWeapon(ped)
	return Citizen.InvokeNative(0x8425C5F057012DAB, ped)
end

local function isPlayingAnim(ped, anim)
	return IsEntityPlayingAnim(ped, anim.dict, anim.name, anim.flags)
end

local function playAnim(ped, anim)
	if not DoesAnimDictExist(anim.dict) then
		return
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Citizen.Wait(0)
	end

	TaskPlayAnim(ped, anim.dict, anim.name, 1.0, 1.0, -1, anim.flags, 0.0, false, 0, false, "", false)

	RemoveAnimDict(anim.dict)
end

local function stopAnim(ped, anim)
	StopAnimTask(ped, anim.dict, anim.name, 1.0)
end

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then
		if currentAnim then
			stopAnim(PlayerPedId(), currentAnim)
		end
	end
end)

RegisterCommand("sidesaddle", function()
	if sideSaddleActive then  -- if currently on left side-saddle
		sideSaddleActive = false  -- switch to normal
		if currentAnim then
			stopAnim(PlayerPedId(), currentAnim)
			currentAnim = nil
		end
	else
		sideSaddleActive = true
	end
end)

Citizen.CreateThread(function()
	while true do
		if sideSaddleActive then
			if shouldDisableDismount then
				DisableControlAction(0, 0xCBDB82A8, true)
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()

	while true do
		local canWait = true

		if sideSaddleActive then
			local playerPed = PlayerPedId()

			local holdingWeapon = GetPedCurrentHeldWeapon(playerPed) ~= GetHashKey("WEAPON_UNARMED")
			if IsPedFullyOnMount(playerPed) and not holdingWeapon then
				local mount = GetMount(playerPed)
				local speed = GetEntitySpeedVector(mount, true)

				local mountSpeed
				local mountTurn

				if speed.y < 2.0 then
					mountSpeed = "idle"
				elseif speed.y < 5.0 then
					if speed.z > Config.thresholdZ then
						mountSpeed = "cantern@slope@up"
					elseif speed.z < -Config.thresholdZ then
						mountSpeed = "cantern@slope@down"
					else
						mountSpeed = "cantern"
					end
				else
					if speed.z > Config.thresholdZ then
						mountSpeed = "gallop@slope@up"
					elseif speed.z < -Config.thresholdZ then
						mountSpeed = "gallop@slope@down"
					else
						mountSpeed = "gallop"
					end
				end

				if speed.y < 2.0 then
					mountTurn = "idle"
				elseif speed.x > Config.thresholdX then
					mountTurn = "turn_l2"
				elseif speed.x < -Config.thresholdX then
					mountTurn = "turn_r2"
				else
					mountTurn = "move"
				end

				shouldDisableDismount = speed.y >= 1.5

				currentAnim = {
					dict = ("veh_horseback@seat_rear@female@left@normal@%s"):format(mountSpeed),
					name = mountTurn,
					flags = 17
				}

				if currentAnim and not isPlayingAnim(playerPed, currentAnim) then
					playAnim(playerPed, currentAnim)
				end

				canWait = false
			elseif currentAnim then
				stopAnim(playerPed, currentAnim)
				currentAnim = nil
			end
		end

		Citizen.Wait(canWait and 1000 or 100)
	end
end)

CreateThread(function()
	if Config.OneShoulderWeapon then
		while true do
			Wait(1)
			local ped = PlayerPedId()
			local currentHeldWeapon = Citizen.InvokeNative(0x8425C5F057012DAB, ped)
			local hasWeapon, attachedWeapon = GetCurrentPedWeapon(ped, true, 10, true)
			local attachPoint = Citizen.InvokeNative(0xCAD4FE9398820D24, ped, 10)
			if hasWeapon and currentHeldWeapon ~= attachedWeapon and attachPoint == 10 and Citizen.InvokeNative(0x0556E9D2ECF39D01, currentHeldWeapon) then
				RemoveWeaponFromPed(ped, currentHeldWeapon)
			end
		end
	end
end)


