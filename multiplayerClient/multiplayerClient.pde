//Client
import processing.net.*;
import javax.swing.JOptionPane;
HashMap<Integer, ArrayList<Thing>>snakes = new HashMap<Integer, ArrayList<Thing>>();
HashMap<Integer, Integer>directions = new HashMap<Integer, Integer>();
HashMap<Integer, Integer>snakeSize = new HashMap<Integer, Integer>();

static final int GAMESPEED = 5;
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
  static final byte JOIN = 8;
  static final byte UPDATE = 1;
  static final byte DIRECTION = 2;
  static final byte FOOD = 3;
  static final byte POSITION = 5;
}

Client myClient; 

static final int U = 0;
static final int D = 1;
static final int L = 2;
static final int R = 3;
int count = 0;

//Your player
Thing myPlayer;

ArrayList<Thing>tail = new ArrayList<Thing>();
int foodX;
int foodY;
void setup() {
  size(500, 500);
  myClient = new Client(this, "192.168.7.86", 5204);
}

void draw() {
  background(0);
  if (myClient.available() > 0) { 
    byte [] header = new byte[2];
    myClient.readBytes(header);
    println("available:"+ myClient.available() )
;    if (myClient.available() >= header[Header.SIZE_INDEX] && header[Header.SIZE_INDEX] > 0) {
      byte [] message = new byte[header[Header.SIZE_INDEX]];
      myClient.readBytes(message);
      switch(header[Header.TYPE_INDEX]) {
      case Type.UPDATE:
        updatePosition(message);
        break;
      case Type.JOIN:
        if (myPlayer == null) {
          println("creating player");
          tail = createPlayer(message);
          myPlayer= tail.get(0);
          println(myPlayer.x);
        } else {
          createPlayer(message);
        }
        break;
      case Type.FOOD:
        updateFood(message);
        break;
      }
    } else {
      myClient.clear();
      println("INVALID PACKET SIZE");  
    }
  }
  if (myPlayer != null) {
    move();
    drawPlayer();
    drawSnakes();
    drawFood();
  }
}

void updateFood(byte[] message) {
  foodX = message[Food.X_INDEX]*10;
  foodY = message[Food.Y_INDEX]*10;
  int id = message[Food.ID_INDEX];
  int size = message[Food.PLAYER_SIZE];
  snakeSize.put(id, size);
}




void drawFood() {
  fill(255, 115, 255);
  rect(foodX, foodY, 10, 10);
}

void drawPlayer() {
  fill(0, 115, 255);
  for (Thing p : snakes.get(myPlayer.id))
    rect(p.x, p.y, 10, 10);
}

void drawSnakes() {
  for (ArrayList<Thing> s : snakes.values()) {
    fill(255, 115, 0);
    if (s!=tail) {
      for (Thing t : s) {
        rect(t.x, t.y, 10, 10);
      }
    }
  }
}

void keyPressed() {
  int dir = directions.get(myPlayer.id);
  if (myPlayer != null) {
    if (key == CODED) {
      if (keyCode == UP && dir!=U && dir!=D) {
        directions.put(myPlayer.id, U);
        sendDirection();
      } else if (keyCode == DOWN && dir!=D && dir!=U) {
        directions.put(myPlayer.id, D);
        sendDirection();
      } else if (keyCode == LEFT&& dir!=L && dir!=R) {
        directions.put(myPlayer.id, L);
        sendDirection();
      } else if (keyCode == RIGHT && dir!=R && dir!=L) {
        directions.put(myPlayer.id, R);
        sendDirection();
      }
    }
  }
}

void sendDirection() {
  byte[]message = new byte[2];
  message[Message.ID_INDEX] = (byte)myPlayer.id;
  message[Message.DIR_INDEX] = (byte)(int)directions.get(myPlayer.id);
  byte[] header = new byte[2];
  header[Header.SIZE_INDEX] = (byte)message.length;
  header[Header.TYPE_INDEX] = Type.DIRECTION;
  myClient.write(header);
  myClient.write(message);
}

void move() {
  if (count++%GAMESPEED==0) {
    for (int id : snakes.keySet()) { 
      Thing p = snakes.get(id).get(0);
      ArrayList<Thing> snake = snakes.get(id);
      switch(directions.get(id)) {
      case U:
        snake.add(0, new Thing(p.x, p.y-10, p.id));
        break;
      case D:
        snake.add(0, new Thing(p.x, p.y+10, p.id));
        break;
      case L:
        snake.add(0, new Thing(p.x-10, p.y, p.id));
        break;
      case R:
        snake.add(0, new Thing(p.x+10, p.y, p.id));
        break;
      }
      while (snake.size() > snakeSize.get(id))
        snake.remove(snake.size()-1);
    }
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



//UpdatePosition
ArrayList<Thing> updatePosition(byte[] packet) {
  int id = (int)packet[Message.ID_INDEX];
  ArrayList<Thing> snake = snakes.get(id);
  if (snake ==null) {
    snake = createPlayer(packet);
  } else {
    for (int i = 0; i < packet.length-2; i+=2) {
       if(i/2<snake.size()){
      if (snake.get(i/2) == null) {
        snake.add(new Thing( packet[Message.X_INDEX+i]*10, packet[Message.Y_INDEX+i]*10, id));
      } else {
        snake.get(i/2).x =  packet[Message.X_INDEX+i]*10;
        snake.get(i/2).y =  packet[Message.Y_INDEX+i]*10;
      }
       }
    }
  }
  return snake;
}

//create new player
ArrayList<Thing> createPlayer(byte [] packet) {
  println("creating Player");
  int id = (int)packet[Message.ID_INDEX];
  println("id:"+id);
  snakeSize.put(id, 10);
  ArrayList<Thing> newPlayer = new ArrayList<Thing>();
  newPlayer.add(new Thing(packet[Message.X_INDEX]*10, packet[Message.Y_INDEX]*10, (int)packet[Message.ID_INDEX]));
  snakes.put((int)packet[Message.ID_INDEX], newPlayer);
  directions.put(id, U);
  return newPlayer;
}

void printBytes(byte[] message) {
  for (int j=0; j<message.length; j++) {
    System.out.format("%02X ", message[j]);
  }
  System.out.println();
}