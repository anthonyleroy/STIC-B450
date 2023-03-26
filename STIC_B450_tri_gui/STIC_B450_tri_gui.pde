//paramètres du vecteur
int nbElements=30; //nombre d'élément dans le vecteur
int minval=0; // valeur minimale
int maxval=256; // valeur maximale

// indices dans le vecteur
int posCourante=0; // position courante
int posMinimum=0; // position de l'élement minimum dans partie du vecteur encore à trier
int posTri=0; // position de la partie du vecteur encore à trier
int nbPermutations=0; //utilisé par le tri à bulles pour déterminer si le tri est terminé

//vecteurs original et à trier
int A [] = new int[nbElements]; //vecteur original (non trié)
int B [] = new int[nbElements]; //vecteur à trier (copie)

//métriques de performance
int startTime=0; //temps au début du tri
int stopTime=0; //temps lorsque le tri est terminé
int nbComparaisons=0; //comptabilise les comparaisons réalisées
int nbEchanges=0; //comptabilise les échanges d'éléments réalisés


// variables d'état
boolean start=false;
boolean init=false; // indique si setup() a été executé ou non
boolean animContinue=true; //animation continue ou pas à pas
boolean fini=false; //état terminé ou non du tri
boolean son=false; // diffuser du son ou non

// variable correspondant au sélectionneur de taille de vecteur
int nbElementsSelection=nbElements;

//constantes associées aux différents types de tri
final int TRI_PAR_SELECTION=0;
final int TRI_A_BULLES=1;
final int TRI_QUICKSORT=2;

String nomsTypeTri [] = {"Tri par selection", "Tri a bulles", "Tri rapide"};

// type de tri en cours
int typeTri=TRI_PAR_SELECTION;

// varaiables spécifiques au tri rapide
IntList pivots;

// index début et fin du sous-vecteur en cours
int ssVecStart = 0;
int ssVecEnd = 0;

class Pair
{
  private final int x;
  private final int y;

  Pair(int x, int y) {
    this.x = x;
    this.y = y;
  }

  public int getX() {
    return x;
  }
  public int getY() {
    return y;
  }
}


// crée une stack pour stocker l'index de début et de fin de subarray
import java.util.Arrays;
import java.util.Stack;
Stack<Pair> stack;


//bibliothèque et composants nécessaires pour produire du son
import processing.sound.*;
SinOsc sine;

//bibliothèque et composants nécessaires pour gérer l'interface utilisateur (boutons, liste déroulante...)
import controlP5.*;
ControlP5 cp5;
ListBox l;
Button pauseButton;

void setup() {
  //taille de la fenêtre
  size(1400, 800);

  // initialisation des composants UI
  cp5 = new ControlP5(this);

  // selectionneur du nombre d'élements dans le vecteur (par défaut nbElements)
  cp5.addSlider("nbElementsSelection")
    .setPosition(1000, 60)
    .setRange(20, 600)
    .setValue(nbElements)
    .setWidth(200)
    .setHeight(30)
    .setNumberOfTickMarks(580)
    ;

  //bouton destiné à créer un nouveau vecteur de la taille correspondante à nbElementsSelection
  cp5.addButton("nouveau")
    .setValue(0)
    .setPosition(1300, 20)
    .setSize(50, 19);

  //bouton destiné à réinitialiser tous les paramètres
  cp5.addButton("reinit")
    .setValue(0)
    .setPosition(1300, 45)
    .setSize(50, 19);

  //bouton de démarrage/pause du tri
  pauseButton= cp5.addButton("pause")
    .setValue(0)
    .setPosition(1300, 70)
    .setSize(50, 19);
  pauseButton.setCaptionLabel("start");

  // bouton pour activer ou désactiver le son
  cp5.addButton("sound")
    .setValue(0)
    .setPosition(1300, 95)
    .setSize(50, 19);

  // liste de sélection du type de tri
  l = cp5.addListBox("Type de tri")
    .setPosition(650, 60)
    .setSize(160, 160)
    .setItemHeight(30)
    .setBarHeight(30)
    //.setColorBackground(color(255, 128))
    .setColorActive(color(255, 165, 0))
    .setType(ListBox.DROPDOWN)
    .setOpen(false)
    .setValue(0)
    //.actAsPulldownMenu(true)
    //.setColorForeground(color(255, 100,0))
    ;

  // ajoute les différents types de tri disponibles à la liste
  for (int i=0; i < nomsTypeTri.length; i++) {
    l.addItem(nomsTypeTri[i], i);
  }

  // le premier type de tri est le type par défaut
  l.setDefaultValue(0);

  // initialise l'oscillateur pour produire du son
  sine = new SinOsc(this);

  //indique que le setup est terminé
  init=true;

  //simule le fait d'avoir pressé sur le bouton nouveau pour créer un nouveau vecteur prêt à être trié
  nouveau(0);
  l.setValue(0);
}

