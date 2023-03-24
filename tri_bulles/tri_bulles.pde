boolean animContinue=false; //animation continue ou pas à pas
boolean fini=false; //état terminé ou non du tri

int nbElements=30; //nombre d'élément dans le vecteur
int minval=0; // valeur minimale
int maxval=256; // valeur maximale
int posCourante=0; // position courante
int nbPermutations=0; //nb permetutation réalisée dans la passe courante

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
  
  // initialise l'oscillateur pour produire du son
  sine = new SinOsc(this);
  
  //relève le moment où on commence à trier
  startTime=millis();

  if (animContinue) {
    sine.play();
  }
  
  background(255);
  textSize(32);
  fill(0);
  text("STIC-B450 - Algorithme de tri à bulles",40,50);
  
  visualize("Vecteur non trié",A, 30,100, map(width/nbElements, width/30, 0, 30,2),false); 
  visualize("Vecteur trié par tri à bulles",B, 30, 300, map(width/nbElements, width/30, 0, 30,2),true);

}

void draw() {
   
  if(keyPressed||animContinue) {
    keyPressed=false;
    background(255);
    textSize(32);
    text("STIC-B450 - Algorithme de tri à bulles",40,50);
  
    visualize("Vecteur non trié",A, 30,100, map(width/nbElements, width/30, 0, 30,2),false); 
    visualize("Vecteur trié par tri à bulles",B, 30, 300, map(width/nbElements, width/30, 0, 30,2),true);

    triBulle();
  }
}

void triBulle() { 

  if (posCourante == nbElements -1){ //on a parcouru tout le vecteur  
  
      if (nbPermutations==0){ // il n'y pas eu de permutation
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
      posCourante=0; // on replace le curseur en début de vecteur 
      nbPermutations=0; // reinitialise le compteur de permutation
  }
  else {
      posCourante++;
      if (animContinue) {
            sine.freq(map(B[posCourante],0,maxval,80,800)); //génère un son de fréquence proportionnelle à la valeur
      }
      if (B[posCourante-1]>B[posCourante]) { // l'élement précédent est l'élément le plus petit du vecteur
        
        // on intervertit les éléments  
        int tmp = B[posCourante-1];
        B[posCourante-1] = B[posCourante];
        B[posCourante]=tmp;
        
        nbEchanges++;
        nbPermutations++;
      }
      nbComparaisons++;
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
    if (animContinue) {
      sine.freq(100+float(v)/maxval*1000); //génère un son de fréquence proportionnelle à la valeur
    }
    if (i == posCourante && showCursor){ 
        fill(color(255,165,0));
        noStroke();
        rect(x+(xstep*i), y+3, 8, 8); // affiche un curseur rectangulaire à la position courante
    } 
    else if(i == posCourante-1 && showCursor){ 
      fill(color(255,0,0));
      noStroke();
      triangle(x+(xstep*i)+5,y+10,x+(xstep*i),y+3,x+(xstep* i)+10,y+3); //affiche un curseur triangulaire élément précédent à comparer
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
