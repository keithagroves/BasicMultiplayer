//Client

import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();

class Thing {
  int id;
  int x;
  int y;
  Thing(int x, int y, int id) {
    this.x = x;
    this.y = y;
    this.id = id;
  }
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
}
Client myClient; 
JSONObject playerJSON;
Thing player;
String dataIn;
void setup() {
  size(500, 500);
  player = new Thing(20,20,(int)random(1000));
  playerJSON = new JSONObject();
  thingToJSON(player);
  myClient = new Client(this, "localhost", 5204); 
  myClient.write(playerJSON.toString());
}

void draw() {
   if (myClient.available() > 0) { 
  dataIn = myClient.readString();
  JSONObject json = parseJSONObject(dataIn);
  jsonToThings(json);
     }
  for(Thing t: things.values()){
    rect(t.x, t.y, 10,10); 
  }
  
}

void keyPressed(){
   if (key == CODED) {
    if (keyCode == UP) {
      player.y--;
    } else if (keyCode == DOWN) {
      player.y++;
    }
    else if (keyCode == LEFT) {
      player.x--;
    } else if (keyCode == RIGHT) {
      player.x++;
    }
    
   }
   myClient.write(playerJSON.toString());
}

void thingToJSON(Thing thing) {
  playerJSON.setInt("id",thing.id);
  playerJSON.setInt("x",thing.getX());
  playerJSON.setInt("y",thing.getY());
}

void jsonToThings(JSONObject json){
  JSONArray values = json.getJSONArray("things");
  for(int i = 0; i < values.size(); i++){
     addToMap(values.getJSONObject(i)); 
  }
}

void addToMap(JSONObject json){
   things.put(json.getInt("id"), new Thing(json.getInt("x"),json.getInt("y"), json.getInt("id")));
}


import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();

class Thing {
  int id;
  int x;
  int y;
  Thing(int x, int y, int id) {
    this.x = x;
    this.y = y;
    this.id = id;
  }
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
}

//SERVER
Server myServer;

void setup(){
 size(500,500);
 myServer = new Server(this, 5204); 
}

void draw() {
 Client thisClient = myServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    String whatClientSaid = thisClient.readString();
    if (whatClientSaid != null) {
      println(thisClient.ip() + "t" + whatClientSaid);
      addToMap(parseJSONObject(whatClientSaid));
      myServer.write();
    }
  }
}


void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
  
}

void addToMap(JSONObject json){
   things.put(json.getInt("id"), new Thing(json.getInt("x"),json.getInt("y"), json.getInt("id")));
}
