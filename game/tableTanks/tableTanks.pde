import ketai.camera.*;
import com.example.zxingadapter.ZxingAdapter;
import com.example.zxingadapter.QRCode;

// State Constants
final int  START_MENU = 0;
final int  CALIBRATION = 1;

// Globals
KetaiCamera cam;
int state = START_MENU;
int offsetX, offsetY, gameWidth, gameHeight = -1;
boolean isCalibrated = false;
ZxingAdapter zxing;
QRCode qrs[];
String eventInfo = "State: " + state; 

void setup() {
  orientation(LANDSCAPE);
  cam = new KetaiCamera(this, 1280, 960, 24);
  cam.start();
  textSize(18);
  zxing = new ZxingAdapter();
  stroke(0);
}

void draw() {
  fill(255);
  cam.read();
  switch(state) {
  case START_MENU:
    image(cam, 0,0, width, height);
    rect(0,0,100,100);
    rect(width-100, height-100, 100, 100);
    break;
  case CALIBRATION:
    background(255);
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth == -1) && (gameHeight == -1)) {
      ellipse(offsetX,offsetY,100, 100);
    }
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
      translate(offsetX, offsetY);
      rect(0,0,gameWidth,gameHeight);
      translate(-offsetX, -offsetY);
    }
    if (qrs != null) {
      for (QRCode qr:qrs) {
        rotate(qr.getAngle());
        rect(qr.getX(), qr.getY(), 100, 100);
        rotate(-qr.getAngle());
      }
    }
    break;
  default:
    print("Incorrect State");
    break;
  }
  
  fill(0, 102, 153, 204);
  String coordinates = "null";
  if (qrs != null) {
     coordinates = "[";
    for (QRCode qr:qrs) {
      coordinates += qr + ",";
    } 
    coordinates += "]";
    text(coordinates, 10, 10, 200,400);
  }
  text(eventInfo, 220, 10, 420,400);
}

void onCameraPreviewEvent()
{
  if (cam.isStarted()) {
    cam.read();
    cam.loadPixels();
    if (zxing != null) {
      try {
        qrs = zxing.readMultipleQRCode(cam.pixels, cam.width, cam.height);
      } catch (Exception ex) {
        eventInfo = "failed to read:" + ex;
        print("failed to read:" + ex);
      }
    }
  } else {
    if (cam.start()) {
      print("Successfully started camera");
      eventInfo = "Successfully started camera";
    } else {
      print("Failed to start camera");
      eventInfo = "Failed to start camera";
    }
  }
}

void enterCalibration() {
  isCalibrated = false;
  offsetX = -1;
  offsetY = -1;
  gameWidth = -1;
  gameHeight = -1;
}

void mousePressed() {
  switch(state) {
  case START_MENU:
    state = CALIBRATION;
    eventInfo = "State: " + state; 
    enterCalibration();
    break;
  case CALIBRATION:
    if ((offsetX == -1) && (offsetY == -1)) {
      offsetX = mouseX;
      offsetY = mouseY;
      print("1");
    } else if ((gameWidth == -1) && (gameHeight == -1)) {
      gameWidth = mouseX - offsetX;
      gameHeight = mouseY - offsetY;
      print("2");
    } else {
      cam.loadPixels();
      zxing.calibrate(cam.pixels, cam.width, cam.height, "?", gameWidth, gameHeight);
      isCalibrated = true;
      state = START_MENU;
      eventInfo = "State: " + state; 
      print("3");
    }
    break;
  default:
    print("Incorrect State");
    break;
  }
}
