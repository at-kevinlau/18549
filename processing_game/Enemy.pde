class Enemy {
  color myColor;
  float x;
  float y;
  float xSpeed;
  float ySpeed;
  float circleSize;
  int xBoard;
  int yBoard;
  
  static final int ATTACK_RANGE = 100;
  
  public Enemy(int x, int y, float radius,int xBoard, int yBoard)
  {
    myColor = color(0,255,0);
    this.x = x;
    this.y = y;
    
    this.circleSize = radius;
    this.xSpeed = random(-10, 10);
    this.ySpeed = random(-10, 10);
    this.xBoard = xBoard;
    this.yBoard = yBoard;

  }
   
  void update() 
  {
    x += xSpeed;
    y += ySpeed; 
  }
   
  void checkCollisions() 
  {
     
    float r = circleSize/2;
     
    if ( (x<r) || (x>xBoard-r)){
      xSpeed = -xSpeed;
    } 
     
    if( (y<r) || (y>yBoard-r)) {
      ySpeed = -ySpeed; 
    }
     
  }
   
  void drawCircle() 
  {
     
    fill(255);
    ellipse(x, y, circleSize, circleSize);
     
  }

}
