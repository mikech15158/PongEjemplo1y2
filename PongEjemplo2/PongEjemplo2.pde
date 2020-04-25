import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remoteLocation;
int x, y, px, py;
float speedX, speedY;
float diam = 10;
float rectSize = 200;


void setup() {
  fullScreen();
  fill(0, 255, 0);
  reset();
  size(1440, 2560);
  oscP5 = new OscP5(this, 12000);
  remoteLocation = new NetAddress("10.17.248.154", 12000);  // 1
  background(78, 93, 75);
  orientation(PORTRAIT);
  remoteLocation = new NetAddress("192.168.1.79", 12000);  // 1
  background(78, 93, 75);
}

void reset() {
  x = width/2;
  y = height/2;
  speedX = random(3, 5);
  speedY = random(3, 5);
}

void draw() { 
  background(0);
  
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
  stroke(0);
  float remoteSpeed = dist(px, py, x, y);
  strokeWeight(remoteSpeed);  
  if (remoteSpeed < 100) line(px, py, x, y); 
  px = x; 
  py = y;  
  if (mousePressed) {
    stroke(255);
    float speed = dist(pmouseX, pmouseY, mouseX, mouseY); 
    strokeWeight(speed);
    if (speed < 100) line(pmouseX, pmouseY, mouseX, mouseY); 
    OscMessage myMessage = new OscMessage("PCData"); 
    myMessage.add(mouseX); 
    myMessage.add(mouseY);
    oscP5.send(myMessage, remoteLocation);
  }
  
  stroke(0);
  remoteSpeed = dist(px, py, x, y);                 // 2
  if (remoteSpeed < 100) strokeWeight(remoteSpeed);       // 3
  line(px, py, x, y);                                     // 4
  px = x;                                                 // 5
  py = y;                                                 // 6
  if (mousePressed) {
    stroke(255);
    float speed = dist(pmouseX, pmouseY, mouseX, mouseY); // 7
    strokeWeight(speed);                                  // 8
    if (speed < 100) line(pmouseX, pmouseY, mouseX, mouseY); // 9
    OscMessage myMessage = new OscMessage("AndroidData"); 
    myMessage.add(mouseX); 
    myMessage.add(mouseY);
    oscP5.send(myMessage, remoteLocation);
  }
  
  
}

void mousePressed() {
  reset();
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkTypetag("ii"))  
  {
    x =  theOscMessage.get(0).intValue();
    y =  theOscMessage.get(1).intValue();
  }
}