void draw() {
  fill(0);
  background(255);
  textSize(32);
  text("STIC-B450 - Algorithmes de tri", 10, 50);

  textSize(14);
  text("Type de tri", 560, 80);
  text("Taille de vecteur", 880, 80);

  visualize("Vecteur non trié", A, 10, 200, map(width/nbElements, width/30, 0, 30, 1), false);
  visualize("Vecteur trié par "+ nomsTypeTri[typeTri], B, 10, 400, map(width/nbElements, width/30, 0, 30, 1), true);

  if (start) {
    if (keyPressed||animContinue) {
      keyPressed=false;

      switch(typeTri) {
      case TRI_PAR_SELECTION:
        triParSelection();
        break;
      case TRI_A_BULLES:
        triBulles();
        break;
      case TRI_QUICKSORT:
        triRapide();
        break;
      default:
        triParSelection();
      }
    }
  }
}

public void pause(int valeur) {
  if (init) {
    if (start) {
      start=false;
      pauseButton.setCaptionLabel("start");
    } else {
      start=true;
      pauseButton.setCaptionLabel("pause");
      //relève le moment où on commence à trier
      startTime=millis();
    }

    // si bouton pressé (valeur=0) alors que pas à pas, relance l'animation continue
    if (valeur==0 && !animContinue) {
      animContinue=true;
      start=true;
      pauseButton.setCaptionLabel("pause");
    }
  }
}

public void sound(int valeur) {
  if (init) {
    if (son) {
      son=false;
      sine.stop();
    } else {
      son=true;
      sine.play();
    }
  }
}

void keyPressed() {
  pause(1);
  animContinue=false;
}

public void nouveau(int valeur) {
  if (init) {
    start=false; // arrête le tri en cours
    pauseButton.setCaptionLabel("start");

    nbElements=nbElementsSelection; //prend en compte le nombre d'éléments choisi dans le sélecteur
    this.A = new int[nbElements]; //vecteur original (non trié)
    this.B = new int[nbElements]; //vecteur à trier (copie)

    // création du vecteur à trier (nombres aléatoires entre minval et maxval)
    for (int i=0; i<nbElements; i++) {
      A[i]= (int) random (minval, maxval);
      //A[i]=i; //pire cas: le pivot est toujours l'élément maximal et partitionne en N-1 éléments d'un côté, 1 élément de l'autre
    }

    //copie le vecteur à trier A dans le vecteur unsorted
    arrayCopy(A, B);

    //type de tri sélectionné dans la liste
    typeTri=(int)l.getValue();

    //initialisation des curseurs
    posCourante=0;
    posMinimum=0;
    posTri = 0;

    //reinitialisation des métriques
    stopTime=0; //temps lorsque le tri est terminé
    nbComparaisons=0; //comptabilise les comparaisons réalisées
    nbEchanges=0; //comptabilise les échanges d'éléments réalisés

    //rétabli l'animation continue par défaut
    animContinue=true;


    fini=false;

    // si Tri rapide: pousse l'index de début et de fin du array dans la stack
    if (typeTri==TRI_QUICKSORT) {
      ssVecStart = 0;
      posCourante=0;
      ssVecEnd = nbElements - 1;
      stack = new Stack<>(); //vide la stack
      stack.push(new Pair(ssVecStart, ssVecEnd));
      pivots= new IntList();
    }
  }
}


public void reinit(int valeur) {
  if (init) {
    start=false;
    this.B = new int[nbElements]; //vecteur original (non trié)

    //copie le vecteur initial dans le vecteur à trier
    arrayCopy(A, B);

    //initialisation des curseurs
    posCourante=0;
    posMinimum=0;
    posTri = 0;

    //type de tri sélectionné dans la liste
    typeTri=(int)l.getValue();

    //reinitialisation des métriques

    stopTime=0; //temps lorsque le tri est terminé
    nbComparaisons=0; //comptabilise les comparaisons réalisées
    nbEchanges=0; //comptabilise les échanges d'éléments réalisés

    // si Tri rapide: pousse l'index de début et de fin du array dans la stack
    if (typeTri==TRI_QUICKSORT) {
      ssVecStart = 0;
      posCourante=0;
      ssVecEnd = nbElements - 1;
      stack = new Stack<>(); //crée nouvelle stack
      stack.push(new Pair(ssVecStart, ssVecEnd));
      pivots = new IntList(); // réinitialise la liste des pivots (pour affichage)
    }

    //réinitialise variable fini à false
    fini=false;

    //rétabli l'animation continue par défaut
    animContinue=true;
  }
}

