import com.dhchoi.*;

import processing.serial.*;

Serial serial;

CountdownTimer timer1, timer2;

void setup() 
{
  size(200, 200);
  println((Object[])Serial.list());
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 115200);

  int d1 = 15 * 1000;
  int d2 = 15 * 1000;
  timer1 = CountdownTimerService.getNewCountdownTimer(this).configure(100, d1);
  timer2 = CountdownTimerService.getNewCountdownTimer(this).configure(100, d2);
}

void draw() {
  background(0);
  noStroke();
  fill(map(timer1.getTimeLeftUntilFinish(), timer1.getTimerDuration(), 0, 255, 0));
  rect(0, 0, width/2, height);
  fill(map(timer2.getTimeLeftUntilFinish(), timer2.getTimerDuration(), 0, 255, 0));
  rect(width/2, 0, width/2, height);
}

void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
}

void onFinishEvent(CountdownTimer t) {
  if (t == timer1) {
    serial.write("UNROTATE\n");
    timer2.start();
  } else {
    switch(int(floor(random(3)))) {
    case 0:
      serial.write("ROTATE " + str(0) + "\n"); // right
    case 1:
      serial.write("ROTATE " + str(4) + "\n"); // left
    case 2:
      serial.write("ROTATE " + str(2) + "\n"); // left
    default:
      serial.write("ROTATE " + str(6) + "\n"); // down
    }
    timer1.start();
  }
}

void keyPressed() {
  if (key == 'e') serial.write("ENABLE\n");
  if (key == 'd') serial.write("DISABLE\n");
  if (key == '0') serial.write("UNROTATE\n");
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if (timer1.isRunning() == false && timer2.isRunning() == false) {
      switch(int(floor(random(3)))) {
      case 0:
        serial.write("ROTATE " + str(0) + "\n"); // right
      case 1:
        serial.write("ROTATE " + str(4) + "\n"); // left
      case 2:
        serial.write("ROTATE " + str(2) + "\n"); // left
      default:
        serial.write("ROTATE " + str(6) + "\n"); // down
      }
      timer1.start();
    }
  }
}