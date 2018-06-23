//Client
import processing.net.*;
HashMap<Integer, ArrayList<Thing>>things = new HashMap<Integer, ArrayList<Thing>>();

class Message {
  static final int JOIN = 0;
  static final int UPDATE = 1;
}

static final int PACKET_ID = 1;
static final int PACKET_SIZE = 0;

Client myClient; 

static final int U = 0;
static final int D = 1;
static final int L = 2;
static final int R = 3;
int dir = D;
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
    byte [] message = new byte[10];
    myClient.readBytes(message);
    switch(message[0]) {
    case Message.UPDATE:
      updateMap(message);
      break;
    case Message.JOIN:
      if (player == null) {
        //player = updateMap(message);
      }
      break;
    }
    if (player != null) {

      move();
      drawPlayer();
      drawSnakes();
    }
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
        myClient.write(thingToBytes(player));
      } else if (keyCode == DOWN && dir!=D && dir!=U) {
        dir = D;
        myClient.write(thingToBytes(player));
      } else if (keyCode == LEFT&& dir!=L && dir!=R) {
        dir = L;
        myClient.write(thingToBytes(player));
      } else if (keyCode == RIGHT && dir!=R && dir!=L) {
        dir = R;
        myClient.write(thingToBytes(player));
      }
    }
  }
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

byte getPACKET_SIZE(byte[] message) {
  return message[PACKET_SIZE];
}

byte [] thingToBytes(Thing player) {
  byte[] message = new byte[10];
  message[0] = Message.UPDATE;
  message[1] = (byte)player.id;
  message[3] = (byte)(player.x/10);
  message[4] = (byte)(player.y/10);
  printBytes(message);
  return message;
}


ArrayList<Thing> updateMap(byte [] packet) {
  ArrayList<Thing> snake = things.get((int)packet[PACKET_ID]);
  if (snake != null) {
    for (int i = 0; i < snake.size(); i++) {
      snake.get(i).x = packet[3 +(2*i)]*10;
      snake.get(i).y = packet[4 +(2*i)]*10;
    }
    return things.get((int)packet[PACKET_ID]);
  } else {
    ArrayList<Thing> newPlayer = new ArrayList<Thing>();
    newPlayer.add(new Thing(0, 0, (int)packet[1]));
    things.put((int)packet[1], newPlayer);
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
