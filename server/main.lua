ESX = nil
local connectedPlayers = {}

function GetPlayers()
	return connectedPlayers
end

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('heezzu_scoreboard:getConnectedPlayers', function(source, cb)
	cb(connectedPlayers)
end)

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
	connectedPlayers[playerId].job = job.name

	TriggerClientEvent('heezzu_scoreboard:counter', -1, connectedPlayers)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	AddPlayerToScoreboard(xPlayer, true)
end)

AddEventHandler('esx:playerDropped', function(playerId)
	connectedPlayers[playerId] = nil

	TriggerClientEvent('heezzu_scoreboard:counter', -1, connectedPlayers)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.CreateThread(function()
			Citizen.Wait(1000)
			local players = ESX.GetPlayers()
			
			for _, player in ipairs(players) do
				local xPlayer = ESX.GetPlayerFromId(player)
				AddPlayerToScoreboard(xPlayer)
			end	
			
			--[[for i = 1, 256, 1 do
				connectedPlayers[i] = {}
				connectedPlayers[i].id = i
				connectedPlayers[i].identifier = 'hexik'..i
				connectedPlayers[i].name = 'nick'..i
				connectedPlayers[i].job = 'ambulance'
				connectedPlayers[i].group = 'user'			
			end]]
		end)
	end
end)

function AddPlayerToScoreboard(xPlayer, update)
	local playerId = xPlayer.source

	connectedPlayers[playerId] = {}
	connectedPlayers[playerId].id = playerId
	connectedPlayers[playerId].identifier = xPlayer.identifier
	connectedPlayers[playerId].name = xPlayer.getName()
	connectedPlayers[playerId].job = xPlayer.job.name
	connectedPlayers[playerId].hiddenjob = xPlayer.hiddenjob.name
	connectedPlayers[playerId].group = xPlayer.group

	if update then
		TriggerClientEvent('heezzu_scoreboard:counter', -1, connectedPlayers)
	end
end

RegisterServerEvent('heezzu_scoreboard:players')
AddEventHandler('heezzu_scoreboard:players', function()
	TriggerClientEvent('heezzu_scoreboard:players', source, connectedPlayers)
end)

RegisterServerEvent('heezzu_scoreboard:Show')
AddEventHandler('heezzu_scoreboard:Show', function(text)
	local _source = source
	TriggerClientEvent("sendProximityMessageMe", -1, _source, _source, text)
end)