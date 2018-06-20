import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();
static final int UPDATE = 1;
static final int PACKET_ID = 1;
static int clientCount = 0;
//SERVER
Server myServer;

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
    if(message != null){
    if(message[0] == UPDATE){
        updateMap(message);
        printBytes(message);
        myServer.write(message);
      }
    }
  }
  for (Thing t : things.values()) {
      fill(255,115,0);
    rect(t.x, t.y, 10, 10);
  }
}

void updateMap(byte [] packet){
  if(things.get((int)packet[PACKET_ID]) != null){
    things.get((int)packet[PACKET_ID]).x = (packet[2]<<24)&0xff000000|
       (packet[3]<<16)&0x00ff0000|
       (packet[4]<< 8)&0x0000ff00|
       (packet[5]<< 0)&0x000000ff;
    things.get((int)packet[PACKET_ID]).y = (packet[6]<<24)&0xff000000|
       (packet[7]<<16)&0x00ff0000|
       (packet[8]<< 8)&0x0000ff00|
       (packet[9]<< 0)&0x000000ff;
  } else {
    things.put((int)packet[1],new Thing(0,0,(int)packet[1]));
    updateMap(packet);
  }
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
  byte[] message = new byte[10];
  message[0] = 0x00;
  message[1] = (byte)clientCount++;
  someClient.write(message);
}

void printBytes(byte[] message){
  for (int j=0; j<message.length; j++) {
   System.out.format("%02X ", message[j]);
}
System.out.println();
}
