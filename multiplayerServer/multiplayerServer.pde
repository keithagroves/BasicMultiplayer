import processing.net.*;
HashMap<Integer, ArrayList<Thing>>snakes = new HashMap<Integer, ArrayList<Thing>>();
HashMap<Integer, Integer>directions = new HashMap<Integer, Integer>();
//portocol
// type, size, 
//id, message

class Message {
  static final int ID_INDEX = 0;
  static final int X_INDEX = 1;
  static final int Y_INDEX = 2;
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
}


void drawSnakes() {
  for (ArrayList<Thing> s : snakes.values()) {
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
    println("header");
    byte[] message = new byte[header[Header.SIZE_INDEX]]; 
    thisClient.readBytes(message);
          updateDirection((int)message[0], (int)message[1]);
            printBytes(message);
    }
  
      //if (message[0] == Type.UPDATE) {
        //myServer.write(message);
      //}
 
  
}

void updateDirection(int id, int d){
  directions.put(id,d);
}

//Thing updateMap(byte [] packet) {
//  if (snakes.get((int)packet[Message.ID_INDEX]) != null) {
//    //snakes.get((int)packet[Message.ID_INDEX]).x = packet[3]*10;
//    snakes.get((int)packet[Message.ID_INDEX]).y = packet[4]*10;
//    return snakes.get((int)packet[ID_INDEX]);
//  } else {
//    Thing newPlayer = new Thing(0, 0, (int)packet[1]);
//    //snakes.put((int)packet[1], newPlayer);
//    updateMap(packet);
//    return newPlayer;
//  }
//}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());

  byte[] message = new byte[3];
  message[Message.ID_INDEX]= (byte)clientCount++;
  message[Message.X_INDEX] = (byte)(int)random(50);
  message[Message.Y_INDEX] = (byte)(int)random(50);
  //Add player to map
  ArrayList<Thing> newPlayer = new ArrayList<Thing>();
  newPlayer.add(new Thing(message[Message.X_INDEX]*10,message[Message.Y_INDEX]*10,message[Message.ID_INDEX]));
  snakes.put((int)message[Message.ID_INDEX],newPlayer);
  directions.put((int)message[Message.ID_INDEX], U);
    byte[] header = new byte[2];
  header[Header.TYPE_INDEX] = Type.JOIN;
  header[Header.SIZE_INDEX] = (byte) message.length;
  
  
  // Write all data for players positions and the current count
  someClient.write(header);
  someClient.write(message);
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
void move() {
  if (count++%6==0) {
    for (int id : snakes.keySet()) { 
      Thing player = snakes.get(id).get(0);
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
}
byte [] thingToBytes(ArrayList<Thing> player) {
  byte[] message = new byte[player.size()*2+1];
  message[Message.ID_INDEX] = (byte)player.get(0).id;
  for(int i = 0; i < player.size(); i++){
    message[Message.X_INDEX+(i*2)] = (byte)(player.get(i).x/10);
    message[Message.Y_INDEX + (i*2)] = (byte)(player.get(i).y/10);
  }
  //printBytes(message);
  return message;
}
