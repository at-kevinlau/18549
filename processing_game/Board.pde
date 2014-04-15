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
    stroke(0,0,0);
    fill(255,255,255);
    rect(this.x, this.y, this.w, this.h);
    
    for (Player e : players)
    {
      stroke(e.myColor);
      rect(this.x+e.x, this.y+e.y, PLAYER_SIZE, PLAYER_SIZE);
    }
  }
  
  boolean makeMove(float x, float y, Player currentPlayer)
  {
    currentPlayer.x = x;
    currentPlayer.y = y;
    return true;
  }
  
  Player checkWinner()
  {
    return null;
  }
  
  void update(int mX, int mY)
  {
  }
  void registerMClick(int mX, int mY)
  {
  }
  void registerMRelease(int mX, int mY)
  {
  }
}

