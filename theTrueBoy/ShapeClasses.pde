class Shape{
  
  int shapeType; 
  float heading;
  Trajectory trajectory;
  PShape shape;
  Node axis;
  PStyle style;   
  NoiseMaker noise;
  boolean isGroup, selected, translate, isClosed, isSmooth;
  
  Shape(int shapeType_, Trajectory trajectory_, PStyle style_, boolean closed, boolean smooth){    
    shapeType = shapeType_;
    style = copyStyle(style_);
    trajectory = trajectory_.copyTrajectory();
    axis = trajectory.axis.copyNode();
    
    shape = createShape();
    switch(shapeType){
    case 1 :
      if(trajectory.nodePath.size()<3){
        shape.beginShape(LINES);
      } else {
        shape.beginShape();
      }
      for (int i = 0; i < trajectory.nodePath.size(); i++){
        shape.vertex(trajectory.nodePath.get(i).pos.x, trajectory.nodePath.get(i).pos.y);
      }
      break;
      
    case 2 :  
      if (calligraphy.getState()){ 
        calligraphize(calligraphySWRange.getLowValue(), calligraphySWRange.getHighValue(), calligraphyInertia.getValue());   
      } else {   
        shape.beginShape();
        for (int i = 0; i < trajectory.nodePath.size(); i++){       
          shape.vertex(trajectory.nodePath.get(i).pos.x, trajectory.nodePath.get(i).pos.y);      
        }
      }
      break; 
      
    case 3 :         
      shape.beginShape();
      for (int i = 0; i < trajectory.nodePath.size(); i++){       
        shape.vertex(trajectory.nodePath.get(i).pos.x, trajectory.nodePath.get(i).pos.y);      
      }
      break;
    
    case 4 : 
      highLightAnchors();
      shape.beginShape();
      shape.strokeCap(ROUND);
      ArrayList<PVector> cp1 = new ArrayList<PVector>();
      for (Node n : trajectory.nodePath){
        cp1.add(n.pos);
      }
      shape.vertex(cp1.get(0).x, cp1.get(0).y);
      shape.bezierVertex(cp1.get(1).x, cp1.get(1).y, cp1.get(2).x, cp1.get(2).y, cp1.get(3).x, cp1.get(3).y);     
      break;   
      
    case 5 : 
      isSmooth = true;
      highLightAnchors();
      shape.beginShape();
      shape.strokeCap(ROUND);
      ArrayList<PVector> cp2 = new ArrayList<PVector>();
      for (Node n : trajectory.nodePath){
        cp2.add(n.pos);
      }
      shape.vertex(cp2.get(0).x, cp2.get(0).y);
      for (int i = 1; i < cp2.size(); i+=3){        
        shape.bezierVertex(cp2.get(i).x, cp2.get(i).y, cp2.get(1+i).x, cp2.get(1+i).y, cp2.get(2+i).x, cp2.get(2+i).y);     
      }
      break;
        
    case 6 :
      isSmooth = true;    
      highLightAnchors();
      shape.beginShape();
      shape.strokeCap(ROUND);
      ArrayList<PVector> cp3 = new ArrayList<PVector>();
      for (Node n : trajectory.nodePath){
        cp3.add(n.pos);
      }
      shape.vertex(cp3.get(0).x, cp3.get(0).y);
      for (int i = 1; i < cp3.size(); i+=3){
        shape.bezierVertex(cp3.get(i).x, cp3.get(i).y, cp3.get(1+i).x, cp3.get(1+i).y, cp3.get(2+i).x, cp3.get(2+i).y);     
      }
      break;
      
    case 7 :
      //text
      break;
    }    
      
    if (!isGroup){ 
      if (closedShape){
        shape.endShape(CLOSE);
      } else {
        shape.endShape();
      }
      shape.setFill(style.fillColor);    
      shape.setStroke(style.strokeColor);      
      shape.setStrokeWeight(style.strokeWeight);
    }
    noise = new NoiseMaker(this);
  } 
  
  void display(){      
    shape(shape);
  }

  void displaySelected(){
    if (selected && frameCount%15 == 0){
      axis.col += 127.5; 
      axis.col %= 255;
    } 
    axis.display(10);
    if (selected){
      for (Node n : trajectory.nodePath){
        n.display(5);
      }
    }
  }
  
  void selectShape(){
    selected = true;
    for (Node n : trajectory.nodePath){
      n.selected = true;
    }
    
    singleShapeMenu.show();
    
    //if one shape selected, show style menu
    //if more than one, show group menu
  }
  
  void selectNode(int which){
    trajectory.nodePath.get(which).selected = true;
  }
  
  void deselectNode(int which){
    trajectory.nodePath.get(which).selected = false;
  }
  
  void deselectShape(){
    //if none selected, hide shape menu
    selected = false;
    for (Node n : trajectory.nodePath){
      n.selected = false;
    }
  }
  
  void highLightAnchors(){
    for (int i = 0; i < trajectory.nodePath.size(); i++){
      if (i%3 == 0){
        trajectory.nodePath.get(i).col = 255;
      }
    }
  }
  
  void drag(PVector dragAmount){
    for (Node n : trajectory.nodePath) {
      if (n.selected) {
        n.drag(dragAmount);  
      }
    }
    followTrajectory(true);
  }
  
  void dragShapeOnly(PVector dragAmount){
    for (Node n : trajectory.nodePath){
      if (n.selected){
        int which = trajectory.nodePath.indexOf(n);
        PVector newPos = new PVector(n.pos.x+dragAmount.x, n.pos.y+dragAmount.y);
        if (isGroup) {
          shape.getChild(0).setVertex(which, newPos); 
          for (int i = 0; i < 2; i++){
            if (which+i > 0 && which+i < trajectory.nodePath.size()){
              shape.getChild(which+i).setVertex(1-i, newPos);
            }
          }          
        } else {
          shape.setVertex(which, newPos.x, newPos.y);
        }
      }
    }
  }
  
  void animateSingleFrame(PVector[] updatedVertices){
    for (Node n : trajectory.nodePath){
      n.pos.set(updatedVertices[trajectory.nodePath.indexOf(n)]);
    }
    followTrajectory(false);
  }
  
  void calligraphize(float min, float max, float inertia){
    if (isGroup){
      //adjust stroke based on given parameters.
      float[] distances = new float[trajectory.nodePath.size()];
      float minDistance = 100;
      float maxDistance = 0;
      for (int i = 0; i < trajectory.nodePath.size()-2; i++){
        distances[i] = trajectory.nodePath.get(i).pos.dist(trajectory.nodePath.get(i+1).pos);
        if (minDistance > distances[i]){
          minDistance = distances[i];
        }
        if (maxDistance < distances[i]){
          maxDistance = distances[i];
        }
      }
      maxDistance /= 1.2;
      
      float swHolder = map(trajectory.nodePath.get(0).pos.dist(trajectory.nodePath.get(1).pos), minDistance, maxDistance, max, min);
      for (int i = 0; i < trajectory.nodePath.size()-1; i++){ 
        //can we generalize this tool into something useful across different modules? color, audio analysis, etc
        float targetSW = min(max(map(distances[i], minDistance, maxDistance, max, min), min), max);
        float difference = swHolder - targetSW;
        swHolder -= inertia*difference;
        swHolder = min(max(min, swHolder), max);
        
        PShape s = createShape();
        s.beginShape(LINES);
        s.strokeWeight(swHolder);
        s.stroke(style.strokeColor);
        s.vertex(trajectory.nodePath.get(i).pos.x, trajectory.nodePath.get(i).pos.y);
        s.vertex(trajectory.nodePath.get(i+1).pos.x, trajectory.nodePath.get(i+1).pos.y);  
        s.endShape();
        
        shape.addChild(s);
      }
    } else {
      shape = createShape(GROUP);
      
      PShape fillShape = createShape();      
      fillShape.beginShape();
      fillShape.fill(style.fillColor);        
      fillShape.strokeWeight(.1); 
      for (int i = 0; i < trajectory.nodePath.size(); i++){       
        fillShape.vertex(trajectory.nodePath.get(i).pos.x, trajectory.nodePath.get(i).pos.y);      
      }
      fillShape.endShape();
      shape.addChild(fillShape);
        
      isGroup = true;
      calligraphize(min, max, inertia);
    }
  }
  
  void scaleShape(Node scaleAxis, float amount){
    float sw;
    for (Node n : trajectory.nodePath){
      n.scaleNode(scaleAxis, amount);
    }
    if (isGroup) {
      for (int i = 1; i < shape.getChildCount(); i++){
        sw = shape.getChild(i).getStrokeWeight(0)*amount;
        shape.getChild(i).setStrokeWeight(sw);
      }
    } else {
      sw = shape.getStrokeWeight(0)*amount;
      shape.setStrokeWeight(sw);
    }
    followTrajectory(true);
  }
  
  void rotateShape(Node rotationAxis, float amount){
    heading += amount;
    for (Node n : trajectory.nodePath){
      n.rotateNode(rotationAxis, amount);
    }
    followTrajectory(true);
  }
  
  void squishShape(Node shapeAxis, Node otherAxis, float amount){
    PVector line = shapeAxis.pos.copy().sub(otherAxis.pos);
    for (Node n : trajectory.nodePath){
      // first convert line to normalized unit vector
      float mag = line.mag();
      line.div(mag);
      
      // translate the point and get the dot product
      float lambda = (line.x * (n.pos.x - shapeAxis.pos.x)) + (line.y * (n.pos.y - shapeAxis.pos.y));
      float x = (line.x * lambda) + shapeAxis.pos.x;
      float y = (line.y * lambda) + shapeAxis.pos.y;
      PVector singleAxis = new PVector(x, y);
      n.scaleNode(new Node(singleAxis), amount);
    }
    followTrajectory(true);
  }
  
  void followTrajectory(boolean noiseFollows){
    for (Node n : trajectory.nodePath){
      int which = trajectory.nodePath.indexOf(n);
      if (isGroup) {
        shape.getChild(0).setVertex(which, n.pos); 
        for (int i = 0; i < 2; i++){
          if (which+i > 0 && which+i < trajectory.nodePath.size()){
            shape.getChild(which+i).setVertex(1-i, n.pos);
          }
        }          
      } else {
        shape.setVertex(which, n.pos.x, n.pos.y);
      }
    }
    if (noiseFollows){
      noise.originalTraj = trajectory.copyTrajectory();
    }
    centerAxis();
  }
  
  void randomizeVertices(){
    trajectory.randomize();
    //try false
    followTrajectory(true);
  }
  
  void followShape(){
    for (Node n : trajectory.nodePath){
      int which = trajectory.nodePath.indexOf(n);
      if (isGroup) {
        n.pos = shape.getChild(0).getVertex(which).copy(); 
        for (int i = 0; i < 2; i++){
          if (which+i > 0 && which+i < trajectory.nodePath.size()){
            n.pos = shape.getChild(which+i).getVertex(1-i).copy();
          }
        }          
      } else {
        n.pos = shape.getVertex(which).copy();
      }
    }
  }
    
  
  void centerAxis(){
    axis.pos.set(averageNodePosAL(trajectory.nodePath));
  }
  
  void dissolve(){
    //different disolve type arguments
    /*for (int i = 0; i < trajectory.nodePath.size()-1; i++){
      Node[] points = new Node[2];
      points[0] = trajectory.nodePath.get(i);
      points[1] = trajectory.nodePath.get(i+1);
      Trajectory line = new Trajectory(points);
      activeShapes.add(new Shape(2, line, style));
    }*/
  }
  
  void reorderOne(int oldIndex, int newIndex){
    Shape s = this.copyShape();
    activeShapes.remove(oldIndex);
    activeShapes.add(newIndex, s);
  }
  
  void bringToFront(){
    activeShapes.remove(activeShapes.indexOf(this));
    activeShapes.add(this);
  }
  
  void bringToBack(){
    activeShapes.remove(activeShapes.indexOf(this));
    activeShapes.add(0, this);
  }
  
  void addVertex(){   
    
  }
  
  void removeVertex(){
    
  }
  
  //this kinda sucks doesn't it?
  //Animation shapeToAnimation(){
  //  int[] type = new int[1];
  //  type[0] = shapeType;
  //  ArrayList<Trajectory> traj = new ArrayList<Trajectory>();
  //  traj.add(trajectory);
  //  Morphism m = new Morphism(traj, style.fillColor);
  //  PStyle[] st = new PStyle[1];
  //  st[0] = style;
  //  return new Animation(type, m, st);
  //}
  
  Shape copyShape(){
    return new Shape(shapeType, trajectory, style, isClosed, isSmooth);
  }
  
  Node copyAxis(){
    return new Node(axis.pos);
  }
}

