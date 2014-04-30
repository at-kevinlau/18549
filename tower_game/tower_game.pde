import org.openkinect.*;
import org.openkinect.processing.*;
import ZxingAdapter.ZxingAdapter;
import ZxingAdapter.QRCode;

final boolean KINECT = false;

// ----- Constants -----
final int WINDOW_WIDTH = 640;
final int WINDOW_HEIGHT = 480;
// State Constants
final int  START_MENU = 0;
final int  CALIBRATION = 1;
final int  GAME = 2;
final int  FORWARD = 3;
final int  STOP = 4;
final int  DEFENSE = 5;

// ----- Globals -----
// System globals
Kinect kinect;
int state = GAME;
//int state = START_MENU;
int offsetX, offsetY, gameWidth, gameHeight = -1;
float[] calibrationPoints = new float[10];
int calibrationPointsIdx = 0;
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
Enemy[] enemyArray = new Enemy[5];
ArrayList<Defense> defenseArray = new ArrayList<Defense>();
int objX, objY;
PImage bg;

/* Functions to handle external touch events */

void updateObjLoc(int x, int y) {
  objX = x;
  objY = y;
}

void doMousePoint(int x, int y) {
  switch(state) {
  case DEFENSE:
    defenseArray.add(new Defense(mouseX,mouseY,width,height));
    state = STOP;
  case GAME:
  case FORWARD:
  case STOP:
    inputPressed(x, y);
    break;
  default:
    print("Incorrect State: " + state);
    break;
  }
}

void setup()
{
  // Display/core init
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  renderables = new ArrayList<Renderable>();
  updatables = new ArrayList<Updatable>();
  kinect = new Kinect(this);
  if (KINECT) {
    kinect.start();
    kinect.enableRGB(true);
  }
  zxing = new ZxingAdapter();
  objX = width/2;
  objY = height/2;
  /*
   * Game init
   */
  players = new ArrayList<Player>();
  players.add(new Player(color(255,0,0), "Tanker Tamara", 50, 100));
  
  currentPlayerIndex = 0;
  currentPlayer = players.get(currentPlayerIndex);
  
  /* Init Enemies */
  smooth();
   for(int i=0; i<enemyArray.length; i++) {
    enemyArray[i] = new Enemy(width/2,height/2,10,width,height);  
  }
   
  defenseArray.add(new Defense(width/3,height/3,width,height));

  resetGame();
  bg = loadImage("stars.jpg");
  
  /*
   * GUI
   */
  // Next turn button
  Button nextTurnButton = new Button(w_percent(.80),h_percent(.79),w_percent(.18),h_percent(.08),"Forward")
  {
    public void onReleaseAction()
    {
      state = FORWARD;
    }
  };
  renderables.add(nextTurnButton);
  updatables.add(nextTurnButton);
  
  // Reset button
  Button resetButton = new Button(w_percent(.80),h_percent(.89),w_percent(.18),h_percent(.08),"+ Defense")
  {
    public void onReleaseAction()
    {
      state = DEFENSE;
//      resetGame();
    }
  };
  renderables.add(resetButton);
  updatables.add(resetButton);
  
  Button stopButton = new Button(w_percent(.80),h_percent(.69),w_percent(.18),h_percent(.08),"Stop")
  {
    public void onReleaseAction()
    {
      state = STOP;
    }
  };
  renderables.add(stopButton);
  updatables.add(stopButton);
  
}

void draw()
{
  fill(255);
  updateQRs();
  switch(state) {
  case START_MENU:
    scale(-1.0, 1.0);
//    image(kinect.getVideoImage(), -width,0, width, height);
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
      
      scale(-1.0, 1.0);
//      PImage tempImage = kinect.getVideoImage();
//      tempImage.filter(GRAY);
//      image(tempImage, -width,0, width, height);
      scale(-1.0, 1.0);
      translate(offsetX, offsetY);
      fill(0,0);
      rect(0,0,gameWidth,gameHeight);
      translate(-offsetX, -offsetY);
    }
    break;
  case GAME:
  case FORWARD:
  case STOP:
  case DEFENSE:
   update(mouseX, mouseY);
    if ((qrs != null) && (qrs.length > 0)) {
      inputRelease((int)(qrs[0].getCenterX()), (int)(qrs[0].getCenterY()));
    }
    renderGame();
       // iterate through every moving circle
    for(int i=0; i<enemyArray.length; i++) {
       
      enemyArray[i].update(objX,objY);
      enemyArray[i].checkCollisions();
      enemyArray[i].drawCircle();
     
       
    }
    for(Defense d:defenseArray) {
       d.update(enemyArray);
       d.drawCircle();
    }
    for (int i = defenseArray.size() - 1; i >= 0; i--) {
      Defense d =defenseArray.get(i); 
       if (d.strength() <= 0)  {
         defenseArray.remove(i);
       }
     }

    break;
  default:
    print("Incorrect State: " + state);
    break;
  }
}

void updateQRs() {
  if (KINECT) {
  kinect.getVideoImage().loadPixels();
    if (zxing != null) {
      try {
        QRCode newQrs[] = zxing.readMultipleQRCode(kinect.getVideoImage().pixels, kinect.getVideoImage().width, kinect.getVideoImage().height);
        if ((newQrs != null) && (newQrs.length > 0)) { 
          qrs = newQrs;
          for (QRCode qr:newQrs){print(qr);} print("\n");
        }
      } catch (Exception ex) {
        print("failed to read:" + ex);
      }
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
//  background(bg);
  image(bg,0,0,width,height);

  rectMode(CORNER);
  if (state == FORWARD) {
    fill(0,0,255);
  } else {
    fill(242,76,39);
  }
  rect(0,0,w_percent(1),h_percent(.20));
  rectMode(CORNER);

  for (Renderable r : renderables)
  {
    r.render();
  }
  // board isn't in the render list
  board.render();
  
  // show turn info
//  fill(currentPlayer.myColor);
//  stroke(0,0,0);
//  textSize(60);
//  textAlign(CENTER, CENTER);
//  text(currentPlayer.myName +"'s", w_percent(.89), h_percent(.05));
//  fill(0,0,0);
//  stroke(0,0,0);
//  textSize(50);
//  text("turn", w_percent(.89), h_percent(.14));

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
      print("Waiting for 3 calibration points...");
    } else if (calibrationPointsIdx == 6) {
      float[] cal = new float[6];
      for (int i = 0; i < 6; i++) {
        if (i%2 == 0) {
          cal[i] = calibrationPoints[i]/height*kinect.getVideoImage().width;
        } else {
          cal[i] = calibrationPoints[i]/height*kinect.getVideoImage().height;
        }
      }
      print(cal);//$
      zxing.calibrate(cal[0], cal[1], cal[2], cal[3], cal[4], cal[5], gameWidth, gameHeight, offsetX, offsetY);
      print("Calibration complete!");
      state = GAME;
      print("State: " + state); 
    } else {
      calibrationPoints[calibrationPointsIdx] = mouseX;
      calibrationPoints[calibrationPointsIdx+1] = mouseY;
      calibrationPointsIdx += 2;
    }
    break;
  case DEFENSE:
    defenseArray.add(new Defense(mouseX,mouseY,width,height));
    state = STOP;
  case GAME:
  case FORWARD:
  case STOP:
    inputPressed(mouseX, mouseY);
    break;
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

