class KinectTracker {

  // Size of kinect image
  int kw = 640;
  int kh = 480;
  int threshold = 793;
  int thresholdBuffer = 10;
  float perspOffsetFactor = .5;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  PImage display;
  
  Kinect kinect;

  KinectTracker(Kinect k) {
    kinect = k;
    kinect.start();
    kinect.enableDepth(true);

    // We could skip processing the grayscale image for efficiency
    // but this example is just demonstrating everything
    kinect.processDepthImage(true);

    display = createImage(kw,kh,PConstants.RGB);

    loc = new PVector(0,0);
    lerpedLoc = new PVector(0,0);
  }
  /*
  void track(int[] depth) {
    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {
        // Mirroring the image
        int offset = kw-x-1+y*kw;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (inThreshold(rawDepth)) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count,sumY/count);
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
  }
  */

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  void display(PImage img, int[] depth) {

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {
        // mirroring image
        int offset = kw-x-1+y*kw;
        // Raw depth (use constant to offset perspective)
        int rawDepth = depth[offset] + (int)(y*perspOffsetFactor);

        int pix = x+y*display.width;
        // if nothing in the depth range or if at the edges of the picture, return white
        if (!inThreshold(rawDepth) || x == 0 || y == 0 || x == kw-1 || y == kh-1) {
          // display.pixels[pix] = img.pixels[offset];
          display.pixels[pix] = color(0,0,0,255);
        } 
        else {
          // A red color instead
          // display.pixels[pix] = color(150,50,50);
          display.pixels[pix] = color(255,255,255,255);
        }
      }
    }
    display.updatePixels();
  }
  
  boolean inThreshold(int thr) {
    return thr < threshold && (thr + thresholdBuffer) > threshold;
  }

  void quit() {
    kinect.quit();
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
  
  
  int getThresholdBuffer() {
    return thresholdBuffer;
  }

  void setThresholdBuffer(int t) {
    thresholdBuffer =  t;
  }
  
  float getPerspOffsetFactor() {
    return perspOffsetFactor;
  }

  void setPerspOffsetFactor(float t) {
    perspOffsetFactor =  t;
  }
}

