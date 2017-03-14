/*  SM Snowfall (Precipitation)
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "2.0"


Handle H_preciptype;
Handle H_density;
Handle H_color;
Handle H_render;

char preciptype[24];
char density[24];
char thecolor[24];
char render[24];

float m_vecOrigin[3];
float maxbounds[3];
float minbounds[3];

char PrecipitationModel[128];

//bool g_snow[MAXPLAYERS + 1];

#define IGNORELIST_MAX 255
new String:ignorelist[IGNORELIST_MAX][128];
new listlen;

bool enable;

public Plugin myinfo =
{
	name = "SM Snowfall (Precipitation)",
	author = "Franc1sco franug",
	description = "Add precipitations to the maps",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	CreateConVar("sm_snowfall_version", PLUGIN_VERSION, "version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	HookEventEx("round_start", Event_RoundStart);
	HookEventEx("teamplay_round_start", Event_RoundStart);

	H_preciptype = CreateConVar("sm_snowfall_type", "3", "Type of the precipitation");
	H_density = CreateConVar("sm_snowfall_density", "75", "Density of the precipitation");
	H_color = CreateConVar("sm_snowfall_color", "255 255 255", "Color of the precipitation");
	H_render = CreateConVar("sm_snowfall_renderamt", "5", "Render of the precipitation");
	
	HookConVarChange(H_preciptype, CVarChange);
	HookConVarChange(H_density, CVarChange);
	HookConVarChange(H_color, CVarChange);
	HookConVarChange(H_render, CVarChange);
	
	GetCVars();
	
	//RegConsoleCmd("sm_snow", Snow);
}
/*
public Action:Snow(client, args)
{
	if(!enable)
	{
		ReplyToCommand(client, "Precipitation disabled in this map");
		return Plugin_Handled;
	}
	g_snow[client] = !g_snow[client];
	
	ReplyToCommand(client, "You have %s the precipitation on you", g_snow[client] ? "enabled":"disabled");
	return Plugin_Handled;
}*/

public CVarChange(Handle:convar_hndl, const String:oldValue[], const String:newValue[])
{
	GetCVars();
}

void GetCVars()
{
	GetConVarString(H_preciptype, preciptype, sizeof(preciptype));
	GetConVarString(H_density, density, sizeof(density));
	GetConVarString(H_color, thecolor, sizeof(thecolor));
	GetConVarString(H_render, render, sizeof(render));

}

public void OnMapStart()
{
	LoadList();
	char MapName[64]; 
	GetCurrentMap(MapName, 64);
	
	enable = true;
	
	for (int i = 0; i < listlen; i++) {
		if(StrContains(MapName, ignorelist[i], false) != -1) {
			enable = false;
			return;
		}
	}
	
	Format(PrecipitationModel, sizeof(PrecipitationModel), "maps/%s.bsp", MapName);
	PrecacheModel(PrecipitationModel, true);
	
	GetEntPropVector(0, Prop_Data, "m_WorldMins", minbounds);
	GetEntPropVector(0, Prop_Data, "m_WorldMaxs", maxbounds);
	
	while(TR_PointOutsideWorld(minbounds)) 
	{
		minbounds[0]++;
		minbounds[1]++;
		minbounds[2]++;
	}
		
	while(TR_PointOutsideWorld(maxbounds)) 
	{
		maxbounds[0]--;
		maxbounds[1]--;
		maxbounds[2]--;
	}
	
	m_vecOrigin[0] = (minbounds[0] + maxbounds[0]) / 2;
	m_vecOrigin[1] = (minbounds[1] + maxbounds[1]) / 2;
	m_vecOrigin[2] = (minbounds[2] + maxbounds[2]) / 2;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{	
	if (!enable)return;
	
	ClearPrecipitations();
	
	new ent = CreateEntityByName("func_precipitation");
	DispatchKeyValue(ent, "model", PrecipitationModel);
	DispatchKeyValue(ent, "preciptype", preciptype);
	DispatchKeyValue(ent, "renderamt", render);
	DispatchKeyValue(ent, "density", density);
	DispatchKeyValue(ent, "rendercolor", thecolor);
	DispatchSpawn(ent);
	//SDKHook(ent, SDKHook_SetTransmit, OnShouldDisplay);
	ActivateEntity(ent);
	
	SetEntPropVector(ent, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxbounds);    
	
	TeleportEntity(ent, m_vecOrigin, NULL_VECTOR, NULL_VECTOR);
}
/*
public OnClientPutInServer(client)
{
	g_snow[client] = true;
}

public Action OnShouldDisplay(int iEnt, int client)
{
	return g_snow[client] ? Plugin_Continue : Plugin_Handled;
}*/

ClearPrecipitations()
{

	new index = -1;
	while ((index = FindEntityByClassname2(index, "func_precipitation")) != -1)
		AcceptEntityInput(index, "Kill");	
}

// Thanks to exvel for the function below. Exvel posted that in the FindEntityByClassname API.
stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;

	return FindEntityByClassname(startEnt, classname);
}

public LoadList()
{
	new String:path[PLATFORM_MAX_PATH];
	BuildPath(PathType:Path_SM, path, sizeof(path), "configs/ignoresnowfall_maps.txt");
	
	new Handle:file = OpenFile(path, "r");
	if(file == INVALID_HANDLE)
	{
		SetFailState("Unable to read file %s", path);
	}
	
	listlen = 0;
	new String:theline[128];
	while(!IsEndOfFile(file) && ReadFileLine(file, theline, sizeof(theline)))
	{
		if (theline[0] == ';' || !IsCharAlpha(theline[0]))
		{
			continue;
		}
		new len = strlen(theline);
		for (new i; i < len; i++)
		{
			if (IsCharSpace(theline[i]) || theline[i] == ';')
			{
				theline[i] = '\0';
				break;
			}
		}
		ignorelist[listlen] = theline;
		listlen++;
	}
	
	CloseHandle(file);
}
