boolean isInside(PVector point, PVector target, PVector range){
  PVector p1 = target.copy().sub(abs(range.x), abs(range.y));
  PVector p2 = target.copy().add(abs(range.x), abs(range.y));
  boolean x = false;
  boolean y = false;
  if (p1.x < point.x){
    if (point.x < p2.x){
      x = true;
    }
  }else if(point.x > p2.x){
    x= true;
  }
  if (p1.y < point.y){
    if (point.y < p2.y){
      y = true;
    }
  }else if(point.y > p2.y){
    y= true;
  }
  if (x && y){
    return true;
  }else{
    return false;
  }
}

boolean flick(boolean switcher){
  if (switcher){
    return false;
  }else{
    return true;
  }   
}

PVector averagePosA(PVector[] list){
  PVector sum = new PVector(0, 0);
  for (int i = 0; i < list.length; i++){
    sum.add(list[i]);
  }
  return sum.div(list.length);
}

PVector averagePosAL(ArrayList<PVector> list){
  PVector sum = new PVector(0, 0);
  for (int i = 0; i < list.size(); i++){
    sum.add(list.get(i));
  }
  return sum.div(list.size());
}

PVector averageNodePosAL(ArrayList<Node> list){
  PVector sum = new PVector(0, 0);
  for (int i = 0; i < list.size(); i++){
    sum.add(list.get(i).pos);
  }
  return sum.div(list.size());
}

PVector averageNodePosA(Node[] list){
  PVector sum = new PVector(0, 0);
  for (int i = 0; i < list.length; i++){
    sum.add(list[i].pos);
  }
  return sum.div(list.length);
}

PVector rotatePV(PVector point, PVector axis, float angle){
  float s = sin(angle);
  float c = cos(angle);
  point.x -= axis.x;
  point.y -= axis.y;
  float xnew = point.x * c - point.y * s;
  float ynew = point.x * s + point.y * c;
  point.x = xnew + axis.x;
  point.y = ynew + axis.y;
  return point;
}

PVector scalePV(PVector point, PVector axis, float amount){
  point.x -= axis.x;
  point.y -= axis.y;
  point.mult(amount);
  point.x += axis.x;
  point.y += axis.y;
  return point;
}

Node scaleNode(Node n, Node axis, float mult){
  n.pos.x -= axis.pos.x;
  n.pos.y -= axis.pos.y;
  n.pos.mult(mult);
  n.pos.x += axis.pos.x;
  n.pos.y += axis.pos.y;
  return n;
}

Trajectory fromPVectors(PVector[] points){
  Node[] nodes = new Node[points.length];
  for (int i = 0; i < points.length; i++){
    nodes[i] = new Node(points[i]);
  }
  return new Trajectory(nodes);
}

PVector trajectorySingle(PVector s, PVector f, int total, int which){
  PVector where = new PVector();
  float fraction = (float)which/(float)total;
  where.x = s.x + fraction*(f.x-s.x);
  where.y = s.y + fraction*(f.y-s.y);
  return where;
}

PVector halfway(PVector s, PVector f){
  PVector where = new PVector();
  where.x = (s.x + f.x)/2;
  where.y = (s.y + f.y)/2;
  return where;
}

color blink(color input, int alpha){
  int a = (input >> 24) & 0xFF;
  int r = (input >> 16) & 0xFF;
  int g = (input >> 8) & 0xFF;
  int b = input & 0xFF;  
  if (a == alpha){
    return color(r, g, b, a);
  } else {
    return color(r, g, b, a/2);
  }
}

