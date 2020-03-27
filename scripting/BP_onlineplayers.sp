#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "boomix"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <geoip>
#include <boompanel3>
#include <json>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "BoomPanel online players page",
	author = PLUGIN_AUTHOR,
	description = "Online players page for BoomPanel3, use this as example to build your own page",
	version = PLUGIN_VERSION,
	url = "https://boompanel.com"
};

public void OnPluginStart()
{
	//BoomPanel3
	RegAdminCmd("sm_players", CMD_Players, ADMFLAG_BAN);
}

public void BoomPanel3_OnPluginLoad() 
{
	BoomPanel3_RegisterPlugin("Online players", "onlineplayers/index.html", "fa-user", true, ADMFLAG_BAN);
}

public void OnAllPluginsLoaded() 
{
	BoomPanel3_OnPluginLoad();
}

public Action CMD_Players(int client, int args) 
{
	
	//Get socket client
	int socketClient = BoomPanel3_GetSocketID();
	
	//Get all players in JSON
	JSON_Array allPlayers = new JSON_Array();
	for (int i = 1; i < MaxClients; i++) {
		if(IsClientAuthorized(i) && !IsFakeClient(i)) {
			JSON_Object player = new JSON_Object();
			char username[128], steamid[20], country[3], IP[20], steamid64[20];
			GetClientName(i, username, sizeof(username));
			GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid));
			GetClientAuthId(i, AuthId_SteamID64, steamid64, sizeof(steamid64));
			GetClientIP(i, IP, sizeof(IP));
			GeoipCode2(IP, country);
			float online = GetClientTime(i);
			player.SetString("name", username);
			player.SetString("steamid", steamid);
			player.SetString("steamid64", steamid64);
			player.SetString("country", country);
			player.SetFloat("online", online);
			allPlayers.PushObject(player);
		}
	}
	
	//Semd JSON to socket client
	BoomPanel3_ReturnDataArray(socketClient, "players", allPlayers);


	//Clear array
	allPlayers.Cleanup();
	delete allPlayers;
	
	return Plugin_Handled;
}