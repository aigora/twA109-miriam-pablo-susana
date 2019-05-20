class Punto {
  int x, y;
  Punto (int xpos, int ypos) {
    x=xpos;
    y=ypos;
  }
}
int disSeg=20;  //distancia que seria el diametro del robot si este fuera un circulo mas el error asociado a disMin
int disMin=5;  //distancia minima de distancia entre puntos

ArrayList<ArrayList<Punto>> objetos= new ArrayList<ArrayList<Punto>>(); //este array contiene a los objetos, que son todos los grupos de puntos
ArrayList<ArrayList<Punto>> sombras= new ArrayList<ArrayList<Punto>>(); //este array contiene a las sombras, puntos que forman un perimetro en torno a los objetos
ArrayList<ArrayList<Punto>> obstaculos= new ArrayList<ArrayList<Punto>>(); //este array contiene a los obstaculos, que son los objetos en el camino del robot
Punto robotPos = new Punto(0, 0); //la posicion del robot
float robotAng = 0; //la direccion en la que apunta el robot
Punto destino = new Punto(robotPos.x, robotPos.y);  //el punto al que queremos que vaya el robot

ArrayList<ArrayList<Punto>> rutas= new ArrayList<ArrayList<Punto>>(); //cada ruta es una serie de puntos que definen la ruta si se sigue de incio a fin

void pathFinder() {
  textSize(15);
  textAlign(CENTER, CENTER);
  obstaculos.clear();
  background(255);
  
  stroke(0);
  for (int i=0; i<objetos.size(); i++) //dibuja todos los puntos
    for (int j=0; j<objetos.get(i).size(); j++)
      drawPoint(objetos.get(i).get(j));
      
  stroke(0, 255, 0);
  drawPoint(robotPos);
  stroke(255, 0, 0);
  drawPoint(destino);
  stroke(200);
  line(robotPos, destino);
      
  getRutas(robotPos, destino);
}

void drawPoint(Punto p) {  //dibuja un punto de una forma mas visual que point()
  fill(255);
  circle(p.x, p.y, 6);
  circle(p.x, p.y, 2);
}

void addPoint(int x, int y) { //añade un punto al grupo que este suficientemente cerca, en caso de que no lo haya crea uno para el nuevo punto
  boolean perteneceGrupo = false;
  boolean demasiadoCerca = false;
  Punto nuevo = new Punto(x, y);
  int grupo=-1;
  for (int i=0; i<objetos.size(); i++) //este for comprueba que el punto no esta demasiado cerca a ningun otro grupo
    for (int j=0; j<objetos.get(i).size(); j++)
      if (dist(objetos.get(i).get(j), nuevo)<disMin)
        demasiadoCerca=true;

  for (int i=0; i<objetos.size(); i++) {
  obstacles:
    for (int j=0; j<objetos.get(i).size(); j++) {
      if (dist(objetos.get(i).get(j), nuevo)<disSeg && !demasiadoCerca) {
        if (grupo==-1) {  //si es el primer grupo al que se une, simplemente se une
          crearSombra(nuevo, i);
          objetos.get(i).add(nuevo);
          grupo=i;
        } else { //si ya se unió a otro grupo, une ambos grupos
          sombras.get(grupo).addAll(sombras.get(i));
          objetos.get(grupo).addAll(objetos.get(i));
          sombras.remove(i);
          objetos.remove(i);
          i--;
        }
        perteneceGrupo = true;
        break obstacles;
      }
    }
  }
  if (!perteneceGrupo && !demasiadoCerca) { //aqui se crea el nuevo grupo
    sombras.add(new ArrayList<Punto>());
    objetos.add(new ArrayList<Punto>());
    crearSombra(nuevo, objetos.size()-1);
    objetos.get(objetos.size()-1).add(nuevo);
  }
}

void crearSombra(Punto p, int grupo) {  //crea un poligono de puntos en torno al punto
  Punto n;

  float radio= (float)disSeg/(cos(PI/3)*2);
  for (int i=1; i<=6; i++) {
    n = new Punto(p.x+int(radio*sin(PI*i/3)), p.y+int(radio*cos(PI*i/3)));
    sombras.get(grupo).add(n);
  }
}

