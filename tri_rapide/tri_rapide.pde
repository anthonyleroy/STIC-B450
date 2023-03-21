boolean animContinue=true; //animation continue ou pas à pas

int nbElements=30; //nombre d'élément dans le vecteur
int minval=0; // valeur minimale
int maxval=256; // valeur maximale
int posCourante=0; // position courante
int posPivot=0; // position de l'élement max
int posTri=0; // position de la partie du vecteur encore à trier
int A [] = new int[nbElements]; //vecteur original (non trié)
int B [] = new int[nbElements]; //vecteur à trier (copie)
int startTime=0; //temps au début du tri
int stopTime=0; //temps lorsque le tri est terminé
boolean fini=false; //état terminé ou non du tri

int nbComparaisons=0; //comptabilise les comparaisons réalisées
int nbEchanges=0; //comptabilise les échanges d'éléments réalisés


IntList pivots;
    
 // récupère l'index de début et de fin du array donné
  int start = 0;
  int end = B.length - 1;
 
 
 // crée une stack pour stocker l'index de début et de fin de subarray
  Stack<Pair> stack = new Stack<>();
 
 
import processing.sound.*; //bibliothèque nécessaire pour produire du son
SinOsc sine;

import java.util.Arrays;
import java.util.Stack;

class Pair
{
    private final int x;
    private final int y;
 
    Pair(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
 
    public int getX() { return x; }
    public int getY() { return y; }
}

void setup() {
  //taille de la fenêtre
  size(1400,600);

  // création du vecteur à trier (nombres aléatoires entre minval et maxval)
  for (int i=0; i<nbElements; i++) {
     A[i]= (int) random (minval, maxval);
     //A[i]=i; //pire cas: le pivot est toujours l'élément maximal et partitionne en N-1 éléments d'un côté, 1 élément de l'autre 
  }
 
  //copie le vecteur à trier A dans le vecteur unsorted
  arrayCopy(A, B);
  
  //initialisation des curseurs
  posCourante=0;
  posTri = 0;
  
   // initialise l'oscillateur pour produire du son
  sine = new SinOsc(this);
  
  
  // pousse l'index de début et de fin du array dans la stack
  stack.push(new Pair(start, end));
  
  pivots= new IntList();
  
  //relève le moment où on commence à trier
  startTime=millis();
  sine.play();
}

public void swap (int[] arr, int i, int j)
    {
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
        nbEchanges++;
    }
    
public int partition(int a[], int start, int end)
    {
        // Choisissez l'élément le plus à droite comme pivot dans le array
        int pivot = a[end];
 
        // les éléments inférieurs au pivot iront à gauche de `pIndex`
        // les éléments plus que le pivot iront à droite de `pIndex`
        // les éléments égaux peuvent aller dans les deux sens
        int pIndex = start;
 
        // à chaque fois qu'on trouve un élément inférieur ou égal au pivot,
        // `pIndex` est incrémenté, et cet élément serait placé
        // avant le pivot.
        for (int i = start; i < end; i++)
        {
          
          if (animContinue) {
            sine.freq(map(a[i],0,maxval,80,800)); //génère un son de fréquence proportionnelle à la valeur
          }
            if (a[i] <= pivot)
            {
                swap(a, i, pIndex);
                pIndex++;
            }
            nbComparaisons++;
        }
 
        // échange `pIndex` avec pivot
        swap (a, pIndex, end);
 
        // renvoie `pIndex` (index de l'élément pivot)
        return pIndex;
    }
    
void draw() {
    if(keyPressed||animContinue) {
    keyPressed=false;
    textSize(32);
    background(255);
    text("STIC-B450 - Algorithme de tri rapide (quicksort)",40,50);
  
    visualize("Vecteur non trié",A,30,100, map(width/nbElements, width/30,0, 30,1),false); 
    
        // boucle jusqu'à ce que la stack soit vide
        if (!stack.empty())
        {
            // supprimer la paire supérieure de la liste et faire démarrer le subarray
            // et indices de fin
            start = stack.peek().getX();
            end = stack.peek().getY();
            stack.pop();
 
            // réarrange les éléments sur le pivot
            int pivot = partition(B, start, end);
 
            // pousse les indices de subarrayx contenant des éléments qui sont
            // moins que le pivot actuel pour stack
            if (pivot - 1 > start) {
                stack.push(new Pair(start, pivot - 1));
            }
 
            // pousse les indices de subarrayx contenant des éléments qui sont
            // plus que le pivot actuel pour stack
            if (pivot + 1 < end) {
                stack.push(new Pair(pivot + 1, end));
            }
            pivots.append(pivot);

        }
        else {
         if (! fini) {
            stopTime=millis();
            fini=true;
            sine.stop();
          }
          if (animContinue){
            text("Le vecteur a été trié en "+ str(stopTime-startTime)+ "ms !",40,450);
            text("Nombre de comparaisons réalisées: " + str(nbComparaisons),40,500);
            text("Nombre d'échanges réalisés: "+str(nbEchanges),40,530);
          }
        };
        visualize("Vecteur trié par tri rapide (quicksort)",B,30,300, map(width/nbElements, width/30,0, 30,1),true);
    }
}


color valueToColor(int valeur) {
  // calcule une couleur intermédiaire entre bleu clair et bleu foncé en fonction de la valeur entière  
  return lerpColor(color(135,206,250), color(0,0,139), float(valeur)/maxval);
}

// fonction d'affichage du vecteur sous forme graphique
void visualize(String caption,int[] values,float x,float y,float xstep,boolean showCursor) {
  fill(0);
  textSize(20);
  text(caption, x, y-5);
  textSize(16);
  
  if (showCursor) {
    rectMode(CORNERS);
    fill(color(255,165,0));
    noStroke();
    rect(x+(xstep*start)+5, y+10, x+(xstep*end)+5, y+12);
    rectMode(CORNER);
  }  
  for (int i=0; i < values.length; i++){
    int v = values[i];
    //pulse.play(100+float(v)/maxval*1000, 1.0); //génère un son de fréquence proportionnelle à la valeur

    if (pivots.hasValue(i) && showCursor){ 
        fill(color(255,165,0));
        noStroke();
        //rect(x+(xstep*i), y+3, 8, 8); // affiche un curseur rectangulaire à la position courante
        triangle(x+(xstep*i)+5,y+10,x+(xstep*i),y+3,x+(xstep* i)+10,y+3); //affiche un curseur triangulaire valeur pivot
    } 
    
    //else if(i == posMinimum && showCursor){ 
    //  fill(color(255,0,0));
    //  noStroke();
    //  triangle(x+(xstep*i)+5,y+10,x+(xstep*i),y+3,x+(xstep* i)+10,y+3); //affiche un curseur triangulaire valeur minimum
    //}
    //if(i == posTri && showCursor) {
    //  fill(color(25,25,112));
    //  noStroke();
    //  circle(x+(xstep*i)+4, y+8, 8); // affiche un curseur circulaire à l'emplacement du dernier élément trié
    //}
    fill(0);
    if (nbElements<100) {
      text(str(v), x+(xstep*i), y+25);
    }
    float h = map(v, minval, maxval, 10, 80); //dimensionne la hauteur de la barre en fonction de la valeur v
    fill(valueToColor(v)); //adapte la couleur en fonction de la valeur v
    rect(x+(xstep*i), y+30, map(width/nbElements,width/30,0,10,1), h);
  }
}