PStyle copyStyle(PStyle s) {
  PStyle ns = new PStyle();
  ns.imageMode = s.imageMode;
  ns.rectMode = s.rectMode;
  ns.ellipseMode = s.ellipseMode;
  ns.shapeMode = s.shapeMode;

  ns.blendMode = s.blendMode;

  ns.colorMode = s.colorMode;
  ns.colorModeX = s.colorModeX;
  ns.colorModeY = s.colorModeY;
  ns.colorModeZ = s.colorModeZ;
  ns.colorModeA = s.colorModeA;

  ns.tint = s.tint;
  ns.tintColor = s.tintColor;
  ns.fill = s.fill;
  ns.fillColor = s.fillColor;
  ns.stroke = s.stroke;
  ns.strokeColor = s.strokeColor;
  ns.strokeWeight = s.strokeWeight;
  ns.strokeCap = s.strokeCap;
  ns.strokeJoin = s.strokeJoin;

  // TODO these fellas are inconsistent, and may need to go elsewhere
  /*
  ns.ambientR = s.ambientR;
  ns.ambientG = s.ambientG;
  ns.ambientB = s.ambientB;
  ns.specularR = s.specularR;
  ns.specularG = s.specularG;
  ns.specularB = s.specularB;
  ns.emissiveR = s.emissiveR;
  ns.emissiveG = s.emissiveG;
  ns.emissiveB = s.emissiveB;
  ns.shininess = s.shininess;

  ns.textFont = s.textFont;
  ns.textAlign = s.textAlign;
  ns.textAlignY = s.textAlignY;
  ns.textMode = s.textMode;
  ns.textSize = s.textSize;
  ns.textLeading = s.textLeading;
  */
  
  return ns;
}

Trajectory openSimplexLoop(Node seed, int dx, int dy, int size, float rangeX, float rangeY){
  ArrayList<Node> noiseLoop = new ArrayList<Node>();
  float inc = TWO_PI/size;
  for (float a = 0; a < TWO_PI; a += inc){
    float xoff = (float)seed.pos.x/dx + map(cos(a), -1, 1, 0, 2);
    float yoff = (float)seed.pos.y/dy + map(sin(a), -1, 1, 0, 2);
    float r = map((float)noise.eval(xoff, yoff), -1, 1, -rangeX/2, rangeX/2);
    float s = map((float)noise.eval(16+xoff, 16+yoff), -1, 1, -rangeY/2, rangeY/2);  
    float x = r*cos(a);
    float y = s*sin(a);
    PVector noiseSlice = new PVector(x, y);
    noiseSlice.add(seed.pos);
    noiseLoop.add(new Node(noiseSlice));
  }   
  
  Node[] path = new Node[noiseLoop.size()];
    for (int i = 0; i < noiseLoop.size(); i++){
      path[i] = noiseLoop.get(i).copyNode();
    }
  return new Trajectory(path);
}

Trajectory PVectorToTrajectory(ArrayList<PVector> list){
  Trajectory t = new Trajectory(new Node[0]);
  for (PVector p : list){
    t.nodePath.add(new Node(p));
  }
  return t;
}

Trajectory PerlinLoop(Node seed, int dx, int dy, int size, float rangeX, float rangeY){
  ArrayList<Node> noiseLoop = new ArrayList<Node>();
  float inc = TWO_PI/size;
  for (float a = 0; a < TWO_PI; a += inc){
    float xoff = (float)seed.pos.x/dx + map(cos(a), -1, 1, 0, 2);
    float yoff = (float)seed.pos.y/dy + map(sin(a), -1, 1, 0, 2);
    float r = map((float)noise(xoff, yoff), -1, 1, -rangeX/2, rangeX/2);
    float s = map((float)noise(16+xoff, 16+yoff), -1, 1, -rangeY/2, rangeY/2);  
    float x = r*cos(a);
    float y = s*sin(a);
    PVector noiseSlice = new PVector(x, y);
    noiseSlice.add(seed.pos);
    noiseLoop.add(new Node(noiseSlice));
  }    
  
  Node[] path = new Node[noiseLoop.size()];
    for (int i = 0; i < noiseLoop.size(); i++){
      path[i] = noiseLoop.get(i).copyNode();
    }
  return new Trajectory(path);
}

int addUntilNew(int number, int[] comparison){
  for (int i : comparison){
    if (number == i){
      number++;
      number = number%comparison.length;
      number = addUntilNew(number, comparison);
    }
  }
  return number;
}
