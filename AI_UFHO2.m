//
//  AI_UFHO2.m
//  UFHO2 - AI
//
//  Created by mdpp on AUgust 2010

#import "AI_UFHO2.h"


/****************** PathFindNode <--- Object that holds node information (cost, x, y, etc.) */
@interface PathFindNode : NSObject {
@public
	int nodeX,nodeY;
	int cost;
	PathFindNode *parentNode;
}
+(id)node;
@end
@implementation PathFindNode
+(id)node
{
    return [[[PathFindNode alloc] init] autorelease];
    
}
@end
/*********************************************************************************/

/****************** CoordCella <--- Oggetto per gestire le celle di un percorso */
@interface CoordCella : NSObject {
@public
	int x, y;
}
+(id)node;
@end
@implementation CoordCella
+(id)node
{
    return [[[CoordCella alloc] init] autorelease];
    
}
@end
/*********************************************************************************/


@implementation DemoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

// Utility varie per mappa

// Ricavo le coordinate di una cella adiacente a partire dalle coord di quella centrale 
-(cellCoord)cercaCella:(int)cellToFind :(int)x :(int)y;
{
    cellCoord cellApp;
    
    cellApp.x = -1;
    cellApp.y = -1;
 
    // errore
    if ((cellToFind < 1 || cellToFind > 6) ||
        (x < 1 || x >= GRID_LENGTH_X-1) || 
        (y < 1 || y >= GRID_LENGTH_Y-1))  
        return cellApp;
        
    // determino le coordinate
    switch (cellToFind) 
    {
            
    case POSITION_NORD: // nord 
    
        cellApp.x = x;
        cellApp.y = y+1;
        
        break;
        
    case POSITION_NORDEST: // ne 
        
        cellApp.x = x+1;
        cellApp.y = y+(x%2);
        
        break;
        
    case POSITION_SUDEST: // se
        
        cellApp.x = x+1;
        cellApp.y = y-(int)!(x%2);
        
        break;
        
        
    case POSITION_SUD: // sud
        
        cellApp.x = x;
        cellApp.y = y-1;
        
        break;
        
    case POSITION_SUDOVEST: // so
        
        cellApp.x = x-1;
        cellApp.y = y-(int)!(x%2);
        
        break;
        
    case POSITION_NORDOVEST: // no
        
        cellApp.x = x-1;
        cellApp.y = y+(x%2);
        
        break;
        
    }
    
    
    return cellApp;
}


// decremento le mosse
-(void)aggiornaNumeroMosse:(int)iPersonaggio :(int)iNumeroMosse;
{
    // decremento le mosse disponibili
 
    iMosseDisponibili[iPersonaggio]+=iNumeroMosse;

}



// metodo per aggiornare posizione dei "personaggi"

-(void)aggiornaCoordPersonaggi:(int) valore: (cellCoord) posizione :(cellCoord) nuovaPosizione ; 
{
    int i;
    
    // verifico cosa c'è nella cella
    
    switch (valore)
    {
        case CELLA_COMPUTER:
            posComputer = nuovaPosizione;
            NSLog(@"Computer in esagono!!! %d,%d ", posComputer.x, posComputer.y);
            break;
            
        case CELLA_GEMMA:
            posGemma = nuovaPosizione;
            posOggetti[0].pos = nuovaPosizione;
            NSLog(@"Gemma in esagono!!! %d,%d ", posGemma.x, posGemma.y);
            break;
            
        case CELLA_GIOCATORE:
            posGiocatore = nuovaPosizione;
            NSLog(@"Giocatore in esagono!!! %d,%d ", posGiocatore.x, posGiocatore.y);
            break;
            
        case CELLA_EXTRA_TEMPO:
        case CELLA_EXTRA_MOSSA:
        case CELLA_BLOCCA_AVVERSARIO:
            NSLog(@"Altri oggetti (%d)!!! %d,%d ", valore, posizione.x, posizione.y);

            // cerco di quale oggetto si tratta
            for (i=1;i<iNumOggetti;i++)
            {    
                if ((posOggetti[i].pos.x == posizione.x) && (posOggetti[i].pos.y == posizione.y))
                {
                    posOggetti[i].pos = nuovaPosizione;
                    return;
                }
            }
            break;
    }
}


// genera una coordinata random
-(void)generaCoordinareRandom:(int *)x :(int *)y;
{
    int appx, appy;
    
    // genera numeri random
    do
    {
        appx = (arc4random() % ((unsigned)GRID_LENGTH_X));
        appy = (arc4random() % ((unsigned)GRID_LENGTH_Y));
    } while (mappaCelle[appx][appy].valueCell != CELLA_VUOTA);

    *x = appx;
    *y = appy;
}


