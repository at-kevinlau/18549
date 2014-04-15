final int WINDOW_WIDTH = 800;
final int WINDOW_HEIGHT = 600;

// All game objects that can be drawn
ArrayList<Renderable> renderables;
// All game objects that can be interacted with (with the mouse)
ArrayList<Updatable> updatables;

ArrayList<Player> players;

Player currentPlayer;
int currentPlayerIndex;

boolean gameOver;
Player winner;

Board board;

void setup()
{
  // Display/core init
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  renderables = new ArrayList<Renderable>();
  updatables = new ArrayList<Updatable>();
  
  /*
   * Game init
   */
  players = new ArrayList<Player>();
  players.add(new Player(color(255,0,0), "Red", 50, 100));
  players.add(new Player(color(0,0,255), "Blue", 100, 50));
  
  currentPlayerIndex = 0;
  currentPlayer = players.get(currentPlayerIndex);
  resetGame();
  
  /*
   * GUI
   */
  // Next turn button
  Button nextTurnButton = new Button(w_percent(.80),h_percent(.79),w_percent(.18),h_percent(.08),"Next turn")
  {
    public void onReleaseAction()
    {
      advanceCurrentPlayer();
    }
  };
  renderables.add(nextTurnButton);
  updatables.add(nextTurnButton);
  
  // Reset button
  Button resetButton = new Button(w_percent(.80),h_percent(.89),w_percent(.18),h_percent(.08),"Reset")
  {
    public void onReleaseAction()
    {
      resetGame();
    }
  };
  renderables.add(resetButton);
  updatables.add(resetButton);
}

void draw()
{
  update(mouseX, mouseY);
  renderGame();
}

void update(int mX, int mY)
{
  if (!gameOver)
  {
    for (Updatable u : updatables)
    {
      u.update(mX, mY);
    }
    // board isn't in the update list
    board.update(mX, mY);
  }
}

void makeMove(float x, float y)
{
  if (gameOver)
  {
    return;
  }
  if (!board.makeMove(x, y, currentPlayer))
  {
    // failed to move
    return;
  }
  
  Player possibleWinner = board.checkWinner();
  if (possibleWinner != null)
  {
    gameOver = true;
    winner = possibleWinner;
  } else
  {
    advanceCurrentPlayer();
  }
}
void advanceCurrentPlayer()
{
  currentPlayerIndex = (currentPlayerIndex + 1) % players.size();
  currentPlayer = players.get(currentPlayerIndex);
}

void resetGame()
{
  currentPlayerIndex = 0;
  currentPlayer = players.get(currentPlayerIndex);
  gameOver = false;
  winner = null;
  createBoard();
}

void createBoard()
{
  // Board
  board = new Board(w_percent(.02), h_percent(.02), w_percent(.76), h_percent(.96));
  for (Player p : players)
  {
    board.addPlayer(p);
  }
}

void renderGame()
{
  smooth();
  background(255,255,255);

  for (Renderable r : renderables)
  {
    r.render();
  }
  // board isn't in the render list
  board.render();
  
  // show turn info
  fill(currentPlayer.myColor);
  stroke(0,0,0);
  textSize(60);
  textAlign(CENTER, CENTER);
  text(currentPlayer.myName +"'s", w_percent(.89), h_percent(.05));
  fill(0,0,0);
  stroke(0,0,0);
  textSize(50);
  text("turn", w_percent(.89), h_percent(.14));

  if (gameOver)
  {
    fill(0,0,0,190);
    stroke(0,0,0);
    rect(0,0,w_percent(1), h_percent(1));
    
    fill(255,255,255);
    textSize(100);
    textAlign(CENTER, CENTER);
    text("Game over!", w_percent(.5), h_percent(.35));
    if (winner != null)
    {
      fill(winner.myColor);
      text(winner.myName + " wins!", w_percent(.5), h_percent(.55));
    } else
    {
      text("Tie game!", w_percent(.5), h_percent(.55));
    }
    fill(255,255,255);
    textSize(40);
    text("Click anywhere to reset", w_percent(.5), h_percent(.9));
  }
}

/*
 * Input/events
 */

void mousePressed()
{
  if (!gameOver)
  {
    for (Updatable u : updatables)
    {
      u.registerMClick(mouseX, mouseY);
    }
  } else
  {
    resetGame();
  }
}
void mouseReleased()
{
  if (!gameOver)
  {
    for (Updatable u : updatables)
    {
      u.registerMRelease(mouseX, mouseY);
    }
  } else
  {
    resetGame();
  }
}


/*
 * Util methods
 */

/*
 * Return a number of pixels equal to the given percentage of the screen width/height
 */
int w_percent(float percent)
{
  return (int) (percent * WINDOW_WIDTH);
}
int h_percent(float percent)
{
  return (int) (percent * WINDOW_HEIGHT);
}

