// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

import org.openkinect.*;
import org.openkinect.processing.*;

// Showing how we can farm all the kinect stuff out to a separate class
KinectTracker tracker;
// Kinect Library object
Kinect kinect;

final int WIDTH = 640;
final int HEIGHT = 520;

// calibration points
PVector topLeft = new PVector(0,0);
PVector topRight = new PVector(WIDTH,0);
PVector bottomLeft = new PVector(0,HEIGHT);

void setup() {
  size(WIDTH,HEIGHT);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
}

void draw() {
  background(255);

  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50,100,250,200);
  noStroke();
  ellipse(v1.x,v1.y,20,20);

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  fill(100,250,50,200);
  noStroke();
  ellipse(v2.x,v2.y,20,20);

  // Show calibration points
  ellipse(topLeft.x, topLeft.y,20,20);
  ellipse(topRight.x,topRight.y,20,20);
  ellipse(bottomLeft.x,bottomLeft.y,20,20);


  // Display some info
  int t = tracker.getThreshold();
  int tBuf = tracker.getThresholdBuffer();
  float pF = tracker.getPerspOffsetFactor();
  fill(255);
  text("threshold: " + t + "    " +  "framerate: " + (int)frameRate + "\n" +
       "threshold range: " + tBuf + "\n" +
       "perspective offset factor: " + pF + "\n" + 
       "UP, DOWN to move threshold, LEFT, RIGHT to increase range,\n" + 
       "CONTROL, ALT to change angle",0,30);
  
}

void keyPressed() {
  int t = tracker.getThreshold();
  int tBuf = tracker.getThresholdBuffer();
  float pF = tracker.getPerspOffsetFactor();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=1;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=1;
      tracker.setThreshold(t);
    } else if (keyCode == LEFT) {
      tBuf-=1;
      tracker.setThresholdBuffer(tBuf);
    } else if (keyCode == RIGHT) {
      tBuf+=1;
      tracker.setThresholdBuffer(tBuf);
    } else if (keyCode == ALT) {
      pF+=.01;
      tracker.setPerspOffsetFactor(pF);
    } else if (keyCode == CONTROL) {
      pF-=.01;
      tracker.setPerspOffsetFactor(pF);
    }
  }
}

void stop() {
  tracker.quit();
  super.stop();
}

