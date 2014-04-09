package com.example.zxingadapter;

public class QRCode
{
	private final String text;
	private final float topLeftX;
	private final float topLeftY;
	private final float topRightX;
	private final float topRightY;
	private final float bottomLeftX;
	private final float bottomLeftY;
	private final float angle;

	public QRCode(String text, float topLeftX, float topLeftY, float topRightX,
			float topRightY, float bottomLeftX, float bottomLeftY, float angle)
	{
		this.text = text;
		this.topLeftX = topLeftX;
		this.topLeftY = topLeftY;
		this.topRightX = topRightX;
		this.topRightY = topRightY;
		this.bottomLeftX = bottomLeftX;
		this.bottomLeftY = bottomLeftY;
		this.angle = angle;
	}

	public String getText()
	{
		return text;
	}

	public float getTopLeftX()
	{
		return topLeftX;
	}

	public float getTopLeftY()
	{
		return topLeftY;
	}

	public float getTopRightX()
	{
		return topRightX;
	}

	public float getTopRightY()
	{
		return topRightY;
	}

	public float getBottomLeftX()
	{
		return bottomLeftX;
	}

	public float getBottomLeftY()
	{
		return bottomLeftY;
	}

	public float getCenterX()
	{
		return (bottomLeftX + topRightX) / 2;
	}

	public float getCenterY()
	{
		return (bottomLeftY + topRightY) / 2;
	}

	public float getWidth()
	{
		return distance(topLeftX, topLeftY, topRightX, topRightY);
	}

	public float getHeight()
	{
		return distance(topLeftX, topLeftY, bottomLeftX, bottomLeftY);
	}

	public float getAngle()
	{
		return angle;
	}

	@Override
	public String toString()
	{
		return text + "(" + getCenterX() + "," + getCenterY() + "," + angle
				+ ")";
	}

	private float distance(float x1, float y1, float x2, float y2)
	{
		return (float) Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2));
	}
}
