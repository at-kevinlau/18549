package QRCodeTest;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
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
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

public class QRCodeTest {
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

	public static String readQRCodeString(String filePath, String charset,
			Map<DecodeHintType, String> hintMap) throws FileNotFoundException,
			IOException, NotFoundException {
		// Read QR Code from image
		BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
				new BufferedImageLuminanceSource(
						ImageIO.read(new FileInputStream(filePath)))));
		Result qrCodeResult = new MultiFormatReader().decode(binaryBitmap,
				hintMap);

		// Return decoded text from QR Code
		return qrCodeResult.getText();
	}

	public static float[] readQRCodeLocation(String filePath, String charset,
			Map<DecodeHintType, String> hintMap) throws FileNotFoundException,
			IOException, NotFoundException {
		// Initialize local variables
		float[] location = new float[2];

		// Read QR Code from image
		BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
				new BufferedImageLuminanceSource(
						ImageIO.read(new FileInputStream(filePath)))));
		Result qrCodeResult = new MultiFormatReader().decode(binaryBitmap,
				hintMap);

		// Read location data from QR Code
		location[0] = qrCodeResult.getResultPoints()[1].getX();
		location[1] = qrCodeResult.getResultPoints()[1].getY();

		return location;
	}

	public static float readQRCodeAngle(String filePath, String charset,
			Map<DecodeHintType, String> hintMap) throws FileNotFoundException,
			IOException, NotFoundException {
		// Initialize local variables
		float angle;
		float topLeftX, topLeftY;
		float topRightX, topRightY;

		// Read QR Code from image
		BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(
				new BufferedImageLuminanceSource(
						ImageIO.read(new FileInputStream(filePath)))));
		Result qrCodeResult = new MultiFormatReader().decode(binaryBitmap,
				hintMap);

		// Determine angle of QR Code
		topLeftX = qrCodeResult.getResultPoints()[1].getX();
		topLeftY = qrCodeResult.getResultPoints()[1].getY();
		topRightX = qrCodeResult.getResultPoints()[0].getX();
		topRightY = qrCodeResult.getResultPoints()[0].getY();
		angle = (float) Math.toDegrees(Math.atan2(topRightX - topLeftX,
				topRightY - topLeftY));

		return angle < 0 ? angle + 360 : angle;
	}

}
