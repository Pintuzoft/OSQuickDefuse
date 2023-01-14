
#include <sourcemod>
#include <sdktools>
#include <cstrike>

int wire = 0;
int cut = 0;
bool hasKit = false;
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
    HookEvent ( "bomb_planted", Event_BombPlanted, EventHookMode_Post );
    HookEvent ( "bomb_begindefuse", Event_BombBeginDefuse, EventHookMode_Post );
    
}


/* EVENTS */
public Action Event_BombBeginPlant ( Handle event, const char[] name, bool dontBroadcast ) {
    int player = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
    wire = 0;

    Handle panel = CreatePanel ( );
    
    SetPanelTitle ( panel, "Choose wire:" );
    DrawPanelText ( panel, " " );
    DrawPanelText ( panel, "Set a wire for instant defuse:" );
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
public Action Event_BombPlanted ( Handle event, const char[] name, bool dontBroadcast ) {
    int player = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
    if ( wire == 0 ) {
        wire = GetRandomInt ( 1, 4 );
        PrintToChat ( player, " \x08Wire has been randomly set to %s%s \x08", code[wire], color[wire] );
    }
    return Plugin_Continue;
}

public Action Event_BombBeginDefuse ( Handle event, const char[] name, bool dontBroadcast ) {
    int player = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
    hasKit = GetEventBool ( event, "haskit" );

    Handle panel = CreatePanel ( );

    SetPanelTitle ( panel, "Choose wire:" );
    DrawPanelText ( panel, " " );
    DrawPanelText ( panel, "Cut a wire for an instant defuse" );
    DrawPanelText ( panel, " " );
    DrawPanelItem ( panel, "Blue" );
    DrawPanelItem ( panel, "Yellow" );
    DrawPanelItem ( panel, "Red" );
    DrawPanelItem ( panel, "Green" );
    DrawPanelText ( panel, " " );

    if ( ! hasKit ) {
        DrawPanelText ( panel, "WARNING!: You don't have a defuse kit: 1/8 chance" );
    } else {
        DrawPanelText ( panel, "Using defuse kit: 1/4 chance" );
    }

    SendPanelToClient ( panel, player, Panel_Defuse, 5 );
    CloseHandle ( panel );
    return Plugin_Continue;
}
 
/* PANELS */
public Panel_Plant ( Handle menu, MenuAction action, int player, int item ) {
    char name[64];
    int choice = ( item - 1 );
    GetClientName ( player, name, sizeof ( name ) );
    if ( choice >= 0 && choice <= 3 ) {
        wire = choice;
        PrintToChat ( player, " \x08You have chosen the %s%s \x08wire", code[wire], color[wire] );
    }
    PrintToChatAll ( "[debug] \x08%s \x08has chosen the %s%s \x08wire", name, code[wire], color[wire] );
}
public Panel_Defuse ( Handle menu, MenuAction action, int player, int item ) {
    int choice = ( item - 1 );
    PrintToConsoleAll ( "[Panel_Defuse:0]");
    if ( choice >= 0 && choice <= 3 ) {
    PrintToConsoleAll ( "[Panel_Defuse:1]");
        cut = choice;
        if ( cut == wire ) {
    PrintToConsoleAll ( "[Panel_Defuse:2]");
            PrintToChat ( player, " \x08You have cut the %s%s \x08wire", code[cut], color[cut] );
            if ( hasKit ) {
    PrintToConsoleAll ( "[Panel_Defuse:3]");
                AcceptDefuse ( player );
            } else {
    PrintToConsoleAll ( "[Panel_Defuse:4]");
                int chance = GetRandomInt ( 1, 2 );
                if ( chance == 1 ) {                    
    PrintToConsoleAll ( "[Panel_Defuse:5]");
                    AcceptDefuse ( player );
                } else {
    PrintToConsoleAll ( "[Panel_Defuse:6]");
                    PrintToChat ( player, " \x08The %s%s \x08wire was the correct one", code[wire], color[wire] );
                    RejectDefuse ( player );
                }
            }
        } else {
    PrintToConsoleAll ( "[Panel_Defuse:7]");
            PrintToChat ( player, " \x08You have cut the %s%s \x08wire", code[cut], color[cut] );
            PrintToChat ( player, " \x08The %s%s \x08wire was the correct one", code[wire], color[wire] );
            RejectDefuse ( player );
        }
    }
}

public void AcceptDefuse ( int player ) {
    char name[64];
    int bomb = FindEntityByClassname ( -1, "planted_c4" );
    if ( bomb ) {
        GetClientName ( player, name, sizeof ( name ) );
        SetEntPropFloat ( bomb, Prop_Send, "m_flDefuseCountDown", 1.0 );
        if ( hasKit ) {        
            PrintToChat ( player, " \x08You have successfully defused the bomb (1/4 chance with kit)" );
            PrintToChatAll ( " \x08%s \x08has correctly cut the %s%s \x08defuse wire (1/4 chance)", name, code[wire], color[wire] );
        } else {
            PrintToChat ( player, " \x08You have successfully defused the bomb (1/8 chance without kit)" );
            PrintToChatAll ( " \x08%s \x08has correctly cut the %s%s \x08defuse wire (1/8 chance)", name, code[wire], color[wire] );
        }
    } else {
        PrintToChat ( player, " \x08The bomb wasnt found!" );
    }
}

public void RejectDefuse ( int player ) {
    char name[64];
    int bomb = FindEntityByClassname ( -1, "planted_c4" );
    if ( bomb ) {
        GetClientName ( player, name, sizeof ( name ) );
        SetEntPropFloat ( bomb, Prop_Send, "m_flC4Blow", 1.0 );
        if ( hasKit ) {
            PrintToChat ( player, " \x08You have accidentally triggered the bomb while trying to defused it (1/4 chance with kit)" );
            PrintToChatAll ( " \x08%s \x08has failed to cut the correct wire with kit (1/4)", name );
        } else {
            PrintToChat ( player, " \x08You have accidentally triggered the bomb while trying to defused it without kit (1/8 chance)" );
            PrintToChatAll ( " \x08%s \x08has failed to cut the correct wire without kit (1/8)", name );
        }
    } else {
        PrintToChat ( player, " \x08The bomb wasnt found!" );
    }
}
 
