void mousePressed(){
  if (ui == false){
    switch (whichTab){
    case 1 : 
      drawMousePressed();
      return;
    case 2 :
      animateMousePressed();
      return;
    case 3 :    
      sequenceMousePressed();
      return;
    }
  }
}

void mouseDragged(){
  if (ui == false){
    switch (whichTab){
    case 1 : 
      drawMouseDragged();
      return;
    case 2 :
      animateMouseDragged();
      return;
    case 3 :    
      sequenceMouseDragged();
      return;
    }
  }
}

void mouseReleased(){
  if (ui == false){
    switch (whichTab){
    case 1 : 
      drawMouseReleased();
      return;
    case 2 :
      animateMouseReleased();
      return;
    case 3 :    
      sequenceMouseReleased();
      return;
    }
  }
}

void keyPressed() {
  println(mouseX, mouseY);
  if(keyCode == TAB) {   
    if (ui){
      cp5.hide();
      ui = false;
    } else {
      cp5.show();
      singleShapeMenu.hide();
      ui = true;
    }
  }
  if (ui == false){
    switch (whichTab){
    case 1 : 
      drawKeyPressed();
      return;
    case 2 :
      animateKeyPressed();
      return;
    case 3 :    
      sequenceKeyPressed();
      return;
    }
  }
}

void mouseWheel(MouseEvent event){ 
  if (ui == false){
    switch (whichTab){
    case 1 : 
      drawMouseWheel(event);
      return;
    case 2 :
      animateMouseWheel(event);
      return;
    case 3 :    
      sequenceMouseWheel(event);
      return;
    }
  }
}

void drawMousePressed(){
  currentNodes.add(new PVector(mouseX, mouseY));
  if (draw){
    if ((int)drawMode.getValue() == 2 && onClick.getState()){
      if (currentNodes.size() == 1){
        //double the starting point in order to draw the line in addTemporaryShape
        currentNodes.add(currentNodes.get(0));
      }
      addTemporaryShape(2, currentNodes.toArray(new PVector[currentNodes.size()]), currentStyle);
    }
  }
  if(edit){  
    if (mouseButton == RIGHT){
      for (Shape s : activeShapes){
        if (s.selected){
          for (int i = 0; i < s.trajectory.nodePath.size(); i++){
            if (isInside(currentNodes.get(0), s.trajectory.nodePath.get(i).pos, new PVector(5, 5))){
              s.selectNode(i);
              return;
            }
          }
        } else {
          if (isInside(currentNodes.get(0), s.axis.pos, new PVector(10, 10))){
            s.selectShape();
            return;
          }
        }
      }
    }     
    if (mouseButton == LEFT){
      for (Shape s : activeShapes){
        if (isInside(currentNodes.get(0), s.axis.pos, new PVector(10, 10))){
          s.translate = true;
          s.selectShape();
          println(activeShapes.indexOf(s));
          return;
        }
        for (int i = 0; i < s.trajectory.nodePath.size(); i++){
          if (isInside(currentNodes.get(0), s.trajectory.nodePath.get(i).pos, new PVector(5, 5))){
            s.translate = true;
            s.selectNode(i);
          } else {
            s.deselectNode(i);
          }
        }
      }
    }    
  }
}

void drawMouseDragged(){
  if (edit){
    if (mouseButton == RIGHT){
      if (temporaryShapes.size()>0) {
        temporaryShapes.remove(0);
      }
      noFill();
      stroke(0);
      strokeWeight(1);
      temporaryShapes.add(createShape(RECT, currentNodes.get(0).x, currentNodes.get(0).y, mouseX-currentNodes.get(0).x, mouseY-currentNodes.get(0).y));
      return; 
    }     
    if (mouseButton == LEFT){
      for (Shape s : activeShapes){
        if (s.translate){
          s.drag(new PVector(mouseX-pmouseX, mouseY-pmouseY));
          return;
        }
      }
    }
  }

  if (draw){
    if (onClick.getState()){
      currentNodes.set(currentNodes.size()-1, new PVector(mouseX, mouseY));
      temporaryShapes.remove(temporaryShapes.size()-1);
    } else {
      currentNodes.add(new PVector(mouseX, mouseY));
    }
    addTemporaryShape((int)drawMode.getValue(), currentNodes.toArray(new PVector[currentNodes.size()]), currentStyle);    
  }
}

