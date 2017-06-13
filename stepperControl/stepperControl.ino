#include <SerialCommand.h>

SerialCommand command;

int EN [] = {2, 5,  8, 11};
int DIR[] = {3, 6,  9, 12}; //define Direction pin
int PUL[] = {4, 7, 10, 13}; //define Pulse pin

void setup() {
  Serial.begin(115200);
  command.addCommand("TEST", rotate);
  command.addCommand("ENABLE", enable);
  command.addCommand("DISABLE", disable);

  for (int i = 0; i < 4; i++) {
    pinMode (EN[i], OUTPUT);
    pinMode (DIR[i], OUTPUT);
    pinMode (PUL[i], OUTPUT);

    digitalWrite(EN[i], HIGH);
  }
}

void loop() {
  command.readSerial();
}

int t1 = 250 * 1.5;
int t2 = t1;

int id1Preset[] = {0,  1, 1,  2, 2,  3, 3,  0};
int id2Preset[] = {1, -1, 2, -1, 3, -1, 0, -1};

void rotate() {
  char *arg;
  arg = command.next();
  Serial.println(arg);

  if (arg == NULL) {
    Serial.println("usage: TEST n");
    return;
  }

  int angle = atoi(arg);

  if (angle < 0 || 8 <= angle) {
    Serial.println("usage: TEST n");
    return;
  }

  int id1 = id1Preset[angle];
  int id2 = id2Preset[angle];
  int counterId1 = (id1 + 2) % 4;
  int counterId2 = (id2 < 0) ? -1 : (id1 + 2 + 1) % 4;

  t1 = t2 = 250 * 1.5;
  digitalWrite(DIR[id1], HIGH);
  if(id2 >= 0) digitalWrite(DIR[id2], HIGH);
  digitalWrite(DIR[counterId1], LOW);
  if(id2 >= 0) digitalWrite(DIR[counterId2], LOW);
  for (int i = 0; i < 640 * 8; i++)
  {
    digitalWrite(PUL[id1], HIGH);
    if(id2 >= 0) digitalWrite(PUL[id2], HIGH);
    digitalWrite(PUL[counterId1], HIGH);
    if(id2 >= 0) digitalWrite(PUL[counterId2], HIGH);
    delayMicroseconds(t1);
    digitalWrite(PUL[id1], LOW);
    if(id2 >= 0) digitalWrite(PUL[id2], LOW);
    digitalWrite(PUL[counterId1], LOW);
    if(id2 >= 0) digitalWrite(PUL[counterId2], LOW);
    delayMicroseconds(t2);
  }
  delay(500);

  t1 = t2 = 250 * 3;
  digitalWrite(DIR[id1], LOW);
  if(id2 >= 0) digitalWrite(DIR[id2], LOW);
  digitalWrite(DIR[counterId1], HIGH);
  if(id2 >= 0) digitalWrite(DIR[counterId2], HIGH);
  for (int i = 0; i < 640 * 8; i++)
  {
    digitalWrite(PUL[id1], HIGH);
    if(id2 >= 0) digitalWrite(PUL[id2], HIGH);
    digitalWrite(PUL[counterId1], HIGH);
    if(id2 >= 0) digitalWrite(PUL[counterId2], HIGH);
    delayMicroseconds(t1);
    digitalWrite(PUL[id1], LOW);
    if(id2 >= 0) digitalWrite(PUL[id2], LOW);
    digitalWrite(PUL[counterId1], LOW);
    if(id2 >= 0) digitalWrite(PUL[counterId2], LOW);
    delayMicroseconds(t2);
  }

}

void enable() {
  for (int i = 0; i < 4; i++) {
    digitalWrite(EN[i], HIGH);
  }
}

void disable() {
  for (int i = 0; i < 4; i++) {
    digitalWrite(EN[i], LOW);
  }
}

