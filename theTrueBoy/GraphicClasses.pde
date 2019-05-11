//might be useless
class PGCopy{
  PGraphics tile;
  Shape[] shapes;
  Node axis, tl, br;
  PVector tileScale = new PVector(1, 1);
  boolean selected = false;
  
  PGCopy(Shape[] shapes_){
    shapes = new Shape[shapes_.length];
    Node[] axes = new Node[shapes_.length];
    for (int i = 0; i < shapes_.length; i++){
      shapes[i] = shapes_[i].copyShape();
      axes[i] = shapes_[i].axis.copyNode();
    }
    axis = new Node(averageNodePosA(axes));
    tl = axis.copyNode();
    br = axis.copyNode();
    
    frameTile();
    tile.beginDraw();   
    tile.scale(tileScale.x, tileScale.y);
    tile.background(0, 0);
    for (Shape s : shapes){
      tile.fill(s.style.fillColor);
      tile.stroke(s.style.strokeColor);
      tile.strokeJoin(ROUND);
      tile.strokeWeight(s.style.strokeWeight);
      tile.beginShape();
      for (int i = 0; i < s.trajectory.nodePath.size(); i++){
        tile.vertex(s.trajectory.nodePath.get(i).pos.x-tl.pos.x, s.trajectory.nodePath.get(i).pos.y-tl.pos.y);
      }
      //if (s.shape.isFilled()){
      //  tile.noFill();
      //}
      //if (s.shape.isStroked()){
      //  tile.noStroke();
      //}
      if (s.shape.isClosed()){
        tile.endShape(CLOSE);
      } else {
        tile.endShape(OPEN);
      }
    }
    tile.endDraw(); 
  }
  
  void frameTile(){
    for (Shape s : shapes){
      for (int i = 0; i < s.trajectory.nodePath.size(); i++){
        if (s.trajectory.nodePath.get(i).pos.x < tl.pos.x){
          tl.drag(new PVector(s.trajectory.nodePath.get(i).pos.x-tl.pos.x, 0));
        }
        if (s.trajectory.nodePath.get(i).pos.x > br.pos.x){
          br.drag(new PVector(s.trajectory.nodePath.get(i).pos.x-br.pos.x, 0));
        }
        if (s.trajectory.nodePath.get(i).pos.y < tl.pos.y){
          tl.drag(new PVector(0, s.trajectory.nodePath.get(i).pos.y-tl.pos.y));
        }
        if (s.trajectory.nodePath.get(i).pos.y > br.pos.y){
          br.drag(new PVector(0, s.trajectory.nodePath.get(i).pos.y-br.pos.y));
        } 
      }
    }
    
    tl.pos.sub(new PVector(20, 20));
    br.pos.add(new PVector(20, 20));
    int copyWidth = (int)(br.pos.x-tl.pos.x);
    int copyHeight = (int)(br.pos.y-tl.pos.y);   
    tile = createGraphics(copyWidth, copyHeight);
  }
   
  void display(){
    image(tile, tl.pos.x, tl.pos.y);
  }
}
