class Button implements Updatable, Renderable
{
  private int x, y, w, h;
  private color baseColor, hoverColor, clickColor, currentColor;
  private String label;
  
  private boolean selected; 
  
  Button(int x, int y, int w, int h, String label)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    baseColor = color(255,255,255);
    hoverColor = color(120,120,120);
    clickColor = color(255,0,0);
    currentColor = baseColor;
    
    selected = false;
    this.label = label;
  }
  
  Button(int x, int y, int w, int h)
  {
    this(x,y,w,h,"");
  }
  
  void update(int mX, int mY)
  {
    if (selected)
    {
      currentColor = clickColor;
    } else if (insideButton(mX, mY))
    {
      currentColor = hoverColor;
    } else
    {
      currentColor = baseColor;
    }
  }
  
  void render()
  {
    fill(currentColor);
    rect(x, y, w, h);
    stroke(0,0,0);
    fill(0,0,0);
    
    textSize(20);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2 - h/16);
  }
  
  /*
   * Event registering
   */
  
  /*
   * Register mouse clicks/releases on this button
   */
  void registerMClick(int mX, int mY, Player currentPlayer)
  {
    if (insideButton(mX, mY))
    {
      selected = true;
      onClickAction();
    }
  }
  void registerMRelease(int mX, int mY, Player currentPlayer)
  {
    // do click action if this button was originally selected
    if (selected && insideButton(mX, mY))
    {
      onReleaseAction();
    }
    if (selected)
    {
      selected = false;
    }
  }
  
  /*
   * Actions that happen when mouse is clicked/released on this button
   */
  public void onClickAction()
  {
  }
  public void onReleaseAction()
  {
  }
  
  /*
   * Util methods
   */
  boolean insideButton(int mX, int mY)
  {
    return (mX >= x && mX <= x+w && mY >= y && mY <= y+h);
  }
}