// decido se aggiungere altri oggetti sulla mappa
-(void)aggiungiOggettiRandom
{
    int appx, appy;
    unsigned iRandom;
    int iNuovoOggetto = 0;
    
    if (iNumOggetti == MAX_OGGETTI)
        return;
    
    // attraverso un numero random decido se aggiungere o meno degli oggetti
    iRandom = ((arc4random() % ((unsigned)30)));
    
    // utilizzo dei moltiplicatori per rendere meno frequente la cella per bloccare l'avversario
    switch (iRandom)
    {
        case CELLA_EXTRA_TEMPO:
        case CELLA_EXTRA_TEMPO*2:
        case CELLA_EXTRA_TEMPO*3:
            NSLog(@"aggiungo un extra time");
            iNuovoOggetto = CELLA_EXTRA_TEMPO;
            break;
            
        case CELLA_EXTRA_MOSSA:
        case CELLA_EXTRA_MOSSA*2:
        case CELLA_EXTRA_MOSSA*3:
            NSLog(@"aggiungo un extra move");
            iNuovoOggetto = CELLA_EXTRA_MOSSA;
            break;
            
        case CELLA_BLOCCA_AVVERSARIO:
            NSLog(@"aggiungo un blocca");
            iNuovoOggetto = CELLA_BLOCCA_AVVERSARIO;
            break;
    }
    
    if (iNuovoOggetto)
    {
        // genero coordinate random
        [self generaCoordinareRandom: &appx :&appy];
        
        posOggetti[iNumOggetti].pos.x = appx;
        posOggetti[iNumOggetti].pos.y = appy;
        mappaCelle[appx][appy].valueCell = iNuovoOggetto;
        
        iNumOggetti++;
    }
}




// ruota una stanza
-(void)ruotaStanza:(int)iPersonaggio :(int)x :(int)y;
{
    // ruoto
    mappaCelle[x][y].triangleUp = !mappaCelle[x][y].triangleUp;
    
    // decremento le mosse
    [self aggiornaNumeroMosse: iPersonaggio :-1];
    
    // aggiorno la visualizzazione
    [self setNeedsDisplay: YES];
}


// metodo per ruotare un'area

-(void)ruotaArea:(int)iPersonaggio :(int)iArea; 
{
    int i;
    cellCoord capp, cappPre;
    structStanza cellaAppoggio;
    
    // Setto la nuova posizione
    mappaAree[iArea].triangleUp = !mappaAree[iArea].triangleUp;

        
    // mi salvo il contenuto della prima cella
    cappPre = [self cercaCella: 1: mappaAree[iArea].cella[0].x :mappaAree[iArea].cella[0].y];
    cellaAppoggio = mappaCelle[cappPre.x][cappPre.y];

    // ruoto il contenuto del triangolo in senso orario
    for (i=6;i>0;i--)
    {        
        // determino le coordinate della cella
        capp = [self cercaCella: i: mappaAree[iArea].cella[0].x :mappaAree[iArea].cella[0].y];
        
        
        if (i>1)
        {
            // se nell'esagono ci sono "personaggi", ne vanno modificate le coordinate 
            [self aggiornaCoordPersonaggi: mappaCelle[capp.x][capp.y].valueCell: capp: cappPre]; 
            
            // muovo la cella
            mappaCelle[cappPre.x][cappPre.y] = mappaCelle[capp.x][capp.y];
            cappPre = capp;
        }
        else
        {
            // se nell'esagono ci sono "personaggi", ne vanno modificate le coordinate 
            [self aggiornaCoordPersonaggi: cellaAppoggio.valueCell: capp: cappPre]; 
            
            // muovo la cella
            mappaCelle[cappPre.x][cappPre.y] = cellaAppoggio;
        }
            
    }
    
    // decremento le mosse
    [self aggiornaNumeroMosse: iPersonaggio :-2];
    
    // aggiorno la visualizzazione
    [self setNeedsDisplay: YES];

}




