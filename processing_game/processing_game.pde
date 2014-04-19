import SimpleOpenNI.*;
import ZxingAdapter.ZxingAdapter;
import ZxingAdapter.QRCode;

// ----- Constants -----
final int WINDOW_WIDTH = 1920;
final int WINDOW_HEIGHT = 1080;
// State Constants
final int  START_MENU = 0;
final int  CALIBRATION = 1;
final int  GAME = 2;

// ----- Globals -----
// System globals
SimpleOpenNI kinect;
int state = START_MENU;
int offsetX, offsetY, gameWidth, gameHeight = -1;
boolean isCalibrated = false;
ZxingAdapter zxing;
QRCode qrs[];

// Game globals
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
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();
  zxing = new ZxingAdapter();
  
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
  fill(255);
  updateQRs();
  switch(state) {
  case START_MENU:
    scale(-1.0, 1.0);
    image(kinect.rgbImage(), -width,0, width, height);
    break;
  case CALIBRATION:
    background(0);
    fill(0);
    stroke(204, 102, 0);
    strokeWeight(5);
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth == -1) && (gameHeight == -1)) {
      ellipse(offsetX,offsetY,100, 100);
    }
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
      translate(offsetX, offsetY);
      rect(0,0,gameWidth,gameHeight);
      translate(-offsetX, -offsetY);
    }
    break;
  case GAME:
    update(mouseX, mouseY);
    if ((qrs != null) && (qrs.length > 0)) {
      inputRelease((int)(qrs[0].getCenterX()), (int)(qrs[0].getCenterY()));
    }
    renderGame();
    break;
  default:
    print("Incorrect State: " + state);
    break;
  }
}

void updateQRs() {
  kinect.update();
  kinect.rgbImage().loadPixels();
    if (zxing != null) {
      try {
        QRCode newQrs[] = zxing.readMultipleQRCode(kinect.rgbImage().pixels, kinect.rgbImage().width, kinect.rgbImage().height);
        if ((newQrs != null) && (newQrs.length > 0)) { 
          qrs = newQrs;
          if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
            if ((!isCalibrated) && (qrs.length == 3) && (!qrs[0].getText().equals(qrs[1].getText())) && (!qrs[1].getText().equals(qrs[2].getText()))) {
              zxing.calibrate(kinect.rgbImage().pixels, kinect.rgbImage().width, kinect.rgbImage().height, gameWidth, gameHeight, offsetX, offsetY);
              isCalibrated = true;
              print("Calibration complete!");
            }
            if ((!isCalibrated) && (qrs.length < 3)) {
              print(qrs.length + " qr codes$");
            }
          }
        }
      } catch (Exception ex) {
        print("failed to read:" + ex);
      }
    }
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

void makeMove(int x, int y)
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
  
  /*
  Player possibleWinner = board.checkWinner();
  if (possibleWinner != null)
  {
    gameOver = true;
    winner = possibleWinner;
  } else
  {
    advanceCurrentPlayer();
  }
  */
}
void advanceCurrentPlayer()
{
  currentPlayer.originalX = currentPlayer.x;
  currentPlayer.originalY = currentPlayer.y;
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
  background(100);
  
  rectMode(CORNER);

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
  switch(state) {
  case START_MENU:
    state = CALIBRATION;
    print("State: " + state);
    isCalibrated = false;
    offsetX = -1;
    offsetY = -1;
    gameWidth = -1;
    gameHeight = -1;
    break;
  case CALIBRATION:
    if ((offsetX == -1) && (offsetY == -1)) {
      offsetX = mouseX;
      offsetY = mouseY;
    } else if ((gameWidth == -1) && (gameHeight == -1)) {
      gameWidth = mouseX - offsetX;
      gameHeight = mouseY - offsetY;
      print("Waiting for 3 QR Codes...");
    } else {
      state = GAME;
      print("State: " + state); 
    }
    break;
  case GAME:
    inputPressed(mouseX, mouseY);
  default:
    print("Incorrect State: " + state);
    break;
  }
}
void mouseReleased()
{
  inputRelease(mouseX, mouseY);
}

void inputPressed(int inX, int inY)
{
  if (!gameOver)
  {
    for (Updatable u : updatables)
    {
      u.registerMClick(inX, inY, currentPlayer);
    }
  } else
  {
    resetGame();
  }
}

void inputRelease(int inX, int inY)
{
  if (!gameOver)
  {
    for (Updatable u : updatables)
    {
      u.registerMRelease(inX, inY, currentPlayer);
    }
    makeMove(inX, inY);
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

