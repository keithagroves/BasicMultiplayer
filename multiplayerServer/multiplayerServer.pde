import processing.net.*;
HashMap<Integer, ArrayList<Thing>>snakes = new HashMap<Integer, ArrayList<Thing>>();
HashMap<Integer, Integer>directions = new HashMap<Integer, Integer>();


//portocol
// type, size, 
//id, message




class Message {
  static final int JOIN = 0;
  static final int UPDATE = 1;
  static final int SIZE_INDEX = 0;
  static final int TYPE_INDEX = 1;
  static final int ID_INDEX = 2;
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
  move();
  protocol();
  drawPlayers():
}


void drawPlayers() {
  for (Thing t : snakes.values()) {
    fill(255, 115, 0);
    rect(t.x, t.y, 10, 10);
  }
}


void protocol(byte[] message) {
  Client thisClient = myServer.available();
  if (thisClient !=null) {
    byte[] message = new byte[2]; 
    message = thisClient.readBytes();
    if (message != null) {
      if (message[0] == UPDATE) {
        updateDirection(message);
        printBytes(message);
        myServer.write(message);
      }
    }
  }
}

Thing updateMap(byte [] packet) {
  if (snakes.get((int)packet[PACKET_ID]) != null) {
    snakes.get((int)packet[PACKET_ID]).x = packet[3]*10;
    snakes.get((int)packet[PACKET_ID]).y = packet[4]*10;
    return snakes.get((int)packet[PACKET_ID]);
  } else {
    Thing newPlayer = new Thing(0, 0, (int)packet[1]);
    snakes.put((int)packet[1], newPlayer);
    updateMap(packet);
    return newPlayer;
  }
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
  byte[] message = new byte[5];
  message[TYPE_INDEX] = message.JOIN;
  message[ID_INDEX]= (byte)clientCount++;
  message[SIZE_INDEX] = message.length();
  message[X_INDEX] = ((int)random(50)) * 10;
  message[Y_INDEX] = ((int)random(50)) * 10;
  // 1. Add player to map
  snakes.put(message[ID_INDEX],new ArrayList<Thing>)
  directions.put(message[ID_INDEX], U);
  //2.  Write all data for players positions and the current count
  someClient.write(message);
}

Thing addPlayer(){
  return new Thing()
}



void printBytes(byte[] message) {
  for (int j=0; j<message.length; j++) {
    System.out.format("%02X ", message[j]);
  }
  System.out.println();
}

void move() {
  if (count++%6==0) {
    for (int id : snakes.keySet()) { 
      Thing player = snakes.get(id);
      ;
      switch(directions.get(id)) {
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