-(void)initMap;
{
    int x,y,i,j;
	
    
    // resetto l'appartenenza delle celle
    for(x=0;x<GRID_LENGTH_X;x++)
    {
        for(y=0;y<GRID_LENGTH_Y;y++)
        {
            mappaCelle[x][y].whichArea = -1;
            mappaCelle[x][y].valueCell = CELLA_VUOTA;
        }
    }
    
    // vari set-up
    effettuataRotazioneArea = FALSE;
    
    for (i=0; i<2; i++)
    {   
        iMosseDisponibili[i] = NUMERO_MOSSE;
        iBloccoAvversario[i] = 0;
        iTempoAggiuntivo[i] = 0;
        iMosseAggiuntive[i] = 0;
    }
    iTempoDisponibile = TEMPO_MAX;
    
    // set up della griglia da riutilizzare in SW definitivo
    // setto come fossero un "Muro" tutte le caselle che non esistono nel gioco
    mappaCelle[0][0].valueCell = CELLA_MURO;
	mappaCelle[0][1].valueCell = CELLA_MURO;
	mappaCelle[0][8].valueCell = CELLA_MURO;
	mappaCelle[1][0].valueCell = CELLA_MURO;
	mappaCelle[1][7].valueCell = CELLA_MURO;
    mappaCelle[1][8].valueCell = CELLA_MURO;
    mappaCelle[2][0].valueCell = CELLA_MURO;
	mappaCelle[2][1].valueCell = CELLA_MURO;
	mappaCelle[2][4].valueCell = CELLA_MURO;
	mappaCelle[2][7].valueCell = CELLA_MURO;
	mappaCelle[2][8].valueCell = CELLA_MURO;
	mappaCelle[5][2].valueCell = CELLA_MURO;
	mappaCelle[5][5].valueCell = CELLA_MURO;
    mappaCelle[5][8].valueCell = CELLA_MURO;
    mappaCelle[6][0].valueCell = CELLA_MURO;
	mappaCelle[6][1].valueCell = CELLA_MURO;
	mappaCelle[6][8].valueCell = CELLA_MURO;
	mappaCelle[7][0].valueCell = CELLA_MURO;
	mappaCelle[7][7].valueCell = CELLA_MURO;
    mappaCelle[7][8].valueCell = CELLA_MURO;
    mappaCelle[8][0].valueCell = CELLA_MURO;
	mappaCelle[8][1].valueCell = CELLA_MURO;
	mappaCelle[8][4].valueCell = CELLA_MURO;
	mappaCelle[8][7].valueCell = CELLA_MURO;
	mappaCelle[8][8].valueCell = CELLA_MURO;


    
    /******** DA RIMUOVERE IN ALGORTMO DEFINITIVO --- INIZIO ******/

    
    // celle per ruotare esagoni grandi

    mappaCelle[3][5].valueCell = CELLA_ROTATE;
    mappaCelle[3][5].whichArea = 0;

    mappaCelle[3][8].valueCell = CELLA_ROTATE;
    mappaCelle[3][8].whichArea = 1;

	mappaCelle[6][7].valueCell = CELLA_ROTATE;
    mappaCelle[6][7].whichArea = 2;

	mappaCelle[6][4].valueCell = CELLA_ROTATE;
    mappaCelle[6][4].whichArea = 3;

	mappaCelle[3][2].valueCell = CELLA_ROTATE;
    mappaCelle[3][2].whichArea = 4;

    mappaCelle[0][4].valueCell = CELLA_ROTATE;
    mappaCelle[0][4].whichArea = 5;
    
	mappaCelle[0][7].valueCell = CELLA_ROTATE;
    mappaCelle[0][7].whichArea = 6;

    /******** DA RIMUOVERE IN ALGORTMO DEFINITIVO --- FINE ******/


    // Setto l'appartenenza delle celle agli esagoni grandi
    
    
    // Setto i centri degli esagoni grandi
    mappaAree[0].cella[0].x = 4;
    mappaAree[0].cella[0].y = 4;
    mappaAree[0].triangleUp = TRUE;
    
    mappaAree[1].cella[0].x = 4;
    mappaAree[1].cella[0].y = 7;
    mappaAree[1].triangleUp = FALSE;
    
    mappaAree[2].cella[0].x = 7;
    mappaAree[2].cella[0].y = 5;
    mappaAree[2].triangleUp = TRUE;
    
    mappaAree[3].cella[0].x = 7;
    mappaAree[3].cella[0].y = 2;
    mappaAree[3].triangleUp = FALSE;
    
    mappaAree[4].cella[0].x = 4;
    mappaAree[4].cella[0].y = 1;
    mappaAree[4].triangleUp = TRUE;
    
    mappaAree[5].cella[0].x = 1;
    mappaAree[5].cella[0].y = 2;
    mappaAree[5].triangleUp = FALSE;
    
    mappaAree[6].cella[0].x = 1;
    mappaAree[6].cella[0].y = 5;
    mappaAree[6].triangleUp = TRUE;
    
    
    // Ricavo le coordinate per ogni cella degli esagoni grandi e seet le varie proprietà
    
    cellCoord capp;
    
    for (i=0;i<7;i++)
    {
        for (j=0;j<7;j++)
        {
            if (j == 0)
            {
                // cella centrale
                mappaCelle[mappaAree[i].cella[j].x][mappaAree[i].cella[j].y].whichArea = i;
                
                // orientamento triangolo
                mappaCelle[mappaAree[i].cella[j].x][mappaAree[i].cella[j].y].triangleUp = !(i%2);
            }
            else
            {
                // tutte le altre celle
                capp = [self cercaCella: j: mappaAree[i].cella[0].x :mappaAree[i].cella[0].y];
                mappaAree[i].cella[j].x = capp.x;
                mappaAree[i].cella[j].y = capp.y;
                mappaCelle[capp.x][capp.y].whichArea = i;

                // orientamento triangolo
                mappaCelle[capp.x][capp.y].triangleUp = (j%2);
            }
            
        }    
    }
    
    // dati di partenza fittizi
    
    // coordinate computer

	posComputer.x = 4;
    posComputer.y = 7;
	mappaCelle[posComputer.x][posComputer.y].valueCell = CELLA_COMPUTER;

    
    // coordinate gemma

	//posGemma.x = 4;
    //posGemma.y = 4;

	posGemma.x = 3;
    posGemma.y = 1;

    posOggetti[0].pos.x = posGemma.x; 
    posOggetti[0].pos.y = posGemma.y; 

	mappaCelle[posGemma.x][posGemma.y].valueCell = CELLA_GEMMA;
    
    // coordinate giocatore

	posGiocatore.x = 4;
    posGiocatore.y = 1;
    mappaCelle[posGiocatore.x][posGiocatore.y].valueCell = CELLA_GIOCATORE;
    
    
    iNumOggetti = 1;
    
    if (posOggetti[0].pointerToPath != nil)
    {
        [posOggetti[0].pointerToPath removeAllObjects];
        posOggetti[0].pointerToPath = nil;
    }

    
    posOggetti[1].pos.x = 4; 
    posOggetti[1].pos.y = 4; 
    
	mappaCelle[4][4].valueCell = CELLA_EXTRA_MOSSA;

    iNumOggetti = 2;
    
}



