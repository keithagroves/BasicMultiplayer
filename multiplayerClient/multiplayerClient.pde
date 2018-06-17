//Client

import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();


Client myClient; 
JSONObject playerJSON;
Thing player;
String dataIn;
void setup() {
  size(500, 500);
  
  player = new Thing(20, 20, (int)random(1000));
  playerJSON = new JSONObject();
  thingToJSON(player);
  myClient = new Client(this, "localhost", 5204); 
  myClient.write(thingToJSON(player).toString());
}

void draw() {
  background(0);
  if (myClient.available() > 0) { 
    dataIn = myClient.readString();
    JSONObject json = null;
    try{
     json = parseJSONObject(dataIn);
    }
    catch(Exception e){
      println("Crash");
    }
    jsonToThings(json);
  }
  fill(0,115,255);
  rect(player.x, player.y, 10,10);
  for (Thing t : things.values()) {
      fill(255,115,0);
    rect(t.x, t.y, 10, 10);
  }
}

void keyPressed() {
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
  println(thingToJSON(player).toString());
  myClient.write(thingToJSON(player).toString());
}

JSONObject thingToJSON(Thing thing) {
  JSONObject playerJSON = new JSONObject();
  playerJSON.setInt("id", thing.id);
  playerJSON.setInt("x", thing.getX());
  playerJSON.setInt("y", thing.getY());
  return playerJSON;
}

void jsonToThings(JSONObject json) {
  if(json!=null){
  JSONArray values = json.getJSONArray("things");
  if(values!=null){
  for (int i = 0; i < values.size(); i++) {
    addToMap(values.getJSONObject(i));
  }
  }
  }
}

void addToMap(JSONObject json) {
  if (json.getInt("id") != player.id)
    things.put(json.getInt("id"), new Thing(json.getInt("x"), json.getInt("y"), json.getInt("id")));
}