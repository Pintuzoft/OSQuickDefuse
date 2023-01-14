
#include <sourcemod>
#include <sdktools>
#include <cstrike>

int wire = 0;
char code[4][8] = { "\x0C", "\x10", "\x02", "\x04" };
char color[4][8] = { "Blue", "Yellow", "Red", "Green" };

public Plugin myinfo = {
	name = "OSQuickDefuse",
	author = "Pintuz",
	description = "OldSwedes Quick Defuse plugin",
	version = "0.01",
	url = "https://github.com/Pintuzoft/OSQuickDefuse"
}


public void OnPluginStart() {
    HookEvent ( "bomb_beginplant", Event_BombBeginPlant, EventHookMode_Post );
}


/* EVENTS */
public Action Event_BombBeginPlant(Handle event, const char[] name, bool dontBroadcast) {
    int player = GetClientOfUserId(GetEventInt(event, "userid"));
    wire = 0;

    Handle panel = CreatePanel ( );
    
    SetPanelTitle ( panel, "Choose wire:" );
    DrawPanelText ( panel, " " );
    DrawPanelText ( panel, "CT can guess for an instant defuse" );
    DrawPanelText ( panel, "Exit or ignore this for a random wire" );
    DrawPanelText ( panel, " " );

    DrawPanelItem ( panel, "Blue" );
    DrawPanelItem ( panel, "Yellow" );
    DrawPanelItem ( panel, "Red" );
    DrawPanelItem ( panel, "Green" );

    DrawPanelText ( panel, " " );
    DrawPanelText ( panel, "Exit" );

    SendPanelToClient ( panel, player, Panel_Plant, 5 );
    
    CloseHandle ( panel );

    return Plugin_Continue;
}

 
/* PANELS */
public Panel_Plant ( Handle menu, MenuAction action, int client, int item ) {
    int choice = ( item - 1 );
    if ( choice >= 0 && choice <= 3 ) {
        wire = choice;
    } else {
        wire = GetRandomInt ( 1, 4 );        
    }
    PrintToChat ( client, " \x08You have chosen the %s%s \x08wire", code[wire], color[wire] );
}


