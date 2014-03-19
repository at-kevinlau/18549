
String s;

void setup() {
size(480,800);
smooth();
fill(255);
stroke(255);
rectMode(CENTER);
s = "fasdfasdfasdf" ;
}

void draw(){
background(mouseY * (255.0/800), 100, 0);

//Draw the ball-and-stick
fill(255);
line(width/2, height/2, mouseX, mouseY);
ellipse(mouseX, mouseY, 40, 40);

pushMatrix();
translate(width/2, height/2);
rect(0,0, 150, 150);
popMatrix();

fill(50);
  text(s, 10, 10, 70, 80);  // Text wraps within text box
}
