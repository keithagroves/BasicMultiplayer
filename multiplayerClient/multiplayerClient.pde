//Client

import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();
static final int UPDATE = 1;
static final int PACKET_ID = 1;
static final int JOIN = 0;
Client myClient; 
Thing player;
void setup() {
  size(500, 500);


  myClient = new Client(this, "localhost", 5204);
}

void draw() {
  background(0);

  if (myClient.available() > 0) { 
    byte [] message = new byte[10];
    myClient.readBytes(message);

    if (message[0] == UPDATE)
      updateMap(message);
    else if (message[0] == JOIN && player == null) {
      player = updateMap(message);
    }
  }
  if (player != null) {
    fill(0, 115, 255);
    rect(player.x, player.y, 10, 10);
    for (Thing t : things.values()) {
      fill(255, 115, 0);
      rect(t.x, t.y, 10, 10);
    }
  }
}

void keyPressed() {
  if (player != null) {
    if (key == CODED) {
      if (keyCode == UP) {
        player.y-=10;
      } else if (keyCode == DOWN) {
        player.y+=10;
      } else if (keyCode == LEFT) {
        player.x-=10;
      } else if (keyCode == RIGHT) {
        player.x+=10;
      }
    }
    myClient.write(thingToBytes(player));
  }
}

byte [] thingToBytes(Thing player) {
  byte[] x = toByteArray(player.x);
  byte[] y = toByteArray(player.y);
  byte[] message = new byte[10];
  message[0] = UPDATE;
  message[1] = (byte)player.id;
  message[2] = x[0];
  message[3] = x[1];
  message[4] = x[2];
  message[5] = x[3];
  message[6] = y[0];
  message[7] = y[1];
  message[8] = y[2];
  message[9] = y[3];

  printBytes(message);
  return message;
}

byte[] toByteArray(int value) {
  return new byte[] { 
    (byte)(value >> 24), 
    (byte)(value >> 16), 
    (byte)(value >> 8), 
    (byte)value };
}

Thing updateMap(byte [] packet) {
  if (things.get((int)packet[PACKET_ID]) != null) {
    things.get((int)packet[PACKET_ID]).x = (packet[2]<<24)&0xff000000|
      (packet[3]<<16)&0x00ff0000|
      (packet[4]<< 8)&0x0000ff00|
      (packet[5]<< 0)&0x000000ff;
    things.get((int)packet[PACKET_ID]).y = (packet[6]<<24)&0xff000000|
      (packet[7]<<16)&0x00ff0000|
      (packet[8]<< 8)&0x0000ff00|
      (packet[9]<< 0)&0x000000ff;
    return things.get((int)packet[PACKET_ID]);
  } else {
    Thing newPlayer = new Thing(0, 0, (int)packet[1]);
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
