package com.example.zxingadapter;

import android.os.Bundle;
import android.os.Environment;
import android.app.Activity;
import android.view.Menu;
import android.widget.TextView;

public class MainActivity extends Activity
{

	@Override
	protected void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		// Retrieve string
		String message = getQRCodeTestString();

		// Create the text view
		TextView textView = new TextView(this);
		textView.setText(message);

		// Set text view as activity layout
		setContentView(textView);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu)
	{
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	private String getQRCodeTestString()
	{
		String outString = "";
		ZxingAdapter reader = new ZxingAdapter();
		QRCode[] qrCodes = reader.readMultipleQRCode(Environment
				.getExternalStorageDirectory() + "/Team14.png");

		for (QRCode qrCode : qrCodes)
		{
			outString += qrCode + "\n";
		}
		
		return outString;
	}
}