////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// A* methods begin//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)spaceIsBlocked:(int)x :(int)y;
{
	//general-purpose method to return whether a space is blocked
	if((mappaCelle[x][y].valueCell == CELLA_MURO) ||
       (mappaCelle[x][y].valueCell == CELLA_ROTATE) ||
       (mappaCelle[x][y].valueCell == CELLA_GIOCATORE) ||
       (mappaCelle[x][y].valueCell == CELLA_COMPUTER)) 
		return YES;
	else
		return NO;
}

-(PathFindNode*)nodeInArray:(NSMutableArray*)a withX:(int)x Y:(int)y
{
	//Quickie method to find a given node in the array with a specific x,y value
	NSEnumerator *e = [a objectEnumerator];
	PathFindNode *n;
	if(e)
	{
		while(n = [e nextObject])
		{
			if((n->nodeX == x) && (n->nodeY == y))
			{
				return n;
			}
		}
	}
	return nil;
}
-(PathFindNode*)lowestCostNodeInArray:(NSMutableArray*)a
{
	//Finds the node in a given array which has the lowest cost
	PathFindNode *n, *lowest;
	lowest = nil;
	NSEnumerator *e = [a objectEnumerator];
	if(e)
	{
		while(n = [e nextObject])
		{
			if(lowest == nil)
			{
				lowest = n;
			}
			else
			{
				if(n->cost < lowest->cost)
				{
					lowest = n;
				}
			}
		}
		return lowest;
	}
	return nil;
}

-(NSMutableArray *)findPath:(int)startX :(int)startY :(int)endX :(int)endY
{
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
	int x,y;
	int newX,newY;
	int currentX,currentY;

	NSMutableArray *openList, *closedList;
 	
	if((startX == endX) && (startY == endY))
		return nil;
	
	openList = [NSMutableArray array];
	//BOOL animate = [shouldAnimateButton state];
    BOOL animate = FALSE;
    
    NSMutableArray *array = [[[NSMutableArray alloc] init] retain];
	
    if(animate)
		pointerToOpenList = openList;
	    
    closedList = [NSMutableArray array];
	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	PathFindNode *startNode = [PathFindNode node];
	startNode->nodeX = startX;
	startNode->nodeY = startY;
	startNode->parentNode = nil;
	startNode->cost = 0;
	[openList addObject: startNode];
    
	
	while([openList count])
	{
		currentNode = [self lowestCostNodeInArray: openList];
		
		if((currentNode->nodeX == endX) && (currentNode->nodeY == endY))
		{
			
            
			//********** PATH FOUND ********************	

            // la prima cella è quella di arrivo
            
            CoordCella *cella = [CoordCella node];
            
            cella->x = currentNode->nodeX;
            cella->y = currentNode->nodeY;
            
            [array addObject:cella];

			aNode = currentNode->parentNode;
            
			while(aNode->parentNode != nil)
			{
                NSLog(@"******  Percorso %d,%d ", aNode->nodeX, aNode->nodeY);

                CoordCella *cella = [CoordCella node];
                
                cella->x = aNode->nodeX;
                cella->y = aNode->nodeY;
                
                [array addObject:cella];
                
				aNode = aNode->parentNode;
			}
            
			return array;

		}
		else
		{
			[closedList addObject: currentNode];
			[openList removeObject: currentNode];
			currentX = currentNode->nodeX;
			currentY = currentNode->nodeY;
            
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++)
			{
				newY = currentY+y;
				for(x=-1;x<=1;x++)
				{
					newX = currentX+x;
					// salta la cella centrale
                    if(y || x) 
					{
                        // salta le celle laterali non confinanti (hex vs quadrato)
                        if(x==0 || (((currentX%2==0) && (y<1)) || ((currentX%2!=0) && (y>-1))) ) 
                        {
                            
                            //simple bounds check 
                            if((newX>=0)&&(newY>=0)&&(newX<GRID_LENGTH_X)&&(newY<GRID_LENGTH_Y))
                            {
                                if(![self nodeInArray: openList withX: newX Y:newY])
                                {
                                    if(![self nodeInArray: closedList withX: newX Y:newY])
                                    {
                                        if(![self spaceIsBlocked: newX :newY])
                                        {
                                            aNode = [PathFindNode node];
                                            aNode->nodeX = newX;
                                            aNode->nodeY = newY;
                                            aNode->parentNode = currentNode;
                                            aNode->cost = currentNode->cost + 1;
										
                                            //Compute your cost here. This demo app uses a simple manhattan
                                            //distance, added to the existing cost 
                                            aNode->cost += (abs((newX) - endX) + abs((newY) - endY));
                                        

                                            [openList addObject: aNode];
                                            if(animate)
                                                [self display];
                                        }
                                    }
                                }
                            }
                        }    
					}
				}
			}
		}		
	}
	
    //**** NO PATH FOUND *****
    return nil;
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// End A* code/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


// cerco tutti i percorsi che mi servono e scelgo l'obiettivo verso cui dirigermi

