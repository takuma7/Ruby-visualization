class Node{
  int id;
  String type;
  String name;
  
  float x,y;
  float posX,posY;
  float distX,distY;
  float speed = 0.1;
  
  float radius;
  float armLength = 1.9;
  float maxLength;
  
  Node parent;
  
  Node next; //for NodeList
  
  color col;
  
  ArrayList children;
  
  Node(){}
  Node(int id,String type, String name){
    this.id = id;
    this.type = type;
    this.name = name;
    setRadius();
    setColor();
    maxLength = radius/2;
    x=random(maxLength, width-maxLength);
    y=random(maxLength, height-maxLength);
    children = new ArrayList();
  }
  
  void addParent(Node parent){
    this.parent = parent;
    //println("added parent("+parent.name+") to ("+this.name+")");
    this.parent.children.add(this);
    int childNum = (int) this.parent.children.size();

    for(int i=0; i<childNum; i++){
      Node nowNode = (Node) this.parent.children.get(i);
      nowNode.posX = this.parent.x + this.parent.radius*armLength*cos(TWO_PI*i/childNum);
      nowNode.posY = this.parent.y + this.parent.radius*armLength*sin(TWO_PI*i/childNum); 
    }
    
 }
  
  void setRadius(){
    if(type=="class"){
      radius = this.name.length()*15;
    }else if(type=="method"){
      radius = this.name.length()*9; 
    }
    else{
      radius = 10;
    }
  }
  
  void setColor(){
    if(type=="class"){
      col = color(0,99,99,80);
    }else if(type=="method"){
       col = color(60,99,99,80);
    }else if(type=="instance"){
      col = color(20,99,99,80);
    }
  }
  
  void connect(Node n1,Node n2){
    //stroke(col);
    stroke(99,30);
    line(n1.x, n1.y, n2.x, n2.y); 
  }
  
  void connectShow(){
    if(this.parent!=null) connect(this,this.parent);
  }
  
  void display(){
    fill(col);
    noStroke();

    ellipse(x,y,radius,radius);
    //println("Node#display called");
  }
  
  void nameShow(){
    fill(99);
    if(type!="instance") text(name,x,y+3); 
  }
  
  void update(){
    if(parent!=null){
          int childNum = (int) this.parent.children.size();

    for(int i=0; i<childNum; i++){
      Node nowNode = (Node) this.parent.children.get(i);
      nowNode.posX = this.parent.x + this.parent.radius*armLength*cos(TWO_PI*i/childNum);
      nowNode.posY = this.parent.y + this.parent.radius*armLength*sin(TWO_PI*i/childNum); 
    }
      distX = (x-posX)*speed;
      distY = (y-posY)*speed;
      x -= distX;
      y -= distY;
    }
  }
}

class NodeList{
  ArrayList nodeList;
  
  NodeList(){
    nodeList = new ArrayList();
  }
  
  void add(Node entry){
    boolean found = false; 
    for(int i=0; i<nodeList.size(); i++){
       Node head = (Node) nodeList.get(i);
       if(head.id == entry.id){
         nodeListEnd(head).next = entry;
         if(entry.type!="class") entry.addParent(head);
         found = true;
         break;
       }
     }
   if(found==false){
     nodeList.add(entry);
     //println(entry.name + "(id:" +entry.id + ") was added to nodeList");
     for(int i=0; i<nodeList.size(); i++){
       Node nowNode=(Node)nodeList.get(i);
       //println("["+i+"]"+nowNode.name);
       while(nowNode.next!=null){
         //println("\t"+nowNode.next.type+nowNode.next.name);
         nowNode = nowNode.next;
       }
     }
   }
  }
  
  Node nodeListEnd(Node head){
    Node nowNode = head;
    while(nowNode.next!=null){
      nowNode = nowNode.next;
    }
    return nowNode;
  }
  
  int size(){
    return nodeList.size(); 
  }
  Node get(int i){
    return (Node) nodeList.get(i);
  }
}
