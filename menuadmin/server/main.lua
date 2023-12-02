local ranks = {}
local playersRank = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
--Esta función sirve para retornar todos los permisos
function getRanks()
	local ranksMysql = MySQL.Sync.fetchAll("SELECT * FROM menuadmin")
	for i,v in pairs(ranksMysql) do
		local permissions = json.decode(v.permissions)
		ranks[v.Id] = permissions
	end
end

RegisterServerEvent('tm1_adminSystem:spectate')
AddEventHandler('tm1_adminSystem:spectate', function(permission, target, args, IdPlayer)
    local target = target
	LogsMenuAdmin('**SPECTATE:**\n **ID Jugador:** '..IdPlayer..' ha specteado a **'..target..'**')
end)

LogsMenuAdmin = function(message)
    PerformHttpRequest('https://discord.com/api/webhooks/997434313031290992/DRJLkoDNjJHMRdN7hVS0S2xXTIsaqbpSK9IUYRCBHpgCV6gkj5nN-Gzf0mALxLZqmXcM', function(err, text, headers) end,
    'POST', json.encode(
        {username = "Menú Admin",
        embeds = {
            {["color"] = color,
            ["author"] = {
            ["name"] = "Menú Admin",
            ["icon_url"] = "https://media.discordapp.net/attachments/1034207094192214138/1036063187981840404/LANOCHERP-2.png?width=671&height=671"},
            ["description"] = "".. message .."",
            ["footer"] = {
            ["text"] = "©Menú Admin - "..os.date("%x %X %p"),
            ["icon_url"] = "https://media.discordapp.net/attachments/1034207094192214138/1036063187981840404/LANOCHERP-2.png?width=671&height=671",},}
        }, avatar_url = "https://media.discordapp.net/attachments/1034207094192214138/1036063187981840404/LANOCHERP-2.png?width=671&height=671"}), {['Content-Type'] = 'application/json' })
end

--Esta funciónn sirve para devolver el nivel de permiso
function getPermissionLevel(source)
	local license = ESX.GetIdentifier(source)
	local permission_level = nil
	local data = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @license", {['@license'] = license})
	if data[1] then
		permission_level = data[1].permission_level
	end
	return permission_level
end

--Función que retorna si tiene permisos para ejecutar la acción
function isItAvaliable(source,permission)
	for i,v in pairs(ranks[playersRank[source]]) do
		if v == permission then
			return true
		end
	end
end

Citizen.CreateThread(function()
	Citizen.Wait(500)
	getRanks()
end)

--Este evento setea en cliente el nivel del permiso
RegisterServerEvent('tm1_adminSystem:getPermissionLevel')
AddEventHandler('tm1_adminSystem:getPermissionLevel', function()
	local source = source
	playersRank[source] = getPermissionLevel(source)
	TriggerClientEvent('tm1_adminSystem:setPermissionLevel',source,playersRank[source],ranks)
end)