-(void)findBestTarget
{
    int i;
    int distanzaMinima;
    int deltaMosse;
    int distanzaGiocatore;
	NSMutableArray *pointerApp;
    
    iPercorsoScelto = 0;
    
    // calcolo i percorsi per tutti gli oggetti che potrei raggiungere
    for (i=0;i<iNumOggetti;i++)
    {
        if (posOggetti[i].pointerToPath != nil)
            [posOggetti[i].pointerToPath removeAllObjects];
        
        posOggetti[i].pointerToPath = [self findPath:posComputer.x :posComputer.y :posOggetti[i].pos.x :posOggetti[i].pos.y];
    }
    
    // se ho più di un oggetto sulla mappa, verifico la distanza del giocatore dalla gemma prima di scegliere
    if (iNumOggetti > 1)
    {
        // se la distanza "teorica" dalla gemma è minore del numero di mosse disponibili, vado alla gemma 
        
        if ([posOggetti[0].pointerToPath count] <= iMosseDisponibili[COMPUTER])
            iPercorsoScelto = 0;
        else
        {
            // calcolo la distanza tra il giocatore e la gemma
            pointerApp = [self findPath:posGiocatore.x :posGiocatore.y :posOggetti[0].pos.x :posOggetti[0].pos.y];

            NSLog(@"Distanza giocatore %d", [pointerApp count]);
            distanzaGiocatore = [pointerApp count];
            deltaMosse = [posOggetti[0].pointerToPath count]-iMosseDisponibili[COMPUTER];
            
            // se il giocatore è più vicino di me alla gemma, verifico la migliore strategia
            if (distanzaGiocatore >= deltaMosse)
            {

                // il tempo aggiuntivo non lo utilizzo, non serve mai... ;o)
                
                // verifico se ho degli oggetti da utilizzare per arrivare per primo alla gemma
                if (iMosseAggiuntive[COMPUTER]*MOSSE_AGGIUNTIVE >= (uint)deltaMosse)
                {
                    // posso utilizzare il bonus "mosse aggiuntive"
                    iPercorsoScelto = 0;
                    return;
                }

                // se il giocatore è più vicino di me alla gemma, cerco un altro obiettivo
                distanzaMinima = [posOggetti[0].pointerToPath count];
                for (i=0;i<iNumOggetti;i++)
                {
                    if ([posOggetti[i].pointerToPath count] < distanzaMinima)
                    {    
                        distanzaMinima = [posOggetti[i].pointerToPath count];
                        iPercorsoScelto = i;
                    }
                }       

            }
        }
        
    }
    else
    {
        // altrimenti il percorso scelto è quello verso la gemma

        iPercorsoScelto = 0;
    }
    

}                                       


// muovo "personaggio" e verifico se ha preso degli oggetti

-(void)muoviPersonaggio: (int)iPersonaggioDaMuovere: (int)x :(int)y;
{
    int appx, appy;
    int iContenutoCella;
    
    // verifico se la casella di destinazione contiene un oggetto (differente dall'obiettivo)
    
    iContenutoCella = mappaCelle[x][y].valueCell;
    
    switch (iContenutoCella)
    {
        case CELLA_GEMMA:
            break;
            
        case CELLA_BLOCCA_AVVERSARIO:
            iBloccoAvversario[iPersonaggioDaMuovere]++;
            break;

        case CELLA_EXTRA_MOSSA:
            iMosseAggiuntive[iPersonaggioDaMuovere]+=MOSSE_AGGIUNTIVE;
            break;

        case CELLA_EXTRA_TEMPO:
            iTempoAggiuntivo[iPersonaggioDaMuovere]+=TEMPO_AGGIUNTIVO;
            break;
            
        default:
            iContenutoCella = -1;
            break;
    }
    
    // muovo il personaggio e gli assegno l'eventuale oggetto preso 
    
    switch (iPersonaggioDaMuovere)
    {
        case COMPUTER:

            // pulisco la vecchia casella
            mappaCelle[posComputer.x][posComputer.y].valueCell = CELLA_VUOTA;
            
            // cambio posizione
            mappaCelle[x][y].valueCell = CELLA_COMPUTER;
            posComputer.x = x;
            posComputer.y = y;

            // decremento le mosse
            [self aggiornaNumeroMosse: COMPUTER :-1];
            
            break;
            
        case GIOCATORE:
            
            // pulisco la vecchia casella
            mappaCelle[posGiocatore.x][posGiocatore.y].valueCell = CELLA_VUOTA;
            
            // cambio posizione
            
            mappaCelle[x][y].valueCell = CELLA_GIOCATORE;
            posGiocatore.x = x;
            posGiocatore.y = y;

            // decremento le mosse
            [self aggiornaNumeroMosse: GIOCATORE :-1];
            
            break;
    
        default:
            return;
        
    }
    

    
    if (iContenutoCella != -1)
    {
        // se ho preso la gemma, la ricreo altrove
        if (iContenutoCella == CELLA_GEMMA)
        {
            [self generaCoordinareRandom:&appx :&appy];
            
            posGemma.x = appx;
            posGemma.y = appy;
            
            posOggetti[0].pos.x = posGemma.x; 
            posOggetti[0].pos.y = posGemma.y; 
            
            mappaCelle[posGemma.x][posGemma.y].valueCell = CELLA_GEMMA;

            // creo altri personaggi (random)
            
            [self aggiungiOggettiRandom];
                
        }
        else
        {
            // cerco l'oggetto che ho appena preso
            int i = 0;
            do
            {
                if ((posOggetti[i].pos.x == x) && ((posOggetti[i].pos.y == y)))
                {
                    // sposto l'ultimo oggetto al posto di quello appena eliminato
                    if (iNumOggetti > 1 && i!=(iNumOggetti-1))
                    {
                        [posOggetti[iNumOggetti].pointerToPath removeAllObjects];
                        posOggetti[iPercorsoScelto] = posOggetti[iNumOggetti];
                    }
                
                    i = iNumOggetti;
                    iNumOggetti--;
                }
                i++;
            } while (i<iNumOggetti);
            
        }
    }
    
    // aggiorna visualizzazione
	[self setNeedsDisplay: YES];
    
}



