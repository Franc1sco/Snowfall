#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "2.0"


new Handle:H_preciptype;
new Handle:H_density;
new Handle:H_color;

new nevada[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "SM Snowfall",
	author = "Franc1sco Steam: franug",
	description = "snowfall on some maps",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public OnMapStart()
{
	CreateConVar("sm_snowfall_version", PLUGIN_VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	//HookEvent("round_start", Event_RoundStart);

	H_preciptype = CreateConVar("sm_snowfall_type", "3", "Type of the precipitation");
	H_density = CreateConVar("sm_snowfall_density", "5", "Density of the precipitation");
	H_color = CreateConVar("sm_snowfall_color", "255 255 255", "Color of the precipitation");
	
	HookEvent("player_spawn", Event_Players);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
}

/* public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{	
	decl String:MapName[128];
	decl String:buffer[128];
	decl String:pre[128];
	decl String:den[128];
	decl String:col[128];

	GetConVarString(H_preciptype, pre, sizeof(pre));
	GetConVarString(H_density, den, sizeof(den));
	GetConVarString(H_color, col, sizeof(col));


	GetCurrentMap(MapName, sizeof(MapName));
	Format(buffer, sizeof(buffer), "maps/%s.bsp", MapName);
	new ent = CreateEntityByName("func_precipitation");
	DispatchKeyValue(ent, "model", buffer);
	DispatchKeyValue(ent, "preciptype", pre);
	DispatchKeyValue(ent, "renderamt", den);
	DispatchKeyValue(ent, "rendercolor", col);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	new Float:minbounds[3];
	GetEntPropVector(0, Prop_Data, "m_WorldMins", minbounds); 
	new Float:maxbounds[3];
	GetEntPropVector(0, Prop_Data, "m_WorldMaxs", maxbounds); 	
	
	minbounds = {-100.0, -100.0, 0.0}; 
	maxbounds = {100.0, 100.0, 200.0}; 
	
	SetEntPropVector(ent, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxbounds);    
	new Float:m_vecOrigin[3];
	m_vecOrigin[0] = (minbounds[0] + maxbounds[0])/2;
	m_vecOrigin[1] = (minbounds[1] + maxbounds[1])/2;
	m_vecOrigin[2] = (minbounds[2] + maxbounds[2])/2;
	TeleportEntity(ent, m_vecOrigin, NULL_VECTOR, NULL_VECTOR);
} */

public Action:Event_Players(Handle:event, const String:name[], bool:dontBroadcast)
{	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	RemoveParent(client);
	
	decl String:MapName[128];
	decl String:buffer[128];
	decl String:pre[128];
	decl String:den[128];
	decl String:col[128];

	GetConVarString(H_preciptype, pre, sizeof(pre));
	GetConVarString(H_density, den, sizeof(den));
	GetConVarString(H_color, col, sizeof(col));


	GetCurrentMap(MapName, sizeof(MapName));
	Format(buffer, sizeof(buffer), "maps/%s.bsp", MapName);
	new ent = CreateEntityByName("func_precipitation");
	DispatchKeyValue(ent, "model", buffer);
	DispatchKeyValue(ent, "preciptype", pre);
	DispatchKeyValue(ent, "renderamt", den);
	DispatchKeyValue(ent, "rendercolor", col);
	DispatchSpawn(ent);
	ActivateEntity(ent);
	
	new Float:minbounds[3] = {-100.0, -100.0, 0.0}; 
	new Float:maxbounds[3] = {100.0, 100.0, 200.0}; 
	
	SetEntPropVector(ent, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxbounds);    
	new Float:m_vecOrigin[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", m_vecOrigin);
	TeleportEntity(ent, m_vecOrigin, NULL_VECTOR, NULL_VECTOR);
	
	nevada[client] = ent;
	
	Entity_SetParent(nevada[client], client);
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	RemoveParent(client);
}

public OnClientDisconnect(client)
{
	RemoveParent(client);
}


stock Entity_SetParent(entity, parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}

stock Entity_ClearParent(entity)
{
	SetVariantString("");
	AcceptEntityInput(entity, "ClearParent");
}

public RemoveParent(client)
{
	if (nevada[client] != 0 && IsValidEdict(nevada[client]))
	{
		//AcceptEntityInput(nevada[client], "Kill");
		Entity_ClearParent(nevada[client]);
		nevada[client] = 0;
	}
}

