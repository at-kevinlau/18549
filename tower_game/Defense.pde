class Defense {
  color myColor;
  float x;
  float y;
  float circleSize;
  int xBoard;
  int yBoard;
  int strength;
  
  static final int ATTACK_RANGE = 100;
  
  public Defense(int x, int y, int xBoard, int yBoard)
  {
    myColor = color(3,126,140);
    this.x = x;
    this.y = y;
    this.strength = 3;
    
    this.circleSize = 30;
    this.xBoard = xBoard;
    this.yBoard = yBoard;

  }
   
  void update(Enemy[] enemyArray) 
  {
    float r = circleSize/2;
     
    for(int i=0; i<enemyArray.length; i++) {
      if (enemyArray[i].block(x,y,r)) {
        strength--;
      }
    }
    
  }
  
  int strength() {
    return strength;
  }
   
  void drawCircle() 
  {
     
    fill(myColor);
    ellipse(x, y, circleSize, circleSize);
     
  }

}