void getObstaculos(Punto inicio, Punto fin) { //calcula que objetos se interponen en el segmento indicado, y los almacena en el array obstaculos
  obstaculos.clear();
  boolean cortado;
  float a1=anguloY(fin, inicio);
  int max, min;

  for (int i=0; i<sombras.size(); i++) {  //recorre todos los objetos, calcula en cada uno de ellos cual es el punto mas a la derecha y a la izquierda, y determina si esta en medio de la ruta
    max=angMax(a1, sombras.get(i));
    min=angMin(a1, sombras.get(i));
    stroke(0);
    //line(inicio, objetos.get(i).get(max));
    //line(inicio, objetos.get(i).get(min));
    if (angulo2(a1, anguloY(sombras.get(i).get(max), inicio))*angulo2(a1, anguloY(sombras.get(i).get(min), inicio))<0 ) {
      obstaculos.add(sombras.get(i));
    }
  }
  for (int i=0; i<obstaculos.size(); i++) {  //elimina los obstaculos que no cortan la recta, que nos son verdaderos obstaculos
    cortado=false;
    for (int j=0; j<obstaculos.get(i).size()-1 && !cortado; j++)
      for (int k=j+1; k<obstaculos.get(i).size() && !cortado; k++)
        if (dist(obstaculos.get(i).get(j), obstaculos.get(i).get(k))<disSeg*1.5 && corte(inicio, fin, obstaculos.get(i).get(k), obstaculos.get(i).get(j))) {
          cortado=true;
        }
    if (!cortado) {
      obstaculos.remove(i);
      i--;
    }
  }
}

void getRutas(Punto inicio, Punto fin) {
  rutas.clear();
  rutas.add(new ArrayList<Punto>());
  rutas.get(0).add(inicio);
  rutas.get(0).add(fin);

  for (int k=0; k<rutas.size(); k++) {
  segmentos:
    for (int i=0; i<rutas.get(k).size()-1 && i<10; i++) {
      float a1=anguloY(rutas.get(k).get(i+1), rutas.get(k).get(i));
      getObstaculos(rutas.get(k).get(i), rutas.get(k).get(i+1));
      if (obstaculos.size()>0) { //crea un clon de la ruta añadiendo un nuevo punto, y elimina el original
        for (int j=0; j<obstaculos.size(); j++) {
          rutas.add(k+1, (ArrayList<Punto>)rutas.get(k).clone());
          rutas.add(k+2, (ArrayList<Punto>)rutas.get(k).clone());
          rutas.get(k+1).add(i+1, obstaculos.get(j).get(angMax(a1, obstaculos.get(j))));
          rutas.get(k+2).add(i+1, obstaculos.get(j).get(angMin(a1, obstaculos.get(j))));
        }
        rutas.remove(k);
        k--;
        break segmentos;
      }
    }
  }

  /*for (int i=0; i<rutas.size(); i++)  //este for imprime todas las rutas posible en azul
   for (int j=0; j<rutas.get(i).size()-1; j++)
   stroke(0, 0, 255,50);
   line(rutas.get(i).get(j), rutas.get(i).get(j+1));*/

  float distMin=0, distRuta;

  for (int j=0; j<rutas.get(0).size()-1; j++)
    distMin+=dist(rutas.get(0).get(j), rutas.get(0).get(j+1));

  while (1<rutas.size()) {  //elimina rutas hasta que solo queda la mas corta
    distRuta=0;
    for (int j=0; j<rutas.get(1).size()-1; j++)
      distRuta+=dist(rutas.get(1).get(j), rutas.get(1).get(j+1));

    if (distRuta<=distMin) {
      rutas.remove(0);
      distMin=distRuta;
    } else
      rutas.remove(1);
  }

  for (int j=0; j<rutas.get(0).size()-1; j++) { //este for imprime la ruta mas corta
    stroke(255, 0, 0);
    line(rutas.get(0).get(j), rutas.get(0).get(j+1));
  }
}
