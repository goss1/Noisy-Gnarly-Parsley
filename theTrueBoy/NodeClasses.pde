class Node implements ControlListener{
  PVector pos;
  boolean selected;
  color col;
  int alpha = 100;
  ColorPicker cp;
  
  Node(PVector pos_){
    pos = pos_.copy();

  }
  
  void flickSelected(){
    if (selected){
      selected = false;
    } else {
      selected = true;
    }
  }
  
  void drag(PVector dragAmount){
    pos.add(dragAmount);
  }
  
  Node copyNode(){
    return new Node(pos);
  }
  
  void rotateNode(Node axis, float angle){
    pos.set(rotatePV(pos, axis.pos, angle));
  }
  
  void scaleNode(Node axis, float amount){
    pos.set(scalePV(pos, axis.pos, amount));
  }
    
  void display(int size){
    stroke(0);
    fill(col);
    if (isInside(new PVector(mouseX, mouseY), pos, new PVector(5, 5))){
      strokeWeight(4);
    } else {
      strokeWeight(2);
    }
    ellipse(pos.x, pos.y, size, size);
  }
  
  public void  controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(cp)){
      int r = int(theEvent.getArrayValue(0));
      int g = int(theEvent.getArrayValue(1));
      int b = int(theEvent.getArrayValue(2));
      int a = int(theEvent.getArrayValue(3));
      col = color(r,g,b);
    }
  } 
}

class Trajectory{
  ArrayList<Node> nodePath = new ArrayList<Node>();
  Node axis;
  color col = 127;
  int alpha; 
  boolean selected;
  
  Trajectory(Node[] nodes_){
    for (int i = 0; i < nodes_.length; i++){
      nodes_[i].col = (int)map(i, 0, nodes_.length, 0, 255);
      nodePath.add(nodes_[i]);
    }
    axis = new Node(averageNodePosAL(nodePath));
  }
  
  Trajectory fromPVectors(PVector[] vertices){
    Node[] nodes = new Node[vertices.length];
    for (int i = 0; i < vertices.length; i++){
      nodes[i] = new Node(vertices[i]);
    }
    return new Trajectory(nodes);
  }
  
  void drag(PVector dragAmount){
    axis.drag(dragAmount);
    for (Node n : nodePath){
      n.drag(dragAmount);
    }
  }
  
  void updatePos(){
    axis.pos = averageNodePosAL(nodePath);
  }
  
  void updateDensity(int totalNodes){
    PVector start = nodePath.get(0).pos.copy();
    PVector finish = nodePath.get(nodePath.size()-1).pos.copy();
    nodePath.clear(); 
    for (int i = 0; i < totalNodes; i++){
      float fraction = (float)i/(float)(totalNodes-1);
      nodePath.add(new Node(new PVector(start.x + fraction*(finish.x-start.x), start.y + fraction*(finish.y-start.y))));
    }     
  }
  
  void scaleNodes(){
    
  }
  
  void rotateNodes(){
    for (Node n : nodePath){
    }
  }
  
  void firstToLast(){
      
  }
  
  void lastToFirst(){
    
  }
  
  void swapTwo(int thisNode, int thatNode){
    Node holder = new Node(nodePath.get(thisNode).pos);
    nodePath.set(thisNode, nodePath.get(thatNode));
    nodePath.set(thatNode, holder); 
  }
  