void drawMouseReleased(){
  if (edit) {
    if (mouseButton == RIGHT){
      temporaryShapes.clear();
      PVector range = new PVector(mouseX, mouseY).sub(currentNodes.get(0)).div(2);
      PVector center = range.copy().add(currentNodes.get(0));
      for (Shape s : activeShapes){
        if (isInside(s.axis.pos, center, range)){
          s.selected = true;
        }
      }      
    }
    if (mouseButton == LEFT){
      for (Shape s : activeShapes){
        if (s.translate){
          s.translate = false;
        }
        for (Node n : s.trajectory.nodePath){
          n.selected = false;
        }
      }
    }
    currentNodes.clear();
    return;
  }
  if (temporaryShapes.size() > 0){
    if (onClick.getState()){
      return;
    }
    temporaryShapes.clear();
    PVector currentMouse = new PVector(mouseX, mouseY);
    Trajectory trajectory = new Trajectory(new Node[0]);
    switch((int)drawMode.getValue()){
    case 1 :
      for (int i = 0; i < (int)nodesPerLine.getValue(); i++){
        PVector step = trajectorySingle(currentNodes.get(0), new PVector(mouseX, mouseY), (int)nodesPerLine.getValue()-1, i).copy();
        trajectory.nodePath.add(new Node(step));
      }
      break;
    case 2 :     
      for (PVector p : currentNodes){
        trajectory.nodePath.add(new Node(p));
      }
      break;
    case 3 :
      for (int i = 0; i < gonSides; i++) {
        trajectory.nodePath.add(new Node(currentMouse));
        currentMouse = rotatePV(currentMouse, currentNodes.get(0), 2*PI/gonSides);
        for (int j = 1; j < verticesPerSide; j++){
          trajectory.nodePath.add(new Node(trajectorySingle(trajectory.nodePath.get(trajectory.nodePath.size()-j).pos, currentMouse, verticesPerSide, j)));
        }
      }
      break;
    case 4 :
      trajectory.nodePath.add(new Node(currentNodes.get(0)));
      int divider = (int)currentNodes.size()/3;
      for (int i = 1; i < 3; i++){
        trajectory.nodePath.add(new Node(currentNodes.get(i*divider)));
      }
      trajectory.nodePath.add(new Node(currentNodes.get(currentNodes.size()-1)));
      break;  
    case 5 :
      for (int i = 0; i < currentNodes.size(); i++){
        if (i%sampleRate == 0){
          trajectory.nodePath.add(new Node(currentNodes.get(i)));
        }
      }
      while (trajectory.nodePath.size()%3 != 1){
        trajectory.nodePath.remove(trajectory.nodePath.size()-1);
      }
      println(trajectory.nodePath.size());
      if (smoothEdges.getState()){
        trajectory.smoothBezier();
      }
      break;
    case 6 :
    //circle out of beziers
      float density = curvesPerCircle;
      float angle = 2 * PI / density;
      float fi = 1.00862458 * angle / PI;
      PVector center = currentNodes.get(0).copy(); 
      float rad = center.dist(currentMouse);
      PVector start = center.copy().add(rad, 0);     
      
      ArrayList<PVector> cp = new ArrayList<PVector>();
      cp.add(new PVector(start.x, start.y));
      cp.add(new PVector(start.x, start.y + rad * tan(fi)));
      cp.add(new PVector(center.x + rad * cos(angle) + rad * tan(fi) * sin(angle), center.y + rad * sin(angle) - rad * tan(fi) * cos(angle)));
      cp.add(new PVector(center.x + rad*cos(angle), center.y + rad*sin(angle)));
      
      trajectory.nodePath.add(new Node(cp.get(0)));  
      
      for (int i = 0; i < density; i++){
        for (int j = 1; j < 4; j++){
          trajectory.nodePath.add(new Node(cp.get(j)));
          cp.set(j, rotatePV(cp.get(j), center, angle)); 
        }
      }
      break; 
    case 7 :
      //any need for a text temporary shape?
      break;    
    }
    
    Shape s = new Shape((int)drawMode.getValue(), trajectory, currentStyle, closedShape, false);
    activeShapes.add(s);    
    currentNodes.clear();    
  }
}

