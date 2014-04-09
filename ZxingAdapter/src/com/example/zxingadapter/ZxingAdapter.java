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
import com.google.zxing.ResultPoint;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.multi.qrcode.QRCodeMultiReader;

public class ZxingAdapter
{
	// Static vars
	private static final String CHARSET = "ISO-8859-1";
	private static final String TOPLEFT = "TOPLEFT";
	private static final String TOPRIGHT = "TOPRIGHT";
	private static final String BOTTOMLEFT = "BOTTOMLEFT";

	// Calibration vars
	private float sourceXMin;
	private float sourceYMin;
	private float sourceXMax;
	private float sourceYMax;
	private float sourceOriginX;
	private float sourceOriginY;
	private float calibrationRatioX;
	private float calibrationRatioY;
	private float calibrationAngle;

	/**
	 * Constructor for uncalibrated reader
	 */
	public ZxingAdapter()
	{
		decalibrate();
	}

	/**
	 * Constructor for calibrated reader (calibrate from file path)
	 * 
	 * @param filePath
	 * @param calibrationString
	 * @param targetWidth
	 * @param targetHeight
	 */
	public ZxingAdapter(String filePath, int targetWidth, int targetHeight)
	{
		calibrate(filePath, targetWidth, targetHeight);
	}

	/**
	 * Constructor for calibrated reader (calibrate from pixel array)
	 * 
	 * @param pixels
	 * @param width
	 * @param height
	 * @param calibrationString
	 * @param targetWidth
	 * @param targetHeight
	 */
	public ZxingAdapter(int[] pixels, int width, int height, int targetWidth,
			int targetHeight)
	{
		calibrate(pixels, width, height, targetWidth, targetHeight);
	}

	/**
	 * Calibrates reader from image file
	 * 
	 * @param filePath
	 * @param calibrationString
	 * @param targetWidth
	 * @param targetHeight
	 */
	public void calibrate(String filePath, int targetWidth, int targetHeight)
	{
		Bitmap bitmap = BitmapFactory.decodeFile(filePath);
		int[] pixels = new int[bitmap.getWidth() * bitmap.getHeight()];
		bitmap.getPixels(pixels, 0, bitmap.getWidth(), 0, 0, bitmap.getWidth(),
				bitmap.getHeight());

		calibrate(pixels, bitmap.getWidth(), bitmap.getHeight(), targetWidth,
				targetHeight);
	}

