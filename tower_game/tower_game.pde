import org.openkinect.*;
import org.openkinect.processing.*;

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
final float  HEALTH_MAX = 500;

// ----- Globals -----
// System globals
//int state = GAME;
int state = START_MENU;
int offsetX, offsetY, gameWidth, gameHeight = -1;
float[] calibrationPoints = new float[10];
int calibrationPointsIdx = 0;
boolean isCalibrated = false;

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
float health;

TouchHandler th;
Kinect kinect;

void setup()
{
  // Display/core init
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  renderables = new ArrayList<Renderable>();
  updatables = new ArrayList<Updatable>();
  
  kinect = new Kinect(this);
  th = new TouchHandler(kinect);
  
  smooth();
  
  /*
   * Game init
   */
  health = HEALTH_MAX;
  
  objX = width / 2;
  objY = height / 2;
  
  players = new ArrayList<Player>();
  players.add(new Player(color(255,0,0), "Tanker Tamara", 50, 100));
  
  currentPlayerIndex = 0;
  currentPlayer = players.get(currentPlayerIndex);
  
  /* Init Enemies */
  for(int i=0; i<enemyArray.length; i++) {
    enemyArray[i] = new Enemy(width/2,height/2,10,width,height);  
  }
   
  defenseArray.add(new Defense(width/3,height/3,width,height));

  resetGame();
  
  /*
   * GUI
   */
  bg = loadImage("stars.jpg");
  
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
  switch(state) {
  case START_MENU:
    scale(-1.0, 1.0);
    break;
  case CALIBRATION:
  /*
    background(0);
    fill(0);
    stroke(204, 102, 0);
    strokeWeight(5);
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth == -1) && (gameHeight == -1)) {
      ellipse(offsetX,offsetY,100, 100);
    }
    if ((offsetX != -1) && (offsetY != -1) && (gameWidth != -1) && (gameHeight != -1)) {
      
      scale(-1.0, 1.0);

      translate(offsetX, offsetY);
      fill(0,0);
      rect(0,0,gameWidth,gameHeight);
      translate(-offsetX, -offsetY);
    }
    break;
  */
    if (th.updateDraw()) {
      state = GAME;
    }
  case GAME:
  case FORWARD:
  case STOP:
  case DEFENSE:
    update(mouseX, mouseY);
    /*
    if ((qrs != null) && (qrs.length > 0)) {
      inputRelease((int)(qrs[0].getCenterX()), (int)(qrs[0].getCenterY()));
    }
    */
    renderGame();
    
    for(int i=0; i<enemyArray.length; i++) {
       
      boolean hit = enemyArray[i].update(objX,objY);
      enemyArray[i].checkCollisions();
      enemyArray[i].drawCircle();
     
       // Update health
      if (hit) {
        health = health - (health/10);
      }
      
      fill(255,0,0);
      rect(w_percent(.80),h_percent(.59),w_percent(.18)*(health/HEALTH_MAX),h_percent(.04));
      if (health <= 10) {
        fill(0,0,0);
        stroke(0,0,0);
        textSize(50);
        text("You Died.", w_percent(.89), h_percent(.14));
      }

    }
    // Update defenses
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