//
// Tri par sélection
//
void triParSelection() {

  if (posTri==nbElements -1) { // tout le vecteur a été trié
    if (! fini) {
      stopTime=millis();
      fini=true;
      sine.stop();
    }
    text("Le vecteur a été trié en "+ str(stopTime-startTime)+ "ms !", 40, 650);
    text("Nombre de comparaisons réalisées: " + str(nbComparaisons), 40, 700);
    text("Nombre d'échanges réalisés: "+str(nbEchanges), 40, 730);
    return;
  }

  if (B[posMinimum]>B[posCourante]) {
    posMinimum = posCourante; // l'élement courant est l'élément le plus petit du vecteur
  }
  nbComparaisons++;

  if (posCourante == nbElements -1) { //on a parcouru tout le vecteur

    // on intervertit l'élément de taille minimum et l'élément qui se trouve à la bonne position
    int tmp = B[posMinimum];
    B[posMinimum] = B[posTri];
    B[posTri]=tmp;

    nbEchanges++; //on comptabilise un échange supplémentaire

    posTri=posTri +1; // déplacement du curseur correspondant à la partie déjà triée
    posCourante=posTri; // on replace le curseur en début de partie non triée
    posMinimum=posTri; // on replace le curseur min en début de partie non triée
  }
  if (son) {
    sine.freq(map(B[posCourante], 0, maxval, 80, 800)); //génère un son de fréquence proportionnelle à la valeur
  }

  posCourante++;

  if (!animContinue) {
    pause(1);  //envoie la valeur 1 pour distinguer d'une pression du bouton
  }
}