	/**
	 * Calibrates reader from bitmap
	 * 
	 * @param pixels
	 * @param width
	 * @param height
	 * @param calibrationString
	 * @param targetWidth
	 * @param targetHeight
	 */
	public void calibrate(int[] pixels, int width, int height, int targetWidth,
			int targetHeight)
	{
		boolean topLeftFound = false;
		boolean topRightFound = false;
		boolean bottomLeftFound = false;

		float topLeftX = 0;
		float topLeftY = 0;
		float topRightX = 0;
		float topRightY = 0;
		float bottomLeftX = 0;
		float bottomLeftY = 0;

		float sourceWidth;
		float sourceHeight;

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

			// Locate 3 calibration QR codes
			for (Result result : results)
			{
				if (result.getText().equals(TOPLEFT))
				{
					topLeftFound = true;
					topLeftX = result.getResultPoints()[1].getX();
					topLeftY = result.getResultPoints()[1].getY();
				}
				else if (result.getText().equals(TOPRIGHT))
				{
					topRightFound = true;
					topRightX = result.getResultPoints()[2].getX();
					topRightY = result.getResultPoints()[2].getY();
				}
				else if (result.getText().equals(BOTTOMLEFT))
				{
					bottomLeftFound = true;
					bottomLeftX = result.getResultPoints()[0].getX();
					bottomLeftY = result.getResultPoints()[0].getY();
				}
			}

			// If any calibration point was not found, decalibrate system and
			// terminate calibration
			if (!(topLeftFound && topRightFound && bottomLeftFound))
			{
				System.out.print("Calibration Failed - Missing ");
				if (!topLeftFound)
				{
					System.out.print(TOPLEFT + ", ");
				}
				if (!topRightFound)
				{
					System.out.print(TOPRIGHT + ", ");
				}
				if (!bottomLeftFound)
				{
					System.out.print(BOTTOMLEFT + ", ");
				}
				System.out.println();
				decalibrate();
				return;
			}

			// Determine source boundaries based on calibration points
			sourceXMin = Math.min(Math.min(topLeftX, topRightX), bottomLeftX);
			sourceXMax = Math.max(Math.max(topLeftX, topRightX), bottomLeftX);
			sourceYMin = Math.min(Math.min(topLeftY, topRightY), bottomLeftY);
			sourceYMax = Math.max(Math.max(topLeftY, topRightY), bottomLeftY);

			// Determine origin
			sourceOriginX = topLeftX;
			sourceOriginY = topLeftY;

			// Determine scaling ratios
			sourceWidth = (float) Math.sqrt(Math.pow((topLeftX - topRightX), 2)
					+ Math.pow((topLeftY - topRightY), 2));
			sourceHeight = (float) Math.sqrt(Math.pow((topLeftX - bottomLeftX),
					2) + Math.pow((topLeftY - bottomLeftY), 2));
			calibrationRatioX = targetWidth / sourceWidth;
			calibrationRatioY = targetHeight / sourceHeight;

			// Determine rotation angle
			calibrationAngle = (float) (Math.atan2(topRightY - topLeftY,
					topRightX - topLeftX));

			System.out.println("System calibrated - Origin@(" + sourceOriginX
					+ "," + sourceOriginY + "), XRatio:" + calibrationRatioX
					+ ", YRatio: " + calibrationRatioY + ", Angle:"
					+ calibrationAngle);

		}
		catch (Exception e)
		{
			e.printStackTrace();

			// Create uncalibrated reader
			decalibrate();
		}

	}

	/**
	 * Removes calibration from the system
	 */
	public void decalibrate()
	{
		System.out.println("System uncalibrated - Default calibration in use");
		sourceXMin = 0;
		sourceXMax = Float.POSITIVE_INFINITY;
		sourceYMin = 0;
		sourceYMax = Float.POSITIVE_INFINITY;
		sourceOriginX = 0;
		sourceOriginY = 0;
		calibrationRatioX = 1;
		calibrationRatioY = 1;
		calibrationAngle = 0;
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
	public QRCode readQRCode(String filePath)
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
	public QRCode readQRCode(int[] pixels, int width, int height)
	{
		return readMultipleQRCode(pixels, width, height)[0];
	}

	/**
	 * Decodes multiple QR codes from file
	 * 
	 * @param filePath
	 * @return
	 */
	public QRCode[] readMultipleQRCode(String filePath)
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
	public QRCode[] readMultipleQRCode(int[] pixels, int width, int height)
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
			List<QRCode> qrCodes = new ArrayList<QRCode>();
			String text;
			float sourceTopLeftX;
			float sourceTopLeftY;
			float sourceTopRightX;
			float sourceTopRightY;
			float sourceBottomLeftX;
			float sourceBottomLeftY;
			float[] topLeft;
			float[] topRight;
			float[] bottomLeft;
			float angle;

			readerLoop: for (int i = 0; i < results.length; i++)
			{
				// Get text
				text = results[i].getText();

				// If point is outside calibration area, skip
				for (ResultPoint point : results[i].getResultPoints())
				{
					if (point.getX() < sourceXMin || point.getX() > sourceXMax
							|| point.getY() < sourceYMin
							|| point.getY() > sourceYMax)
					{
						continue readerLoop;
					}
				}

				// Get source (x,y) position
				sourceTopLeftX = results[i].getResultPoints()[1].getX();
				sourceTopLeftY = results[i].getResultPoints()[1].getY();
				sourceTopRightX = results[i].getResultPoints()[2].getX();
				sourceTopRightY = results[i].getResultPoints()[2].getY();
				sourceBottomLeftX = results[i].getResultPoints()[0].getX();
				sourceBottomLeftY = results[i].getResultPoints()[0].getY();

				// Get scaled (x,y) position and angle
				topLeft = scalePoint(sourceTopLeftX, sourceTopLeftY);
				topRight = scalePoint(sourceTopRightX, sourceTopRightY);
				bottomLeft = scalePoint(sourceBottomLeftX, sourceBottomLeftY);
				angle = (float) Math.atan2(topRight[1] - topLeft[1],
						topRight[0] - topLeft[0]);

				// Create and save QRCode object
				qrCodes.add(new QRCode(text, topLeft[0], topLeft[1],
						topRight[0], topRight[1], bottomLeft[0], bottomLeft[1],
						angle));
			}

			// Return QRCode array
			return qrCodes.toArray(new QRCode[qrCodes.size()]);

		}
		catch (Exception e)
		{
			e.printStackTrace();
		}

		// Return size 0 array if reading failed
		return new QRCode[0];
	}

	public String readQRCodeString(String filePath)
	{
		return readQRCode(filePath).getText();
	}

	public String readQRCodeString(int[] pixels, int width, int height)
	{
		return readQRCode(pixels, width, height).getText();
	}

	public float[] readQRCodeLocation(String filePath)
	{
		float[] location = new float[2];
		QRCode qrCode = readQRCode(filePath);
		location[0] = qrCode.getCenterX();
		location[1] = qrCode.getCenterY();
		return location;
	}

	public float[] readQRCodeLocation(int[] pixels, int width, int height)
	{
		float[] location = new float[2];
		QRCode qrCode = readQRCode(pixels, width, height);
		location[0] = qrCode.getCenterX();
		location[1] = qrCode.getCenterY();
		return location;
	}

	public float readQRCodeAngle(String filePath)
	{
		return readQRCode(filePath).getAngle();
	}

	public float readQRCodeAngle(int[] pixels, int width, int height)
	{
		return readQRCode(pixels, width, height).getAngle();
	}

	/**
	 * Generate hint maps for reader
	 */
	private Map<DecodeHintType, Object> setupHintMap()
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
	 * Scales point to be on calibration target plane
	 * 
	 * @param sourcePointX
	 * @param sourcePointY
	 * @return
	 */
	private float[] scalePoint(float sourcePointX, float sourcePointY)
	{
		float[] targetPoint = new float[2];
		
		float rotatedPointX = (float) ((sourcePointX - sourceOriginX)
				* Math.cos(calibrationAngle) + (sourcePointY - sourceOriginY)
				* Math.sin(calibrationAngle));
		float rotatedPointY = (float) (-(sourcePointX - sourceOriginX)
				* Math.sin(calibrationAngle) + (sourcePointY - sourceOriginY)
				* Math.cos(calibrationAngle));
		
		targetPoint[0] = rotatedPointX * calibrationRatioX;
		targetPoint[1] = rotatedPointY * calibrationRatioY;

		return targetPoint;
	}
}
