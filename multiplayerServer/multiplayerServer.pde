import processing.net.*;
HashMap<Integer, Thing>things = new HashMap<Integer, Thing>();

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
    String whatClientSaid = thisClient.readString();
    if (whatClientSaid != null) {
      println(thisClient.ip() + "t" + whatClientSaid);
      addToMap(parseJSONObject(whatClientSaid));
      myServer.write(mapToJson(things).toString());
    }
  }
}


void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
}

void addToMap(JSONObject json) {
  println(json);
  things.put(json.getInt("id"), new Thing(json.getInt("x"), json.getInt("y"), json.getInt("id")));
}


JSONObject mapToJson(HashMap<Integer, Thing> things) {
  JSONObject JSONthings = new JSONObject();
  JSONArray list = new JSONArray();
  int i = 0;
  for (int t : things.keySet()) {
    list.setJSONObject(i, thingToJson(things.get(t)));
    i++;
  }
  JSONthings.setJSONArray("things", list);
  return JSONthings;
}

JSONObject thingToJson(Thing t) {
  JSONObject obj = new JSONObject();
  obj.setInt("id", t.id);
  obj.setInt("x", t.x);
  obj.setInt("y", t.y);
  return obj;
}
