import g4p_controls.*;
import processing.serial.*;

char[] tKey = {0, 0}; //tKey es una version mejorada de key. Puede guardar dos teclas y las borra cuando se deja de apretar
int pantalla = 0; //se usa para cambiar entre las distintas pantllas
int puerto = -1;

PImage teclaW1;
PImage teclaW2;
PImage teclaA1;
PImage teclaA2;
PImage teclaS1;
PImage teclaS2;
PImage teclaD1;
PImage teclaD2;
PFont fontNormal, fontBold;

Serial btserial;

GTextField xText; 
GTextField yText;

int salto=5, mini=5; //estas dos variables dan información sobre el angulo de escaneo, y debe ser als mismas que en arduino

void setup() {
  G4P.messagesEnabled(false);
  xText = new GTextField(this, width*0.056, height*0.29, width*0.1, height*0.04); 
  yText = new GTextField(this, width*0.196, height*0.29, width*0.1, height*0.04);
  xText.setVisible(false);
  yText.setVisible(false);

  size(1280, 720);
  stroke(0);
  textAlign(CENTER, CENTER);
  surface.setTitle("MovAut");
  fill(0);
  fontNormal = createFont("Arial", width*0.016);
  fontBold   = createFont("Arial Bold", width*0.016);
  textFont(fontNormal);

  imageMode(CENTER);
  teclaW1=loadImage("W1.png");
  teclaA1=loadImage("A1.png");
  teclaS1=loadImage("S1.png");
  teclaD1=loadImage("D1.png");

  printArray(Serial.list());
  if (puerto!=-1)
    btserial=new Serial(this, Serial.list()[puerto], 9600);
}

int suma;

void draw() {

  switch(pantalla) { //este switch decide que pantalla se mostrará
  case 0:   //modo manual

    if (puerto!=-1) {
      suma=tKey[0]+tKey[1];
      switch(suma) {
      case 'w':
        btserial.write('w');
        break;
      case 'a':
        btserial.write('a');
        break;
      case 's':
        btserial.write('s');
        break;
      case 'd':
        btserial.write('d');
        break;
      case 216:
        btserial.write('q');
        break;
      case 219:
        btserial.write('e');
        break;
      case 212:
        btserial.write('z');
        break;
      case 215:
        btserial.write('c');
        break;
      case 112:
        btserial.write('p');
        break;
      default:
        btserial.write(0);
        break;
      }
    }
    background(240);

    if (tKey[0]=='w' || tKey[1]=='w')
      tint(50);
    image(teclaW1, width*0.5, height*0.29, width*0.1, height*0.17);
    noTint();

    if (tKey[0]=='a' || tKey[1]=='a')
      tint(50);
    image(teclaA1, width*0.38, height*0.50, width*0.1, height*0.17);
    noTint();

    if (tKey[0]=='s' || tKey[1]=='s')
      tint(50); 
    image(teclaS1, width*0.5, height*0.50, width*0.1, height*0.17);
    noTint();

    if (tKey[0]=='d'|| tKey[1]=='d')
      tint(50);
    image(teclaD1, width*0.62, height*0.50, width*0.1, height*0.17);
    noTint();


    fill(200);
    rect(width*0.04, height*0.05, width*0.18, height*0.12); //cambiar a modo automatico
    rect(width*0.04, height*0.83, width*0.18, height*0.12); //configurar bluetooth
    fill(0);
    text("Cambiar a\nmodo automático", width*0.13, height*0.105);
    text("Configurar \nBluetooth", width*0.13, height*0.885);
    break;

  case 1:   //modo automatico
    if (mouseX>width*0.055 && mouseX<width*0.16 && mouseY>height*0.29 && mouseY<height*0.33 
      || mouseX>width*0.195 && mouseX<width*0.3 && mouseY>height*0.29 && mouseY<height*0.33)
      cursor(TEXT);
    else
      cursor(ARROW);

    translate(width*0.65-robotPos.x, height*0.5-robotPos.y);
    pathFinder();
    translate(-width*0.65+robotPos.x, -height*0.5+robotPos.y);
    textFont(fontNormal);

    fill(240);
    stroke(240);
    rect(0, 0, width*0.35, height);
    rect(0, 0, width, height*0.05);
    rect(width*0.95, 0, width, height);
    rect(0, height*0.95, width, height);
    stroke(0);
    fill(0, 0, 0, 0);
    rect(width*0.35, height*0.05, width*0.6, height*0.9);
    fill(200);
    rect(width*0.04, height*0.05, width*0.18, height*0.12); //cambiar a modo manual
    rect(width*0.04, height*0.35, width*0.12, height*0.04); //confirmar
    rect(width*0.04, height*0.45, width*0.12, height*0.09); //borrar mapa
    rect(width*0.18, height*0.45, width*0.12, height*0.09); //borrar destino
    rect(width*0.04, height*0.83, width*0.18, height*0.12); //configurar bluetooth
    fill(255);
    rect(width*0.055, height*0.29, width*0.105, height*0.04);
    rect(width*0.195, height*0.29, width*0.105, height*0.04);
    fill(0);
    text("Cambiar a\nmodo manual", width*0.13, height*0.105);
    text("Coordenadas de destino:", width*0.14, height*0.25);
    text("x:", width*0.045, height*0.305);
    text("y:", width*0.185, height*0.305);
    text("Confirmar", width*0.1, height*0.365);
    text("Borrar\ndestino", width*0.24, height*0.49);
    text("Borrar\nmapa", width*0.10, height*0.49);
    text("Configurar \nBluetooth", width*0.13, height*0.885);


    translate(width*0.65, height*0.5);  //dibuja el robot y le da el giro correspondiente
    rotate(robotAng);
    translate(-width*0.65, -height*0.5);
    fill(200);
    rect(-5+width*0.65, -12+height*0.5, 10, 22);
    rect(5+width*0.65, -10+height*0.5, 6, 10);
    rect(-11+width*0.65, -10+height*0.5, 6, 10);
    rect(-2+width*0.65, 10+height*0.5, 4, 5);

    translate(width*0.65, height*0.5);  //deshace el giro
    rotate(-robotAng);
    translate(-width*0.65, -height*0.5);

    break;
  case 2:  //configuración bluetooth

    background(240);
    if (tKey[0]-'0'<=9 && tKey[0]-'0'>=0 && tKey[0]-'0'<Serial.list().length) {
      puerto=tKey[0]-'0';
      btserial=new Serial(this, Serial.list()[tKey[0]-'0'], 9600);
    }

    fill(200);
    rect(width*0.04, height*0.83, width*0.18, height*0.12); //volver
    rect(width*0.77, height*0.09, width*0.18, height*0.12); //cerrar puerto
    fill(0);
    text("Elija un puerto introduciendo el número correspondiente:", width*0.25, height*0.105);
    for (int i=0; i<Serial.list().length; i++) {
      if (i==puerto) {
        textFont(fontBold);
        //btserial = new Serial(this, Serial.list()[puerto], 9600);
      }
      text(i, width*0.50, height*(0.105+0.05*i));
      text(Serial.list()[i], width*0.55, height*(0.105+0.05*i));
      textFont(fontNormal);
    }

    text("Cerrar puerto", width*0.86, height*0.145);
    text("Volver", width*0.13, height*0.885);
    break;
  }
}


