import com.dhchoi.*;

import processing.serial.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress netAddress;
NetAddress netAddressPd;

Serial serial;

CountdownTimer timer1, timer2;
CountdownTimer timerSoft1, timerSoft2, timerSoft21;

void setup() 
{
  size(200, 200);
  println((Object[])Serial.list());
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 115200);

  oscP5 = new OscP5(this, 5005);
  netAddress = new NetAddress("127.0.0.1", 5006);
  netAddressPd = new NetAddress("127.0.0.1", 6005);

  int d1 = 30 * 1000;//25 * 1000;
  int d2 = 60 * 1000;//25 * 1000;
  timer1 = CountdownTimerService.getNewCountdownTimer(this).configure(100, d1);
  timer2 = CountdownTimerService.getNewCountdownTimer(this).configure(100, d2);
  timerSoft1 = CountdownTimerService.getNewCountdownTimer(this).configure(100, 8 * 1000);
  timerSoft2 = CountdownTimerService.getNewCountdownTimer(this).configure(100, 13 * 1000);
  timerSoft21 = CountdownTimerService.getNewCountdownTimer(this).configure(100, 20 * 1000);
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
  OscMessage m;
  m = new OscMessage("/passing/vvvv/tween");
  if (t == timerSoft1) {
    //println("first one tick");
    float t0 = t.getTimerDuration() - t.getTimeLeftUntilFinish();
    float t1 = t.getTimerDuration();
    float p = constrain(map(t0, 0, t1, 0, 1), 0, 1);
    m.add(p);
    oscP5.send(m, netAddress);
    if(t0 > 1000 && timer1.isRunning() == false) {
      switch(int(floor(random(3)))) {
      case 0:
        serial.write("ROTATE " + str(0) + "\n"); // right
      case 1:
        serial.write("ROTATE " + str(4) + "\n"); // left
      default:
        serial.write("ROTATE " + str(6) + "\n"); // down
      }
      timer1.start();
    }
  } else if (t == timerSoft2) {
    //println("second one tick");
    float t0 = t.getTimerDuration() - t.getTimeLeftUntilFinish();
    float t1 = t.getTimerDuration();
    float p = constrain(map(t0, 0, t1, 1, 0), 0, 1);
    m.add(p);
    oscP5.send(m, netAddress);
    if(t0 > 1000 && timer2.isRunning() == false) {
      serial.write("UNROTATE\n");
      timer2.start();
    }
  } else return;
}

void onFinishEvent(CountdownTimer t) {
  if (t == timer1) {
            //println("first one finished");
    OscMessage m = new OscMessage("/passing/pd/move");
    m.add(1);
    oscP5.send(m, netAddressPd);

    int d2 = int(30 + random(30)) * 1000;
    timer2.configure(100, d2);
    //timer2.start();
    timerSoft2.start();
    timerSoft21.start();
  } else if (t == timer2) {
    //println("second one finished");
  } else if (t == timerSoft1) {
    OscMessage m;
    m = new OscMessage("/passing/pd/move");
    m.add(0);
    oscP5.send(m, netAddressPd);
  } else if (t == timerSoft2) {
    OscMessage m;
    m = new OscMessage("/passing/pd/move");
    m.add(0);
    oscP5.send(m, netAddressPd);
  } else if (t == timerSoft21) {
    OscMessage m;
    m = new OscMessage("/passing/vvvv/spawn");
    m.add(1);
    oscP5.send(m, netAddress);

    m = new OscMessage("/passing/pd/spawn");
    m.add(1);
    oscP5.send(m, netAddressPd);
  }
}

void keyPressed() {
  if (key == 'e') serial.write("ENABLE\n");
  if (key == 'd') serial.write("DISABLE\n");
  if (key == '0') serial.write("UNROTATE\n");
}

void mousePressed() {
}

void oscEvent(OscMessage m) {
  /* check if theOscMessage has the address pattern we are looking for. */
  println(m.addrPattern() + " " + m.typetag());

  if (m.checkAddrPattern("/passing/plate/tip")) {
    if (timer1.isRunning() == false && timer2.isRunning() == false
    && timerSoft1.isRunning() == false && timerSoft2.isRunning() == false
    && timerSoft21.isRunning() == false) {
      String dir = m.get(0).stringValue();
      println(m.get(0).stringValue());
      int d1 = int(30 + random(30)) * 1000;
      timer1.configure(100, d1);
      //timer1.start();
      timerSoft1.start();

      OscMessage m2 = new OscMessage("/passing/pd/move");
      m2.add(1);
      oscP5.send(m2, netAddressPd);
    } else {
      println("already running, reject");
    }
  }
}