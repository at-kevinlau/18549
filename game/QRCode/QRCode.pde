import QRCodeTest.QRCodeTest;
import java.util.HashMap;
import java.util.Map;

Map<DecodeHintType, String> decodeHintMap = new HashMap<DecodeHintType, String>();
String filePath = "mnt/sdcard/Pictures/cameraQRCode/tableTanksCapture.jpg";
String info = "UNINITITITATEDDD";
void setup() {
  decodeHintMap.put(DecodeHintType.CHARACTER_SET, "ISO-8859-1");
  textSize(18);
  background(51);
/*   try {
  info = QRCodeTest.readQRCodeString(filePath,"ISO-8859-1",decodeHintMap);
} catch (Exception ex) {
  info = "FAIL: " + ex;
}*/

   text(info, 10, 10, 200,400);
}

void draw() {
  background(51);
  
   text(info, 10, 10, 200,400);
}
