import netP5.*;                                           // 1
import oscP5.*;
import ketai.net.*;
import ketai.sensors.*;

OscP5 oscP5;
KetaiSensor sensor;
NetAddress remoteLocation;
float accelerometerX, accelerometerY, accelerometerZ;
float x, y, speedX, speedY,p;
float diam = 10;
float rectSize = 200;
String myIPAddress; 
String remoteAddress = "192.168.1.2"; 

void setup() {
  fullScreen();
  fill(0, 255, 0);
  reset();
  sensor = new KetaiSensor(this);
  orientation(PORTRAIT);
  textAlign(CENTER, CENTER);
  textSize(72);
  initNetworkConnection();
  sensor.start();
  size(480, 480);
  oscP5 = new OscP5(this, 12000);
  remoteLocation = new NetAddress("192.168.1.79", 12000);  // 1 Customize!
  textAlign(CENTER, CENTER);
  textSize(24);
}

void reset() {
  x = width/2;
  y = height/2;
  speedX = random(3, 5);
  speedY = random(3, 5);
}

void draw() { 
  background(78, 93, 75);
  
  ellipse(x, y, diam, diam);

  rect(0, 0, 20, height);
  rect(width-30, mouseY-rectSize/2, 10, rectSize);

  x += speedX;
  y += speedY;

  // if ball hits movable bar, invert X direction
  if ( x > width-30 && x < width -20 && y > mouseY-rectSize/2 && y < mouseY+rectSize/2 ) {
    speedX = speedX * -1;
  } 

  // if ball hits wall, change direction of X
  if (x < 25) {
    speedX *= -1.1;
    speedY *= 1.1;
    x += speedX;
  }


  // if ball hits up or down, change direction of Y   
  if ( y > height || y < 0 ) {
    speedY *= -1;
  }
  text("Remote Mouse Info: \n" +                          // 3
  "mouseX: " + x + "\n" +
    "mouseY: " + y + "\n" +
    "mousePressed: " + p + "\n\n" +
    "Local Accelerometer Data: \n" + 
    "x: " + nfp(accelerometerX, 1, 3) + "\n" +
    "y: " + nfp(accelerometerY, 1, 3) + "\n" +
    "z: " + nfp(accelerometerZ, 1, 3) + "\n\n" +
    "Local IP Address: \n" + myIPAddress + "\n\n" +
    "Remote IP Address: \n" + remoteAddress, width/2, height/2);

  OscMessage myMessage = new OscMessage("accelerometerData"); // 4
  myMessage.add(accelerometerX);                        // 5
  myMessage.add(accelerometerY);
  myMessage.add(accelerometerZ);
  oscP5.send(myMessage, remoteLocation);    
  text("Remote Accelerometer Info: " + "\n" +
    "x: "+ nfp(accelerometerX, 1, 3) + "\n" +
    "y: "+ nfp(accelerometerY, 1, 3) + "\n" +
    "z: "+ nfp(accelerometerZ, 1, 3) + "\n\n" +
    "Local Info: \n" + 
    "mousePressed: " + mousePressed, width/2, height/2);

  myMessage = new OscMessage("mouseStatus");
  myMessage.add(mouseX);                                  // 2
  myMessage.add(mouseY);                                  // 3
  myMessage.add(int(mousePressed));                       // 4
  oscP5.send(myMessage, remoteLocation);                  // 5
}

void mousePressed() {
  reset();
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkTypetag("iii"))                  // 7
  {
    x =  theOscMessage.get(0).intValue();                 // 8
    y =  theOscMessage.get(1).intValue();
    p =  theOscMessage.get(2).intValue();
  }
   if (theOscMessage.checkTypetag("fff"))                  // 6
  {
    accelerometerX =  theOscMessage.get(0).floatValue();  // 7
    accelerometerY =  theOscMessage.get(1).floatValue();
    accelerometerZ =  theOscMessage.get(2).floatValue();
  }
}

void onAccelerometerEvent(float x, float y, float z)
{
  accelerometerX = x;
  accelerometerY = y;
  accelerometerZ = z;
}

void initNetworkConnection()
{
  oscP5 = new OscP5(this, 12000);                         // 9
  remoteLocation = new NetAddress(remoteAddress, 12000);  // 10
  myIPAddress = KetaiNet.getIP();                         // 11
}
