import ketai.camera.*;
import QRCodeTest.QRCodeTest;
import java.util.HashMap;
import java.util.Map;

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
String charset = "ISO-8859-1";
Map<DecodeHintType, String> decodeHintMap = new HashMap<DecodeHintType, String>();
String readString = "nothing read yet";
String fileName = "tableTanksCapture.jpg";
String filePath = "mnt/sdcard/Pictures/cameraQRCode/tableTanksCapture.jpg";
    
void setup() {
  decodeHintMap.put(DecodeHintType.CHARACTER_SET, charset);
  orientation(LANDSCAPE);
  imageMode(CENTER);
  cam = new KetaiCamera(this, 320, 240, 24);
  cam.start();
  textSize(18);
}

void draw() {
  background(51);
  image(cam, 0,0, width*2, height*2);
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
   
   /*
   cam.read();
  if (cam.savePhoto(fileName)) {
    writeEvents++;
  } else {
    writeEvents--;
  }
  try { Thread.sleep(3000); } catch (Exception ex) {}
  try {
    readString = "(" + QRCodeTest.readQRCodeLocation(filePath, charset, decodeHintMap)[0] + ", "
        + QRCodeTest.readQRCodeLocation(filePath, charset, decodeHintMap)[1] + ", "
        + QRCodeTest.readQRCodeAngle(filePath, charset, decodeHintMap) + "): "
        + QRCodeTest.readQRCodeString(filePath, charset, decodeHintMap);
        readEvents++;
  } catch (Exception ex) {
    readString = "failed to read:" + ex;
    readEvents--;
  }
  captureEvents++;*/
}

void onCameraPreviewEvent()
{
  cam.read();
  if (cam.savePhoto(fileName)) {
    writeEvents++;
  } else {
    writeEvents--;
  }
  try {
    readString = "(" + QRCodeTest.readQRCodeLocation(filePath, charset, decodeHintMap)[0] + ", "
        + QRCodeTest.readQRCodeLocation(filePath, charset, decodeHintMap)[1] + ", "
        + QRCodeTest.readQRCodeAngle(filePath, charset, decodeHintMap) + "): "
        + QRCodeTest.readQRCodeString(filePath, charset, decodeHintMap);
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

