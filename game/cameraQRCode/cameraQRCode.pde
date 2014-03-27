import ketai.camera.*;
import com.example.zxingadapter.ZxingAdapter;

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
int captureEvents = 0;
int lastEvent = 0;
int writeEvents = 0;
int readEvents = 0;
String readString = "nothing read yet";
boolean isReady = false;
    
void setup() {
  orientation(LANDSCAPE);
  cam = new KetaiCamera(this, 320, 240, 24);
  cam.start();
  textSize(18);
}

void draw() {
  background(51);
  image(cam, 0,0, width, height);
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
                "-----------------------\n" + cam.list();
   String eventInfo = 
                "capture events: " + captureEvents + "\n" +
                "last event: " + lastEvent + "\n" +
                "read event: " + readEvents + "\n" +
                "write event: " + writeEvents + "\n" +
                "-----------------------\n" + readString;
                
   text(info, 10, 10, 200,400);
   text(eventInfo, 220, 10, 420,400);
/*   if (isReady) {
     // store QR code
       cam.read();
      if (cam.savePhoto(fileName)) {
        writeEvents++;
      } else {
        writeEvents--;
      }

     //read QR Code
     try {
       readString = "(" + ZxingAdapter.readQRCodeLocation(filePath)[0] + ", "
           + ZxingAdapter.readQRCodeLocation(filePath)[1] + ", "
           + ZxingAdapter.readQRCodeAngle(filePath) + "): "
           + ZxingAdapter.readQRCodeString(filePath);
           readEvents++;
     } catch (Exception ex) {
       readString = "failed to read:" + ex;
       readEvents--;
     }
   }
   */
}

void onCameraPreviewEvent()
{
  cam.read();
  cam.loadPixels();
  try {
    com.example.zxingadapter.QRCode[] qrs = com.example.zxingadapter.ZxingAdapter.readMultipleQRCode(cam.pixels, cam.width, cam.height);
    readString = "[";
    for (com.example.zxingadapter.QRCode qr : qrs) {
      readString += qr + "\n";
    }
    readString += "]";
    readEvents++;
  } catch (Exception ex) {
    readString = "failed to read:" + ex;
    readEvents--;
  }
  captureEvents++;
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

