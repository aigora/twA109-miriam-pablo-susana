#include <Servo.h>     
#include <SoftwareSerial.h>
SoftwareSerial BT(6,7);    // Definimos los pines RX y TX del Arduino conectados al Bluetooth

const int EchoPin = 8;
const int TriggerPin = 9;
int cm = 7;

Servo servo1;


const int der1=3;
const int der2=2;
const int izq1=4;
const int izq2=5;
const int derVel=6;
const int izqVel=7;

int velocidad=150;

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
  pinMode(derVel, OUTPUT);
  pinMode(izqVel, OUTPUT);
  
  digitalWrite(der1,0);
  digitalWrite(der2,0);
  digitalWrite(izq1,0);
  digitalWrite(izq2,0);

}
void loop()  { 

  char estado ;
  if(Serial.available()>0){        // lee el bluetooth y almacena en estado
    estado = Serial.read();
  }
  
  
  if(estado=='w'){           // Boton desplazar al Frente
    digitalWrite(der1,1);
    digitalWrite(der2,0);
    digitalWrite(izq1,1);
    digitalWrite(izq2,0);
  }
  if(estado=='a'){          // Boton IZQ 
    digitalWrite(der1,0);
    digitalWrite(der2,1);
    digitalWrite(izq1,1);
    digitalWrite(izq2,0);
  }
  if(estado==0){         // Boton Parar
    digitalWrite(der1, 0);     
    digitalWrite(der2, 0); 
    digitalWrite(izq1, 0);    
    digitalWrite(izq2, 0); 
  }
  if(estado=='d'){          // Boton DER
    digitalWrite(der1,1);
    digitalWrite(der2,0);
    digitalWrite(izq1,0);
    digitalWrite(izq2,1); 
  }   
  if(estado=='s'){          // Boton Reversa
    digitalWrite(der1,0);
    digitalWrite(der2,1);
    digitalWrite(izq1,0);
    digitalWrite(izq2,1);    
  }
  if(estado=='q'){           // Boton IZQ + Frente
    digitalWrite(der1,0);
    digitalWrite(der2,0);
    digitalWrite(izq1,1);
    digitalWrite(izq2,0);
  }
  if(estado=='e'){           // Boton DER + Frente
    digitalWrite(der1,1);
    digitalWrite(der2,0);
    digitalWrite(izq1,0);
    digitalWrite(izq2,0);
  }
  if(estado=='z'){           // Boton IZQ + Reversa
    digitalWrite(der1,0);
    digitalWrite(der2,0);
    digitalWrite(izq1,0);
    digitalWrite(izq2,1);
  }
  if(estado=='c'){           // Boton DER + Reversa
    digitalWrite(der1,0);
    digitalWrite(der2,1);
    digitalWrite(izq1,0);
    digitalWrite(izq2,0);
  }
  if(estado=='p'){
    escaneo();
  }
}


void escaneo(){
  int mini = 0;
  int maxi = 170;
  int salto = 5;
  int distancias[(maxi-mini)/salto];

  for(int i=0;i<1;i++){
    for(int j=mini;j<=maxi;j+=salto){
      servo1.write(j);
      distancias[(j-mini)/salto]= (i*2*distancias[(j-mini)/salto] + ultra(TriggerPin, EchoPin))/(i*2+1);
      delay(20);
    }
    for(int j=maxi;j>=mini;j-=salto){
      servo1.write(j);
      ultra(TriggerPin, EchoPin);
      distancias[(j-mini)/salto]= ((i*2+1)*distancias[(j-mini)/salto] + ultra(TriggerPin, EchoPin))/(i*2+2);
      delay(20);
    }
  }
  for(int i=0;i<(maxi-mini)/salto;i++)
    Serial.write(distancias[i]);
}

int ultra(int TriggerPin, int EchoPin){
  long duration, distanceCm;

  digitalWrite(TriggerPin, LOW);
  delayMicroseconds(4);
  digitalWrite(TriggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(TriggerPin,LOW);

  duration = pulseIn(EchoPin, HIGH,10000);

  distanceCm = duration * 10/292/2;
  if (distanceCm<5 || distanceCm>150) 
    return 0;
  else
    return distanceCm;
}
