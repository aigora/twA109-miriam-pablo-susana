class Punto {
  int x, y;
  Punto (int xpos, int ypos) {
    x=xpos;
    y=ypos;
  }
}

ArrayList<ArrayList<Punto>> objetos= new ArrayList<ArrayList<Punto>>(); //este array contiene a los objetos, que son todos los grupos de puntos
ArrayList<ArrayList<Punto>> obstaculos= new ArrayList<ArrayList<Punto>>(); //este array contiene a los obstaculos, que son los objetos en el camino del robot
Punto origen = new Punto(540, 360);//un punto colocado en el centro del mapa, mas adelante sera la posicion del robot
Punto mouse = new Punto(0, 0);

ArrayList<ArrayList<Punto>> rutas= new ArrayList<ArrayList<Punto>>(); //cada ruta es una serie de puntos que definen la ruta si se sigue de incio a fin

void setup() {
  size(1080, 720);
  stroke(0);
  textSize(15);
  textAlign(CENTER, CENTER);
  surface.setTitle("MovAut");
}


void draw() {
  obstaculos.clear();
  mouse.x=mouseX;
  mouse.y=mouseY;
  background(255);

  fill(0);
  text("Haga click para añadir puntos. Los puntos demasiado cercanos serán ignorados.\nLos puntos cercanos formarán grupos.\nPuede mover el punto de origen con wasd.", width*0.5, height*0.1);

  if(key=='p')
    getRutas(origen, mouse);
  
  fill(0, 0, 255);
  for (int i=0; i<rutas.size(); i++)
    line(origen, rutas.get(i).get(0));

  stroke(0, 255, 0);
  line(origen, mouse);

  stroke(0);
  for (int i=0; i<objetos.size(); i++) {  //dibuja todos los puntos
    for (int j=0; j<objetos.get(i).size(); j++) {
      drawPoint(objetos.get(i).get(j));
      fill(0);
      text(j, objetos.get(i).get(j).x, objetos.get(i).get(j).y+10);
    }
  }

  fill(0);
  text(obstaculos.size(), 50, 50);
  text(objetos.size(), 50, 100);

  text(anguloY(mouse, origen)*360.0/(2*PI), mouseX, mouseY);
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
      if (dist(objetos.get(i).get(j), nuevo)<10)
        demasiadoCerca=true;
  
  for (int i=0; i<objetos.size(); i++) {
  obstacles:
    for (int j=0; j<objetos.get(i).size(); j++) {
      if (dist(objetos.get(i).get(j), nuevo)<20 && !demasiadoCerca) {
        if (grupo==-1) {  //si es el primer grupo al que se une, simplemente se une
          objetos.get(i).add(nuevo);
          grupo=i;
        } else { //si ya se unió a otro grupo, une ambos grupos
          objetos.get(grupo).addAll(objetos.get(i));
          objetos.remove(i);
          i--;
        }
        perteneceGrupo = true;
        break obstacles;
      }
    }
  }
  if (!perteneceGrupo && !demasiadoCerca) { //aqui se crea el nuevo grupo
    objetos.add(new ArrayList<Punto>());
    objetos.get(objetos.size()-1).add(nuevo);
  }
}

void getObstaculos(Punto inicio, Punto fin) { //calcula que objetos se interponen en el segmento indicado, y los almacena en el array obstaculos
  obstaculos.clear();
  boolean cortado;
  float a1=anguloY(fin, inicio);
  int max, min;

  for (int i=0; i<objetos.size(); i++) {  //recorre todos los objetos, calcula en cada uno de ellos cual es el punto mas a la derecha y a la izquierda, y determina si esta en medio de la ruta
    max=angMax(a1, objetos.get(i));
    min=angMin(a1, objetos.get(i));
    //line(inicio, objetos.get(i).get(max));
    //line(inicio, objetos.get(i).get(min));
    if (angulo2(a1, anguloY(objetos.get(i).get(max), inicio))*angulo2(a1, anguloY(objetos.get(i).get(min), inicio))<0)
      obstaculos.add(objetos.get(i));
  }
  for (int i=0; i<obstaculos.size(); i++) {  //elimina los obstaculos que no cortan la recta, que nos son verdaderos obstaculos
    cortado=false;
    for (int j=0; j<obstaculos.get(i).size()-1 /*&& !cortado*/; j++)
      for (int k=j+1; k<obstaculos.get(i).size() /*&& !cortado*/; k++)
        if (/*dist(obstaculos.get(i).get(j), obstaculos.get(i).get(k))<25 &&*/ corte(inicio, fin, obstaculos.get(i).get(k), obstaculos.get(i).get(j))) {
          cortado=true;
          //line(obstaculos.get(i).get(j), obstaculos.get(i).get(k));
        }
    if (!cortado) {
      obstaculos.remove(i);
      i--;
    }
  }
}

