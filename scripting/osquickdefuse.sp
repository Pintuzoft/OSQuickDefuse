
#include <sourcemod>
#include <sdktools>
#include <cstrike>

int wire;
bool hasKit = false;
Handle panel; 

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
    HookEvent ( "bomb_defused", Event_BombDefused, EventHookMode_Post );
    HookEvent ( "bomb_abortdefuse", Event_BombAbortDefuse, EventHookMode_Post );
    HookEvent ( "bomb_exploded", Event_BombExploded, EventHookMode_Post );
}

public void OnRoundStart() {
    wire = -1;
    hasKit = false;
    ResetPanel ( );
}

/* EVENTS */
public Action Event_BombExploded ( Handle event, const char[] name, bool dontBroadcast ) {
    ResetPanel ( );
    return Plugin_Continue;
}
public Action Event_BombAbortDefuse ( Handle event, const char[] name, bool dontBroadcast ) {
    ResetPanel ( );
    return Plugin_Continue;
}
public Action Event_BombDefused ( Handle event, const char[] name, bool dontBroadcast ) {
    ResetPanel ( );
    return Plugin_Continue;
}
public Action Event_BombBeginPlant ( Handle event, const char[] name, bool dontBroadcast ) {
    int player = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
    wire = -1;
    hasKit = false;
    if ( panel ) {
        ResetPanel ( );
    }
    if ( playerIsReal ( player ) ) {
        LoadPlantPanel ( player );
    } 
    return Plugin_Continue;
}
public Action Event_BombPlanted ( Handle event, const char[] name, bool dontBroadcast ) {
    if ( wire < 0 || wire > 3 ) {
        wire = GetRandomInt ( 0, 3 );
        PrintToConsoleAll ( " \x08Wire has been randomly selected", code[wire], color[wire] );
    }
    return Plugin_Continue;
}

public Action Event_BombBeginDefuse ( Handle event, const char[] name, bool dontBroadcast ) {
    int player = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
    hasKit = GetEventBool ( event, "haskit" );
    if ( playerIsReal ( player ) ) { 
        LoadDefusePanel ( player );
    } else {
        wire = GetRandomInt ( 0, 3 );
    }
    return Plugin_Continue;
}
 
/* PANELS */
 public Panel_Plant ( Handle menu, MenuAction action, int player, int choice ) {
    char name[64];
    wire = (choice - 1);
    GetClientName ( player, name, sizeof ( name ) );
    if ( wire >= 0 && wire <= 3 ) {
        PrintToChat ( player, " \x08You have chosen the %s%s \x08wire", code[wire], color[wire] );
    }
    PrintToChatAll ( "[debug] \x08%s \x08has chosen the %s%s \x08wire", name, code[wire], color[wire] );
}

public Panel_Defuse ( Handle menu, MenuAction action, int player, int choice ) {
    int cut = (choice - 1);
    if ( wire < 0 || wire > 3 ) {
        wire = GetRandomInt ( 0, 3 );
        PrintToConsoleAll ( " \x08Wire has been randomly selected (%s%s \x08)", code[wire], color[wire] );
    }
    if ( cut >= 0 && cut <= 3 ) {
        if ( cut == wire ) {
            PrintToChat ( player, " \x08You have cut the %s%s \x08wire", code[cut], color[cut] );
            if ( hasKit ) {
                AcceptDefuse ( player );
            } else {
                int chance = GetRandomInt ( 1, 2 );
                if ( chance == 1 ) {                    
                    AcceptDefuse ( player );
                } else {
                    PrintToChat ( player, " \x08The %s%s \x08wire was the correct one", code[wire], color[wire] );
                    RejectDefuse ( player );
                }
            }
        } else {
            PrintToChat ( player, " \x08You have cut the %s%s \x08wire", code[cut], color[cut] );
            PrintToChat ( player, " \x08The %s%s \x08wire was the correct one", code[wire], color[wire] );
            RejectDefuse ( player );
        }
    }
    LoadDefusePanel ( player );
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
    }
    if ( playerIsReal ( player ) ) {
        ResetPanel ( );     
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
    }
    if ( playerIsReal ( player ) ) {
        ResetPanel ( );     
    }
}

public void LoadDefusePanel ( int player ) {
    panel = CreatePanel ( );
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
} 

public void LoadPlantPanel ( int player ) {
    panel = CreatePanel ( );
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
} 

public void ResetPanel ( ) {
    if ( panel != null ) {
        delete panel;
    }
    panel = null;
}

public bool playerIsReal ( int player ) {
    if ( player < 1 || player > MaxClients ) {
        return false;
    }
    if ( IsClientInGame ( player ) && 
         ! IsFakeClient ( player ) &&      
         ! IsClientSourceTV ( player ) ) {
        return true;
    }
    return false;
}