/*class Animation{
  int animationLength;
  int whichFrame;
  int[] shapeType, fillAlpha, strokeAlpha;
  ArrayList<PVector> shapePath = new ArrayList<PVector>();
  Node axis;
  PStyle[] style;
  PVector jitter;   
  boolean selected, play;
  ControlP5 menu;
  
  Animation(int[] shapeType_, Morphism morphism_, PStyle[] style_){
    animationLength = morphism_.trajectoryPath.size();
    axis = morphism_.axis.copyNode();
    shapeType = new int[animationLength];
    style = new PStyle[animationLength];
    fillAlpha = new int[animationLength];
    strokeAlpha = new int[animationLength];
    for (int i = 0; i < morphism_.trajectoryPath.size(); i++){
      shapeType[i] = shapeType_[i];
      style[i] = copyStyle(style_[i]);
      fillAlpha[i] = (style[i].fillColor >> 24) & 0xFF;
      strokeAlpha[i] = (style[i].strokeColor >> 24) & 0xFF;
      shapePath.add(new Shape(shapeType[i], morphism_.trajectoryPath.get(i), style[i]));
    }
    menu = new ControlP5(main);
    buildMenu();
  }
  
  void buildMenu(){
  }
  
  void drag(PVector dragAmount){
    axis.drag(dragAmount);
    for (Shape s : shapePath){
      s.drag(dragAmount);
    }
  }
    
  void display(){
    shapePath.get(whichFrame).display();
    if (play){
      whichFrame = (whichFrame+1)%animationLength;
    }
  }
  
  void pauseAnimation(){
    play = false;
  }
  
  void advanceFrame(){
    whichFrame = (whichFrame+1)%animationLength;
  }
  
  void retreatFrame(){
    whichFrame = (whichFrame-1)%animationLength;
  }
  
  void resetAnimation(){
    whichFrame = 0;
  }  
  
  
}

class ShapeGroup{
  ArrayList<Animation> shapeMotion = new ArrayList<Animation>();
  ArrayList<Shape> staticShapes;
  Morphism groupMotion;
  Trajectory groupShape;
  Node axis;
  boolean dynamic;
  boolean selected;  
  color col;
  int alpha = 255;
  ControlP5 menu;
  
  //how do we account for difference in shapeMotion_.size() and groupMotion.size() ?
  ShapeGroup(ArrayList<Animation> shapeMotion_, Morphism groupMotion_, color col_){
    
    // first frame of every shape animation
    for (int i = 0; i < shapeMotion_.size(); i++){
      staticShapes.add(shapeMotion_.get(i).shapePath.get(0));
    }
    
    // every fame of every shape animation
    if (shapeMotion_.get(0).animationLength > 1){
      for (Animation s : shapeMotion_){
        shapeMotion.add(s);
        dynamic = true;
      }
    }

    groupMotion = groupMotion_.copyMorphism();
    groupShape = groupMotion.trajectoryPath.get(0).copyTrajectory();
    
    if (groupMotion.morphismLength > 1){
      dynamic = true;
    }
    
    //animate/set the shape of the ShapeGroup
    for (Trajectory t : groupMotion.trajectoryPath){
      for (int i = 0; i < t.nodePath.size(); i++){
        PVector correction = shapeMotion.get(i).axis.pos;
        correction.sub(t.nodePath.get(i).pos);
        shapeMotion.get(i).drag(correction);
      }
    }
    
    axis = groupMotion.trajectoryPath.get(0).axis.copyNode();
    col = col_;
    
    menu = new ControlP5(main);
    buildMenu();
  }
  
  void buildMenu(){
  
  }
  
  void display(){
    if (dynamic) {
      for (Animation s : shapeMotion){
        s.display();
      }
    } else {
      for (Shape s : staticShapes){
        s.display();
      }
    }
  }
  
  void displayKeyPoints(){
    groupShape.display();
  }
  
  void addShape(){
    
  }
  
  void removeShape(){
    
  }

  //how do we 'attach' staticGroup to the shapes in group?
  void drag(PVector dragAmount){
    groupShape.drag(dragAmount);
    if (dynamic){
      for (Animation sa : shapeMotion){
        sa.drag(dragAmount);
      }
    } else {
      for (Shape s : staticShapes){
        s.drag(dragAmount);
      }
    }
  }
  
  ShapeGroup copyGroup(){  
    return new ShapeGroup(shapeMotion, groupMotion, col);
  }
}

/*
class Scene{
  ArrayList<GroupAnimation> movingParts = new ArrayList<GroupAnimation>();
  Controlp5 menu;
  
  Scene(ArrayList<GroupAnimation> movingParts_){
    for (GroupAnimation ga : movingParts_){
      movingParts.add(ga);
    }
    menu = new ControlP5(main);
    buildMenu();
  }
  
  void buildMenu(){
  }
  
  void play(){
  }
  
  void pause(){
  }
  
  void advanceFrame(){
  }
  
  void retreatFrame(){
  }
  
}
*/