void getRutas(Punto inicio, Punto fin) {
  println();
  rutas.clear();
  rutas.add(new ArrayList<Punto>());
  rutas.get(0).add(inicio);
  rutas.get(0).add(fin);

  for (int k=0; k<rutas.size();k++){
    segmentos:
    for (int i=0; i<rutas.get(k).size()-1; i++) {
      //print("i:",i,' ');
      float a1=anguloY(rutas.get(k).get(i+1), rutas.get(k).get(i));
      getObstaculos(rutas.get(k).get(i), rutas.get(k).get(i+1));
      if (obstaculos.size()>0) { //crea un clon de la ruta añadiendo un nuevo punto, y elimina el original
        for (int j=0; j<obstaculos.size(); j++) { 
          rutas.add(k+j*2+1,(ArrayList<Punto>)rutas.get(k).clone());
          rutas.add(k+j*2+2,(ArrayList<Punto>)rutas.get(k).clone());
          rutas.get(k+j*2+1).add(i+1, obstaculos.get(j).get(angMax(a1, obstaculos.get(j))));
          rutas.get(k+j*2+2).add(i+1, obstaculos.get(j).get(angMin(a1, obstaculos.get(j))));
        }
        rutas.remove(k);
        k--;
        break segmentos;
      }
    }
  }
  
  for (int i=0; i<rutas.size(); i++)  //este for imprime todas las rutas posible en azul
    for (int j=0; j<rutas.get(i).size()-1; j++) {
      stroke(0, 0, 255);
      line(rutas.get(i).get(j), rutas.get(i).get(j+1));
    }
  
  float distMin=0, distRuta;
  println();
  for (int j=0; j<rutas.get(0).size()-1; j++)
      distMin+=dist(rutas.get(0).get(j), rutas.get(0).get(j+1));
  println(distMin);
  
  while(1<rutas.size()){  //elimina rutas hasta que solo queda la mas corta
    distRuta=0;
    for (int j=0; j<rutas.get(1).size()-1; j++) {
      distRuta+=dist(rutas.get(1).get(j), rutas.get(1).get(j+1));
    }
    println(distRuta);
    if(distRuta<=distMin){
      rutas.remove(0);
      distMin=distRuta;
    }
    else
      rutas.remove(1);
  }
  
  for (int j=0; j<rutas.get(0).size()-1; j++) { //este for imprime la ruta mas corta
      stroke(255, 0, 0);
      line(rutas.get(0).get(j), rutas.get(0).get(j+1));
    }
}

void line(Punto p1, Punto p2) { //como la funcion line, pero toma puntos en vez de coordenadas
  line(p1.x, p1.y, p2.x, p2.y);
}

float dist(Punto a, Punto b) { //como la funcion dist, pero con puntos
  return sqrt((float)(pow((a.x-b.x), 2)+pow((a.y-b.y), 2)));
}

float anguloY(int x1, int y1, int x2, int y2) { //mide el angulo entre una recta y el eje de abcisas
  float angulo = -1;
  if (x1>x2)
    angulo = atan(float(y2-y1)/float(x2-x1))+PI/2;
  if (x2>x1)
    angulo = atan(float(y2-y1)/float(x2-x1))+3*PI/2;
  if (x1==x2 && y2<y1)
    angulo = PI;
  if (x1==x2 && y2>y1)
    angulo = 0;
  return angulo;
}

