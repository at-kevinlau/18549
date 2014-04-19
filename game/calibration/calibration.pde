import SimpleOpenNI.*;
import com.example.zxingadapter.ZxingAdapter;
import com.example.zxingadapter.QRCode;

// State Constants
final int  START_MENU = 0;
final int  CALIBRATION = 1;

// Globals
SimpleOpenNI kinect;
int state = START_MENU;
int offsetX, offsetY, gameWidth, gameHeight = -1;
boolean isCalibrated = false;
ZxingAdapter zxing;
QRCode qrs[];
String eventInfo = "State: " + state; 

void setup() {
  size(1920, 1080);
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();
  textSize(18);
  zxing = new ZxingAdapter();
  stroke(0);
}

void draw() {
  fill(255);
  kinect.update();
  kinect.rgbImage().loadPixels();
    if (zxing != null) {
      try {
        QRCode newQrs[] = zxing.readMultipleQRCode(kinect.rgbImage().pixels, kinect.rgbImage().width, kinect.rgbImage().height);
        if ((newQrs != null) && (newQrs.length > 0)) { 
          qrs = newQrs;
          if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
            if ((!isCalibrated) && (qrs.length == 3) && (!qrs[0].getText().equals(qrs[1].getText())) && (!qrs[1].getText().equals(qrs[2].getText()))) {
              zxing.calibrate(kinect.rgbImage().pixels, kinect.rgbImage().width, kinect.rgbImage().height, gameWidth, gameHeight);
              isCalibrated = true;
              eventInfo = "Calibration complete!";
            }
          }
        }
      } catch (Exception ex) {
        eventInfo = "failed to read:" + ex;
        print("failed to read:" + ex);
      }
    }
    
  switch(state) {
  case START_MENU:
    image(kinect.rgbImage(), 0,0, width, height);
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
  
  fill(0);
  if (qrs != null) {
      if (!isCalibrated) {
        for (QRCode qr:qrs) {
          rotate(qr.getAngle());
          rect(qr.getTopLeftX()*0.592, qr.getTopLeftY()*0.592, 100, 100);
          rotate(-qr.getAngle());
        }
      } else {
        translate(offsetX, offsetY);
        for (QRCode qr:qrs) {
          rotate(qr.getAngle());
          rect(qr.getTopLeftX(), qr.getTopLeftY(), 100, 100);
          rotate(-qr.getAngle());
        }
        translate(-offsetX, -offsetY);
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