RegisterServerEvent('tm1_adminSystem:noclip')
AddEventHandler('tm1_adminSystem:noclip', function(permission, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		TriggerClientEvent('tm1_adminSystem:nocliped',source)
		LogsMenuAdmin('**NOCLIP:**\n **ID Jugador:** '..IdPlayer..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:godmode')
AddEventHandler('tm1_adminSystem:godmode', function(permission, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		TriggerClientEvent('tm1_adminSystem:godmoded',source)
		LogsMenuAdmin('**GODMODE:**\n **ID Jugador:** '..IdPlayer..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:vanish')
AddEventHandler('tm1_adminSystem:vanish', function(permission, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		TriggerClientEvent('tm1_adminSystem:vanished',source)
		LogsMenuAdmin('**VANISH:**\n **ID Jugador:** '..IdPlayer..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:clearChat')
AddEventHandler('tm1_adminSystem:clearChat', function(permission)
	if isItAvaliable(source,permission) == true then
		TriggerClientEvent('chat:clear', -1)
	end
end)

RegisterServerEvent('tm1_adminSystem:setJob')
AddEventHandler('tm1_adminSystem:setJob', function(permission, args, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		if args[1] and args[2] and args[3] then
			if tonumber(args[1]) and args[2] and tonumber(args[3]) then
				local xPlayer = ESX.GetPlayerFromId(args[1])

				if xPlayer then
					xPlayer.setJob(args[2], tonumber(args[3]))
					TriggerClientEvent('esx:showNotification',source, 'Se añadió el trabajo a ID: '..args[1]..' como '..args[2]..' con rango '..args[3])
					LogsMenuAdmin('**SETJOB:**\n **ID Jugador:** '..IdPlayer..' \n Ha contratado a ID:'..args[1]..' como '..args[2]..' con rango '..args[3]..'')
				else
					TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
				end
			else
				TriggerClientEvent('esx:showNotification',source, "Así no se usa.")
			end
		else
			TriggerClientEvent('esx:showNotification',source, "Faltan parámetros.")
		end
	end
end)

RegisterServerEvent('tm1_adminSystem:spawnCar')
AddEventHandler('tm1_adminSystem:spawnCar', function(permission, args, IdPlayer)
	LogsMenuAdmin('**SpawnVehículo:**\n **ID Jugador:** '..IdPlayer..' se ha sacado el vehículo: **'..args..'**')
end)

RegisterServerEvent('tm1_adminSystem:fixvehicle')
AddEventHandler('tm1_adminSystem:fixvehicle', function(permission, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		LogsMenuAdmin('**Arreglar Vehículo:**\n **ID Jugador:** '..IdPlayer..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:clearVehicle')
AddEventHandler('tm1_adminSystem:clearVehicle', function(permission, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		LogsMenuAdmin('**Borrado Vehículo:**\n **ID Jugador:** '..IdPlayer..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:spawnWeapon')
AddEventHandler('tm1_adminSystem:spawnWeapon', function(permission, args, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		if args[1] and args[2] and args[3] then
			if tonumber(args[1]) and args[2] and tonumber(args[3]) then
				local xPlayer = ESX.GetPlayerFromId(args[1])
				local weapon = string.upper(args[2])
				if xPlayer then
					xPlayer.addWeapon("WEAPON_"..weapon, tonumber(args[3]))
					TriggerClientEvent('esx:showNotification',source, 'Se puso correctamente al ID: '..args[1]..' el arma '..args[2]..' con la cantidad de balas de '..args[3])
					LogsMenuAdmin('**ARMA:**\n **ID Jugador:** '..IdPlayer..' \n Ha puesto al ID:'..args[1]..' el arma '..args[2]..' con la cantidad de balas de '..args[3])
				else
					TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
				end
			else
				TriggerClientEvent('esx:showNotification',source, "Así no se usa.")
			end
		else
			TriggerClientEvent('esx:showNotification',source, "Faltan parámetros.")
		end
	end
end)

RegisterServerEvent('tm1_adminSystem:spawnObject')
AddEventHandler('tm1_adminSystem:spawnObject', function(permission, args, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		if args[1] and args[2] and args[3] then
			if tonumber(args[1]) and args[2] and tonumber(args[3]) then
				local xPlayer = ESX.GetPlayerFromId(args[1])

				if xPlayer then
					xPlayer.addInventoryItem(args[2], tonumber(args[3]))
					TriggerClientEvent('esx:showNotification',source, 'Se añadió '..args[2]..' objeto al ID: '..args[1]..' con la cantidad de '..args[3])
					LogsMenuAdmin('**OBJETO:**\n **ID Jugador:** '..IdPlayer..' \n Ha puesto al ID:'..args[1]..' el objeto '..args[2]..'con la cantidad de '..args[3])
				else
					TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
				end
			else
				TriggerClientEvent('esx:showNotification',source, "Así no se usa.")
			end
		else
			TriggerClientEvent('esx:showNotification',source, "Faltan parámetros.")
		end
	end
end)

RegisterServerEvent('tm1_adminSystem:spawnMoney')
AddEventHandler('tm1_adminSystem:spawnMoney', function(permission, args, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		if args[1] and args[2] and args[3] then
			if tonumber(args[1]) and args[2] and tonumber(args[3]) then
				local xPlayer = ESX.GetPlayerFromId(args[1])

				if xPlayer then
					xPlayer.addAccountMoney(args[2], tonumber(args[3]))
					TriggerClientEvent('esx:showNotification',source, 'Se añadió tipo:'..args[2]..' al ID: '..args[1]..' con la cantidad de '..args[3])
					LogsMenuAdmin('**DINERO:**\n **ID Jugador:** '..IdPlayer..' \n Ha puesto al ID: '..args[1]..' de tipo '..args[2]..' la cantidad de '..args[3])
				else
					TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
				end
			else
				TriggerClientEvent('esx:showNotification',source, "Así no se usa.")
			end
		else
			TriggerClientEvent('esx:showNotification',source, "Faltan parámetros.")
		end
	end
end)

RegisterServerEvent('tm1_adminSystem:clearInventory')
AddEventHandler('tm1_adminSystem:clearInventory', function(permission, target, IdPlayer)
	local source = source
	if isItAvaliable(source,permission) == true then
		local xPlayer

		if target then
			xPlayer = ESX.GetPlayerFromId(target)
		else
			xPlayer = ESX.GetPlayerFromId(source)
		end

		if not xPlayer then
			TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
			return
		end

		for i=1, #xPlayer.inventory, 1 do
			if xPlayer.inventory[i].count > 0 then
				xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
			end
		end
		for k,v in ipairs(xPlayer.loadout) do
			xPlayer.removeWeapon(v.name)
		end

		LogsMenuAdmin('**Borrado Inventario:**\n **ID Jugador:** '..IdPlayer..' ha borrado el inventario de ID:'..target..'')
		TriggerClientEvent('esx:showNotification',source, "Inventario ~g~borrado.")
	end
end)

RegisterServerEvent('tm1_adminSystem:bring')
AddEventHandler('tm1_adminSystem:bring', function(permission, target, option, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then

		if target then
			xPlayer = ESX.GetPlayerFromId(target)
			zPlayer = ESX.GetPlayerFromId(source)
		else
			TriggerClientEvent('esx:showNotification',source, "Introduce un parámetro.")
			return
		end

		if not xPlayer then
			TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
			return
		end

		if option == -1 then
			TriggerClientEvent('esx:showNotification',source, "Te has teletransportado  ~g~correctamente~w~.")
            TriggerClientEvent('esx:showNotification',target, "Un administrador se ha teletransportado hacia ti.")
			TriggerClientEvent('tm1_adminSystem:goto', source, xPlayer.getCoords().x, xPlayer.getCoords().y, xPlayer.getCoords().z)
			LogsMenuAdmin('**Goto:**\n **ID Jugador:** '..IdPlayer..' ha ido al jugador ID:'..target..'')
			return
		end
		TriggerClientEvent('tm1_adminSystem:goto', target, zPlayer.getCoords().x, zPlayer.getCoords().y, zPlayer.getCoords().z)
		TriggerClientEvent('esx:showNotification',target, "Un administrador te ha teleportado hacia el.")
		TriggerClientEvent('esx:showNotification',source, "Has traido  ~g~correctamente~w~ al jugador.")
		LogsMenuAdmin('**Bring:**\n **ID Jugador:** '..IdPlayer..' ha traido al jugador ID:'..target..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:freeze')
AddEventHandler('tm1_adminSystem:freeze', function(permission, target, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
		local xPlayer
		if target then
			xPlayer = ESX.GetPlayerFromId(target)
		else
			TriggerClientEvent('esx:showNotification',source, "Introduce un parámetro.")
			return
		end

		if not xPlayer then
			TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
			return
		end

		TriggerClientEvent('tm1_adminSystem:freezed',target)
		TriggerClientEvent('esx:showNotification',source, "Has cambiado el estado del jugador.")
		LogsMenuAdmin('**Freezed:**\n **ID Jugador:** '..IdPlayer..' ha freezeado al jugador ID:'..target..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:heal')
AddEventHandler('tm1_adminSystem:heal', function(permission, target, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
		local xPlayer
		if target then
			xPlayer = ESX.GetPlayerFromId(target)
		else
			TriggerClientEvent('esx:showNotification',source, "Introduce un parámetro.")
			return
		end

		if not xPlayer then
			TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
			return
		end

		TriggerClientEvent('tm1_adminSystem:healed',target)
		TriggerClientEvent('esx:showNotification',source, "Has ~g~rellenado~w~ a un jugador.")
		LogsMenuAdmin('**Heal:**\n **ID Jugador:** '..IdPlayer..' ha rellenado la vida del jugador ID:'..target..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:kill')
AddEventHandler('tm1_adminSystem:kill', function(permission, target, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
		local xPlayer
		if target then
			xPlayer = ESX.GetPlayerFromId(target)
		else
			TriggerClientEvent('esx:showNotification',source, "Introduce un parámetro.")
			return
		end

		if not xPlayer then
			TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
			return
		end

		TriggerClientEvent('tm1_adminSystem:killed',target)
		TriggerClientEvent('esx:showNotification',source, "Has ~r~matado~w~ a un jugador.")
		LogsMenuAdmin('**Kill:**\n **ID Jugador:** '..IdPlayer..' ha matado al jugador ID:'..target..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:revive')
AddEventHandler('tm1_adminSystem:revive', function(permission, target, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
		local xPlayer
		if target then
			xPlayer = ESX.GetPlayerFromId(target)
		else
			TriggerClientEvent('esx:showNotification',source, "Introduce un parámetro.")
			return
		end

		if not xPlayer then
			TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
			return
		end

		TriggerClientEvent('esx_ambulancejob:revive',target)
		TriggerClientEvent('esx:showNotification',source, "Has ~g~revivido~w~ a un jugador.")
		LogsMenuAdmin('**Revivido:**\n **ID Jugador:** '..IdPlayer..' ha revivido al jugador ID:'..target..'')
	end
end)

RegisterServerEvent('tm1_adminSystem:kick')
AddEventHandler('tm1_adminSystem:kick', function(permission, args, reason, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
		print(reason)
		print(args[1])
		if tonumber(args[1]) and reason then
			local xPlayer = ESX.GetPlayerFromId(args[1])
			if xPlayer then
				xPlayer.kick(reason.. " - STAFF: " .. IdPlayer )
				LogsMenuAdmin('**Kickeado:**\n **ID Jugador:** '..IdPlayer..' ha kickeado al ID:'..xPlayer..'')
			else
				TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
				return
			end
		else
			TriggerClientEvent('esx:showNotification',source, "Así no se usa. [ID] [Razón]")
    	end
	end
end)

RegisterServerEvent('tm1_adminSystem:ban')
AddEventHandler('tm1_adminSystem:ban', function(permission, args, reason, IdPlayer)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
		print(reason)
		print(args[1])
		if tonumber(args[1]) and reason then
			local xPlayer = ESX.GetPlayerFromId(args[1])
			if xPlayer then
				xPlayer.kick(reason.. " - STAFF: " .. IdPlayer )
				LogsMenuAdmin('**Kickeado:**\n **ID Jugador:** '..IdPlayer..' ha kickeado al ID:'..xPlayer..'')
			else
				TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
				return
			end
		else
			TriggerClientEvent('esx:showNotification',source, "Así no se usa. [ID] [Razón]")
    	end
	end
end)

RegisterServerEvent('tm1_adminSystem:ck')
AddEventHandler('tm1_adminSystem:ck', function(permission, target, Playerid)
	local source = source
	local target = target
	if isItAvaliable(source,permission) == true then
	    local xPlayer = ESX.GetPlayerFromId(target)
            if target then
                local xTarget = ESX.GetPlayerFromId(target)
                local steam = GetPlayerIdentifier(target)
				if not xPlayer then
					TriggerClientEvent('esx:showNotification',source, "Jugador ~r~no ~w~disponible.")
					return
				end
                if steam then
                    MySQL.Async.execute(
                        'DELETE FROM users WHERE identifier = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM owned_vehicles WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM addon_account_data WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM billing  WHERE identifier = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM addon_inventory_items WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM datastore_data WHERE owner = @identifier',
                        {['@identifier'] = steam})------
                    MySQL.Async.execute(
                        'DELETE FROM phone_users_contacts WHERE identifier = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM dpkeybinds WHERE id = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM phone_messages WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM user_licenses  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM motel WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM owned_vehicles  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM casas WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_bank_transfer  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_app_chat WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_calls  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_gallery WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_gps  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_group_message WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_settings  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_users_contacts WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM user_licenses  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_insto_accounts WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_insto_instas  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_insto_likes WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_bank_transfer  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_job_message WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_messages  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM gksphone_messages_group WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM prx_tab_lspd_hist  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM prx_tab_ems_hist WHERE owner = @identifier',
                        {['@identifier'] = steam})
                    MySQL.Async.execute(
                        'DELETE FROM loaf_keys  WHERE owner = @identifier',
                        {['@identifier'] = steam})
                end
            	DropPlayer(target, 'El CK se ha realizado correctamente. ¡Ya puedes volver a entrar!')
				LogsMenuAdmin('**CK:**\n **CK realizado a:** '..steam..' y ordenado por '..Playerid)
			else
				
			end

    	end
end)