package processing.test.androidprocessingexample;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.util.DisplayMetrics; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class androidprocessingexample extends PApplet {

 
float heightPixels;
float widthPixels;
float rotation;
String s;
public void setup() {
 
  DisplayMetrics dm = new DisplayMetrics(); 
  getWindowManager().getDefaultDisplay().getMetrics(dm);
  rotation = 0;
  heightPixels = dm.heightPixels;
  widthPixels = dm.widthPixels;
  s = "Dimensions: (" + widthPixels + ", " + heightPixels + ")" ;
}

public void draw() {
  background(0xffFF9900);
  stroke(0);
  fill(175);
  rotation+=0.05f;
  
  // Translate origin to center
  translate(width/2,height/2);
  
  // The greek letter, theta, is often used as the name of a variable to store an angle
  // The angle ranges from 0 to PI, based on the ratio of mouseX location to the sketch's width.
  float theta = PI*mouseX / width; 
  
  // Rotate by the angle theta
  rotate(rotation);
  
  // Display rectangle with CENTER mode
  rectMode(CENTER);
  rect(0,0,100,150);
  
  fill(50);
  text(s, 10, 10, 70, 80);  // Text wraps within text box
}

  public int sketchWidth() { return 480; }
  public int sketchHeight() { return 800; }
}
