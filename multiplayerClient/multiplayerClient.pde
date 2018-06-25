//Client
import processing.net.*;
HashMap<Integer, ArrayList<Thing>>things = new HashMap<Integer, ArrayList<Thing>>();

class Message {
  static final int ID_INDEX = 0;
  static final int X_INDEX = 1;
  static final int Y_INDEX = 2;
  static final int DIR_INDEX =1;
}

class Header {
  static final int SIZE_INDEX = 0;
  static final int TYPE_INDEX = 1;
}

class Type{
  static final int JOIN = 0;
  static final int UPDATE = 1;
  static final int DIRECTION = 2;
}

Client myClient; 

static final int U = 0;
static final int D = 1;
static final int L = 2;
static final int R = 3;
int dir = U;
int count = 0;

//Your player
Thing player;

ArrayList<Thing>tail = new ArrayList<Thing>();

void setup() {
  size(500, 500);
  myClient = new Client(this, "localhost", 5204);
}

void draw() {
  background(0);
  if (myClient.available() > 0) { 
    byte [] header = new byte[2];
    myClient.readBytes(header);
    printBytes(header);
    byte [] message = new byte[header[Header.SIZE_INDEX]];
    myClient.readBytes(message);
    printBytes(message);
    switch(header[Header.TYPE_INDEX]) {
    case Type.UPDATE:
      updateMap(message);
      break;
    case Type.JOIN:
      if (player == null) {
        println("creating player");
            printBytes(message);

        tail = updateMap(message);
        player= tail.get(0);
        println(player.x);
      }
      else{
         updateMap(message); 
      }
      break;
    }
   
  }
   if (player != null) {

      move();
      drawPlayer();
      //drawSnakes();
    }
}


void drawPlayer() {
  fill(0, 115, 255);
  rect(player.x, player.y, 10, 10);
}

void drawSnakes() {
  for (ArrayList<Thing> s : things.values()) {
    fill(255, 115, 0);
    for (Thing t : s)
      rect(t.x, t.y, 10, 10);
  }
}

void keyPressed() {
  if (player != null) {
    if (key == CODED) {
      if (keyCode == UP && dir!=U && dir!=D) {
        dir = U;
        sendDirection();
      } else if (keyCode == DOWN && dir!=D && dir!=U) {
        dir = D;
        sendDirection();
      } else if (keyCode == LEFT&& dir!=L && dir!=R) {
        dir = L;
        sendDirection();
      } else if (keyCode == RIGHT && dir!=R && dir!=L) {
        dir = R;
        sendDirection();
      }
    }
  }
}

void sendDirection(){
   byte[]message = new byte[2];
   message[Message.ID_INDEX] = (byte)player.id;
   message[Message.DIR_INDEX] = (byte)dir;
   byte[] header = new byte[2];
   header[Header.SIZE_INDEX] = (byte)message.length;
   header[Header.TYPE_INDEX] = Type.DIRECTION;
   printBytes(header);
   myClient.write(header);
   myClient.write(message);
}

void move() {
  if (count++%6==0) {
    switch(dir) {
    case U:
      player.y-=10;
      break;
    case D:
      player.y+=10;
      break;
    case L:
      player.x-=10;
      break;
    case R:
      player.x+=10;
      break;
    }
  }
}


byte [] thingToBytes(ArrayList<Thing> player) {
  byte[] message = new byte[player.size()*2+1];
  message[Message.ID_INDEX] = (byte)player.get(0).id;
  for(int i = 0; i < player.size(); i++){
    message[Message.X_INDEX+(i*2)] = (byte)(player.get(i).x/10);
    message[Message.Y_INDEX + (i*2)] = (byte)(player.get(i).y/10);
  }
  printBytes(message);
  return message;
}


ArrayList<Thing> updateMap(byte [] packet) {
  printBytes(packet);
  int id = (int)packet[Message.ID_INDEX];
  ArrayList<Thing> snake = things.get(id);
  if (snake != null) {
    things.put(id,new ArrayList<Thing>());
    snake = things.get(id);
    for (int i = 1; i < packet.length-1; i++) {
      snake.add(new Thing(packet[i]*10, packet[i+1]*10, id));
      println("adding snake at "+ packet[i]*10 + " and " + packet[i+1]*10);
    }
    return snake;
  } else {
    ArrayList<Thing> newPlayer = new ArrayList<Thing>();
    newPlayer.add(new Thing(packet[Message.X_INDEX]*10, packet[Message.Y_INDEX]*10, (int)packet[Message.ID_INDEX]));
    things.put((int)packet[Message.ID_INDEX], newPlayer);
    updateMap(packet);
    return newPlayer;
  }
}

void printBytes(byte[] message) {
  for (int j=0; j<message.length; j++) {
    System.out.format("%02X ", message[j]);
  }
  System.out.println();
}
