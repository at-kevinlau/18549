package com.example.zxingadapter;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Environment;

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
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

public class ZxingAdapter {
	private static final String CHARSET = "ISO-8859-1";
	private static Map<EncodeHintType, Object> encodeHintMap;
	private static Map<DecodeHintType, Object> decodeHintMap;

	/**
	 * Writes an image file containing the encoded QR code data.
	 * 
	 * @param qrCodeData
	 *            Data to be encoded into QR code.
	 * @param filePath
	 *            Location to save QR code image file.
	 * @param qrCodeHeight
	 *            Height of QR code image file.
	 * @param qrCodeWidth
	 *            Width of QR code image file.
	 * @throws WriterException
	 * @throws IOException
	 */
	public static void createQRCode(String qrCodeData, String filePath,
			int qrCodeHeight, int qrCodeWidth) throws IOException,
			WriterException {
		// Setup hint maps
		setupHintMaps();

		// Write QR code
		BitMatrix matrix = new MultiFormatWriter()
				.encode(new String(qrCodeData.getBytes(CHARSET), CHARSET),
						BarcodeFormat.QR_CODE, qrCodeWidth, qrCodeHeight,
						encodeHintMap);

		// Write BitMatrix to Bitmap
		int bitmapHeight = matrix.getHeight();
		int bitmapWidth = matrix.getWidth();
		Bitmap bitmap = Bitmap.createBitmap(bitmapWidth, bitmapHeight,
				Bitmap.Config.RGB_565);
		for (int x = 0; x < bitmapWidth; x++) {
			for (int y = 0; y < bitmapHeight; y++) {
				bitmap.setPixel(x, y, matrix.get(x, y) ? Color.BLACK
						: Color.WHITE);
			}
		}

		// Determine save location
		String sdCardDirectory = Environment.getExternalStorageDirectory()
				.toString();
		File image = new File(sdCardDirectory + "/qrcode.png");

		// Encode the file as a PNG image and save the image
		FileOutputStream outStream = new FileOutputStream(image);

		bitmap.compress(Bitmap.CompressFormat.PNG, 100, outStream);
		outStream.flush();
		outStream.close();

	}

	/**
	 * Reads encoded data from QR code.
	 * 
	 * @param filePath
	 *            Location to load QR code image file
	 * @return String encoded in QR code
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws NotFoundException
	 */
	public static String readQRCodeString(String filePath)
			throws FileNotFoundException, IOException, NotFoundException {
		// Setup hint maps
		setupHintMaps();

		// Read QR Code from image
		Result qrCodeResult = readQRCode(filePath, decodeHintMap);

		// Return decoded text from QR Code
		return qrCodeResult.getText();
	}

	/**
	 * Reads (x,y) location of top left corner of QR code in image file from QR
	 * code.
	 * 
	 * @param filePath
	 *            Location to load QR code image file
	 * @return Array containing (x,y) location of top left corner of QR code.
	 *         Index 0 stores x. Index 1 stores y.
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws NotFoundException
	 */
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

	/**
	 * Reads angle of QR code image file. Normal viewing of QR code is 0
	 * degrees. Angle is measured counter-clockwise up to 360 degrees.
	 * 
	 * @param filePath
	 *            Location to load QR code image file
	 * @return Angle of QR code in image file
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws NotFoundException
	 */
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

	/**
	 * Generate hint maps for readers and writers
	 */
	private static void setupHintMaps() {
		encodeHintMap = new HashMap<EncodeHintType, Object>();
		encodeHintMap.put(EncodeHintType.ERROR_CORRECTION,
				ErrorCorrectionLevel.L);

		decodeHintMap = new HashMap<DecodeHintType, Object>();
		decodeHintMap.put(DecodeHintType.CHARACTER_SET, CHARSET);
	}

	/**
	 * Reads an image file to produce QR code data
	 * 
	 * @param filePath
	 *            Location to load QR code image file.
	 * @param decodeHintMap
	 *            Hint map to assist decoding QR code.
	 * @return Result containing QR code data read from the image file.
	 * @throws NotFoundException
	 */
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

}
