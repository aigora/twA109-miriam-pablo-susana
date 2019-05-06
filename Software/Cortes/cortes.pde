class Punto {
  int x, y;
  Punto (int xpos, int ypos) {
    x=xpos;
    y=ypos;
  }
}

Punto a = new Punto(300, 300);
Punto b = new Punto(500, 100);
Punto c = new Punto(100, 75);
Punto d = new Punto(0, 0);

void setup() {
  size(1080, 720);
  stroke(0);
  textSize(15);
  surface.setTitle("MovAut");
}

Punto f;

void draw() {
  d.x=mouseX;
  d.y=mouseY;
  background(255);
  drawPoint(a);
  drawPoint(b);
  drawPoint(c);
  drawPoint(d);
  line(a, b);
  line(c, d);
  fill(0);
  text("A:", 40, 50);
  text(a.x, 60, 50);
  text(a.y, 100, 50);
  text("B:", 40, 80);
  text(b.x, 60, 80);
  text(b.y, 100, 80);
  text("C:", 40, 110);
  text(c.x, 60, 110);
  text(c.y, 100, 110);
  text("D:", 40, 140);
  text(d.x, 60, 140);
  text(d.y, 100, 140);
  corte(a,b,c,d);
}

void drawPoint(Punto p) {  //dibuja un punto de una forma mas visual que point()
  fill(255);
  circle(p.x, p.y, 6);
  circle(p.x, p.y, 2);
}

void line(Punto p1, Punto p2) { //como la funcion line, pero toma puntos en vez de coordenadas
  line(p1.x, p1.y, p2.x, p2.y);
}

void mouseClicked() {
  switch(key) {
  case 'a':
    a.x=mouseX;
    a.y=mouseY;
    break;
  case 'b':
    b.x=mouseX;
    b.y=mouseY;
    break;
  case 'c':
    c.x=mouseX;
    c.y=mouseY;
    break;
  case 'd':
    d.x=mouseX;
    d.y=mouseY;
    break;
  }
}

int corte(Punto a, Punto b, Punto c, Punto d) { //devuelve 1 si dos segmentos se cortan, 0 si no
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
  if((a.x==c.x && a.y==c.y) || (a.x==d.x && a.y==d.y) || (b.x==c.x && b.y==c.y) || (b.x==d.x && b.y==d.y))
    return 0;
  
  //los segmentos solo se cortan si el punto de corte esta contenido en ellas
  if (x>=min(a.x, b.x) && x<=max(a.x, b.x) && y>=min(a.y, b.y) && y<=max(a.y, b.y) &&
    x>=min(c.x, d.x) && x<=max(d.x, b.x) && y>=min(c.y, d.y) && y<=max(c.y, d.y)){
    
    //esta parte es solo para imprimir informacion en la demostracion, no es necesaria
    text("X:", 40, 170);
    text(x, 60, 170);
    text(y, 100, 170);
    fill(255);
    circle(x, y, 6);
    circle(x, y, 2);
  
    return 1;
  }
  else
    return 0;
}
