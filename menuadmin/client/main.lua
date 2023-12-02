---------------
-- VARIABLES --
---------------
PERMISSION_LEVEL = 0
isMenuOpened = false
noclip = false
godmode = false
vanish = false
spectate = false
freeze = false
noclip_speed = 3.0

ranks = {}

---------
-- ESX --
---------
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
	ESX.UI.Menu.CloseAll()
end)

--------------
-- LLAMADAS --
--------------
AddEventHandler('playerSpawned', function(spawn)
	TriggerServerEvent('tm1_adminSystem:getPermissionLevel')
end)
Citizen.CreateThread(function()
	Citizen.Wait(1000)
	TriggerServerEvent('tm1_adminSystem:getPermissionLevel')
end)


-------------
-- EVENTOS --
-------------
RegisterNetEvent('tm1_adminSystem:setPermissionLevel')
AddEventHandler('tm1_adminSystem:setPermissionLevel',function(permission,rank)
	PERMISSION_LEVEL = permission
	ranks = rank
end)

RegisterNetEvent('tm1_adminSystem:nocliped')
AddEventHandler('tm1_adminSystem:nocliped',function()
	noclip = not noclip
	while true do
		Citizen.Wait(0)
		local ped = GetPlayerPed(-1)
		if noclip then
			SetEntityInvincible(ped, true)
			SetEntityVisible(ped, false, false)
		else
			Citizen.Wait(200)
			SetEntityInvincible(ped, false)
			SetEntityVisible(ped, true, false)
		end
    end
    if noclip == true then
    	TriggerEvent('esx:showNotification', "~w~Has ~g~activado ~w~el noclip.")
    else
    	TriggerEvent('esx:showNotification', "~w~Has ~r~desactivado ~w~el noclip.")
    end
    openAdministrativeMenu()
end)

RegisterNetEvent('tm1_adminSystem:godmoded')
AddEventHandler('tm1_adminSystem:godmoded',function()
	godmode = not godmode
	while true do
		Citizen.Wait(0)
    	local ped = GetPlayerPed(-1)
    	SetEntityInvincible(ped, godmode)
	end
    if godmode == true then
    	TriggerEvent('esx:showNotification', "~w~Has ~g~activado ~w~el godmode.")
    else
    	TriggerEvent('esx:showNotification', "~w~Has ~r~desactivado ~w~el godmode.")
    end
    openAdministrativeMenu()
end)

RegisterNetEvent('tm1_adminSystem:returnSpectate')
AddEventHandler('tm1_adminSystem:returnSpectate',function()
	spectate = false
end)

RegisterNetEvent('tm1_adminSystem:vanished')
AddEventHandler('tm1_adminSystem:vanished',function()
	vanish = not vanish
	while true do
		Citizen.Wait(0)
		local ped = GetPlayerPed(-1)
		if vanish then
			SetEntityInvincible(ped, true)
			SetEntityVisible(ped, false, false)
		else
			Citizen.Wait(200)
			SetEntityInvincible(ped, false)
			SetEntityVisible(ped, true, false)
		end
    end
    if vanish == true then
    	TriggerEvent('esx:showNotification', "~w~Has ~g~activado ~w~el vanish.")
    else
    	TriggerEvent('esx:showNotification', "~w~Has ~r~desactivado ~w~el vanish.")
    end
    openAdministrativeMenu()
end)

RegisterNetEvent('tm1_adminSystem:goto')
AddEventHandler('tm1_adminSystem:goto',function(x,y,z)
	SetEntityCoords(PlayerPedId(), x, y, z)
end)

RegisterNetEvent('tm1_adminSystem:freezed')
AddEventHandler('tm1_adminSystem:freezed',function()
	freeze = not freeze
	local ped = GetPlayerPed(-1)
	local player = PlayerId()
	if not freeze then
		if not IsEntityVisible(ped) then
			SetEntityVisible(ped, true)
		end

		if not IsPedInAnyVehicle(ped) then
			SetEntityCollision(ped, true)
		end

		FreezeEntityPosition(ped, false)
		--SetCharNeverTargetted(ped, false)
		SetPlayerInvincible(player, false)
		TriggerEvent('esx:showNotification', "Te ha ~g~descongelado~w~ un administrador.")
	else
		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		--SetCharNeverTargetted(ped, true)
		SetPlayerInvincible(player, true)
		--RemovePtfxFromPed(ped)

		if not IsPedFatallyInjured(ped) then
			ClearPedTasksImmediately(ped)
		end
		TriggerEvent('esx:showNotification', "Te ha ~r~congelado~w~ un administrador.")
	end
end)

