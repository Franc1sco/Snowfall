#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <devzones>


public OnEntityCreated(entity, const String:classname[])
{
	if(StrContains(classname , "trigger_multiple", false) != -1)
	{
		new iReference = EntIndexToEntRef(entity);
		CreateTimer(0.0, Timer_Created, iReference);
		
		PrintToChatAll("creadooo xdd");
		
		
	}
	
	//PrintToChatAll(classname);
}

public Action:Timer_Created(Handle:timer, any:ref)
{
    new entity = EntRefToEntIndex(ref);
    if(entity != INVALID_ENT_REFERENCE)
    {
		decl String:sTargetName[256];
		GetEntPropString(entity, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
		ReplaceString(sTargetName, sizeof(sTargetName), "sm_devzone ", "");
		
		if(StrContains(sTargetName , "snowfall", false) == -1) return;
		
		PrintToChatAll("creadooo xdd 2");
		new Float:Position[3];
		if(!Zone_GetZonePosition(sTargetName, false, Position)) return;
		
		CrearNevada(entity, Position);
    }
}

CrearNevada(entity, Float:Position[3])
{
	decl String:MapName[128];
	decl String:buffer[128];


	GetCurrentMap(MapName, sizeof(MapName));
	Format(buffer, sizeof(buffer), "maps/%s.bsp", MapName);
	new ent = CreateEntityByName("func_precipitation");
	DispatchKeyValue(ent, "model", buffer);
	DispatchKeyValue(ent, "preciptype", "3");
	DispatchKeyValue(ent, "renderamt", "5");
	DispatchKeyValue(ent, "rendercolor", "255 255 255");
	DispatchSpawn(ent);
	ActivateEntity(ent);
	new Float:minbounds[3];
	GetEntPropVector(entity, Prop_Data, "m_vecMins", minbounds); 
	new Float:maxbounds[3];
	GetEntPropVector(entity, Prop_Data, "m_vecMaxs", maxbounds); 	
	
	SetEntPropVector(ent, Prop_Send, "m_vecMins", minbounds);
	SetEntPropVector(ent, Prop_Send, "m_vecMaxs", maxbounds);    
	TeleportEntity(ent, Position, NULL_VECTOR, NULL_VECTOR);
	
	PrintToChatAll("creadooo");
}