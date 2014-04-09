import android.util.DisplayMetrics; 
float heightPixels;
float widthPixels;
float rotation;
String s;
void setup() {
  size(480,800);
  DisplayMetrics dm = new DisplayMetrics(); 
  getWindowManager().getDefaultDisplay().getMetrics(dm);
  rotation = 0;
  heightPixels = dm.heightPixels;
  widthPixels = dm.widthPixels;
  s = "Dimensions: (" + widthPixels + ", " + heightPixels + ")" ;
}

void draw() {
  background(#FF9900);
  stroke(0);
  fill(175);
  rotation+=0.05;
  
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