RegisterNetEvent('tm1_adminSystem:healed')
AddEventHandler('tm1_adminSystem:healed',function()
	local Ped = GetPlayerPed(-1)
	SetEntityHealth(Ped, 200)
	TriggerEvent('esx_basicneeds:healPlayer')
	ClearPedBloodDamage(Ped)
	ResetPedVisibleDamage(Ped)
	ClearPedLastWeaponDamage(Ped)
end)

RegisterNetEvent('tm1_adminSystem:killed')
AddEventHandler('tm1_adminSystem:killed',function()
	local Ped = GetPlayerPed(-1)
	SetEntityHealth(Ped, 0)
end)
-----------
-- HILOS --
-----------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustReleased(0, 107) then
			if PERMISSION_LEVEL ~= 0 then
				if isMenuOpened == false then
					openAdministrativeMenu()
					isMenuOpened = true
				elseif isMenuOpened == true then
					ESX.UI.Menu.CloseAll()
					isMenuOpened = false
				end
            end
			if PERMISSION_LEVEL == 0 then
				print('No tienes permisos suficientes!')
			end
		end
		if noclip then
	      local ped = GetPlayerPed(-1)
	      local x,y,z = getPosition()
	      local dx,dy,dz = getCamDirection()
	      local speed = noclip_speed

	      -- Resetear velocidad
	      SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)

	      if IsControlPressed(0,32) then
	        x = x+speed*dx
	        y = y+speed*dy
	        z = z+speed*dz
	      end

	      if IsControlPressed(0,269) then
	        x = x-speed*dx
	        y = y-speed*dy
	        z = z-speed*dz
	      end

	      SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
	    end
	end
 end)

---------------
-- FUNCIONES --
---------------

function isItAvaliable(permission)
	for i,v in pairs(ranks[PERMISSION_LEVEL]) do
		if v == permission then
			return true
		end
	end
	return false
end

