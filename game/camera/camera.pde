/**
 * <p>Ketai Sensor Library for Android: http://KetaiProject.org</p>
 *
 * <p>Ketai Camera Features:
 * <ul>
 * <li>Interface for built-in camera</li>
 * <li></li>
 * </ul>
 * <p>Updated: 2012-10-21 Daniel Sauter/j.duran</p>
 */

import ketai.camera.*;

KetaiCamera cam;

void setup() {
  orientation(LANDSCAPE);
  imageMode(CENTER);
  cam = new KetaiCamera(this, 320, 240, 24);
}

void draw() {
  image(cam, width/2, height/2);
  
  
  int id = cam.getCameraID();
  int num = cam.getNumberOfCameras();
  int h = cam.getPhotoHeight();
  int w = cam.getPhotoWidth();
  int zoom = cam.getZoom();
  boolean flash = cam.isFlashEnabled();
  boolean started = cam.isStarted();
  
  String info = "id: " + id + "\n" +
                "num: " + num + "\n" +
                "h: " + h + "\n" +
                "w: " + w + "\n" +
                "zoom: " + zoom + "\n" +
                "flash: " + flash + "\n" +
                "started: " + started + "\n";
}

void onCameraPreviewEvent()
{
  cam.read();
}

// start/stop camera preview by tapping the screen
void mousePressed()
{
  if (cam.isStarted())
  {
    cam.stop();
  }
  else
    cam.start();
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode == MENU) {
      if (cam.isFlashEnabled())
        cam.disableFlash();
      else
        cam.enableFlash();
    }
  }
}