// verifico se la mossa è valida

-(BOOL)mossaValida: (int)dax: (int)day: (int)ax: (int)ay;
{
    // nel caso di mossa del giocatore dovrei controllare se le celle sono adiacenti (mdpp)
    
    return TRUE;    
}


// verifico se la mossa è valida

-(int)verificaMossa: (int)dax: (int)day: (int)ax: (int)ay;
{   
    
    // se devo passare ad un'area differente, devo verificarne l'orientamento
    if (mappaCelle[dax][day].whichArea != mappaCelle[ax][ay].whichArea)
    {
        // mi sto muovendo in verticale
        if (mappaAree[mappaCelle[dax][day].whichArea].cella[0].x == mappaAree[mappaCelle[ax][ay].whichArea].cella[0].x)
        {
            if (((!mappaAree[mappaCelle[dax][day].whichArea].triangleUp) && 
                 (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y > mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y)) || 
                ((mappaAree[mappaCelle[dax][day].whichArea].triangleUp) && 
                 (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y < mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y))) 
            {
                // l'area in cui mi trovo è orientata correttamente 
                
                if (((!mappaAree[mappaCelle[ax][ay].whichArea].triangleUp) && 
                     (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y > mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y)) || 
                    ((mappaAree[mappaCelle[dax][ay].whichArea].triangleUp) && 
                     (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y < mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y))) 
                    return RUOTA_PROX_AREA;
            }
            else
                return RUOTA_AREA;
        }
        else
        {
            if (((mappaAree[mappaCelle[dax][day].whichArea].triangleUp) && 
                 (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y > mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y)) || 
                ((!mappaAree[mappaCelle[dax][day].whichArea].triangleUp) && 
                 (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y < mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y))) 
            {
                // l'area in cui mi trovo è orientata correttamente 
                
                if (((mappaAree[mappaCelle[ax][ay].whichArea].triangleUp) && 
                     (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y > mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y)) || 
                    ((!mappaAree[mappaCelle[ax][ay].whichArea].triangleUp) && 
                     (mappaAree[mappaCelle[dax][day].whichArea].cella[0].y < mappaAree[mappaCelle[ax][ay].whichArea].cella[0].y))) 
                    return RUOTA_PROX_AREA;
            }
            else
                return RUOTA_AREA;
        }
                
    }
    
    
    // mi sto muovendo in verticale
    if (dax == ax) 
    {
        if (((ay == day+1) && mappaCelle[dax][day].triangleUp) || ((ay == day-1) && !mappaCelle[dax][day].triangleUp))
        {
            // la cella in cui mi trovo è orientata correttamente        
            if (((ay == day+1) && !mappaCelle[ax][ay].triangleUp) || ((ay == day-1) && mappaCelle[ax][ay].triangleUp))
                return MUOVI_PERSONAGGIO;
            else
                return RUOTA_PROX_STANZA;
        }
        else
            return RUOTA_STANZA;
    }
    
    // sono su una casella dispari
    if (dax%2)
    {
        if (((ay == day+1) && !mappaCelle[dax][day].triangleUp) || ((ay == day) && mappaCelle[dax][day].triangleUp))
        {
            // la cella in cui mi trovo è orientata correttamente        
            if (((ay == day+1) && mappaCelle[ax][ay].triangleUp) || ((ay == day) && !mappaCelle[ax][ay].triangleUp))
                return MUOVI_PERSONAGGIO;
            else
                return RUOTA_PROX_STANZA;
        }
        else
            return RUOTA_STANZA;
    }
    else
    {
        if (((ay == day) && !mappaCelle[dax][day].triangleUp) || ((ay == day-1) && mappaCelle[dax][day].triangleUp))
        {
            // la cella in cui mi trovo è orientata correttamente        
            if (((ay == day) && mappaCelle[ax][ay].triangleUp) || ((ay == day-1) && !mappaCelle[ax][ay].triangleUp))
                return MUOVI_PERSONAGGIO;
            else
                return RUOTA_PROX_STANZA;
        }
        else
            return RUOTA_STANZA;
    }        
    
    return NESSUNA_MOSSA;
}



// effettuo la prossima mossa per il "computer" (ruota o muovi)

