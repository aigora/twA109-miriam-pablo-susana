#include <Servo.h>     
#include <SoftwareSerial.h>
SoftwareSerial BT(6,7);    // Definimos los pines RX y TX del Arduino conectados al Bluetooth

const int EchoPin = 2;
const int TriggerPin = 3;
Servo servo1;

const int der1=8;
const int der2=9;
const int izq1=5;
const int izq2=4;

void setup()  { 
  BT.begin(9600);       // Inicializamos el puerto serie BT que hemos creado
  Serial.begin(9600);   // Inicializamos  el puerto serie
  
  pinMode(TriggerPin, OUTPUT);
  pinMode(EchoPin, INPUT);
  servo1.attach(12);
  
  pinMode(der1, OUTPUT); 
  pinMode(der2, OUTPUT);
  pinMode(izq1, OUTPUT); 
  pinMode(izq2, OUTPUT); 
  
  digitalWrite(der1,0);
  digitalWrite(der2,0);
  digitalWrite(izq1,0);
  digitalWrite(izq2,0);

}
void loop()  { 
  
  char estado;
  if(BT.available()>0){        // lee el bluetooth y almacena en estado
    estado = BT.read();
  }
  switch(estado){
    case 'w':        // Boton desplazar al Frente
      digitalWrite(der1,1);
      digitalWrite(der2,0);
      digitalWrite(izq1,1);
      digitalWrite(izq2,0);
      break;
  
    case 'a':          // Boton IZQ 
      digitalWrite(der1,0);
      digitalWrite(der2,1);
      digitalWrite(izq1,1);
      digitalWrite(izq2,0);
      break;
    case 'd':          // Boton DER
      digitalWrite(der1,1);
      digitalWrite(der2,0);
      digitalWrite(izq1,0);
      digitalWrite(izq2,1); 
      break;   
    case 's':          // Boton Reversa
      digitalWrite(der1,0);
      digitalWrite(der2,1);
      digitalWrite(izq1,0);
      digitalWrite(izq2,1);    
      break;
    case 'q':           // Boton IZQ + Frente
      digitalWrite(der1,0);
      digitalWrite(der2,0);
      digitalWrite(izq1,1);
      digitalWrite(izq2,0);
      break;
    case 'e':           // Boton DER + Frente
      digitalWrite(der1,1);
      digitalWrite(der2,0);
      digitalWrite(izq1,0);
      digitalWrite(izq2,0);
      break;
    case 'z':           // Boton IZQ + Reversa
      digitalWrite(der1,0);
      digitalWrite(der2,0);
      digitalWrite(izq1,0);
      digitalWrite(izq2,1);
      break;
    case 'c':           // Boton DER + Reversa
      digitalWrite(der1,0);
      digitalWrite(der2,1);
      digitalWrite(izq1,0);
      digitalWrite(izq2,0);
      break;
    case 'p':
      digitalWrite(der1,0);
      digitalWrite(der2,0);
      digitalWrite(izq1,0);
      digitalWrite(izq2,0);
      escaneo();
      break;
    default:
      digitalWrite(der1,0);
      digitalWrite(der2,0);
      digitalWrite(izq1,0);
      digitalWrite(izq2,0);
      break;
  }
}


void escaneo(){
  
  int mini = 5;
  int maxi = 155;
  int salto = 5;

  long dist[((maxi-mini)/salto)+1][5]; //en estos arrays leo las distancias de cada barrido, las cuatros primeras filas son para los cuatro barridos, y la quinta para el promedio

  for(int j=mini;j<=maxi;j+=salto){
    servo1.write(j);
    dist[(j-mini)/salto][0] = ultra(TriggerPin, EchoPin);
    delay(30);
  }
  for(int j=maxi;j>=mini;j-=salto){
    servo1.write(j);
    dist[(j-mini)/salto][1] = ultra(TriggerPin, EchoPin);
    delay(30);
  }
  for(int j=mini;j<=maxi;j+=salto){
    servo1.write(j);
    dist[(j-mini)/salto][2] = ultra(TriggerPin, EchoPin);
    delay(30);
  }
  for(int j=maxi;j>=mini;j-=salto){
    servo1.write(j);
    dist[(j-mini)/salto][3] = ultra(TriggerPin, EchoPin);
    delay(30);
  }
  servo1.write(80); //este para que vuelva a mirar al frente. no sirve de nada realmente

  for(int i=0;i<=((maxi-mini)/salto)+1;i++){ //aqui hacemos la media, y nos quedamos con el valor mas cercano a la media
    dist[i][4] = (dist[i][0] + dist[i][1] + dist[i][2] + dist[i][3])/4;
    int lecMin=0;
    for(int j=1;j<4;j++){
      if(abs(dist[i][j]-dist[i][4])<abs(dist[i][lecMin]-dist[i][4]))
        lecMin=j;
    }
    dist[i][4]=dist[i][lecMin];
  }

  BT.flush();
  for(int i=0;i<=((maxi-mini)/salto)+1;i++){ //envia todos los datos
    BT.write(210); //bite de titulo
    BT.write(i); //numero del angulo(el pc lo convierte a un angulo)
    if(dist[i][4]<1)
      BT.write(1);
    if(dist[i][4]>199)  
      BT.write(199);
    if(dist[i][4]>=1 && dist[i][4]<=199)
      BT.write(byte(dist[i][4])); //distancia medida en el angulo
  }
  BT.write(220); //byte que indica el final
  
  delay(1000);  //espera un segundo antes de volver a leer para asegurarse de que el pc lee todos los datos, y no leerlos el mismo
}

long ultra(int TriggerPin, int EchoPin){
  long duration, distanceCm;

  digitalWrite(TriggerPin, LOW);
  delayMicroseconds(4);
  digitalWrite(TriggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(TriggerPin,LOW);

  duration = pulseIn(EchoPin, HIGH);

  distanceCm = duration * 10.0/292.0/2.0;
  
  return distanceCm;
}
