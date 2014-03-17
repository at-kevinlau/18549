package processing.test.androidprocessingexample;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class androidprocessingexample extends PApplet {

public void setup() {
 
  noStroke();
  fill(255);
  rectMode(CENTER);     // This sets all rectangles to draw from the center point
}

public void draw() {
  background(0xffFF9900);
  rect(width/2, height/2, 150, 150);
}

  public int sketchWidth() { return 480; }
  public int sketchHeight() { return 800; }
}