function openGetterMenuAdmin(type)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'getterAdminMenu',
	{
		title = "Introducir: [ID] [Razón]",
	}, function(data, menu)
		local parameter = data.value
		local IdPlayer = GetPlayerName(NetworkGetEntityOwner(GetPlayerPed(-1)))
		if type == "kick" then
			local args = split(parameter, " ")
			local reason = string.sub(parameter, 2, -1)
			TriggerServerEvent('tm1_adminSystem:kick','kick',args, reason, IdPlayer)
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function openGetterMenuSpawn(type)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'getterAdminMenu',
	{
		title = "Introducir: [ID] [Tipo] [Cantidad]",
	}, function(data, menu)
		local parameter = data.value
		local IdPlayer = GetPlayerName(NetworkGetEntityOwner(GetPlayerPed(-1)))
		if type == "spawnWeapon" then
			local args = split(parameter, " ")
			TriggerServerEvent('tm1_adminSystem:spawnWeapon','spawnWeapon',args, IdPlayer)
		elseif type == "spawnObject" then
			local args = split(parameter, " ")
			TriggerServerEvent('tm1_adminSystem:spawnObject','spawnObject',args, IdPlayer)
		elseif type == "spawnMoney" then
			local args = split(parameter, " ")
			TriggerServerEvent('tm1_adminSystem:spawnMoney','spawnMoney',args, IdPlayer)
		elseif type == "setJob" then
			local args = split(parameter, " ")
			TriggerServerEvent('tm1_adminSystem:setJob','setJob',args, IdPlayer)
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function openGetterMenuVehicle(type)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'getterAdminMenu',
	{
		title = "Introducir: [Modelo Vehículo]",
	}, function(data, menu)
		local parameter = data.value
		local IdPlayer = GetPlayerName(NetworkGetEntityOwner(GetPlayerPed(-1)))
		if type == "spawnCar" then
			TriggerEvent('esx:spawnVehicle', parameter)
			TriggerEvent('esx:showNotification', "Se ha intentado spawnear un : ~g~"..parameter.."~w~.")
			TriggerServerEvent('tm1_adminSystem:spawnCar','spawnCar',parameter, IdPlayer)
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function openGetterMenu(type)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'getterAdminMenu',
	{
		title = "Introducir: [ID]",
	}, function(data, menu)
		local parameter = data.value
		local IdPlayer = GetPlayerName(NetworkGetEntityOwner(GetPlayerPed(-1)))
		if type == "clearInventory" then
			TriggerServerEvent('tm1_adminSystem:clearInventory','clearInventory',parameter, IdPlayer)
		elseif type == "goto" then
			TriggerServerEvent('tm1_adminSystem:bring','goto',parameter, -1, IdPlayer)
		elseif type == "bring" then
			TriggerServerEvent('tm1_adminSystem:bring','bring',parameter, 0, IdPlayer)
		elseif type == "freeze" then
			TriggerServerEvent('tm1_adminSystem:freeze','freeze',parameter, IdPlayer)
		elseif type == "heal" then
			TriggerServerEvent('tm1_adminSystem:heal','heal',parameter, IdPlayer)
		elseif type == "kill" then
			TriggerServerEvent('tm1_adminSystem:kill','kill',parameter, IdPlayer)
		elseif type == "revive" then
			TriggerServerEvent('tm1_adminSystem:revive','revive',parameter, IdPlayer)
		elseif type == "ck" then
			TriggerServerEvent('tm1_adminSystem:ck','ck',parameter, IdPlayer)
		end
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function openAdministrativeMenu()

	local elements = {}
	local elements1 = {}
	local elements2 = {}
	local elements3 = {}
	local elements4 = {}

	if PERMISSION_LEVEL ~= 0 then
		table.insert(elements, {label ="No tienes suficientes permisos para ver esto", value = "noPermissions"})
	else
		local actions = {
			{label = "Administrar Jugadores", value = "adminplayers"},
			{label = "Herramientas", value = "staff"},
			{label = "Spawnear", value = "spawn"},
			{label = "Sanciones Administrativas", value = "sanciones"},
			{label = "Noclip", value = "noclip"},
			{label = "GodMode", value = "godmode"},
			{label = "Vanish", value = "vanish"},
			{label = "Spectear", value = "spectate"},
			{label = "Teletransporte a punto", value = "tpoint"},
			{label = "Ir a jugador", value = "goto"},
			{label = "Traer a jugador", value = "bring"},
			{label = "Spawnear vehículo", value = "spawnCar"},
			{label = "Arreglar vehículo", value = "fixvehicle"},
			{label = "Borrar vehículo", value = "clearVehicle"},
			{label = "Spawnear Arma", value = "spawnWeapon"},
			{label = "Spawnear Objeto", value = "spawnObject"},
			{label = "Spawnear Dinero", value = "spawnMoney"},
			{label = "Borrar inventario", value = "clearInventory"},
			{label = "Setear el job", value = "setJob"},
			{label = "Freezear", value = "freeze"},
			{label = "Revivir Jugador", value = "revive"},
			{label = "Rellenar vida", value = "heal"},
			{label = "Matar jugador", value = "kill"},
			{label = "Borrar el chat", value = "clearChat"},
			{label = "Warnear Jugador", value = "warn"},
			{label = "Ver Warns", value = "warnlist"},
			{label = "Kickear jugador", value = "kick"},
			{label = "Banear Jugador", value = "ban"},
			{label = "Ver Baneos", value = "banlist"},
			{label = "Actualizar Warns/Bans", value = "refresh"},
			{label = "Realizar CK", value = "ck"},
		}

		for i,v in pairs(actions) do
			if isItAvaliable(v.value) then
				if v.value == "spawn" then
					table.insert(elements, {label = v.label , value = v.value})
				elseif v.value == "staff" then
					table.insert(elements, {label = v.label , value = v.value})
				elseif v.value == "adminplayers" then
					table.insert(elements, {label = v.label , value = v.value})
				elseif v.value == "sanciones" then
					table.insert(elements, {label = v.label , value = v.value})
				elseif v.value == "noclip" and noclip == true then
					table.insert(elements3, {label = v.label.." <span style='color: green;'>Activado</span>" , value = v.value})
				elseif v.value == "noclip" and noclip == false then
					table.insert(elements3, {label = v.label.." <span style='color: red;'>Desactivado</span>" , value = v.value})
				elseif v.value == "godmode" and godmode == true then
					table.insert(elements3, {label = v.label.." <span style='color: green;'>Activado</span>" , value = v.value})
				elseif v.value == "godmode" and godmode == false then
					table.insert(elements3, {label = v.label.." <span style='color: red;'>Desactivado</span>" , value = v.value})
				elseif v.value == "vanish" and vanish == true then
					table.insert(elements3, {label = v.label.." <span style='color: green;'>Activado</span>" , value = v.value})
				elseif v.value == "vanish" and vanish == false then
					table.insert(elements3, {label = v.label.." <span style='color: red;'>Desactivado</span>" , value = v.value})
				elseif v.value == "spectate" and spectate == true then
					table.insert(elements2, {label = v.label.." <span style='color: green;'>Activado</span>" , value = v.value})
				elseif v.value == "spectate" and spectate == false then
					table.insert(elements2, {label = v.label.." <span style='color: red;'>Desactivado</span>" , value = v.value})
				elseif v.value == "spawnWeapon" then
					table.insert(elements1, {label = v.label , value = v.value})
				elseif v.value == "spawnObject" then
					table.insert(elements1, {label = v.label , value = v.value})
				elseif v.value == "spawnMoney" then
					table.insert(elements1, {label = v.label , value = v.value})
				elseif v.value == "setJob" then
					table.insert(elements1, {label = v.label , value = v.value})
				elseif v.value == "spawnCar" then
					table.insert(elements1, {label = v.label , value = v.value})
				elseif v.value == "fixvehicle" then
					table.insert(elements1, {label = v.label , value = v.value})
				elseif v.value == "tpoint" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "goto" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "bring" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "freeze" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "heal" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "kill" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "revive" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "clearVehicle" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "clearChat" then
					table.insert(elements2, {label = v.label , value = v.value})
				elseif v.value == "warn" then
					table.insert(elements4, {label = v.label , value = v.value})
				elseif v.value == "warnlist" then
					table.insert(elements4, {label = v.label , value = v.value})
				elseif v.value == "kick" then
					table.insert(elements4, {label = v.label , value = v.value})
				elseif v.value == "ban" then
					table.insert(elements4, {label = v.label , value = v.value})
				elseif v.value == "banlist" then
					table.insert(elements4, {label = v.label , value = v.value})
				elseif v.value == "refresh" then
					table.insert(elements4, {label = v.label , value = v.value})
				elseif v.value == "ck" then
					table.insert(elements4, {label = v.label , value = v.value})
				end
			end
		end
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminMenu',
		{
			title  = "Menú administrativo",
			align    = 'right',
			elements = elements
		},
		function(data, menu)
			local IdPlayer = GetPlayerName(NetworkGetEntityOwner(GetPlayerPed(-1)))
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(ped, false)

			if data.current.value == "spawn" then
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn',
				{
					title = "Spawnear objetos",
					align = 'right',
					elements = elements1
				},
				function(data2, menu2)
					if data2.current.value == "spawnWeapon" then
						openGetterMenuSpawn('spawnWeapon')
					elseif data2.current.value == "spawnObject" then
						openGetterMenuSpawn('spawnObject')
					elseif data2.current.value == "spawnMoney" then
						openGetterMenuSpawn('spawnMoney')
					elseif data2.current.value == "setJob" then
						openGetterMenuSpawn('setJob')
					elseif data2.current.value == "spawnCar" then
						openGetterMenuVehicle('spawnCar')
					elseif data2.current.value == "fixvehicle" then
						if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
							SetVehicleFixed(vehicle)
							SetVehicleDeformationFixed(vehicle)
							SetVehicleUndriveable(vehicle, false)
							Citizen.InvokeNative(0xB736A491E64A32CF,Citizen.PointerValueIntInitialized(vehicle))
							TriggerEvent('esx:showNotification', "Vehículo ~g~arreglado~w~")
							TriggerServerEvent('tm1_adminSystem:fixvehicle','fixvehicle', IdPlayer)
						else
							TriggerEvent('esx:showNotification', "No estás en ningún vehículo")
						end
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.current.value == "adminplayers" then
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminplayers',
				{
					title = "Administrar Jugadores",
					align = 'right',
					elements = elements2
				},
				function(data3, menu3)
					if data3.current.value == "spectate" then
						spectate = not spectate
						if spectate == true then
							TriggerServerEvent('es_camera:spectate')
						else
							TriggerServerEvent('es_camera:spectate',-1)
						end
					elseif data3.current.value == "noPermissions" then
						isMenuOpened = false
					elseif data3.current.value == "tpoint" then
						teleportToPoint()
					elseif data3.current.value == "goto" then
						openGetterMenu('goto')
					elseif data3.current.value == "bring" then
						openGetterMenu('bring')
					elseif data3.current.value == "freeze" then
						openGetterMenu('freeze')
					elseif data3.current.value == "heal" then
						openGetterMenu('heal')
					elseif data3.current.value == "kill" then
						openGetterMenu('kill')
					elseif data3.current.value == "revive" then
						openGetterMenu('revive')
					elseif data3.current.value == "clearVehicle" then
						TriggerEvent('esx:deleteVehicle')
						TriggerEvent('esx:showNotification', "Vehículo ~r~eliminado~w~")
						TriggerServerEvent('tm1_adminSystem:clearVehicle','clearVehicle', IdPlayer)
					elseif data3.current.value == "clearChat" then
						TriggerServerEvent('tm1_adminSystem:clearChat','clearChat')
					end
				end, function(data3, menu3)
					menu3.close()
				end)
			elseif data.current.value == "staff" then
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'staff',
				{
					title = "Herramientas",
					align = 'right',
					elements = elements3
				},
				function(data4, menu4)
					if data4.current.value == "noclip" then
						TriggerServerEvent('tm1_adminSystem:noclip','noclip', IdPlayer)
					elseif data4.current.value == "godmode" then
						TriggerServerEvent('tm1_adminSystem:godmode','godmode', IdPlayer)
					elseif data4.current.value == "vanish" then
						TriggerServerEvent('tm1_adminSystem:vanish','vanish', IdPlayer)
					elseif data4.current.value == "noPermissions" then
						isMenuOpened = false
					end
				end, function(data4, menu4)
					menu4.close()
				end)
			elseif data.current.value == "sanciones" then
				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sanciones',
				{
					title = "Sanciones Administrativas",
					align = 'right',
					elements = elements4
				},
				function(data5, menu5)
					if data5.current.value == "kick" then
						openGetterMenuAdmin('kick')
					elseif data5.current.value == "ck" then
						openGetterMenu('ck')
					elseif data5.current.value == "warn" then
						ExecuteCommand("bwh warn")
					elseif data5.current.value == "warnlist" then
						ExecuteCommand("bwh warnlist")
					elseif data5.current.value == "ban" then
						ExecuteCommand("bwh ban")
					elseif data5.current.value == "banlist" then
						ExecuteCommand("bwh banlist")
					elseif data5.current.value == "refresh" then
						ExecuteCommand("bwh refresh")
					end
				end, function(data5, menu5)
					menu5.close()
				end)
			end
		end, function(data, menu)
			isMenuOpened = false
			menu.close()
	end)
end

function teleportToPoint()
    local player = GetPlayerPed(-1)
	local blip = GetFirstBlipInfoId(8)
	local coord = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
	for height = 1, 1000 do
		SetPedCoordsKeepVehicle(PlayerPedId(), coord.x, coord.y, height + 0.0)
		local foundGround, zPos = GetGroundZFor_3dCoord(coord.x, coord.y, height + 0.0)
		if foundGround then
			SetPedCoordsKeepVehicle(PlayerPedId(), coord.x, coord.y, height + 0.0)
			break
		end
		Citizen.Wait(5)
	end
end

function getPosition()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  	return x,y,z
end

function getCamDirection()
  local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
  local pitch = GetGameplayCamRelativePitch()

  local x = -math.sin(heading*math.pi/180.0)
  local y = math.cos(heading*math.pi/180.0)
  local z = math.sin(pitch*math.pi/180.0)

  local len = math.sqrt(x*x+y*y+z*z)
  if len ~= 0 then
    x = x/len
    y = y/len
    z = z/len
  end

  return x,y,z
end

function split(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end