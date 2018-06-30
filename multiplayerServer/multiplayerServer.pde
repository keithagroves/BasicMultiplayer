import processing.net.*;
HashMap<Integer, ArrayList<Thing>>snakes = new HashMap<Integer, ArrayList<Thing>>();
HashMap<Integer, Integer>directions = new HashMap<Integer, Integer>();
HashMap<Integer, Integer>snakeSize = new HashMap<Integer, Integer>();
HashMap<String, Integer>ipId= new HashMap<String, Integer>();

boolean update;
//portocol
// type, size, 
//id, message
static final int GAMESPEED = 5;
long oldTime = System.currentTimeMillis();
;
class Message {
  static final byte ID_INDEX = 0;
  static final byte X_INDEX = 1;
  static final byte Y_INDEX = 2;
  static final byte DIR_INDEX =1;
}

class Food {
  static final byte ID_INDEX = 0;
  static final byte X_INDEX = 1;
  static final byte Y_INDEX = 2;
  static final byte PLAYER_SIZE = 3;
}

class Header {
  static final byte SIZE_INDEX = 0;
  static final byte TYPE_INDEX = 1;
}

class Type {
  static final byte JOIN = 0;
  static final byte END = 6;
  static final byte UPDATE = 1;
  static final byte DIRECTION = 2;
  static final byte FOOD = 3;
  static final byte COUNT = 4;
  static final byte POSITION = 5;
}

static int clientCount = 0;

//SERVER
Server myServer;
int count = 0;
int foodX = ((int)random(50)*10);
int foodY = ((int)random(50)*10);

static final int U = 0;
static final int D = 1;
static final int L = 2;
static final int R = 3;
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
  checkSnakeCollisions();
}

void drawFood() {
  fill(255, 115, 255);
  rect(foodX, foodY, 10, 10);
}


void drawSnakes() {
  for (ArrayList<Thing> s : snakes.values()) {
    //updatePosition((byte)s.get(0).id);
    fill(255, 115, 0);
    for (Thing t : s)
      rect(t.x, t.y, 10, 10);
  }
}


void protocol() {
  Client thisClient = myServer.available();
  if (thisClient !=null) {
    byte[] header = new byte[2]; 
    thisClient.readBytes(header);
    if (header[Header.TYPE_INDEX] ==Type.DIRECTION ) {
      byte[] message = new byte[header[Header.SIZE_INDEX]];
      thisClient.readBytes(message);
      if (message.length > 1) {
        updateDirection((int)message[0], (int)message[1]);
      }
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
  someClient.write(header);
  someClient.write(message);
  foodUpdate(message[Message.ID_INDEX]);
  //updateCount();
  for (ArrayList<Thing> snake : snakes.values()) {
    updatePosition((byte)snake.get(0).id);
  }
}

void updatePosition(byte id) {
  //Thing player = snakes.get((int)id).get(0);
  //byte[] message = new byte[3];
  //message[Message.ID_INDEX]= id;
  //message[Message.X_INDEX] = (byte)(player.x/10);
  //message[Message.Y_INDEX] = (byte)(player.y/10);
  byte [] message = thingToBytes(snakes.get((int)id));
  byte[]header = new byte[2];
  header[Header.SIZE_INDEX] = (byte)message.length;
  header[Header.TYPE_INDEX] = (byte)Type.UPDATE;

  myServer.write(header);
  myServer.write(message);
}

void foodUpdate(byte id) {
  //byte[] message = {id,(byte)(foodX/10), (byte)(foodY/10), (byte)(int)snakeSize.get(id)};
  byte[] message = new byte[4];
  message[Food.ID_INDEX] = id;
  message[Food.X_INDEX] = (byte)(foodX/10);
  message[Food.Y_INDEX] = (byte)(foodY/10);
  message[Food.PLAYER_SIZE] = (byte)(int)snakeSize.get((int)id);
  byte[] header = {(byte)message.length, Type.FOOD};

  myServer.write(header);
  myServer.write(message);
}

void updateCount() {
  byte[] message = {(byte)(count)};
  byte[] header = {(byte)message.length, Type.COUNT};
  myServer.write(header);
  myServer.write(message);
}


void move() {
  if (count++%GAMESPEED==0) {
    oldTime = System.currentTimeMillis();
    //if ((count+1)%GAMESPEED*15==0) {
    // update = true; 
    //}
    for (int id : snakes.keySet()) { 
      //println("id:" + id);
      Thing player = snakes.get(id).get(0);
      ArrayList<Thing> snake = snakes.get(id);
      switch(directions.get(id)) {
      case U:
        snake.add(0, new Thing(player.x, player.y-10, player.id));
        //player.y-=10;
        break;
      case D:
        snake.add(0, new Thing(player.x, player.y+10, player.id));

        //player.y+=10;
        break;
      case L:
        snake.add(0, new Thing(player.x-10, player.y, player.id));

        //player.x-=10;
        break;
      case R:
        snake.add(0, new Thing(player.x+10, player.y, player.id));

        //player.x+=10;
        break;
      }
      if (snake.size() > snakeSize.get(id))
        snake.remove(snake.size()-1);
      if (update) {
        println("id:" + id);
        updatePosition((byte)id);
      }
      //updatePosition((byte)id);
    }
    update = false;
  }
}
byte [] thingToBytes(ArrayList<Thing> player) {
  byte[] message = new byte[player.size()*2+1];
  message[Message.ID_INDEX] = (byte)player.get(0).id;
  for (int i = 0; i < player.size(); i++) {
    message[Message.X_INDEX+(i*2)] = (byte)(player.get(i).x/10);
    message[Message.Y_INDEX + (i*2)] = (byte)(player.get(i).y/10);
  }
  return message;
}

void checkFoodCollisions() {
  for (ArrayList<Thing> list : snakes.values()) {
    for (Thing p : list) {
      if (p.x== foodX && p.y == foodY) {
        foodX = (((int)random(50))*10);
        foodY = (((int)random(50))*10);
        snakeSize.put(p.id, snakeSize.get(p.id)+1);
        foodUpdate((byte)p.id);
      }
    }
  }
}

void checkSnakeCollisions() {
  for (ArrayList<Thing> list : snakes.values()) {
    Thing head = list.get(0);
    for (ArrayList<Thing> snake : snakes.values()) {
      if (snake != list) {
        for (Thing p : snake) {
          if (head.x == p.x && head.y == p.y) {
            //foodX = (((int)random(50))*10);
            //foodY = (((int)random(50))*10);
            snakeSize.put(head.id, 1);
            foodUpdate((byte)head.id);
          }
        }
      }
    }
  }
}

// ClientEvent message is generated when a client disconnects.
void disconnectEvent(Client thisClient) {
  print("Server Says:  ");
  println(thisClient.ip() + "t has been disconnected");
  int id = ipId.get(thisClient.ip());
  snakes.remove(id);
  directions.remove(id);
  snakeSize.remove(id);
  println(thisClient.ip() + "t has been deleted");
}


void printBytes(byte[] message) {
  println("length "+message.length);
  for (int j=0; j<message.length; j++) {
    System.out.format("%02X ", message[j]);
  }
  System.out.println();
}

void printInts(byte[] message) {
  for (int j=0; j<message.length; j++) {
    print( (int)message[j]+" ");
  }
  System.out.println();
}
