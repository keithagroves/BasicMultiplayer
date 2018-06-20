import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();
HashMap<Integer, Integer>directions = new HashMap<Integer, Integer>();

static final int UPDATE = 1;
static final int PACKET_ID = 1;
static int clientCount = 0;
//SERVER
Server myServer;
int foodX = ((int)random(50)*10);
int foodY = ((int)random(50)*10);
void setup() {
  size(500, 500);
  myServer = new Server(this, 5204);
}

void draw() {
  Client thisClient = myServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    byte[] message = new byte[10]; 
    message = thisClient.readBytes();
    if (message != null) {
      if (message[0] == UPDATE) {
        updateMap(message);
        printBytes(message);
        myServer.write(message);
      }
    }
  }
  for (Thing t : things.values()) {
    fill(255, 115, 0);
    rect(t.x, t.y, 10, 10);
  }
}

void protocol(byte[] message){
  if (message[0] == UPDATE) {
        updateMap(message);
        printBytes(message);
        myServer.write(message);
      }
}

Thing updateMap(byte [] packet) {
  if (things.get((int)packet[PACKET_ID]) != null) {
    things.get((int)packet[PACKET_ID]).x = packet[3]*10;
    things.get((int)packet[PACKET_ID]).y = packet[4]*10;
    return things.get((int)packet[PACKET_ID]);
  } else {
    Thing newPlayer = new Thing(0, 0, (int)packet[1]);
    things.put((int)packet[1], newPlayer);
    updateMap(packet);
    return newPlayer;
  }
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
  byte[] message = new byte[10];
  message[0] = 0x00;
  message[1] = (byte)clientCount++;
  someClient.write(message);
}

void printBytes(byte[] message) {
  for (int j=0; j<message.length; j++) {
    System.out.format("%02X ", message[j]);
  }
  System.out.println();
}
