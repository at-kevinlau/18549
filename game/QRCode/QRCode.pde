import com.example.zxingadapter.ZxingAdapter;

String filePath = "mnt/sdcard/Pictures/cameraQRCode/tableTanksCapture.jpg";
String info = "UNINITIATED";
void setup() {
  textSize(18);
  background(51);
try {
  info = ZxingAdapter.readQRCodeString(filePath) + ZxingAdapter.readQRCodeLocation(filePath) + ZxingAdapter.readQRCodeAngle(filePath);  
} catch (Exception ex) {
  info = "FAIL: " + ex;
}

   text(info, 10, 10, 200,400);
}

void draw() {
  background(51);
  
   text(info, 10, 10, 200,400);
}
