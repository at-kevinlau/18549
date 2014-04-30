class Player
{
  color myColor;
  String myName;
  int x, y;
  int originalX, originalY;
  int lifePoints;
  
  static final int MOVE_RANGE = 100;
  
  public Player(color c, String n, int x, int y)
  {
    myColor = c;
    myName = n;
    this.x = x;
    this.y = y;
    this.lifePoints = 100;
    
    this.originalX = x;
    this.originalY = y;
  }
}
