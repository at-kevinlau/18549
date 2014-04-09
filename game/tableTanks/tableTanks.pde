//import ketai.camera.*;
import com.example.zxingadapter.ZxingAdapter;
import com.example.zxingadapter.QRCode;

// State Constants
final int  START_MENU = 0;
final int  CALIBRATION = 1;

// Globals
//KetaiCamera cam;
int state = START_MENU;
int offsetX, offsetY, gameWidth, gameHeight = -1;
boolean isCalibrated = false;

void setup() {
  orientation(LANDSCAPE);
  //cam = new KetaiCamera(this, 320, 240, 24);
  //cam.start();
  textSize(18);
}

void draw() {
  background(0);
  switch(state) {
  case START_MENU:
    background(100);
    break;
  case CALIBRATION:
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
      fill(255);
      translate(offsetX, offsetY);
      rect(0,0,gameWidth,gameHeight);
    }
    print(offsetX + " " + offsetY + " " + gameWidth + " " + gameHeight);
    break;
  default:
    print("Incorrect State");
    break;
  }
}

void onCameraPreviewEvent()
{
  /*if (cam.isStarted()) {
    cam.read();
    cam.loadPixels();
    try {
      QRCode[] qrs = ZxingAdapter.readMultipleQRCode(cam.pixels, cam.width, cam.height);
    } catch (Exception ex) {
      print("failed to read:" + ex);
    }
  } else {
    if (cam.start()) {
      print("Successfully started camera");
    } else {
      print("Failed to start camera");
    }
  }*/
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
      // TODO: calibrate
      isCalibrated = true;
      state = START_MENU;
      print("3");
    }
    break;
  default:
    print("Incorrect State");
    break;
  }
}
