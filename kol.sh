#include <a_samp>

new bool:IsRacing[MAX_PLAYERS];

public OnPlayerSpawn(playerid)
{
    SetPlayerPos(playerid, -1520.0, -48.0, 6.0);  
    SetPlayerFacingAngle(playerid, 90.0); 

    new car = CreateVehicle(411, -1520.0, -48.0, 5.5, 90.0, 3, 3, 0);
    PutPlayerInVehicle(playerid, car, 0);
    
    SetPlayerRaceCheckpoint(playerid, 0, -1030.0, 200.0, 6.0, 0, 0, 0, 5.0);
    IsRacing[playerid] = true;
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if(IsRacing[playerid])
    {
        IsRacing[playerid] = false;
        new name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, sizeof(name));
        
        SendClientMessageToAll(-1, "🎉 {00FF00}Pemenang: ");
        SendClientMessageToAll(-1, name);
    }
    return 1;
}
