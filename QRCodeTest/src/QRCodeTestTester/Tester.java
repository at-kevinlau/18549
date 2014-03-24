package QRCodeTestTester;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import QRCodeTest.QRCodeTest;

import com.google.zxing.DecodeHintType;
import com.google.zxing.EncodeHintType;
import com.google.zxing.NotFoundException;
import com.google.zxing.WriterException;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

public class Tester {

	private static final String FILE_PATH = "QRCodeR270.png";
	
	public static void main(String[] args) throws WriterException, IOException,
	NotFoundException {
		String qrCodeData = "Hello World!";
		String filePath = FILE_PATH;
		String charset = "ISO-8859-1";
		Map<EncodeHintType, ErrorCorrectionLevel> encodeHintMap = new HashMap<EncodeHintType, ErrorCorrectionLevel>();
		encodeHintMap.put(EncodeHintType.ERROR_CORRECTION,
				ErrorCorrectionLevel.L);
		Map<DecodeHintType, String> decodeHintMap = new HashMap<DecodeHintType, String>();
		decodeHintMap.put(DecodeHintType.CHARACTER_SET, charset);

		// Create a QR code image file
		/*
		QRCodeTest.createQRCode(qrCodeData, filePath, charset, encodeHintMap, 200, 200);
		System.out.println("QR Code Image created successfully");
		*/
		
		// Read the QR code image file
		System.out.println("QRCodeString: "
				+ QRCodeTest.readQRCodeString(filePath, charset, decodeHintMap));
		System.out.println("QRCodeLocation: ("
				+ QRCodeTest.readQRCodeLocation(filePath, charset, decodeHintMap)[0] + ", "
				+ QRCodeTest.readQRCodeLocation(filePath, charset, decodeHintMap)[1] + ")");
		System.out.println("QRCodeAngle: "
				+ QRCodeTest.readQRCodeAngle(filePath, charset, decodeHintMap));
	}
}
