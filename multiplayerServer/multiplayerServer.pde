import processing.net.*;

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

//SERVER
Server myServer;
int count = 0;
int foodX = ((int)random(50)*10);
int foodY = ((int)random(50)*10);


void setup() {
  size(500, 500);
  myServer = new Server(this, 5204);
}

void draw() {
  background(0);
  move();
  protocol();
  drawSnakes();
  drawFood();
  checkFoodCollisions();
}

void drawFood() {
  fill(255, 115, 255);
  rect(foodX, foodY, 10, 10);
}





void protocol() {
  Client thisClient = myServer.available();

  if (thisClient !=null) {
    if (thisClient.available() >0) {
      byte[] header = readHeader(thisClient);
      if (header[Header.TYPE_INDEX] ==Type.DIRECTION ) {
        updateDirection(thisClient, header);
      } else if (header[Header.TYPE_INDEX] ==Type.END ) {
        byte[] message = new byte[header[Header.SIZE_INDEX]];
        thisClient.readBytes(message);
        int id = message[Message.ID_INDEX];
        snakes.remove(id);
        directions.remove(id);
        snakeSize.remove(id);
        println(thisClient.ip() + "t has been disconnected");
        myServer.disconnect(thisClient);
      }
    }
  }
}

void updateDirection(int id, int d) {
  directions.put(id, d);
  update = true;
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
  ipId.put(someClient.ip(), clientCount);
  byte[] message = new byte[3];
  message[Message.ID_INDEX]= (byte)clientCount++;
  message[Message.X_INDEX] = (byte)(int)random(50);
  message[Message.Y_INDEX] = (byte)(int)random(50);
  //Add player to map
  ArrayList<Thing> newPlayer = new ArrayList<Thing>();
  newPlayer.add(new Thing(message[Message.X_INDEX]*10, message[Message.Y_INDEX]*10, message[Message.ID_INDEX]));
  snakes.put((int)message[Message.ID_INDEX], newPlayer);
  directions.put((int)message[Message.ID_INDEX], U);
  snakeSize.put((int)message[Message.ID_INDEX], 1);
  byte[] header = new byte[2];
  header[Header.TYPE_INDEX] = Type.JOIN;
  header[Header.SIZE_INDEX] = (byte) message.length;

  // Write all data for players positions and the current count
  myServer.write(header);
  myServer.write(message);
  foodUpdate(message[Message.ID_INDEX]);
  for (int id: snakes.keySet()) {
    updatePosition((byte)id);
  }
}

void updatePosition(byte id) {
  byte [] message = thingToBytes(snakes.get((int)id));
  byte[]header = new byte[2];
  header[Header.SIZE_INDEX] = (byte)message.length;
  header[Header.TYPE_INDEX] = (byte)Type.UPDATE;

  myServer.write(header);
  myServer.write(message);
}

void foodUpdate(byte id) {
  byte[] message = new byte[4];
  message[Food.ID_INDEX] = id;
  message[Food.X_INDEX] = (byte)(foodX/10);
  message[Food.Y_INDEX] = (byte)(foodY/10);
  message[Food.PLAYER_SIZE] = (byte)(int)snakeSize.get((int)id);
  byte[] header = {(byte)message.length, Type.FOOD};

  myServer.write(header);
  myServer.write(message);
}



void move() {
  if (count++%GAMESPEED==0) {
   
      switch(directions.get(id)) {
      case U:
        snake.add(0, new Thing(player.x, player.y-10, player.id));
        break;
      case D:
        snake.add(0, new Thing(player.x, player.y+10, player.id));
        break;
      case L:
        snake.add(0, new Thing(player.x-10, player.y, player.id));
        break;
      case R:
        snake.add(0, new Thing(player.x+10, player.y, player.id));
        break;
      }
      if (snake.size() > snakeSize.get(id))
        snake.remove(snake.size()-1);
      if (update) {
        //println("id:" + id);
        updatePosition((byte)id);
        update = false;
        move();
        break;
      }
    }
  }
}


void checkFoodCollisions() {

}


// ClientEvent message is generated when a client disconnects.
void disconnectEvent(Client thisClient) {
  print("Server Says:  ");
  println(thisClient.ip() + "t has been disconnected");
  //int id = ipId.get(thisClient.ip());
  //snakes.remove(id);
  //directions.remove(id);
  //snakeSize.remove(id);
  println(thisClient.ip() + "t has been deleted");
}