-(void)muoviComputer
{
    int iMossa;
    CoordCella *cella;
    
    // determino la cella su cui muovermi
    // se la mia mossa precedente è stata una rotazione, cerco di tornare dove mi trovavo prima

    if (effettuataRotazioneArea && ![self spaceIsBlocked: prossimaMossa.x :prossimaMossa.y])
    {
        cella = [[CoordCella alloc] autorelease];
        
        cella->x = prossimaMossa.x;
        cella->y = prossimaMossa.y;
        
        effettuataRotazioneArea = FALSE;
    }
    else
        cella = [posOggetti[iPercorsoScelto].pointerToPath objectAtIndex: [posOggetti[iPercorsoScelto].pointerToPath count]-1];

    
    // verifico se posso andare alla cella x,y
    
    iMossa = [self verificaMossa: posComputer.x :posComputer.y :cella->x :cella->y];

    
    // se la prossima mossa è la rotazione di un'area e non ho almeno 2 mosse, prox mosse "disturba avversario"
    if ((iMosseDisponibili[COMPUTER] < 2) && ((iMossa == RUOTA_AREA) || (iMossa == RUOTA_PROX_AREA)))
        iMossa = DISTURBA_AVVERSARIO;
    
    // effettuo la mossa individuata
    switch (iMossa)
    {
        case MUOVI_PERSONAGGIO:
            NSLog(@"Posso muovere");
            [self muoviPersonaggio: COMPUTER :cella->x :cella->y];
            break;
            
        case RUOTA_STANZA:
            NSLog(@"Ruota cella");
            [self ruotaStanza:COMPUTER :posComputer.x :posComputer.y];
            break;

        case RUOTA_PROX_STANZA:
            NSLog(@"Ruota prox cella");
            [self ruotaStanza:COMPUTER :cella->x :cella->y];
            break;

        case RUOTA_AREA:
            NSLog(@"Ruota area");

            // la prossima mossa sarà tornare dove mi trovavo prima della rotazione
            
            prossimaMossa = posComputer;
            effettuataRotazioneArea = TRUE;

            [self ruotaArea:COMPUTER :mappaCelle[posComputer.x][posComputer.y].whichArea];

            break;
            
        case RUOTA_PROX_AREA:
            NSLog(@"Ruota prox area");
            [self ruotaArea:COMPUTER :mappaCelle[cella->x][cella->y].whichArea];
            break;
            
        case DISTURBA_AVVERSARIO:
            NSLog(@"Disturbo l'avversario");
            
            // per ora giro la casella dove si trova (mdpp sistemare)
            [self ruotaStanza:COMPUTER :posGiocatore.x :posGiocatore.y];
            
            break;
    
    }
}




-(void)mouseDown:(NSEvent*)e
{
	[self mouseDragged: e];
}

-(void)mouseDragged:(NSEvent*)e
{
	NSPoint p = [e locationInWindow];
	NSPoint clickSpot = [self convertPoint: p fromView: nil];
	int x, y;
    int cx, cy;
    
    // determino la cella clickata

    cx = clickSpot.x;
    cy = clickSpot.y;

    x = (int) (cx / BOX_DIMENSION);
	y = (int) ((cy-(BOX_DIMENSION/2*(x%2))) / BOX_DIMENSION); 
    

    NSLog(@"Clickato %d,%d", cx, cy);
    NSLog(@"Cella %d,%d", x, y);
    

    // ruoto la cella
    
    switch(mappaCelle[x][y].valueCell)
    {
        case CELLA_VUOTA:
        case CELLA_GEMMA:
        case CELLA_GIOCATORE:
        case CELLA_EXTRA_TEMPO:
        case CELLA_EXTRA_MOSSA:
        case CELLA_BLOCCA_AVVERSARIO:
            [self ruotaStanza:GIOCATORE :x :y];
            break;
            
        case CELLA_ROTATE:
            [self ruotaArea:GIOCATORE :mappaCelle[x][y].whichArea];
            break;
    }    

	[self setNeedsDisplay: YES];
    
}

