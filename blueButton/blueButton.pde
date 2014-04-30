boolean isBlue = false;

void setup() {
  size(640,480);
}

void draw() {
  if (isBlue){
    background(0,0,255);
  } else {
    background(0,0,0);
  }
  fill(0,255,0);
  rect(100,100,100,100);
}

boolean pressButton(float[] clicks){
  for (int i = 0; i < clicks.length; i++) {
    boolean isIn = true;
    if ((clicks[i] < 100) || (clicks[i] > 200)) isIn = false;
    i++;
    if ((clicks[i] < 100) || (clicks[i] > 200)) isIn = false;
    if (isIn) return true;
  }
  return false;
}

void mousePressed() {
  float[] clicks = new float[2];
  clicks[0] = mouseX;
  clicks[1] = mouseY;
  if (pressButton(clicks)) isBlue = !isBlue;
}
