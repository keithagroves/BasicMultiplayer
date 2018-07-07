//Client
import processing.net.*;
import javax.swing.JOptionPane;


static final int U = 0;
static final int D = 1;
static final int L = 2;
static final int R = 3;

static final int DELAY = 5; 

class Food{
  public static final int X_INDEX = 1;  
  public static final int Y_INDEX = 3;
  public static final int ID_INDEX = 2;
   int x = 0;
   int y = 0;
   Food(int x, int y){
    this.x = x;
    this.y = y;
   }
}

class Type{
  public static final int FOOD = 1;
  public static final int SEGMENT = 2;
  public static final int DIRECTION = 3;  
}
class Segment {
 int x;
 int y;
 Segment(int x, int y){
  this.x = x;
  this.y = y;
 }
}

class Direction{
  
}
int dir = U;
Food food = new Food(20,20);
Segment me = new Segment(40,40);
Client myClient; 
int count = 0;

void setup() {
  size(500, 500);
  myClient = new Client(this, "localhost", 5204);
}

void draw() {
  background(0);
  drawFood();
  drawPlayer();
  move();
   println("hello");

}

void updateFood(byte[] message) {
  food.x = message[Food.X_INDEX]*10;
  food.y = message[Food.Y_INDEX]*10;

}




void drawFood() {
  fill(255, 115, 255);
  rect(food.x, food.y, 10, 10);
}

void drawPlayer() {
  fill(0, 115, 255);
  
    rect(me.x, me.y, 10, 10);
}



void keyPressed() {
  
    if (key == CODED) {
      if (keyCode == UP && dir!=U && dir!=D) {
        dir = U;
        //sendDirection();
      } else if (keyCode == DOWN && dir!=D && dir!=U) {
        dir = D;
        //sendDirection();
      } else if (keyCode == LEFT&& dir!=L && dir!=R) {
        dir=L;
        //sendDirection();
      } else if (keyCode == RIGHT && dir!=R && dir!=L) {
        dir = R;
        //sendDirection();
      }
    
  }
}



void move() {
  if(count++ % DELAY==0){
      switch(dir) {
      case U:
        me.y-=10;
        break;
      case D:
      me.y+=10;        break;
      case L:
      me.x-=10;        break;
      case R:
      me.x+=10;        break;
      }
  }
  
}