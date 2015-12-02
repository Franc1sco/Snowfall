#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
    name = "Let It Snow",
    author = "FlyingMongoose",
    description = "Creates an entity to enforce it snow on the map",
    version = "1.0",
    url = "http://www.tunedchaos.com"
}

new g_offsCollisionGroup;

new Handle:cvarSnowOn;
new PrecipIndex[MAXPLAYERS];

public OnPluginStart()
{
    g_offsCollisionGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");
    cvarSnowOn = CreateConVar("letsnow_on","0","Turns snow on and off, 1=On 2=Off",FCVAR_PLUGIN,true,0.0,true,1.0);
    HookConVarChange(cvarSnowOn,cvarSnowChanged);
}

public cvarSnowChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    if(GetConVarBool(cvar))
    {
        for(new i=1; i < GetMaxClients(); i++)
        {
            if(IsClientInGame(i) && IsClientConnected(i) && i != 0)
            {
                CreateSnow(i);
            }
        }
        PrintToChatAll("\x06 [Let It Snow]: Snow has been enabled");
    }else{
        for(new i=1; i < GetMaxClients(); i++)
        {
            if(IsClientInGame(i) && IsClientConnected(i) && i != 0)
            {
                RemoveSnow(i)
            }
        }
        PrintToChatAll("\x06 [Let It Snow]: Snow has been disabled");
    }
    
}


public OnMapStart()
{
    PrecacheModel("models/error.mdl",true);
    if(GetConVarBool(cvarSnowOn))
    {
        for(new i=1; i < GetMaxClients(); i++)
        {
            if(IsClientInGame(i) && IsClientConnected(i) && i != 0)
            {
                CreateSnow(i);
            }
        }
    }
}

public OnClientPostAdminCheck(client)
{
    if(GetConVarBool(cvarSnowOn))
    {
        if(IsClientInGame(client) && IsClientConnected(client) && client != 0)
        {
            CreateSnow(client);
        }
    }
}

public OnClientDisconnect(client)
{
    if(GetConVarBool(cvarSnowOn))
    {
        if(IsClientInGame(client) && client != 0)
        {
            CreateSnow(client);
        }
    }
}



public CreateSnow(client)
{
    decl String:propName[128];
    new Float:playerpos[3]; 
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerpos);
    GetEntPropString(client,Prop_Data,"m_iName",propName,128);
    
    
    PrecipIndex[client] = CreateEntityByName("func_precipitation");
    if(PrecipIndex[client] != -1)
    {
        DispatchKeyValue(PrecipIndex[client],"parentname",propName);
        DispatchKeyValue(PrecipIndex[client],"preciptype","3");
        DispatchKeyValue(PrecipIndex[client],"model","models/error.mdl");
        DispatchKeyValue(PrecipIndex[client],"renderamt","5");
        DispatchKeyValue(PrecipIndex[client],"rendercolor","100 100 100");
        
        DispatchSpawn(PrecipIndex[client]); 
        ActivateEntity(PrecipIndex[client]); 
        
        TeleportEntity(PrecipIndex[client], playerpos, NULL_VECTOR, NULL_VECTOR); 
        
        SetEntityModel(PrecipIndex[client], "models/error.mdl");
        
        new Float:minbounds[3] = {-100.0, -100.0, 0.0}; 
        new Float:maxbounds[3] = {100.0, 100.0, 200.0}; 
        SetEntPropVector(PrecipIndex[client], Prop_Send, "m_vecMins", minbounds); 
        SetEntPropVector(PrecipIndex[client], Prop_Send, "m_vecMaxs", maxbounds); 
        
        SetEntProp(PrecipIndex[client], Prop_Send, "m_nSolidType", 2); 
        SetEntData(PrecipIndex[client], g_offsCollisionGroup, 2, 4, true);
        

    }else{
        LogError("[SourceMod] LetItSnow Plugin Failed to create func_precipitation entity for client %d",client);
    }
}

public RemoveSnow(client)
{
    if(PrecipIndex[client] != -1)
    {
		
		Entity_ClearParent(PrecipIndex[client]);
    }
}

stock Entity_ClearParent(entity)
{
	SetVariantString("");
	AcceptEntityInput(entity, "ClearParent");
}