void mousePressed() {  //detecta que botones son pulsados
  if (mouseX>width*0.04 && mouseX<width*0.22 && mouseY>height*0.05 && mouseY<height*0.17  && pantalla<2 ) {  //cambio de modo
    if (pantalla==0) {
      pantalla=1;
      xText.setVisible(true);
      yText.setVisible(true);
    } else
      if (pantalla==1) {
        pantalla=0;
        xText.setVisible(false);
        yText.setVisible(false);
      }
  }

  if (mouseX>width*0.04 && mouseX<width*0.16 && mouseY>height*0.35 && mouseY<height*0.39  && pantalla==1) {  //introducir destino
    if (xText.getText()!="" && yText.getText()!="") {
      destino.x = Integer.parseInt(xText.getText());
      destino.y = Integer.parseInt(yText.getText());
    }
    if (puerto!=-1) {  //no hace esto si el puerto esta cerrado
      btserial.write('p');
      delay(100); //con este delay evito leer la p que acabo de mandar
      int dato;
      float ang, dis;
      do {
        dato=btserial.read();
      } while (dato==210);  //espero hasta recibir el primer el primer byte de cabecera
      print('1');
      while (dato!=220) {  //saldre de qui cuando encuentre el byte de cierre
        if (dato==210) {
          print("punto");
          ang=btserial.read();
          ang=ang*salto+mini; //convierto la i al grado correspondiente
          ang=ang*2*PI/360.0; //convierto el angulo a radianes
          ang=ang+robotAng; //le sumo el angulo del robot
          dis=btserial.read();
          if (dis>disSeg/2 && dis<=199) //no hace el punto si la distancia es demasiado cercana(imposible) o demasiado lejana(poco fiable)
            addPoint(cambioCartesianas(ang, dis)[0]+robotPos.x, cambioCartesianas(ang, dis)[1]+robotPos.y);
        }
        dato=btserial.read();
      }
      btserial.write(0);
    }
  }

  if (mouseX>width*0.04 && mouseX<width*0.16 && mouseY>height*0.45 && mouseY<height*0.54  && pantalla==1){ //borrar mapa
    objetos.clear();
    sombras.clear();
  }

  if (mouseX>width*0.18 && mouseX<width*0.30 && mouseY>height*0.45 && mouseY<height*0.54  && pantalla==1) { //borrar destino
    destino.x=robotPos.x;
    destino.y=robotPos.y;
  }

  if (mouseX>width*0.35 && mouseX<width*0.95 && mouseY>height*0.05 && mouseY<height*0.95  && pantalla==1) { //marco pathfinder
    addPoint(int(mouseX-width*0.65), int(mouseY-height*0.5));
  }


  if (mouseX>width*0.04 && mouseX<width*0.22 && mouseY>height*0.83 && mouseY<height*0.95) //ir y volver a la configuracion bluetooth
    if (pantalla<2) {
      pantalla=2;
      xText.setVisible(false);
      yText.setVisible(false);
    } else
      if (pantalla==2)
        pantalla=0;

  if (mouseX>width*0.77 && mouseX<width*0.95 && mouseY>height*0.09 && mouseY<height*0.21 && pantalla==2) {  //cerraar puerto
    puerto=-1;
    btserial.stop();
  }
}

void keyPressed() {   //detecta si una nueva tecla es pulsada, y si hay sitio la guarda en tKey
  if (key=='a' && pantalla == 1)  //estos dos if son solo una demostracion de la capacidad de giro del robor en el mapa
    robotAng-=0.05;
  if (key=='d' && pantalla == 1)
    robotAng+=0.05;

ciclo:
  for (int i=0; i<2; i++) {
    if (tKey[i]==0 && tKey[0]!=key) {
      tKey[i]=key;
      break ciclo;
    }
  }
}

void keyReleased() {   //detecta si una tecla de tKey ha sido soltada, y la borra
  for (int i=0; i<2; i++) {
    if (tKey[i]==key)
      if (i==0)
        tKey[0]=tKey[1];
    tKey[1]=0;
  }
}
