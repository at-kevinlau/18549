package ZxingAdapterTest;

import java.util.HashMap;
import java.util.Map;

import ZxingAdapter.ZxingAdapter;
import ZxingAdapter.QRCode;

import com.google.zxing.DecodeHintType;
import com.google.zxing.EncodeHintType;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

public class ZxingAdapterTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String qrCodeData = "BOTTOMLEFT";
		String filePath = qrCodeData + ".png";
		String charset = "ISO-8859-1";
		Map<EncodeHintType, ErrorCorrectionLevel> encodeHintMap = new HashMap<EncodeHintType, ErrorCorrectionLevel>();
		encodeHintMap.put(EncodeHintType.ERROR_CORRECTION,
				ErrorCorrectionLevel.L);
		Map<DecodeHintType, String> decodeHintMap = new HashMap<DecodeHintType, String>();
		decodeHintMap.put(DecodeHintType.CHARACTER_SET, charset);
		ZxingAdapter adapter = new ZxingAdapter();
		
		
		// Create a QR code image file
		try {
			adapter.createQRCode(qrCodeData, filePath, charset, encodeHintMap, 200, 200);
		} catch (Exception e) {
			e.printStackTrace();
		}
		System.out.println("QR Code Image created successfully");
		
		// Read the QR code image file
		QRCode[] qrCodes = adapter.readMultipleQRCode(filePath);
		for (QRCode qrCode : qrCodes) {
			System.out.println(qrCode);
		}
	}

}
