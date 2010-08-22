//
//  AI_UFHO2.h
//  UFHO2 - AI
//
//  Created by mdpp on August 2010

#import <Cocoa/Cocoa.h>

#define CELLA_VUOTA             0
#define CELLA_MURO              1
#define CELLA_COMPUTER          2
#define CELLA_GEMMA             3
#define CELLA_GIOCATORE         4
#define CELLA_EXTRA_TEMPO       5
#define CELLA_EXTRA_MOSSA       6
#define CELLA_BLOCCA_AVVERSARIO 7

#define CELLA_MARKER            8 // utilizzato per evidenziare il percorso scelto (solo per test)
#define CELLA_ROTATE            9 // cella per rotazione (solo per test)


#define COMPUTER    0
#define GIOCATORE   1

#define TOOL_OPEN 0
#define TOOL_WALL 1
#define TOOL_START 2
#define TOOL_FINISH 3

#define MAX_OGGETTI 5


// Posizioni
#define POSITION_CENTER     0
#define POSITION_NORD       1
#define POSITION_NORDEST    2
#define POSITION_SUDEST     3
#define POSITION_SUD        4
#define POSITION_SUDOVEST   5
#define POSITION_NORDOVEST  6


// prossima mossa
#define NESSUNA_MOSSA       -1
#define MUOVI_PERSONAGGIO   0
#define RUOTA_STANZA        1
#define RUOTA_AREA          2
#define RUOTA_PROX_STANZA   3
#define RUOTA_PROX_AREA     4
#define DISTURBA_AVVERSARIO 5

#define NUMERO_MOSSE 6
#define TEMPO_MAX 20

#define MOSSE_AGGIUNTIVE 2
#define TEMPO_AGGIUNTIVO 10

#define GRID_LENGTH_X 9
#define GRID_LENGTH_Y 9

#define BOX_DIMENSION 64



// struttura per singola cella (da utilizzare come array)
typedef struct {
    int valueCell;
    BOOL triangleUp;
    int whichArea;
} structStanza;

// struttura per coordinate
typedef struct {
    int x;
    int y;
} cellCoord;

// struttura per oggetti differenti da giocatore e computer
typedef struct {
    cellCoord pos;
	NSMutableArray *pointerToPath;
} objProperties;


// struttura per aree
typedef struct {
    cellCoord cella[7];
    BOOL triangleUp;
} structArea;



@interface DemoView : NSView {

	// struttura per celle hex (ufho2)
    
    structStanza mappaCelle[GRID_LENGTH_X][GRID_LENGTH_Y]; // mappa di gioco
    
    structArea   mappaAree[7]; // struttura per le 7 aree (esagoni grandi) 
	
    int currentTool; //keeps track of what tile we're drawing
	
    cellCoord posGiocatore; // coordinate giocatore
    cellCoord posComputer;  // coordinate computer
    cellCoord posGemma;     // coordinate gemme
   
    int iTempoDisponibile;

    int iMosseDisponibili[2];    
    int iBloccoAvversario[2];
    int iTempoAggiuntivo[2];
    int iMosseAggiuntive[2];
    
    objProperties posOggetti[MAX_OGGETTI]; // coordinate oggetti oltre i giocatori

    int iNumOggetti; // Numero di oggetti presenti nella mappa
    
    cellCoord coordPercorsoScelto[100];
	
    int iPercorsoScelto;
    
    // variabili per tornare alla posizione precedente in caso di rotazione dell'area

    BOOL effettuataRotazioneArea;
    cellCoord prossimaMossa;
    
    NSMutableArray *pointerToOpenList; 
    
	IBOutlet NSButton *shouldAnimateButton;
}

-(IBAction)muoviComputer:(id)sender;

-(IBAction)quitDemo:(id)sender;

-(IBAction)selectTool:(id)sender;

-(IBAction)clearMap:(id)sender;

-(IBAction)runDemo:(id)sender;

-(void)drawGrid:(NSArray*)openList;

@end
