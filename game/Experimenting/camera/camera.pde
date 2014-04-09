import ketai.camera.*;

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


KetaiCamera cam;
int readEvents = 0;
int lastEvent = 0;

void setup() {
  orientation(LANDSCAPE);
  imageMode(CENTER);
  cam = new KetaiCamera(this, 320, 240, 24);
  cam.start();
  textSize(18);
}

void draw() {
  background(51);
  image(cam, 0,0);
  cam.read();
  
  int id = cam.getCameraID();
  boolean previewSupported = cam.isRGBPreviewSupported;
  int num = cam.getNumberOfCameras();
  int h = cam.getPhotoHeight();
  int w = cam.getPhotoWidth();
  int zoom = cam.getZoom();
  boolean flash = cam.isFlashEnabled();
  boolean started = cam.isStarted();
  
  String info = "id: " + id + "\n" +
                "isRGBPreviewSupported: " + previewSupported + "\n" +
                "requestedStart: " + cam.requestedStart + "\n" + 
                "num: " + num + "\n" +
                "h: " + h + "\n" +
                "w: " + w + "\n" +
                "zoom: " + zoom + "\n" +
                "flash: " + flash + "\n" +
                "started: " + started + "\n"+
                "read events: " + readEvents + "\n" +
                "last event: " + lastEvent + "\n" +
                "-----------------------\n" + cam.list();
                
   text(info, 10, 10, 200,400);
}

void onCameraPreviewEvent()
{
  cam.read();
  readEvents++;
}

// start/stop camera preview by tapping the screen

void mousePressed()
{
  if (cam.isStarted())
  {
    cam.stop();
  }
  else{
    if (cam.start()) {
      lastEvent++;
    } else {
      lastEvent--;
    }
  }
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

