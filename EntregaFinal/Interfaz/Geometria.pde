void line(Punto p1, Punto p2) { //como la funcion line, pero toma puntos en vez de coordenadas
  line(p1.x, p1.y, p2.x, p2.y);
}

float dist(Punto a, Punto b) { //como la funcion dist, pero con puntos
  return sqrt((float)(pow((a.x-b.x), 2)+pow((a.y-b.y), 2)));
}

float anguloY(int x1, int y1, int x2, int y2) { //mide el angulo entre una recta y el eje de abcisas
  float angulo = 0;
  if (x1>x2)
    angulo = atan(float(y2-y1)/float(x2-x1))+PI/2;
  if (x2>x1)
    angulo = atan(float(y2-y1)/float(x2-x1))+3*PI/2;
  if (x1==x2 && y2<y1)
    angulo = PI;
  if (x1==x2 && y2>=y1)
    angulo = 0;
  return angulo;
}

float anguloY(Punto p1, Punto p2) { //hace lo mismo que el otro anguloY, pero coje puntos en vez de coordenadas
  float angulo = 0;
  if (p1.x>p2.x)
    angulo = atan(float(p2.y-p1.y)/float(p2.x-p1.x))+PI/2;
  if (p2.x>p1.x)
    angulo = atan(float(p2.y-p1.y)/float(p2.x-p1.x))+3*PI/2;
  if (p1.x==p2.x && p2.y<p1.y)
    angulo = PI;
  if (p1.x==p2.x && p2.y>=p1.y)
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
  angMax=angulo2(a1, anguloY(objeto.get(max), robotPos));
  for (int i=0; i<objeto.size(); i++) {
    ang=angulo2(a1, anguloY(objeto.get(i), robotPos));
    if (ang>angMax) {
      max=i;
      angMax=angulo2(a1, anguloY(objeto.get(max), robotPos));
    }
  }
  return max;
}

int angMin(float a1, ArrayList<Punto> objeto) {  //devuelve el indice del punto con la diferencia angular menor respecto a un agulo a1
  int min= 0;
  float angMin, ang;
  angMin=angulo2(a1, anguloY(objeto.get(min), robotPos));
  for (int i=0; i<objeto.size(); i++) {
    ang=angulo2(a1, anguloY(objeto.get(i), robotPos));
    if (ang<angMin) {
      min=i;
      angMin=angulo2(a1, anguloY(objeto.get(min), robotPos));
    }
  }
  return min;
}



boolean corte(Punto a, Punto b, Punto c, Punto d) { //devuelve TRUE si dos segmentos se cortan, FALSE si no
  float x, y;

  //primero calcula la ecuacion de las rectas a partir de los puntos
  float m1=float(b.y-a.y)/float(b.x-a.x);
  float n1=float(a.y)-m1*float(a.x);
  float m2=float(d.y-c.y)/float(d.x-c.x);
  float n2=float(c.y)-m2*float(c.x);

  //si una de los segmentos es vertical, su pendiente es inservible, asi que calcula x de otra forma, y luego calcula la y usando la m de la otra recta
  if (b.x==a.x) {
    x=a.x;
    y = m2*x+n2;
  } else {
    if (c.x==d.x)
      x=c.x;
    else 
    x = (n1-n2)/(m2-m1);
    y = m1*x+n1;
  }

  //aqui le decimos que si dos de los limites de los segmentos coinciden, no se cortan (es necesaria para que el pathfinder funcione)
  if ((a.x==c.x && a.y==c.y) || (a.x==d.x && a.y==d.y) || (b.x==c.x && b.y==c.y) || (b.x==d.x && b.y==d.y))
    return false;

  //los segmentos solo se cortan si el punto de corte esta contenido en ellas
  if (x>=min(a.x, b.x) && x<=max(a.x, b.x) && y>=min(a.y, b.y) && y<=max(a.y, b.y) &&
    x>=min(c.x, d.x) && x<=max(c.x, d.x) && y>=min(c.y, d.y) && y<=max(c.y, d.y))
    return true;
  else
    return false;
}

int[] cambioCartesianas(float ang, float dis) { //convierte polares a cartesianas
  int coord[] = new int[2];
  coord[0]=int(dis*sin(ang)); //esto es la x
  coord[1]=-int(dis*cos(ang)); //esto es la y

  return coord;
}

float[] cambioPolares(int x, int y) { //convierte cartesianas a polares
  float coord[] = new float[2];

  if (x>0)
    coord[0] = atan(float(y)/float(x))+PI/2;
  if (x<0)
    coord[0] = atan(float(y)/float(x))+3*PI/2;
  if (x==0 && 0<y)
    coord[0] = PI;
  if (x==0 && 0>=y)
    coord[0] = 0;

  coord[1]=sqrt((float)(pow(x, 2)+pow(y, 2)));

  return coord;
}
