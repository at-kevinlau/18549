/**
 * An Updatable can update its state based on mouse position
 *
 */

interface Updatable
{
  void update(int mX, int mY);
  void registerMClick(int mX, int mY, Player currentPlayer);
  void registerMRelease(int mX, int mY, Player currentPlayer);
}
