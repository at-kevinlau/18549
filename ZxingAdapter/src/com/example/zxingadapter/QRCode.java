package com.example.zxingadapter;

public class QRCode {
	private final String text;
	private final float xPos;
	private final float yPos;
	private final float angle;
	
	public QRCode(String text, float xPos, float yPos, float angle) {
		this.text = text;
		this.xPos = xPos;
		this.yPos = yPos;
		this.angle = angle;
	}
	
	public String getText() {
		return text;
	}
	
	public float getX() {
		return xPos;
	}
	
	public float getY() {
		return yPos;
	}
	
	public float getAngle() {
		return angle;
	}
	
	@Override
	public String toString() {
		return text + "(" + xPos + "," + yPos + "," + angle + ")";
	}
}
