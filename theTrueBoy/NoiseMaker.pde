class NoiseMaker{
  //all noise related values go here
  Node noiseAxis = new Node(new PVector(150, 150)); 
  Trajectory originalTraj;
  Trajectory  noisePath;
  float heading = 0;
  PVector shapeSize = new PVector(1, 1);
  PVector translation = new PVector(0, 0);
  ArrayList<PVector> offset = new ArrayList<PVector>();
  //PImage[] noiseFieldLayers = new PImage[3];
  PImage noiseFieldImage;
  Boolean translateAxis;
  
  NoiseMaker(Shape s){
    originalTraj = s.trajectory.copyTrajectory();
    buildNoiseField(.03, .03, 0, 0, 0);
    buildNoiseTrajectory(3, s.trajectory.nodePath.size());
  }
  
  //different constructors (polymorphsim) based on whether or not you are
  //a) noising vertices b) noising a shapes path c) noising every vertex in a morphism etc
  NoiseMaker(Morphism m_){
  }
  
  //here we are generating a noiseSpace in 3 dimensions, expressed in the menu
  //as a field of colors. when nDist and oDist are nearby or one is close to 
  //zero, the noise generated  on that axis becomes similar to its neighbor axis
  //void buildNoiseField(/*float seed,*/ float xinc, float yinc, float mDist, float nDist, float mult){
  //  for (int i = 0; i <3; i++){
  //    noiseFieldLayers[i] = createImage(canvasSize.x, canvasSize.y, RGB);
  //    float xoff = 0;  
  //    for (int x = 0; x < noiseFieldLayers[i].width; x++){
  //      xoff += xinc;
  //      float yoff = 0;
  //      for (int y =  0; y < noiseFieldLayers[i].height; y++){
  //        yoff += yinc;      
  //        int loc = x + y*noiseFieldLayers[i].width;
  //        float m = map((float)noise.eval(xoff+mDist, yoff+mDist), -1, 1, 0, 255);
  //        float n = map((float)noise.eval(xoff+nDist, yoff+nDist), -1, 1, 0, 255);
  //        float o = map((float)noise.eval(xoff, yoff), -1, 1, 0, 255);
  //        noiseFieldLayers[i].pixels[loc] = color(m, n, o, map(mult, 1, 50, 10, 250));
  //      }
  //    }  
  //  }
  //}
  
  void buildNoiseField(/*float seed,*/ float xinc, float yinc, float mDist, float nDist, float mult){
    for (int i = 0; i <3; i++){
      noiseFieldImage = createImage(300, 300, RGB);
      float xoff = 0;  
      for (int x = 0; x < noiseFieldImage.width; x++){
        xoff += xinc;
        float yoff = 0;
        for (int y =  0; y < noiseFieldImage.height; y++){
          yoff += yinc;      
          int loc = x + y*noiseFieldImage.width;
          float m = map((float)noise.eval(xoff+mDist, yoff+mDist), -1, 1, 0, 255);
          float n = map((float)noise.eval(xoff+nDist, yoff+nDist), -1, 1, 0, 255);
          float o = map((float)noise.eval(xoff, yoff), -1, 1, 0, 255);
          noiseFieldImage.pixels[loc] = color(m, n, o, map(mult, 1, 50, 10, 250));
        }
      }  
    }
  }
  
  void buildNoiseTrajectory(int shape, int size){
    Node[] noiseSamples = new Node[size];
    PVector sample = new PVector(100, 100);
    PVector center = new PVector(150, 150);
    float r = 0;
    int sampleCounter = 0;
    switch(shape){
    case 0 :
      for (int i = 0; i < size; i++){
        noiseSamples[i] = new Node(trajectorySingle(sample, new PVector(200, 200), size, i));
      }
      break;
    case 1 :
      //triangle
      break;
    case 2 :
      float freq = 400/ (float)(size-1);
      while(sample.x < 200){
        noiseSamples[sampleCounter] = new Node(sample);
        sampleCounter++;
        sample.add(freq, 0);
      }
      r = sample.x - 200;
      sample.sub(new PVector(r, -r));
      while(sample.y < 200){
        noiseSamples[sampleCounter] = new Node(sample);
        sampleCounter++;
        sample.add(0, freq);
      }
      r = sample.y - 200;
      sample.sub(new PVector(r, r));
      while(sample.x > 100){
        noiseSamples[sampleCounter] = new Node(sample);
        sampleCounter++;
        sample.add(-freq, 0);
      }
      r = 100 - sample.x;
      sample.sub(new PVector(-r, r));
      while(sampleCounter < size){
        noiseSamples[sampleCounter] = new Node(sample);
        sampleCounter++;
        sample.add(0, -freq);
      }
      break;
    case 3 :           
      for (int i = 0; i < size; i++){
        noiseSamples[i] = new Node(sample);
        sample = rotatePV(sample, center, 2*PI/(size-1));
      }
      break;  
    }
    println(sampleCounter);    
    noisePath = new Trajectory(noiseSamples);
  }
  
  Shape updateShape(Shape s){
    PVector[] noiseAmounts = new PVector[originalTraj.nodePath.size()];
    for (int i = 0; i < noiseAmounts.length; i++){      
      PVector sampleLoc = noisePath.nodePath.get(i).pos.copy();
      float xChange = red(noiseFieldImage.get((int)sampleLoc.x, (int)sampleLoc.y));
      float yChange = green(noiseFieldImage.get((int)sampleLoc.x, (int)sampleLoc.y));
      xChange = map(xChange, 0, 255, -noiseMult.getValue(), noiseMult.getValue());
      yChange = map(yChange, 0, 255, -noiseMult.getValue(), noiseMult.getValue());
      PVector change = rotatePV(new PVector(xChange, yChange), new PVector(0, 0), rotateNoiseDirection.getValue()*2*PI/360).copy();
      if (isInside(noisePath.nodePath.get(i).pos, new PVector(150, 150), new PVector(150, 150))){        
        noiseAmounts[i] = change.add(originalTraj.nodePath.get(i).pos);
      } else {
        noiseAmounts[i] = originalTraj.nodePath.get(i).pos.copy();
      } 
    }
    s.animateSingleFrame(noiseAmounts);
    if (s.shapeType == 6){
      s.trajectory.smoothBezier();
      s.followTrajectory(false);
    }
    if (s.shapeType == 5){
      if (smoothEdges.getState()){
        s.trajectory.smoothBezier();
        s.followTrajectory(false);
      }
    }
    return s;
  }
  
  void display(){
    image(noiseFieldImage, addNoise.getPosition()[0], addNoise.getPosition()[1]+80);
    displayPath();
  }
  
  void rotateNoiseShape(float amount){
    heading += amount;
    for (Node n : noisePath.nodePath){
      n.rotateNode(noiseAxis, amount);
    }
  }
  
  void scaleNoiseShape(PVector amount){
    shapeSize.set(shapeSize.x*amount.x, shapeSize.y*amount.y);
    for (Node n : noisePath.nodePath){
      n.scaleNode(new Node(new PVector(150, n.pos.y)), amount.x);
      n.scaleNode(new Node(new PVector(n.pos.x, 150)), amount.y);
    }
  }
  
  void translateNoiseShape(PVector amount){
    translation.add(amount);
    for (Node n : noisePath.nodePath){
      n.drag(amount);
    }
  }
  
  void displayPath(){
    strokeWeight(1);
    for (Node n : noisePath.nodePath){
      fill(map(noisePath.nodePath.indexOf(n), 0, noisePath.nodePath.size(), 0, 255));
      ellipse(addNoise.getPosition()[0]+n.pos.x, addNoise.getPosition()[1]+80+n.pos.y, 4, 4);
    }
    fill(255, 0, 0);
    ellipse(addNoise.getPosition()[0]+noiseAxis.pos.x, addNoise.getPosition()[1]+80+noiseAxis.pos.y, 5, 5);
  }
  
  //we can also have similarly named methods with different arguments
  void displayTemporary(){
  }
  
  
  
  //Shape returnShape(){
  //}

}
  
