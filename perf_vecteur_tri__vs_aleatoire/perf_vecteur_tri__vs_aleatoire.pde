final int nbElements = 32768;
int temps_aleatoire=0;
int temps_trie=0;
int start=0;
int somme=0;

void setup() {
  size(1400, 800);
  
  int aleatoire[] = new int [nbElements];
  int trie[] = new int [nbElements];
  
  for (int i=0; i < nbElements; i++) {
    aleatoire[i] = (int) random (0, 256);
    trie[i]= i;
  }

  start = millis();
  for (int i=0; i < 10000; i++) 
    for (int j=0; j < nbElements; j++) 
      if (trie[j] < 128) 
          somme += trie[j];
  
  temps_trie = millis() - start;
  
  somme=0;
  start = millis();
  
  for (int k=0; k < 10000; k++) 
    for (int l=0; l < nbElements; l++) 
      if (aleatoire[l] < 128) 
          somme += aleatoire[l];

  temps_aleatoire = millis() - start;
}

void draw() {
  background(255);
  fill (0);
  text("Temps vecteur non trié: "+ temps_aleatoire + " ms", 10 , 10);
  text("Temps vecteur trié "+ temps_trie + "ms", 10 , 30 );
  text("Somme= " + somme, 10 , 50 );
}
