import processing.serial.*;

char[] tKey = {0,0}; //tKey es una version mejorada de key. Puede guardar dos teclas y las borra cuando se deja de apretar
int pantalla = 0; //se usa para cambiar entre las distintas pantllas

PImage teclaW1;
PImage teclaW2;
PImage teclaA1;
PImage teclaA2;
PImage teclaS1;
PImage teclaS2;
PImage teclaD1;
PImage teclaD2;

Serial btserial;

void setup(){
  size(1280,720);
  stroke(0);
  textAlign(CENTER,CENTER);
  surface.setTitle("MovAut");
  fill(0);
  
  imageMode(CENTER);
  teclaW1=loadImage("W1.png");
  teclaA1=loadImage("A1.png");
  teclaS1=loadImage("S1.png");
  teclaD1=loadImage("D1.png");
  
  btserial=new Serial(this,Serial.list()[0],9600);
  printArray(Serial.list());
}

int suma;

void draw(){
  background(240);
  
  switch(pantalla){ //este switch decide que pantalla se mostrará
    case 0:   //modo manual
      
      suma=tKey[0]+tKey[1];
      switch(suma){
        case 0:
        case 234:
        case 197:
          btserial.write(0);
          break;
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
        case 'p':
          btserial.write('p');
          btserial.clear();
          int i=0;
          while(i<34){
            print('i');
            if(btserial.available()>1){ //aqui lee la distancia que corresponde a cada angulo. Aun no hace nada con esas distancias
              print(i," ",btserial.read(),"\n");
              i++;
            }
          }
          break;
      }
      
      
      if(tKey[0]=='w' || tKey[1]=='w')
        tint(50);
      image(teclaW1,width*0.5,height*0.29,width*0.1,height*0.17);
      noTint();
  
      if(tKey[0]=='a' || tKey[1]=='a')
        tint(50);
      image(teclaA1,width*0.38,height*0.50,width*0.1,height*0.17);
      noTint();
  
      if(tKey[0]=='s' || tKey[1]=='s')
        tint(50); 
      image(teclaS1,width*0.5,height*0.50,width*0.1,height*0.17);
      noTint();
  
      if(tKey[0]=='d'|| tKey[1]=='d')
        tint(50);
      image(teclaD1,width*0.62,height*0.50,width*0.1,height*0.17);
      noTint();
  
  
      fill(200);
      rect(width*0.04,height*0.05,width*0.18,height*0.12);
      fill(0);
      textSize(width*0.016);
      text("Cambiar a\nmodo automático",width*0.13,height*0.105);
      break;
    
    case 1:   //modo automatico
      if(mouseX>width*0.055 && mouseX<width*0.16 && mouseY>height*0.29 && mouseY<height*0.33 
      || mouseX>width*0.195 && mouseX<width*0.3 && mouseY>height*0.29 && mouseY<height*0.33)
        cursor(TEXT);
      else
        cursor(ARROW);
      
      fill(200);
      rect(width*0.04,height*0.05,width*0.18,height*0.12);
      rect(width*0.04,height*0.35,width*0.12,height*0.04);
      rect(width*0.04,height*0.45,width*0.12,height*0.09);
      rect(width*0.18,height*0.45,width*0.12,height*0.09);
      fill(255);
      rect(width*0.35,height*0.05,width*0.6,height*0.9);
      rect(width*0.055,height*0.29,width*0.105,height*0.04);
      rect(width*0.195,height*0.29,width*0.105,height*0.04);
      fill(0);
      textSize(width*0.016);
      text("Cambiar a\nmodo manual",width*0.13,height*0.105);
      text("Coordenadas de destino:",width*0.14,height*0.25);
      text("x:",width*0.045,height*0.305);
      text("Borrar\ndestino",width*0.24,height*0.49);
      text("Borrar\nmapa",width*0.10,height*0.49);
      text("y:",width*0.185,height*0.305);
      text("Confirmar",width*0.1,height*0.365);
      break;
  }
}


void mousePressed(){  //detecta que botones son pulsados
  if(mouseX>width*0.04 && mouseX<width*0.22 && mouseY>height*0.05 && mouseY<height*0.17)  //cambio de modo
     pantalla=(pantalla+1)%2;
    
  if(mouseX>width*0.04 && mouseX<width*0.16 && mouseY>height*0.35 && mouseY<height*0.39  && pantalla==1); //introducir destino
     //pendiente de accion
     
  if(mouseX>width*0.04 && mouseX<width*0.16 && mouseY>height*0.45 && mouseY<height*0.54  && pantalla==1); //borrar destino
     //pendiente de accion
  
  if(mouseX>width*0.18 && mouseX<width*0.30 && mouseY>height*0.45 && mouseY<height*0.54  && pantalla==1); //borrar mapa
     //pendiente de accion
}

void keyPressed(){   //detecta si una nueva tecla es pulsada, y si hay sitio la guarda en tKey
  ciclo:
  for(int i=0;i<2;i++){
    if(tKey[i]==0 && tKey[0]!=key){
      tKey[i]=key;
      break ciclo;
    }
  }
}

void keyReleased(){   //detecta si una tecla de tKey ha sido soltada, y la borra
  for(int i=0;i<2;i++){
    if(tKey[i]==key)
      if(i==0)
        tKey[0]=tKey[1];
      tKey[1]=0;
  }
}