float anguloY(Punto p1, Punto p2) { //hace lo mismo que el otro anguloY, pero coje puntos en vez de coordenadas
  float angulo = -1;
  if (p1.x>p2.x)
    angulo = atan(float(p2.y-p1.y)/float(p2.x-p1.x))+PI/2;
  if (p2.x>p1.x)
    angulo = atan(float(p2.y-p1.y)/float(p2.x-p1.x))+3*PI/2;
  if (p1.x==p2.x && p2.y<p1.y)
    angulo = PI;
  if (p1.x==p2.x && p2.y>p1.y)
    angulo = 0;
  return angulo;
}

float angulo2(float a1, float a2) { //mide la diferencia entre dos angulos, con valores entre -pi y pi
  float angulo=0;
  angulo = a2-a1;
  if (angulo>PI)
    angulo = angulo - 2*PI;
  if (angulo<-PI)
    angulo = angulo + 2*PI;
  return angulo;
}

int angMax(float a1, ArrayList<Punto> objeto) { //devuelve el indice del punto con la diferencia angular mayor respecto a un agulo a1
  int max= 0;
  float angMax, ang;
  angMax=angulo2(a1, anguloY(objeto.get(max), origen));
  for (int i=0; i<objeto.size(); i++) {
    ang=angulo2(a1, anguloY(objeto.get(i), origen));
    if (ang>angMax) {
      max=i;
      angMax=angulo2(a1, anguloY(objeto.get(max), origen));
    }
  }
  return max;
}

int angMin(float a1, ArrayList<Punto> objeto) {  //devuelve el indice del punto con la diferencia angular menor respecto a un agulo a1
  int min= 0;
  float angMin, ang;
  angMin=angulo2(a1, anguloY(objeto.get(min), origen));
  for (int i=0; i<objeto.size(); i++) {
    ang=angulo2(a1, anguloY(objeto.get(i), origen));
    if (ang<angMin) {
      min=i;
      angMin=angulo2(a1, anguloY(objeto.get(min), origen));
    }
  }
  return min;
}


boolean corte(Punto a, Punto b, Punto c, Punto d) { //devuelve TRUE si dos segmentos se cortan, FALSE si no
  int x, y;

  //primero calcula la ecuacion de las rectas a partir de los puntos
  float m1=float(b.y-a.y)/float(b.x-a.x);
  float n1=float(a.y)-m1*float(a.x);
  float m2=float(d.y-c.y)/float(d.x-c.x);
  float n2=float(c.y)-m2*float(c.x);

  //si una de los segmentos es vertical, su pendiente es inservible, asi que calcula x de otra forma, y luego calcula la y usando la m de la otra recta
  if (b.x==a.x) {
    x=a.x;
    y = (int)(m2*float(x)+n2);
  } else {
    if (c.x==d.x)
      x=c.x;
    else 
    x = (int)((n1-n2)/(m2-m1));
    y = (int)(m1*float(x)+n1);
  }

  //aqui le decimos que si dos de los limites de los segmentos coinciden, no se cortan (es necesaria para que el pathfinder funcione)
  if ((a.x==c.x && a.y==c.y) || (a.x==d.x && a.y==d.y) || (b.x==c.x && b.y==c.y) || (b.x==d.x && b.y==d.y))
    return false;

  //los segmentos solo se cortan si el punto de corte esta contenido en ellas
  if (x>=min(a.x, b.x) && x<=max(a.x, b.x) && y>=min(a.y, b.y) && y<=max(a.y, b.y) &&
    x>=min(c.x, d.x) && x<=max(d.x, b.x) && y>=min(c.y, d.y) && y<=max(c.y, d.y))
    return true;
  else
    return false;
}

void mouseClicked() {
  addPoint(mouseX, mouseY); //añade puntos al hacer click;
}

void keyPressed() {
  if (key=='a')
    origen.x-=2;
  if (key=='d')
    origen.x+=2;
  if (key=='w')
    origen.y-=2;
  if (key=='s')
    origen.y+=2;
}
