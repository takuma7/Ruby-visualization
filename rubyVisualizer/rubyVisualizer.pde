import processing.net.*;

int port = 10002;
boolean myServerRunning = true;
color bgColor = color(0);
int direction = 1;
int textLine = 30;

Server myServer;

PFont font;
NodeList nodeList = new NodeList();

void setup(){
  //size(1400,800);
  size(screen.width, screen.height);
  colorMode(HSB,100);
  background(bgColor);
  smooth();
  font = loadFont("Monaco-48.vlw");
  textAlign(CENTER);
  textFont(font,12);
  
  myServer = new Server(this, port); //Starts a myServer on port 10002
}

/*
void mousePressed(){
  //if the mouse clicked the myServer stops
  myServer.stop();
  myServerRunning = false;
}*/

void draw_class(String className, String classID)
{
  if( (className.equals("Kernel")||className.equals("Mutex")||className.equals("Gem")) == false){
    //println("draw_class was called - className: "+className+" classID: "+classID);
    Node nClass = new Node(int(classID),"class",className);
    nodeList.add(nClass);
  }
}

void draw_class(String className, String classID,String superName)
{
  if( (className.equals("Kernel")||className.equals("Mutex")||className.equals("Gem")) == false){
    //println("draw_class was called - className: "+className+" classID: "+classID 
    //        + "superClass: "+superName);
    Node nClass = new Node(int(classID),"class",className);
    int nodeListSize = nodeList.size();
    for(int i=0; i<nodeListSize; i++){
      Node nowNode = (Node) nodeList.get(i);
      if(nowNode.name.equals(superName)){
        nClass.addParent(nowNode);
        break;
      }
    }
    nodeList.add(nClass);
  }
}

void draw_method(String methodName, String className)
{
  //  text(methodName+"\n",15,textLine);
  int classID=0;
  int nodeListSize = nodeList.size();
  for(int i=0; i<nodeListSize; i++){
    Node nowNode = (Node) nodeList.get(i);
    if(className.equals(nowNode.name)){
      classID = nowNode.id;
      break;
    }
  }
  if(classID!=0){
    Node nMethod = new Node(classID,"method",methodName);
    nodeList.add(nMethod);
  }
}

void draw_instance(String className)
{
  //text(className+"\n",15,textLine);
  int classID=0;
  int nodeListSize=nodeList.size();
  for(int i=0; i<nodeListSize; i++){
    Node nowNode = (Node) nodeList.get(i);
    if(className.equals(nowNode.name)){
      classID=nowNode.id;
      break; 
    }
  }
  if(classID!=0){
    Node nInstance = new Node(classID,"instance",className);
    nodeList.add(nInstance);
  }
}
/*
Node searchParent(int klass,Node[] nodeArray){
  Node parent;
  return parent;
}

void addNode2array(Node n,Node[] nodeArray){
   
}*/

void update()
{
   int nodeListSize = nodeList.size();
   for(int i=0; i<nodeListSize; i++){
     Node nowNode = (Node) nodeList.get(i);
     while(nowNode.next!=null){
       nowNode.connectShow();
       nowNode = nowNode.next;
     }
   }
   for(int i=0; i<nodeListSize; i++){
     Node nowNode = (Node) nodeList.get(i);
     while(nowNode.next!=null){
       nowNode.display();
       nowNode = nowNode.next;
     }
   }
   for(int i=0; i<nodeListSize; i++){
     Node nowNode = (Node) nodeList.get(i);
     while(nowNode.next!=null){
       nowNode.nameShow();
       nowNode = nowNode.next;
     }
   }
   for(int i=0; i<nodeListSize; i++){
     Node nowNode = (Node) nodeList.get(i);
     while(nowNode.next!=null){
       nowNode.update();
       nowNode = nowNode.next;
     }
   }
}
void fadeToBg(){
  noStroke();
  fill(bgColor);
  rect(0,0,width,height);
}

void draw()
{
  fadeToBg();
  if(myServerRunning == true)
  {
    //text("server",15,45);
    Client thisClient = myServer.available();
    if(thisClient != null){
      if(thisClient.available() > 0){
        //println("message from" + thisClient.ip() + " : " + thisClient.readString());
        String msg = thisClient.readString().trim();
        String[] msgAryAry = msg.split("\n");
        for(int i=0; i<msgAryAry.length-1; i++){
          String[] msgArray = msgAryAry[i].split(" ");
          //println(i + " msgArray.length = " + msgArray.length);
          //println(msgArray[0]);
          //println(msgAryAry);
          if(msgArray[0].equals("rb2p5")){
            //println("message from ruby\n");
            
            String type = msgArray[1];
            //println(msgArray);
            if(type.equals("class"))
            {
              //[2]name [3]klass
              //println("msgArray.length : " + msgArray.length);
              //println(msgArray);
              if(msgArray.length==4) draw_class(msgArray[2],msgArray[3]);
              else if(msgArray.length==5) draw_class(msgArray[2],msgArray[3],msgArray[4]);
              //println("draw_class("+msgArray[2] + ", "+msgArray[3] + ");");
            }
            else if(type.equals("method"))
            {
              //[2]name [3]class [4]klass
              //println(msgArray);
                draw_method(msgArray[2],msgArray[3]);
            }
            else if(type.equals("instance"))
            {
              //[2]class [3]klass
              draw_instance(msgArray[2]);
            }
            textLine += 35;
          }
        }
      }
    }
  }
  else
  {
    //text("server",15,45);
    //text("stopped",15,65);
  }
  
  update();
}
