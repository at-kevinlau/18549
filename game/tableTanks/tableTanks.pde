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
  cam = new KetaiCamera(this, 1080, 1440, 24);
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
    background(0);
    fill(0);
    stroke(204, 102, 0);
    strokeWeight(5);
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth == -1) && (gameHeight == -1)) {
      ellipse(offsetX,offsetY,100, 100);
    }
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
      translate(offsetX, offsetY);
      rect(0,0,gameWidth,gameHeight);
      translate(-offsetX, -offsetY);
      if ((!isCalibrated) && (qrs.length == 3) && (!qrs[0].getText().equals(qrs[1].getText())) && (!qrs[1].getText().equals(qrs[2].getText()))) {
        cam.loadPixels();
        zxing.calibrate(cam.pixels, cam.width, cam.height, gameWidth, gameHeight);
        isCalibrated = true;
        eventInfo = "Calibration complete!";
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
      coordinates += qr + ",\n";
    } 
    coordinates += "]";
    text(coordinates, 10, 10, 200,400);
  }
  text(eventInfo, 220, 10, 420,400);
  
  if (qrs != null) {
      for (QRCode qr:qrs) {
        rotate(qr.getAngle());
        if (!isCalibrated) {
          rect(qr.getTopLeftX()*0.592, qr.getTopLeftY()*0.592, 100, 100);
        } else {
          rect(qr.getTopLeftX(), qr.getTopLeftY(), 100, 100);
        }
        rotate(-qr.getAngle());
      }
    }
}

void onCameraPreviewEvent()
{
  if (cam.isStarted()) {
    cam.read();
    cam.loadPixels();
    if (zxing != null) {
      try {
        QRCode newQrs[] = zxing.readMultipleQRCode(cam.pixels, cam.width, cam.height);
        if ((newQrs != null) && (newQrs.length > 0)) { 
          qrs = newQrs;
        }
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
      eventInfo = "Waiting for 3 QR Codes...";
      print("2");
    } else {
      state = START_MENU;
      eventInfo = "State: " + state; 
    }
    break;
  default:
    print("Incorrect State");
    break;
  }
}
