class Board implements Renderable, Updatable
{
  private int x,y,w,h;
  private ArrayList<Player> players;
  
  private int PLAYER_SIZE = 50;
  
  Board(int x, int y, int w, int h)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    players = new ArrayList<Player>();
  }
  
  void addPlayer(Player p)
  {
    players.add(p);
  }
  
  void render()
  {
    rectMode(CORNER);
    stroke(0,0,0);
    fill(255,255,255);
    rect(this.x, this.y, this.w, this.h);
    
    rectMode(CENTER);
    for (Player e : players)
    {
      stroke(e.myColor);
      rect(this.x+e.x, this.y+e.y, PLAYER_SIZE, PLAYER_SIZE);
      fill(0,0,0,0);
      ellipse(this.x+e.originalX, this.y+e.originalY, Player.MOVE_RANGE*2, Player.MOVE_RANGE*2);
    }
  }
  
  boolean makeMove(int x, int y, Player currentPlayer)
  {
    int targetX = x - this.x;
    int targetY = y - this.y;
    System.out.println(dist(currentPlayer.originalX, currentPlayer.originalY, targetX, targetY));
    if (dist(currentPlayer.originalX, currentPlayer.originalY, targetX, targetY) <= Player.MOVE_RANGE)
    {
      currentPlayer.x = targetX;
      currentPlayer.y = targetY;
      return true;
    }
    return false;
  }
  
  Player checkWinner()
  {
    return null;
  }
  
  void update(int mX, int mY)
  {
  }
  void registerMClick(int mX, int mY, Player currentPlayer)
  {
  }
  void registerMRelease(int mX, int mY, Player currentPlayer)
  {
  }
}

