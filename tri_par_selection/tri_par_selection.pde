boolean animContinue=true; //animation continue ou pas à pas
boolean fini=false; //état terminé ou non du tri

int nbElements=30; //nombre d'élément dans le vecteur
int minval=0; // valeur minimale
int maxval=256; // valeur maximale
int posCourante=0; // position courante
int posMinimum=0; // position de l'élement minimum dans partie du vecteur encore à trier 
int posTri=0; // position de la partie du vecteur encore à trier

int A [] = new int[nbElements]; //vecteur original (non trié)
int B [] = new int[nbElements]; //vecteur à trier (copie)

int startTime=0; //temps au début du tri
int stopTime=0; //temps lorsque le tri est terminé
int nbComparaisons=0; //comptabilise les comparaisons réalisées
int nbEchanges=0; //comptabilise les échanges d'éléments réalisés

import processing.sound.*; //bibliothèque nécessaire pour produire du son
SinOsc sine;
    
void setup() {
  //taille de la fenêtre
  size(1400,600);

  // création du vecteur à trier (nombres aléatoires entre minval et maxval)
  for (int i=0; i<nbElements; i++) {
     A[i]= (int) random (minval, maxval);
  }
 
  //copie le vecteur à trier A dans le vecteur unsorted
  arrayCopy(A, B);
  
  //initialisation des curseurs
  posCourante=0;
  posMinimum=0;
  posTri = 0;
  
  // initialise l'oscillateur pour produire du son
  sine = new SinOsc(this);
  
  //relève le moment où on commence à trier
  startTime=millis();
  if (animContinue) {
    sine.play();
  }
  background(255);
  fill(0);
  textSize(32);
  text("STIC-B450 - Algorithme de tri par sélection",40,50);
  
  visualize("Vecteur non trié",A, 30,100, map(width/nbElements, width/30, 0, 30,2),false); 
  visualize("Vecteur trié par sélection",B, 30, 300, map(width/nbElements, width/30, 0, 30,2),true);
    
}

void draw() {
  if(keyPressed||animContinue) {
    keyPressed=false;
    background(255);
    fill(0);
    textSize(32);
    text("STIC-B450 - Algorithme de tri par sélection",40,50);
  
    visualize("Vecteur non trié",A, 30,100, map(width/nbElements, width/30, 0, 30,2),false); 
    visualize("Vecteur trié par sélection",B, 30, 300, map(width/nbElements, width/30, 0, 30,2),true);
    triParSelection();
  }
}

void triParSelection() { 
   
   if (posTri==nbElements -1){ // tout le vecteur a été trié
      if (! fini) { 
        stopTime=millis();
        fini=true;
      }
      sine.stop();
      text("Le vecteur a été trié en "+ str(stopTime-startTime)+ "ms !",40,450);
      text("Nombre de comparaisons réalisées: " + str(nbComparaisons),40,500);
      text("Nombre d'échanges réalisés: "+str(nbEchanges),40,530);
      return;
   }
  
  
  if (B[posMinimum]>B[posCourante]) {
      posMinimum = posCourante; // l'élement courant est l'élément le plus petit du vecteur
  }
  nbComparaisons++;
  
  if (posCourante == nbElements -1){ //on a parcouru tout le vecteur
    
    // on intervertit l'élément de taille minimum et l'élément qui se trouve à la bonne position 
    int tmp = B[posMinimum];
    B[posMinimum] = B[posTri];
    B[posTri]=tmp;
    
    nbEchanges++; //on comptabilise un échange supplémentaire
   
    posTri=posTri +1; // déplacement du curseur correspondant à la partie déjà triée
    posCourante=posTri; // on replace le curseur en début de partie non triée
    posMinimum=posTri; // on replace le curseur min en début de partie non triée
  }
  
  else   posCourante++;
  
  if (animContinue) {
      sine.freq(map(B[posCourante],0,maxval,80,800)); //génère un son de fréquence proportionnelle à la valeur
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
  for (int i=0; i < values.length; i++){
    int v = values[i];
    if (i == posCourante && showCursor){ 
        fill(color(255,165,0));
        noStroke();
        rect(x+(xstep*i), y+3, 8, 8); // affiche un curseur rectangulaire à la position courante
    } 
    else if(i == posMinimum && showCursor){ 
      fill(color(255,0,0));
      noStroke();
      triangle(x+(xstep*i)+5,y+10,x+(xstep*i),y+3,x+(xstep* i)+10,y+3); //affiche un curseur triangulaire valeur minimum
    }
    if(i == posTri && showCursor) {
      fill(color(25,25,112));
      noStroke();
      circle(x+(xstep*i)+4, y+8, 8); // affiche un curseur circulaire à l'emplacement du dernier élément trié
    }
    fill(0);
    if (nbElements<=30) {
      text(str(v), x+(xstep*i), y+25);
    }
    float h = map(v, minval, maxval, 10, 80); //dimensionne la hauteur de la barre en fonction de la valeur v
    fill(valueToColor(v)); //adapte la couleur en fonction de la valeur v
    rect(x+(xstep*i), y+30, map(width/nbElements,width/30,0,10,1), h);
  }
}