//
// Tri à bulles
//
void triBulles() {

  if (posCourante == nbElements -1) { //on a parcouru tout le vecteur

    if (nbPermutations==0) { // il n'y pas eu de permutation
      if (! fini) {
        stopTime=millis();
        fini=true;
        sine.stop();
      }

      text("Le vecteur a été trié en "+ str(stopTime-startTime)+ "ms !", 40, 650);
      text("Nombre de comparaisons réalisées: " + str(nbComparaisons), 40, 700);
      text("Nombre d'échanges réalisés: "+str(nbEchanges), 40, 730);
      return;
    }
    posCourante=0; // on replace le curseur en début de vecteur
    nbPermutations=0; // reinitialise le compteur de permutation
  } else {
    posCourante++;
    if (son) {
      sine.freq(map(B[posCourante], 0, maxval, 80, 800)); //génère un son de fréquence proportionnelle à la valeur
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

    if (!animContinue) {
      pause(1);  //envoie la valeur 1 pour distinguer d'une pression du bouton
    }
  }
}

int pivot=0;
int pIndex=0;
boolean triEnCours=false;

//
// tri quicksort
//
public void triRapide() {

  // en début de sous-vecteur à trier
  if (!triEnCours && !stack.empty()) {
    // supprimer la paire supérieure de la liste et faire démarrer le subarray
    // et indices de fin
    ssVecStart = stack.peek().getX();
    ssVecEnd = stack.peek().getY();
    stack.pop();

    // On prend l'élément le plus à droite comme pivot dans le array
    pivot = B[ssVecEnd];

    // les éléments inférieurs au pivot iront à gauche de `pIndex`
    // les éléments plus que le pivot iront à droite de `pIndex`
    // les éléments égaux peuvent aller dans les deux sens
    pIndex = ssVecStart;
    posCourante=ssVecStart;
    triEnCours=true;
  }

  // continue tant que le tri est en cours
  if (triEnCours)
  {

    println("vec start" + ssVecStart);
    println("vec end" + ssVecEnd);


    // à chaque fois qu'on trouve un élément inférieur ou égal au pivot,
    // `pIndex` est incrémenté, et cet élément est placé avant le pivot.
    if (posCourante <= ssVecEnd) {

      if (son) {
        //génère un son de fréquence proportionnelle à la valeur de l'élément en cours
        sine.freq(map(B[posCourante], 0, maxval, 80, 800));
      }

      if (B[posCourante] <= pivot)
      {
        int temp = B[posCourante];
        B[posCourante] = B[pIndex];
        B[pIndex] = temp;

        nbEchanges++;
        pIndex++;
      }
      nbComparaisons++;
      posCourante++;
    }

    // arrivé en fin de sous-vecteur à trier
    if (posCourante == ssVecEnd) {
      // échange `pIndex` avec pivot
      int temp = B[pIndex];
      B[pIndex] = B[ssVecEnd];
      B[ssVecEnd] = temp;

      nbEchanges++;

      // renvoie `pIndex` (index de l'élément pivot)
      pivot= pIndex;

      // pousse les indices de subarrayx contenant des éléments qui sont
      // moins que le pivot actuel pour stack
      if (pivot - 1 > ssVecStart) {
        stack.push(new Pair(ssVecStart, pivot - 1));
      }

      // pousse les indices de subarrayx contenant des éléments qui sont
      // plus que le pivot actuel pour stack
      if (pivot + 1 < ssVecEnd) {
        stack.push(new Pair(pivot + 1, ssVecEnd));
      }

      //rajoute le pivot à la liste des pivots utilisés (pour affichage)
      pivots.append(pivot);
      triEnCours=false;
    }
  } else {
    if (stack.empty()) {

      if (! fini) {
        stopTime=millis();
        fini=true;
        sine.stop();
      }
      text("Le vecteur a été trié en "+ str(stopTime-startTime)+ "ms !", 40, 650);
      text("Nombre de comparaisons réalisées: " + str(nbComparaisons), 40, 700);
      text("Nombre d'échanges réalisés: "+str(nbEchanges), 40, 730);
      text("Nombre de pivots utilisés: " + str(pivots.size()), 40, 760);
    }
  };

  if (!animContinue) {
    pause(1);  //envoie la valeur 1 pour distinguer d'une pression du bouton
  }
}

color valueToColor(int valeur) {
  // calcule une couleur intermédiaire entre bleu clair et bleu foncé en fonction de la valeur entière
  return lerpColor(color(135, 206, 250), color(0, 0, 139), float(valeur)/maxval);
}

// fonction d'affichage du vecteur sous forme graphique
void visualize(String caption, int[] values, float x, float y, float xstep, boolean showCursor) {
  fill(0);
  textSize(20);
  text(caption, x, y-5);
  textSize(16);
  for (int i=0; i < values.length; i++) {
    int v = values[i];
    if (i == posCourante && showCursor) {
      fill(color(255, 165, 0));
      noStroke();
      rect(x+(xstep*i), y+3, 8, 8); // affiche un curseur rectangulaire à la position courante
    } else if (i == posMinimum && showCursor) {
      fill(color(255, 0, 0));
      noStroke();
      triangle(x+(xstep*i)+5, y+10, x+(xstep*i), y+3, x+(xstep* i)+10, y+3); //affiche un curseur triangulaire valeur minimum
    }
    if (i == posTri && showCursor) {
      fill(color(25, 25, 112));
      noStroke();
      circle(x+(xstep*i)+4, y+8, 8); // affiche un curseur circulaire à l'emplacement du dernier élément trié
    }

    // met en évidence le sous-vecteur en cours de tri
    if (typeTri==TRI_QUICKSORT && showCursor && pivots != null && pivots.size()>0) {
      rectMode(CORNERS);
      fill(color(255, 0, 0));
      noStroke();
      // calcule la hauteur de l'élément pivot
      int hauteurPivot=(int)map(B[pivots.get(pivots.size()-1)], minval, maxval, 10, 80);
      // dessine une ligne de 2 pixels d'épaisseur à hauteur du pivot sur le sous-vecteur en cours
      rect(x+(xstep*ssVecStart)+5, y+hauteurPivot+30, x+(xstep*ssVecEnd)+5, y+hauteurPivot+32);
      rectMode(CORNER);

      if (pivots != null && pivots.hasValue(i)) {
        fill(color(255, 165, 0));
        noStroke();
        //rect(x+(xstep*i), y+3, 8, 8); // affiche un curseur rectangulaire à la position courante
        triangle(x+(xstep*i)+5, y+10, x+(xstep*i), y+3, x+(xstep* i)+10, y+3); //affiche un curseur triangulaire valeur pivot
      }
    }

    fill(0);
    if (nbElements<=30) {
      text(str(v), x+(xstep*i), y+25);
    }
    float h = map(v, minval, maxval, 10, 80); //dimensionne la hauteur de la barre en fonction de la valeur v
    fill(valueToColor(v)); //adapte la couleur en fonction de la valeur v

    // si tri quicksort, afficher le pivot en cours en orange
    if (typeTri==TRI_QUICKSORT && i==ssVecEnd && showCursor) {
      fill(color(255, 165, 0));
    }
    rect(x+(xstep*i), y+30, map(width/nbElements, width/30, 1, 10, 1), h);
  }
}
