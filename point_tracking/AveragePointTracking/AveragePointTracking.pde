import gab.opencv.*;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

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

final int WIDTH = 600;
final int HEIGHT = 400;

// calibration points
PVector topLeft = new PVector(0,0);
PVector topRight = new PVector(WIDTH,0);
PVector bottomLeft = new PVector(0,HEIGHT);

// 1 = topLeft, 2 = topRight, 3 = bottomLeft
int currentlySelectedCalib = 1;

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
  fill(100,250,50,50);
  noStroke();
  ellipse(v2.x,v2.y,20,20);

  // Show calibration points
  fill (250,50,100,200);
  ellipse(topLeft.x, topLeft.y,20,20);
  fill (100,250,50,200);
  ellipse(topRight.x,topRight.y,20,20);
  fill (50,100,250,200);
  ellipse(bottomLeft.x,bottomLeft.y,20,20);

  fill (128,128,128,128);
  int bottomExtraWidth = (int)(topLeft.x - bottomLeft.x);
  quad (topLeft.x, topLeft.y,
        topRight.x, topRight.y,
        topRight.x + bottomExtraWidth, bottomLeft.y,
        bottomLeft.x, bottomLeft.y);

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

void mousePressed() {
 if (currentlySelectedCalib == 1) {
   topLeft = new PVector(mouseX, mouseY);
   topRight = new PVector(topRight.x, topLeft.y);
 } else if (currentlySelectedCalib == 2) {
   topRight = new PVector(mouseX, mouseY);
   topLeft = new PVector(topLeft.x, topRight.y);
 } else if (currentlySelectedCalib == 3) {
   bottomLeft = new PVector(mouseX, mouseY);
 } 
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
  if (key == '1') {
    currentlySelectedCalib = 1;
  } else if (key == '2') {
    currentlySelectedCalib = 2;
  } else if (key == '3') {
    currentlySelectedCalib = 3;
  } else if (key == ' ') {
    System.out.println("Mouse game coordinates: " + screenXYtoGameXY(mouseX,mouseY));
  }
}

Point toPoint(PVector in) {
 return new Point(in.x, in.y); 
}

PVector screenXYtoGameXY(int scrX, int scrY)
{
  int bottomExtraWidth = (int)(topLeft.x - bottomLeft.x);
  PVector bottomRight = new PVector(topRight.x + bottomExtraWidth, bottomLeft.y);
  
  Point[] src = new Point[4];
  src[0] = toPoint(topLeft);
  src[1] = toPoint(topRight);
  src[2] = toPoint(bottomRight);
  src[3] = toPoint(bottomLeft);
  
  Point[] dst = new Point[4];
  dst[0] = new Point(0.0,0.0);
  dst[1] = new Point(1.0,0.0);
  dst[2] = new Point(1.0,1.0);
  dst[3] = new Point(0.0,1.0);
  
  MatOfPoint2f srcMat = new MatOfPoint2f();
  MatOfPoint2f dstMat = new MatOfPoint2f();
  srcMat.fromArray(src);
  dstMat.fromArray(dst);
  
  Mat warpMatrix = Imgproc.getPerspectiveTransform(srcMat,dstMat);
  
  Mat warp = warpMatrix;
  
  Point warped_point = new Point(scrX, scrY);
  ArrayList<Point> singlePoint = new ArrayList<Point>();
  singlePoint.add(warped_point);
  MatOfPoint2f singleWarped = new MatOfPoint2f();
  singleWarped.fromList(singlePoint);
  
  MatOfPoint2f endPoint = new MatOfPoint2f();
  endPoint.fromList(singlePoint);
  
  
  Core.perspectiveTransform(singleWarped, endPoint, warpMatrix);
  
  int[] empty = new int[1];
  
  return new PVector(endPoint.get(0,0,empty), endPoint.get(1,0,empty));
  
  /*
  Mat homogeneousMat = warp.inv().mul(singleWarped);
  Point3 homogeneous = new Point3(homogeneousMat.get(0,0),homogeneousMat.get(1,0),homogeneousMat.get(2,0)); 
  Point result = new Point(homogeneous.x, homogeneous.y);  // Drop the z=1 to get out of homogeneous coordinates
  // now, result == srcQuad[3], which is what you wanted
  */

}

void stop() {
  tracker.quit();
  super.stop();
}