void drawKeyPressed(){
  if (edit){
    if (key == 'q'){
      hideNodes = flick(hideNodes);
    }
    if (key == 'f'){
      for (int i = activeShapes.size()-1; i >= 0; i--){
        if (activeShapes.get(i).selected){
          activeShapes.get(i).bringToFront();
        }
      }
    }
    if (key == 'b'){
      for (int i = activeShapes.size()-1; i >= 0; i--){
        if (activeShapes.get(i).selected){
          activeShapes.get(i).bringToBack();
        }
      }
    }
    if (key == ','){
      for (Shape s : activeShapes){
        if (s.selected){
          s.squishShape(s.axis, new Node(new PVector(mouseX, mouseY)), 1.05);
        }
      }
    }
    if (key == '.'){
      for (Shape s : activeShapes){
        if (s.selected){
          s.squishShape(s.axis, new Node(new PVector(mouseX, mouseY)), 1/1.05);
        }
      }
    }
  }
  if (key == ENTER && (int)drawMode.getValue() == 2){   
    Shape s = new Shape(2, PVectorToTrajectory(currentNodes), currentStyle, closedShape, false);
    activeShapes.add(s);
    currentNodes.clear();
    temporaryShapes.clear();
    return;
  }
  if (key == 'e'){
    edit = true;
    draw = false;
    return;
  }
  if (key == 'd'){
    draw = true;
    edit = false;
    for (Shape s : activeShapes){
      s.deselectShape();
      singleShapeMenu.hide();
    }
    return;
  }
  if (key == BACKSPACE){
    for (int i = activeShapes.size()-1; i >= 0; i--){
      if (activeShapes.get(i).selected){
        activeShapes.remove(i);
        singleShapeMenu.hide();
      }
    }
  }
}

void drawMouseWheel(MouseEvent event){
  if (edit){
    for (Shape s : activeShapes){
      if (s.selected){
        if (event.getCount() > 0) {
          s.scaleShape(s.axis, 1.01);
        } else {
          s.scaleShape(s.axis, 1/1.01);
        }
      }
    }
  }
}

void animateMousePressed(){
}
void animateMouseDragged(){
}
void animateMouseReleased(){
}
void animateKeyPressed(){
}
void animateMouseWheel(MouseEvent event){
}


void sequenceMousePressed(){
}
void sequenceMouseDragged(){
}
void sequenceMouseReleased(){
}
void sequenceKeyPressed(){
}
void sequenceMouseWheel(MouseEvent event){
}

void addTemporaryShape(int type, PVector[] points, PStyle style){
  PShape p = createShape();
  switch(type){
  case 1 :
    temporaryShapes.clear();
    p.beginShape(LINES);
    p.vertex(currentNodes.get(0).x, currentNodes.get(0).y);
    p.vertex(mouseX, mouseY); 
    break;
  case 2 :
    p.beginShape(LINES);
    p.vertex(currentNodes.get(currentNodes.size()-2).x, currentNodes.get(currentNodes.size()-2).y);
    p.vertex(currentNodes.get(currentNodes.size()-1).x, currentNodes.get(currentNodes.size()-1).y);
    break;
  case 3 :     
    temporaryShapes.clear();
    PVector currentMouse = currentNodes.get(currentNodes.size()-1).copy();
    p.beginShape();
    for (int j = 0; j < gonSides; j++) {
      p.vertex(currentMouse.x, currentMouse.y);
      currentMouse = rotatePV(currentMouse, currentNodes.get(0), (2*PI/gonSides));
    }
    break;
  case 4 :
    int size = currentNodes.size()-1;
    p.beginShape();
    p.vertex(currentNodes.get(0).x, currentNodes.get(0).y);
    p.bezierVertex(currentNodes.get((int)size/3).x, currentNodes.get((int)size/3).y, currentNodes.get((int)2*size/3).x, currentNodes.get((int)2*size/3).y, currentNodes.get(size).x, currentNodes.get(size).y);
    break;  
  case 5 :
    p.beginShape(LINES);
    p.vertex(pmouseX, pmouseY);
    p.vertex(mouseX, mouseY);
    break;
  case 6 :
    temporaryShapes.clear();
    float diam = 2*(new PVector(mouseX, mouseY)).dist(currentNodes.get(0));
    p = createShape(ELLIPSE, currentNodes.get(0).x, currentNodes.get(0).y, diam, diam);     
    break;   
  }
  
  if (type != 6){
    p.endShape();
  }
  p.setFill(style.fillColor);    
  p.setStroke(style.strokeColor);      
  p.setStrokeWeight(style.strokeWeight); 
    
  temporaryShapes.add(p);
}
