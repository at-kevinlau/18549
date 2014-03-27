package com.example.zxingadapter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.LuminanceSource;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.multi.qrcode.QRCodeMultiReader;
import com.google.zxing.qrcode.QRCodeReader;

public class ZxingAdapter
{
	private static final String CHARSET = "ISO-8859-1";

	/**
	 * Generate hint maps for readers and writers
	 */
	private static Map<DecodeHintType, Object> setupHintMap()
	{
		// Character Set
		Map<DecodeHintType, Object> decodeHintMap = new HashMap<DecodeHintType, Object>();
		decodeHintMap.put(DecodeHintType.CHARACTER_SET, CHARSET);

		// Formats
		List<BarcodeFormat> possibleFormats = new ArrayList<BarcodeFormat>();
		possibleFormats.add(BarcodeFormat.QR_CODE);
		decodeHintMap.put(DecodeHintType.POSSIBLE_FORMATS, possibleFormats);

		return decodeHintMap;
	}

	/**
	 * Decodes QR code data from image file
	 * 
	 * @param filePath
	 *            Location to load QR code image file.
	 * @param decodeHintMap
	 *            Hint map to assist decoding QR code.
	 * @return Result containing QR code data read from the image file.
	 */
	public static QRCode readQRCode(String filePath)
	{
		// Get pixel array from image file
		Bitmap bitmap = BitmapFactory.decodeFile(filePath);
		int[] pixels = new int[bitmap.getWidth() * bitmap.getHeight()];
		bitmap.getPixels(pixels, 0, bitmap.getWidth(), 0, 0, bitmap.getWidth(),
				bitmap.getHeight());

		return readQRCode(pixels, bitmap.getWidth(), bitmap.getHeight());
	}

	/**
	 * Decodes QR code from pixel array
	 * 
	 * @param pixels
	 * @param width
	 * @param height
	 * @param decodeHintMap
	 * @return
	 */
	public static QRCode readQRCode(int[] pixels, int width, int height)
	{
		// Initialize hintMap
		Map<DecodeHintType, Object> decodeHintMap = setupHintMap();

		// Convert pixel array to BinaryBitmap
		LuminanceSource source = new RGBLuminanceSource(width, height, pixels);
		BinaryBitmap binaryBitmap = new BinaryBitmap(
				new HybridBinarizer(source));

		try
		{
			// Decode results using zxing
			Result result = new QRCodeReader().decode(binaryBitmap,
					decodeHintMap);

			// Use Results array to create QRCode array
			String text;
			float topLeftX, topLeftY;
			float topRightX, topRightY;
			float angle;

			// Get text
			text = result.getText();

			// Get (x,y) position and angle
			topLeftX = result.getResultPoints()[1].getX();
			topLeftY = result.getResultPoints()[1].getY();
			topRightX = result.getResultPoints()[0].getX();
			topRightY = result.getResultPoints()[0].getY();
			angle = (float) Math.toDegrees(Math.atan2(topRightX - topLeftX,
					topRightY - topLeftY));

			// Create and save QRCode object
			return new QRCode(text, topLeftX, topLeftY, angle);
		} catch (Exception e)
		{
			e.printStackTrace();
		}

		// Return size 0 array if reading failed
		return null;
	}

	/**
	 * Decodes multiple QR codes from file
	 * 
	 * @param filePath
	 * @return
	 */
	public static QRCode[] readMultipleQRCode(String filePath)
	{
		// Get pixel array from image file
		Bitmap bitmap = BitmapFactory.decodeFile(filePath);
		int[] pixels = new int[bitmap.getWidth() * bitmap.getHeight()];
		bitmap.getPixels(pixels, 0, bitmap.getWidth(), 0, 0, bitmap.getWidth(),
				bitmap.getHeight());

		return readMultipleQRCode(pixels, bitmap.getWidth(), bitmap.getHeight());
	}

	/**
	 * Decodes multiple QR codes from pixel array
	 * 
	 * @param pixels
	 * @param width
	 * @param height
	 * @param decodeHintMap
	 * @return
	 */
	public static QRCode[] readMultipleQRCode(int[] pixels, int width,
			int height)
	{
		// Initialize hintMap
		Map<DecodeHintType, Object> decodeHintMap = setupHintMap();

		// Convert pixel array to BinaryBitmap
		LuminanceSource source = new RGBLuminanceSource(width, height, pixels);
		BinaryBitmap binaryBitmap = new BinaryBitmap(
				new HybridBinarizer(source));

		try
		{
			// Decode results using zxing
			Result[] results = new QRCodeMultiReader().decodeMultiple(
					binaryBitmap, decodeHintMap);

			// Use Results array to create QRCode array
			QRCode[] qrCodes = new QRCode[results.length];
			String text;
			float topLeftX, topLeftY;
			float topRightX, topRightY;
			float angle;

			for (int i = 0; i < results.length; i++)
			{
				// Get text
				text = results[i].getText();

				// Get (x,y) position and angle
				topLeftX = results[i].getResultPoints()[1].getX();
				topLeftY = results[i].getResultPoints()[1].getY();
				topRightX = results[i].getResultPoints()[0].getX();
				topRightY = results[i].getResultPoints()[0].getY();
				angle = (float) Math.toDegrees(Math.atan2(topRightX - topLeftX,
						topRightY - topLeftY));
				if (angle < 0)
				{
					angle += 360;
				}

				// Create and save QRCode object
				qrCodes[i] = new QRCode(text, topLeftX, topLeftY, angle);
			}

			// Return QRCode array
			return qrCodes;

		} catch (Exception e)
		{
			e.printStackTrace();
		}

		// Return size 0 array if reading failed
		return new QRCode[0];
	}

	public static String readQRCodeString(String filePath)
	{
		return readQRCode(filePath).getText();
	}

	public static String readQRCodeString(int[] pixels, int width, int height)
	{
		return readQRCode(pixels, width, height).getText();
	}

	public static float[] readQRCodeLocation(String filePath)
	{
		float[] location = new float[2];
		QRCode qrCode = readQRCode(filePath);
		location[0] = qrCode.getX();
		location[1] = qrCode.getY();
		return location;
	}

	public static float[] readQRCodeLocation(int[] pixels, int width, int height)
	{
		float[] location = new float[2];
		QRCode qrCode = readQRCode(pixels, width, height);
		location[0] = qrCode.getX();
		location[1] = qrCode.getY();
		return location;
	}

	public static float readQRCodeAngle(String filePath)
	{
		return readQRCode(filePath).getAngle();
	}

	public static float readQRCodeAngle(int[] pixels, int width, int height)
	{
		return readQRCode(pixels, width, height).getAngle();
	}
}
