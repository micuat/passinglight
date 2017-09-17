import com.dhchoi.*;

import processing.serial.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;

Serial serial;

CountdownTimer timer1, timer2;

void setup() 
{
  size(200, 200);
  println((Object[])Serial.list());
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 115200);

  oscP5 = new OscP5(this, 5005);

  int d1 = 10 * 1000;//25 * 1000;
  int d2 = 10 * 1000;//25 * 1000;
  timer1 = CountdownTimerService.getNewCountdownTimer(this).configure(100, d1);
  timer2 = CountdownTimerService.getNewCountdownTimer(this).configure(100, d1 + d2);
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
    //println("first one finished");
    serial.write("UNROTATE\n");
  } else if (t == timer2) {
    //println("second one finished");
  }
}

void keyPressed() {
  if (key == 'e') serial.write("ENABLE\n");
  if (key == 'd') serial.write("DISABLE\n");
  if (key == '0') serial.write("UNROTATE\n");
}

void mousePressed() {
  if (timer2.isRunning() == false) {
    timer1.start();
    timer2.start();

    float x = mouseX - width/2;
    float y = height/2 - mouseY;
    float angle = atan2(y, x) / PI * 2;
    if (angle < 0) angle += 4;

    int id = int(floor(angle)) * 2;
    serial.write("ROTATE " + str(id) + "\n");
  }
}

void oscEvent(OscMessage m) {
  /* check if theOscMessage has the address pattern we are looking for. */
  println(m.addrPattern() + " " + m.typetag());

  if (m.checkAddrPattern("/passing/plate/tip")) {
    if (timer2.isRunning()) {
      println("already running, reject");
    } else {
      String dir = m.get(0).stringValue();
      println(m.get(0).stringValue());
      timer1.start();
      timer2.start();

      if (dir.equals("right")) {
        serial.write("ROTATE " + str(0) + "\n");
      } else if (dir.equals("up")) {
        serial.write("ROTATE " + str(2) + "\n");
      } else if (dir.equals("left")) {
        serial.write("ROTATE " + str(4) + "\n");
      } else if (dir.equals("down")) {
        serial.write("ROTATE " + str(6) + "\n");
      } else {
        println("wrong parameter!");
      }
    }
  }
}