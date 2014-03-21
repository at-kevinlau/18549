package QRCodeTest;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.NotFoundException;
import com.google.zxing.Result;
import com.google.zxing.ResultPoint;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

public class QRCodeTest {

	public static void main(String[] args) throws WriterException, IOException,
			NotFoundException {
		String qrCodeData = "Hello World!";
		String filePath = "QRCode.png";
		String charset = "ISO-8859-1";
		Map<EncodeHintType, ErrorCorrectionLevel> encodeHintMap = new HashMap<EncodeHintType, ErrorCorrectionLevel>();
		encodeHintMap.put(EncodeHintType.ERROR_CORRECTION,
				ErrorCorrectionLevel.L);
		Map<DecodeHintType, String> decodeHintMap = new HashMap<DecodeHintType, String>();
		decodeHintMap.put(DecodeHintType.CHARACTER_SET, charset);
		
		// Create a QR code image file
		createQRCode(qrCodeData, filePath, charset, encodeHintMap, 200, 200);
		System.out.println("QR Code Image created successfully");

		// Read the QR code image file
		System.out.println("Data read from QR Code: "
				+ readQRCode(filePath, charset, decodeHintMap));

	}

	public static void createQRCode(String qrCodeData, String filePath,
			String charset, Map<EncodeHintType, ErrorCorrectionLevel> hintMap,
			int qrCodeHeight, int qrCodeWidth) throws WriterException,
			IOException {
		BitMatrix matrix = new MultiFormatWriter().encode(
				new String(qrCodeData.getBytes(charset), charset),
				BarcodeFormat.QR_CODE, qrCodeWidth, qrCodeHeight, hintMap);
		MatrixToImageWriter.writeToFile(matrix, filePath.substring(filePath
				.lastIndexOf('.') + 1), new File(filePath));
	}

	public static String readQRCode(String filePath, String charset,
			Map<DecodeHintType, String> hintMap)
			throws FileNotFoundException, IOException, NotFoundException {
		String resultString = "";
		
		// Read QR Code from image
		BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
				new BufferedImageLuminanceSource(
						ImageIO.read(new FileInputStream(filePath)))));
		Result qrCodeResult = new MultiFormatReader().decode(binaryBitmap,
				hintMap);
		
		// Include decoded text from QR Code
		resultString += "Text: " + qrCodeResult.getText() + ", ";
		
		// Included ResultPoint data from QR Code
		resultString += "ResultPoints: {";
		ResultPoint[] resultPoints = qrCodeResult.getResultPoints();
		for (int i = 0; i < resultPoints.length; i++) {
			resultString += resultPoints[i].toString() + ",";
		}
		resultString += "}, ";
		
		return resultString;
	}

}
