package com.example.zxingadapter;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.EncodeHintType;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.NotFoundException;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

public class ZxingAdapter {
	private static final String CHARSET = "ISO-8859-1";
	private static Map<EncodeHintType, Object> encodeHintMap;
	private static Map<DecodeHintType, Object> decodeHintMap;

	private static void setupHintMaps() {
		encodeHintMap = new HashMap<EncodeHintType, Object>();
		encodeHintMap.put(EncodeHintType.ERROR_CORRECTION,
				ErrorCorrectionLevel.L);

		decodeHintMap = new HashMap<DecodeHintType, Object>();
		decodeHintMap.put(DecodeHintType.CHARACTER_SET, CHARSET);
	}

	private static Result readQRCode(String filePath,
			Map<DecodeHintType, Object> decodeHintMap) throws NotFoundException {
		/*
		 * JAVA IMPL, REMOVE ONCE WORKING ANDROID IMPL CONFIRMED BinaryBitmap
		 * binaryBitmap = new BinaryBitmap(new HybridBinarizer( new
		 * BufferedImageLuminanceSource( ImageIO.read(new
		 * FileInputStream(filePath)))));
		 */
		Bitmap bitmap = BitmapFactory.decodeFile(filePath);
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.PNG, 50, stream);
		byte[] byteArray = stream.toByteArray();
		LuminanceSource source = new PlanarYUVLuminanceSource(byteArray,
				bitmap.getWidth(), bitmap.getHeight(), 0, 0, bitmap.getWidth(),
				bitmap.getHeight(), false);
		BinaryBitmap binaryBitmap = new BinaryBitmap(
				new HybridBinarizer(source));

		return new MultiFormatReader().decode(binaryBitmap, decodeHintMap);
	}

	public static void createQRCode(String qrCodeData, String filePath,
			int qrCodeHeight, int qrCodeWidth) throws WriterException,
			IOException {
		// Setup hint maps
		setupHintMaps();

		// Write QR code
		BitMatrix matrix = new MultiFormatWriter()
				.encode(new String(qrCodeData.getBytes(CHARSET), CHARSET),
						BarcodeFormat.QR_CODE, qrCodeWidth, qrCodeHeight,
						encodeHintMap);
		MatrixToImageWriter.writeToFile(matrix, filePath.substring(filePath
				.lastIndexOf('.') + 1), new File(filePath));
	}

	public static String readQRCodeString(String filePath)
			throws FileNotFoundException, IOException, NotFoundException {
		// Setup hint maps
		setupHintMaps();

		// Read QR Code from image
		Result qrCodeResult = readQRCode(filePath, decodeHintMap);

		// Return decoded text from QR Code
		return qrCodeResult.getText();
	}

	public static float[] readQRCodeLocation(String filePath)
			throws FileNotFoundException, IOException, NotFoundException {
		// Setup hint maps
		setupHintMaps();

		// Initialize local variables
		float[] location = new float[2];

		// Read QR Code from image
		Result qrCodeResult = readQRCode(filePath, decodeHintMap);

		// Read location data from QR Code
		location[0] = qrCodeResult.getResultPoints()[1].getX();
		location[1] = qrCodeResult.getResultPoints()[1].getY();

		return location;
	}

	public static float readQRCodeAngle(String filePath)
			throws FileNotFoundException, IOException, NotFoundException {
		// Setup hint maps
		setupHintMaps();

		// Initialize local variables
		float angle;
		float topLeftX, topLeftY;
		float topRightX, topRightY;

		// Read QR Code from image
		Result qrCodeResult = readQRCode(filePath, decodeHintMap);

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