  void smoothBezier(){
    /*
    turns nodePath into a smooth nodePath for continuous bezier curves
    makes (ideally) small adjustments to the second and third control point of
    each bezier in order to assure slopes are equal at anchor points. Maybe
    there is fun in how we smooth it out. Maybe interface with noise. How?
    */
    
    for (int i = 3; i < nodePath.size()-1; i+=3){
      PVector first = nodePath.get(i-1).pos.copy();
      PVector second = nodePath.get(i).pos.copy();
      first.sub(second);
      second.sub(nodePath.get((i+1)%nodePath.size()).pos);
      
      float angle = PVector.angleBetween(first, second)/2;
      
      //if drawing with a counterclockwise acceleration negate rotation angle
      first.normalize();
      second.normalize();
      second.rotate(2*angle);
      if(first.dist(second)< .001){
        angle*=-1;
      }
      
      nodePath.set(i-1, new Node(rotatePV(nodePath.get(i-1).pos, nodePath.get(i).pos, angle)));
      nodePath.set(i+1, new Node(rotatePV(nodePath.get(i+1).pos, nodePath.get(i).pos, -angle)));
    } 
  }
  
  //this is one method of randomizing node order. Any other clever ways?
  void randomize(){
    int[] alreadyDrawn = new int[nodePath.size()];
    for (Node n : nodePath){
      int drawing = (int)random(nodePath.size()-nodePath.indexOf(n));
      drawing = addUntilNew(drawing, alreadyDrawn);
      alreadyDrawn[nodePath.indexOf(n)] = drawing;
      swapTwo(nodePath.indexOf(n), drawing);
    }
    smoothBezier();
  }
  
  void display(){
    strokeWeight(3);
    stroke(col);
    if (isInside(new PVector(mouseX, mouseY), axis.pos, new PVector(5, 5))){
      axis.display(15);  
    } else {
      axis.display(10);
    }
    for (int i = 0; i < nodePath.size(); i++){       
      nodePath.get(i).display(5);
      if (i < nodePath.size()-1){
        stroke(map(i, 0, nodePath.size(), 0, 255));
        line(nodePath.get(i).pos.x, nodePath.get(i).pos.y, nodePath.get(i+1).pos.x, nodePath.get(i+1).pos.y);
      }
    }    
  }
  
  Trajectory copyTrajectory(){
    Node[] path = new Node[nodePath.size()];
    for (int i = 0; i < nodePath.size(); i++){
      path[i] = nodePath.get(i).copyNode();
    }
    return new Trajectory(path);
  }
  
  Trajectory copyPartialTrajectory(int start, int finish){
    Node[] path = new Node[finish-start+1];
    for (int i = start; i < finish+1; i++){
      path[i-start] = nodePath.get(i).copyNode();
    }
    return new Trajectory(path);
  }
}

class Morphism implements ControlListener{
  int morphismLength;
  int currentMorphism;
  ArrayList<Trajectory> trajectoryPath = new ArrayList<Trajectory>();
  color col;
  Node axis;
  boolean selected;
  ControlP5 menu;
  
  Morphism(ArrayList<Trajectory> trajectories_,color col_){
    morphismLength = trajectories_.size();
    for (Trajectory t : trajectories_){
      trajectoryPath.add(t);
    }
    axis = trajectoryPath.get(0).axis.copyNode();
    col = col_;
    centerPath();
    menu = new ControlP5(main);
    buildMenu();
  }
  
  void buildMenu(){
  }
  
  void updateDensity(int totalTrajectories){
    for (int i = 0; i < totalTrajectories; i++){
      
    }
  }
  
  void display(){
    trajectoryPath.get(currentMorphism).display();
    currentMorphism++;
    if (currentMorphism == morphismLength)
    {
      currentMorphism = 0;
    }
  }
  
  void drag(PVector dragAmount){
    for (Trajectory t : trajectoryPath){
      t.drag(dragAmount);
    }
  } 
  
  void centerPath(){
    PVector center = trajectoryPath.get(0).axis.pos.copy();
    for (Trajectory t : trajectoryPath){      
      PVector correction = t.axis.pos.copy();
      correction.sub(center).mult(-1);
      t.drag(correction);
    }
  }
  
  void clearTrajectories(){
    trajectoryPath.clear();
  }
  
  Morphism copyMorphism(){
    return new Morphism(trajectoryPath, col);
  }
  
  public void  controlEvent(ControlEvent theEvent) {
    
  }
}
