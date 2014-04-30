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
    myColor = color(242,76,39);
    this.x = random(0,xBoard);
    this.y = random(0,yBoard);
    
    this.circleSize = radius;
    this.xSpeed = random(-10, 10);
    this.ySpeed = random(-10, 10);
    this.xBoard = xBoard;
    this.yBoard = yBoard;

  }
   
  boolean update(int dstX, int dstY) 
  {
     int speed = 50;
     x += (dstX-x)/speed;
     y += (dstY-y)/speed;
     int margin = 10;
     if (x < dstX + margin && x > dstX - margin 
     && y < dstY + margin && y > dstY - margin) {
       x= random(0,xBoard);
       y= random(0,yBoard);
       return true;
     }
     return false;
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
     
    fill(myColor);
    ellipse(x, y, circleSize, circleSize);
     
  }

  boolean block (float bx, float by, float br) 
  {
    if (abs(x-bx) < br && abs(y-by) < br) {
      x= random(0,xBoard);
      y= random(0,yBoard);
      return true;
    }
    return false;
  }
}