-(void)drawGrid:(NSArray*)openList
{
	int x,y;
	NSRect r;
    
	//Demo App - disegno la griglia e gli oggetti contenuti
	
	for(x=0;x<GRID_LENGTH_X;x++)
	{
		for(y=0;y<GRID_LENGTH_Y;y++)
		{
            
			r = NSMakeRect(x*BOX_DIMENSION,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)),BOX_DIMENSION,BOX_DIMENSION);
			switch(mappaCelle[x][y].valueCell)
			{
				case CELLA_VUOTA:
					[[NSColor whiteColor] setFill];
					break;
				case CELLA_ROTATE:
				case CELLA_MURO:
                    [[NSColor lightGrayColor] setFill];
                    break;
				case CELLA_COMPUTER:
					[[NSColor greenColor] setFill];
					break;
				case CELLA_GEMMA:
					[[NSColor redColor] setFill];
					break;
				case CELLA_GIOCATORE:
					[[NSColor purpleColor] setFill];
					break;
				case CELLA_MARKER:
					[[NSColor blueColor] setFill];
                    break;
                case CELLA_EXTRA_TEMPO:
					[[NSColor magentaColor] setFill];
                    break;
                case CELLA_EXTRA_MOSSA:
					[[NSColor orangeColor] setFill];
                    break;
                case CELLA_BLOCCA_AVVERSARIO:
					[[NSColor cyanColor] setFill];
                    break;
                    
			}
            [NSBezierPath fillRect: r];
            
            // Bordi
            [[NSColor lightGrayColor] set];            
            [NSBezierPath strokeRect: r];

            
            // Scrivo coordinate per debug
/* 
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:8], NSFontAttributeName,[NSColor blackColor], NSForegroundColorAttributeName, nil];
            
            NSString *myString = [[NSString alloc] initWithFormat:@"%i,%i",x,y];
            NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:myString attributes: attributes];
            [currentText drawAtPoint:NSMakePoint(x*BOX_DIMENSION,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
*/
            
                        
			switch(mappaCelle[x][y].valueCell)
			{
				case CELLA_MARKER:
				case CELLA_VUOTA:
                case CELLA_GIOCATORE:
                case CELLA_GEMMA:
                case CELLA_COMPUTER:
                case CELLA_EXTRA_TEMPO:
                case CELLA_EXTRA_MOSSA:
                case CELLA_BLOCCA_AVVERSARIO:

                    [[NSColor lightGrayColor] set];            

                    if (mappaCelle[x][y].triangleUp == TRUE)
                    {
                        NSBezierPath* trianglePath = [NSBezierPath bezierPath];
            
                        // up
            
                        [trianglePath moveToPoint:NSMakePoint(x*BOX_DIMENSION,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        [trianglePath lineToPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION/2,y*BOX_DIMENSION+BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        [trianglePath moveToPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION/2,y*BOX_DIMENSION+BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        [trianglePath lineToPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
            
                        [trianglePath stroke];
            
                    }
                    else
                    {
                        NSBezierPath* trianglePath = [NSBezierPath bezierPath];
                
                        // down
                
                        [trianglePath moveToPoint:NSMakePoint(x*BOX_DIMENSION,y*BOX_DIMENSION+BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        [trianglePath lineToPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION/2,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        [trianglePath moveToPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION/2,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        [trianglePath lineToPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION,y*BOX_DIMENSION+BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                
                        [trianglePath stroke];
                
                    }
                break;
                    
                case CELLA_ROTATE:
                {
                    
                    // triangolo grande
                    if (mappaAree[mappaCelle[x][y].whichArea].triangleUp == TRUE)
                    {
                        // up
                        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:15], NSFontAttributeName,[NSColor blackColor], NSForegroundColorAttributeName, nil];

                        NSString *myString = [[NSString alloc] initWithFormat:@"^"];

                        NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:myString attributes: attributes];
                        [currentText drawAtPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION/1.5,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        
                        [myString release];
                        [currentText release];
                    }
                    else
                    {
                        // down
                        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:12], NSFontAttributeName,[NSColor blackColor], NSForegroundColorAttributeName, nil];

                        NSString *myString = [[NSString alloc] initWithFormat:@"v"];

                        NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:myString attributes: attributes];
                        [currentText drawAtPoint:NSMakePoint(x*BOX_DIMENSION+BOX_DIMENSION/1.5,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)))];
                        
                        [myString release];
                        [currentText release];
                    }
                }
                break;
                    
                    
            }
            
            
		}
	}
	
/*********************
 
	//for live updates, examine the openList and highlight
	if(openList)
	{
		[[NSColor colorWithDeviceRed:.7 green:1.0 blue:.7 alpha:1.0] set];
		int i;
		for(i=0;i<[openList count];i++)
		{
			PathFindNode *n = [openList objectAtIndex: i];
			x = n->nodeX;
			y = n->nodeY;
			r = NSMakeRect(x*BOX_DIMENSION,y*BOX_DIMENSION+(BOX_DIMENSION/2*(x%2)),BOX_DIMENSION,BOX_DIMENSION);
			NSRectFill(r);
    
		}
	}

**************************/ 
 
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[self drawGrid: pointerToOpenList];
}

-(BOOL)acceptsFirstResponder
{
	return YES;
}


// muovi Computer

-(IBAction)muoviComputer:(id)sender
{
    
    // muovo per tutte le mosse disponibili
    
    // while (iMosseDisponibili[COMPUTER] > 0)
    {
        NSLog(@"Mosse disponibili %d", iMosseDisponibili[COMPUTER]);

        [self runDemo: sender];
    
        [self muoviComputer];
    }
    
    if (iMosseDisponibili[COMPUTER] <= 0)
        iMosseDisponibili[COMPUTER] = NUMERO_MOSSE;

    
}

-(IBAction)quitDemo:(id)sender
{
	[NSApp terminate: nil];
}

-(IBAction)selectTool:(id)sender
{
	currentTool = [sender selectedTag];
}

-(void)resetGrid
{
    //[self initMap];
    
	// [self setNeedsDisplay: YES];

    NSLog(@"RESET!!!!!!!! ");
  
}

-(void)awakeFromNib
{
    
    [self initMap];
    
	[self setNeedsDisplay: YES];
    
    NSLog(@"** AWAKE ** ");
    

}
-(IBAction)clearMap:(id)sender
{
	//For demo app, clears the grid, redraws
	[self resetGrid];
    
    [self initMap];
    
	[self setNeedsDisplay: YES];
    
    NSLog(@"----- CLEAR ------- ");
    
}

-(IBAction)runDemo:(id)sender
{
	//verifico che le coordinate siano settate (mdpp forse non serve)
	if(
	   (posComputer.x<0) || (posComputer.y<0) || (posComputer.x>=GRID_LENGTH_X) || (posComputer.y >= GRID_LENGTH_Y) ||
	   (posGemma.x<0) || (posGemma.y<0) || (posGemma.x>=GRID_LENGTH_X) || (posGemma.y >= GRID_LENGTH_Y)
		)
	{
		return;
	}
		
	int x,y;
	for(x=0;x<GRID_LENGTH_X;x++)
	{
		for(y=0;y<GRID_LENGTH_Y;y++)
		{
			if(mappaCelle[x][y].valueCell == CELLA_MARKER)
				mappaCelle[x][y].valueCell = CELLA_VUOTA;
		}
	}
	
    [self findBestTarget];
    
    pointerToOpenList = nil;
	[self setNeedsDisplay: YES];
    
    NSLog(@"Trovato percorso");

}
@end
