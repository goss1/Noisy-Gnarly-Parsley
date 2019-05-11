/*
spend a day organizing your life. The interactions tab should be more sensible. Figure
out which miscellaneous functions can be in classes, get rid of unused code

TO DO:
- extend Button in order to build color palette inside cp5
- no controlp5 inside classes. Have all menus in main
- methods in shape for triangulating
- make an axisCopy for everything
- fix blink
- use bezierDetail() when transforming from curve to line?
- look over dirp and figure out which features you want to keep

ARRAYLIST TIPS
add(int index, E element)
Inserts the specified element at the specified position in this list.

contains(Object o)
Returns true if this list contains the specified element

indexOf(Object o)
Returns the index of the first occurrence of the specified element in this list, or -1 if this list does not contain the element.
*/

import controlP5.*;

ControlP5 cp5;
ControlP5 singleShapeMenu;
ControlP5 noiseMenu;

PVector canvasSize = new PVector(1440, 900);
OpenSimplexNoise noise;
color bg;
PApplet main = this;
boolean ui = true;
boolean closedShape;
boolean edit, noiseMenuOn, hideNodes;
boolean draw = true;

PStyle currentStyle = new PStyle();
PShape exampleShape = new PShape();
String[] settingsLabels = {"A2BS", "freeDrawS", "gonS", "A2B2C2DS", "freeCurveS", "ellipseS", "textS"};

ArrayList<PVector> currentNodes = new ArrayList<PVector>();
ArrayList<PImage> backgrounds = new ArrayList<PImage>();
ArrayList<PShape> temporaryShapes = new ArrayList<PShape>();
ArrayList<Button> palette = new ArrayList<Button>();
ArrayList<Shape> activeShapes = new ArrayList<Shape>();
//ArrayList<ShapeGroup> activeGroups = new ArrayList<ShapeGroup>();
//ArrayList<Animation> activeAnimations = new ArrayList<Animation>();
ArrayList<PGCopy> activePGCopies = new ArrayList<PGCopy>();

ArrayList<Node> activeNodes = new ArrayList<Node>();
ArrayList<Trajectory> activeTrajectories = new ArrayList<Trajectory>();
ArrayList<Morphism> activeMorphisms = new ArrayList<Morphism>();

RadioButton drawMode;
RadioButton whichColor;
RadioButton updateWhichColor;

Accordion drawAccordion;
Accordion animateAccordion;
Accordion sequenceAccordion;
Accordion shapeAccordion;

Group updateStyle;
Group noiseGroup;
ColorPicker cp;
ColorPicker updateCP;
Toggle onClick;
Toggle calligraphy;
Toggle smoothEdges;

Button addPalette;
Group addNoise;
Button animateShape;
Button randomizeVerts;
Knob rotateShape;
Knob rotateNoiseShape;
Knob rotateNoiseDirection;
Slider strokeWeight;
Slider nodesPerLine;
Slider updateStrokeWeight;
Slider calligraphyInertia;
RadioButton noiseShape;
Slider2D scaleNoiseField;
Slider2D translateNoiseField;
Slider2D translateNoiseShape;
Slider2D translateNoiseAxis;

Slider noiseMult;
Slider2D scaleNoiseShape;
Button commitNoise;
Range calligraphySWRange;
int curvesPerCircle;
int gonSides;
int verticesPerSide;
int whichTab = 1;
int sampleRate = 5;

void setup(){
  size(1440, 900, P2D);
  noise = new OpenSimplexNoise();
  buildUI();
}

void draw(){
  switch(whichTab){
  case 1 :
    drawLoop();
    break;
  case 2 :
    animateLoop();
    break;
  case 3 : 
    sequenceLoop();
    break;
  }
}

void drawLoop(){
  //some code that handles setting the background (if there is one) each frame.
  //solid color, PImage, etc.
  background(bg);
  //we need a method of ordering different types for display (can't necessarily display 
  //all Shape before other graphics, unless we can somehow fit other graphics into Shape
  //class (unlikely))
  for (Shape s : activeShapes){
    s.display();
  }
  if (edit){  
    if (!hideNodes){
      for (Shape s : activeShapes){
        s.displaySelected();
      }
    }
  }
  for (PShape p : temporaryShapes){
    shape(p);
  }
  if (cp5.isVisible()){ 
    shape(exampleShape);
  }
  if (singleShapeMenu.isVisible()){ 
    if (addNoise.isOpen()){ 
      for (Shape s : activeShapes){
        if (s.selected){
          s.noise.display();
        }
      }
    }
  }
}

void animateLoop(){
  background(bg);
  //we need a method of ordering different types for display (can't necessarily display 
  //all Shape before all PGCopy)
  //for (Animation a  : activeAnimations){
    //a.display();
  //}
}

void sequenceLoop(){
}

void buildUI(){
  cp5 = new ControlP5(this);
  
  cp5.getTab("default")
    .activateEvent(true)
    .setLabel("draw")
    .setId(1)
    ;
     
  cp5.addTab("animate")
    .activateEvent(true)  
    .setId(2)
    ;
     
  cp5.addTab("sequence")
    .activateEvent(true)
    .setId(3)
    ;
     
  // if you want to receive a controlEvent when
  // a  tab is clicked, use activeEvent(true)
  
  Group drawMenu = cp5.addGroup("draw")
                .setBackgroundHeight(200)
                .setBackgroundColor(color(0, 10));
                ;
                
  Group styleMenu = cp5.addGroup("style")
                .setBackgroundHeight(200)
                .setBackgroundColor(color(0, 10));
                ;
                
  Group shapeMenu = cp5.addGroup("shape")
                .setBackgroundHeight(200)
                .setBackgroundColor(color(0, 10));
                ; 
    
  whichColor = cp5.addRadioButton("whichColor")
    .setPosition(275, 10)
    .addItem("fill", 1)
    .addItem("stroke", 2)
    .addItem("background", 3)
    .moveTo(styleMenu)
    .activate(0)
    ;  
    
  cp = cp5.addColorPicker("colorpicker")
    .activateEvent(true)
    .setPosition(10, 10)
    .moveTo(styleMenu)
    ;
    
  addPalette = cp5.addButton("")
    .setSize(15, 15)
    .setPosition(250, 54)
    .moveTo(styleMenu)    
    ;
     
  strokeWeight = cp5.addSlider("strokeWeight")
    .setPosition(10, 80)
    .setSize(200,10)
    .setRange(0, 50)
    .setValue(3)
    .moveTo(styleMenu)
    ;
    
  cp5.addToggle("closedShape")
    .setPosition(10, 170)
    .setSize(10, 10)
    .setLabelVisible(false)
    .moveTo(shapeMenu)
    ;  
   
  cp5.addTextlabel("close shape")
    .setText("close shape")
    .setPosition(20, 170)
    .moveTo(shapeMenu)
    ;  
    
  //float[] state = {1, 0, 0};
    
  drawMode = cp5.addRadioButton("drawMode")
    .setPosition(10, 10)
    .addItem("A2B", 1)
    .addItem("freeDraw", 2)
    .addItem("gon", 3)
    .addItem("A2B2C2D", 4)
    .addItem("freeCurve", 5)
    .addItem("ellipse", 6)
    .addItem("text", 7)
    .moveTo(shapeMenu)
    .activate(0)
    ;
  
  Group A2BSettings = cp5.addGroup("A2BS")
    .setBackgroundColor(color(0, 10))
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
  ;
  
  nodesPerLine = cp5.addSlider("nodesPerLine")
    .setPosition(10, 10)
    .setSize(150,10)
    .setRange(2, 100)
    .setValue(2)
    .moveTo(A2BSettings)
    ;
  
  Group freeDrawSettings = cp5.addGroup("freeDrawS")
    .setBackgroundColor(color(0, 50))
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
    .hide()
  ; 
  
  onClick = cp5.addToggle("onClick")
    .setSize(10, 10)
    .setPosition(10, 10)
    .moveTo(freeDrawSettings)
    ;
    
  calligraphy = cp5.addToggle("calligraphy")
    .setSize(10, 10)
    .setPosition(10, 40)
    .moveTo(freeDrawSettings)
    ; 
    
  calligraphySWRange = cp5.addRange("SW Range")
    // disable broadcasting since setRange and setRangeValues will trigger an event
    .setBroadcast(false) 
    .setPosition(10, 70)
    .setSize(130, 10)
    .setHandleSize(5)
    .setRange(1, 50)
    .setRangeValues(10,20)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true) 
    .moveTo(freeDrawSettings)
    ;
     
  calligraphyInertia = cp5.addSlider("inertia")
    .setPosition(10, 90)
    .setSize(130, 10)
    .setRange(.05, 1)
    .setValue(1)
    .moveTo(freeDrawSettings)
    ;
     
  Group gonSettings = cp5.addGroup("gonS")
    .setBackgroundColor(color(0, 50))
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
    .hide()
  ;
   
  Group A2B2C2DSettings = cp5.addGroup("A2B2C2DS")
    .setBackgroundColor(color(0, 50))
    .setBackgroundHeight(200)
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
    .hide()
  ;
  
  Group freeCurveSettings = cp5.addGroup("freeCurveS")
    .setBackgroundColor(color(0, 50))
    .setBackgroundHeight(200)
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
    .hide()
  ;
  
  smoothEdges = cp5.addToggle("smoothEdges")
    .setSize(10, 10)
    .setPosition(10, 30)
    .moveTo(freeCurveSettings)
    ;  
  
  Group ellipseSettings = cp5.addGroup("ellipseS")
    .setBackgroundColor(color(0, 50))
    .setBackgroundHeight(200)
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
    .hide()
  ;
  
  Group textSettings = cp5.addGroup("textS")
    .setBackgroundColor(color(0, 50))
    .setBackgroundHeight(200)
    .setPosition(85, 20)
    .setWidth(200)
    .setBackgroundHeight(165)
    .moveTo(shapeMenu)
    .hide()
  ;
  
  cp5.addSlider("sampleRate")
    .setSize(120, 10)
    .setPosition(10, 10)
    .setRange(1, 8)  
    .setValue(4)
    .setNumberOfTickMarks(8)
    .moveTo(freeCurveSettings)
    ;
    
  cp5.addSlider("curvesPerCircle")
    .setPosition(10, 10)
    .setRange(4, 16)   
    .setValue(4)
    .setNumberOfTickMarks(13)
    .moveTo(ellipseSettings)
    ;
    
  cp5.addSlider("gonSides")
    .setSize(150, 10)
    .setPosition(10, 10)
    .setRange(3, 30) 
    .setNumberOfTickMarks(28)
    .moveTo(gonSettings)
    ;
    
  cp5.addSlider("verticesPerSide")
    .setPosition(10, 30)
    .setRange(1, 20)   
    .setNumberOfTickMarks(20)
    .moveTo(gonSettings)
    ;  

  drawAccordion = cp5.addAccordion("acc1")
    .setPosition(40,40)
    .setWidth(350)
    .addItem(styleMenu)
    .addItem(shapeMenu)
    .addItem(drawMenu)
    ;

  /*               
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
  */
  
  drawAccordion.open(0,1,2);
  
  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  drawAccordion.setCollapseMode(Accordion.MULTI);
 
  // when in SINGLE mode, only 1 accordion  
  // group can be open at a time.  
  // accordion.setCollapseMode(Accordion.SINGLE);
  currentStyle.fillColor =  color(random(255), random(255),random(255));
  currentStyle.strokeColor = color(random(255), random(255),random(255));
  currentStyle.strokeWeight = strokeWeight.getValue();
  bg = color(random(255), random(255),random(255));
  cp.setColorValue(currentStyle.fillColor);
  
  exampleShape = createShape(ELLIPSE, 348, 120, 45, 45);
  exampleShape.setFill(currentStyle.fillColor);
  exampleShape.setStroke(currentStyle.strokeColor);
  exampleShape.setStrokeWeight(currentStyle.strokeWeight);

  
  singleShapeMenu = new ControlP5(this);
  
  new DragButton(singleShapeMenu, "dragMenu", new PVector (10, 10))
    .setSize(15, 15)
    .setPosition(0, 0)
    ;
    
  rotateShape = singleShapeMenu.addKnob("rotateShape")
    .setRange(0, 360)
    .setValue(0)
    .setPosition(30,0)
    .setRadius(30)
    .setAngleRange(2*PI)
    .setStartAngle(-PI/2)
    .setViewStyle(1)
    ;  
  
  animateShape = singleShapeMenu.addButton("animate")
    .setPosition(100, 25)
    .setSize(45, 15)
    ; 
    
  randomizeVerts = singleShapeMenu.addButton("randomizeVerts")
    .setPosition(150, 25)
    .setSize(45, 15)
    ; 
    
  addNoise = singleShapeMenu.addGroup("noise")
    .close()
    ; 
   
  noiseShape = cp5.addRadioButton("noiseShape")
    .setPosition(5, 310)
    .addItem("line",0)
    .addItem("triangle", 1)
    .addItem("square", 2)
    .addItem("circle", 3)
    .moveTo(addNoise)
    .activate(3)
    ;
    
  rotateNoiseShape = singleShapeMenu.addKnob("rotateNoiseShape")
    .setRange(0, 360)
    .setValue(0)
    .setPosition(230, 310)
    .setRadius(30)
    .setAngleRange(2*PI)
    .setStartAngle(-PI/2)
    .setViewStyle(1)
    .moveTo(addNoise)
    ;  
   
  rotateNoiseDirection = singleShapeMenu.addKnob("rotateNoiseDirection")
    .setRange(0, 360)
    .setValue(0)
    .setPosition(230, 500)
    .setRadius(30)
    .setAngleRange(2*PI)
    .setStartAngle(-PI/2)
    .setViewStyle(1)
    .moveTo(addNoise)
    ;
    
  scaleNoiseField = singleShapeMenu.addSlider2D("scaleNoiseField")
    .setPosition(50, 400)
    .setSize(70, 70)
    .setMinMax(0, 0, .1, .1)
    .setValue(.03, .03)
    .moveTo(addNoise)
    ; 
    
  translateNoiseField = singleShapeMenu.addSlider2D("translateNoiseField")
    .setPosition(130,400)
    .setSize(70, 70)
    .setMinMax(0, 0, 1, 1)
    .setValue(0, 0)
    .moveTo(addNoise)
    ;
  
  translateNoiseShape = singleShapeMenu.addSlider2D("translateNoiseShape")
    .setPosition(130,310)
    .setSize(70, 70)
    .setMinMax(-200, -200, 200, 200)
    .setValue(0, 0)
    .moveTo(addNoise)
    ; 
    
  translateNoiseAxis = singleShapeMenu.addSlider2D("translateNoiseAxis")
    .setPosition(220,400)
    .setSize(70, 70)
    .setMinMax(-100, -100, 100, 100)
    .setValue(0, 0)
    .moveTo(addNoise)
    ;  
    
  noiseMult = singleShapeMenu.addSlider("noiseMult")
    .setPosition(5, 355)
    .setSize(10, 120)
    .setRange(0, 300)
    .setValue(0)
    .moveTo(addNoise)
    ;
   
  scaleNoiseShape = singleShapeMenu.addSlider2D("scaleNoiseShape")
    .setPosition(50, 310)
    .setSize(70, 70)
    .setMinMax(.0001, .0001, 2, 2)
    .setValue(1, 1)
    .moveTo(addNoise)
    ;
    
  commitNoise = singleShapeMenu.addButton("commitNoise")
    .setPosition(230, 375)
    .setSize(60, 15)
    .moveTo(addNoise)
    ;
    
  updateStyle = singleShapeMenu.addGroup("updateStyle")
    .close()
    ;
  
  updateWhichColor = cp5.addRadioButton("updateWhichColor")
    .setPosition(265, 10)
    .addItem("updateFill", 1)
    .addItem("updateStroke", 2)
    .moveTo(updateStyle)
    .activate(0)
    ;
  
  updateCP = singleShapeMenu.addColorPicker("updateCP")
    .setPosition(0, 10)
    .moveTo(updateStyle)
    ; 
    
  updateStrokeWeight = singleShapeMenu.addSlider("strokeWeight")
    .setPosition(0, 80)
    .setSize(200,10)
    .setRange(0, 50)
    .setValue(3)
    .moveTo(updateStyle)
    ;
    
  shapeAccordion = singleShapeMenu.addAccordion("shapeacc")
    .setPosition(0,80)
    .setWidth(300)
    .addItem(updateStyle)
    .addItem(addNoise)
    ;

  /*               
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
  cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
  */
      
  singleShapeMenu.hide(); 
  
  noiseMenu = new ControlP5(this);
  
  noiseGroup = noiseMenu.addGroup("noise generator")
    .setPosition(10, 10)
    .setSize(200, 600)
    ;
    
  noiseMenu.hide();  
}

void controlEvent(ControlEvent theControlEvent) {  
  if (theControlEvent.isTab()) {
    whichTab = theControlEvent.getTab().getId();
  }
  if (theControlEvent.isFrom(cp)) {
    switch((int)whichColor.getValue()){
    case 1:
      currentStyle.fillColor = cp.getColorValue();
      exampleShape.setFill(currentStyle.fillColor);
      break;
    case 2:
      currentStyle.strokeColor = cp.getColorValue();
      exampleShape.setStroke(currentStyle.strokeColor);
      break;
    case 3:
      bg = cp.getColorValue();
      break;
    }
  }
  if (theControlEvent.isFrom(whichColor)){
    switch((int)whichColor.getValue()){
    case 1:
      cp.setColorValue(currentStyle.fillColor);
      exampleShape.setFill(currentStyle.fillColor);
      break;
    case 2:
      cp.setColorValue(currentStyle.strokeColor);
      exampleShape.setStroke(currentStyle.strokeColor);
      break;
    case 3:
      cp.setColorValue(bg);
      break;
    }
  }
  if (theControlEvent.isFrom(strokeWeight)) {
    currentStyle.strokeWeight = strokeWeight.getValue();
    exampleShape.setStrokeWeight(currentStyle.strokeWeight);
  }
  if (theControlEvent.isFrom(addPalette)){
    palette.add(cp5.addButton(str(palette.size())));
    palette.get(palette.size()-1)
      .setSize(15, 15)
      .setPosition(palette.size()*15+30, 200)
      .setLabelVisible(false)
      ;
    switch((int)whichColor.getValue()){
    case 1:
      palette.get(palette.size()-1)
        .setColorBackground(currentStyle.fillColor)
        .setColorActive(currentStyle.fillColor)
        ;
      break;
    case 2:
      palette.get(palette.size()-1)
        .setColorBackground(currentStyle.strokeColor)
        .setColorActive(currentStyle.strokeColor)
        ;
      break;
    case 3:
      palette.get(palette.size()-1)
        .setColorBackground(bg)
        .setColorActive(bg)
        ;
      break;
    }
  }
  for (Button b : palette){
    if (theControlEvent.isFrom(b)){
      cp.setColorValue(b.getColor().getActive());
      switch((int)whichColor.getValue()){
      case 1:      
        currentStyle.fillColor = cp.getColorValue();
        exampleShape.setFill(currentStyle.fillColor);
        break;
      case 2:
        currentStyle.strokeColor = cp.getColorValue(); 
        exampleShape.setStroke(currentStyle.strokeColor);
        break;
      case 3:
        bg = cp.getColorValue();
        break;
      }
    }
  }
  if (theControlEvent.isFrom(drawMode)) {
    for (int i = 1; i < 8; i++){
      if (i == (int)drawMode.getValue()){
        cp5.getGroup(settingsLabels[i-1]).show();
      } else {
        cp5.getGroup(settingsLabels[i-1]).hide();
      }
    }
  }
  if (theControlEvent.isFrom(updateWhichColor)){
    switch((int)updateWhichColor.getValue()){
    case 1:
      updateCP.setColorValue(currentStyle.fillColor);
      break;
    case 2:
      updateCP.setColorValue(currentStyle.strokeColor);
      break;
    }
  }
  if (theControlEvent.isFrom(updateCP)){
    for (Shape s : activeShapes){
      if (s.selected){
        switch((int)updateWhichColor.getValue()){
        case 1:
          s.style.fillColor = updateCP.getColorValue();
          s.shape.setFill(s.style.fillColor);
          break;
        case 2:
          s.style.strokeColor = updateCP.getColorValue();
          s.shape.setStroke(s.style.strokeColor);
          break;
        }
      }
    }
  }
  if (theControlEvent.isFrom(updateStrokeWeight)){
    for (Shape s : activeShapes){
      if (s.selected){
        if(updateStrokeWeight.getValue() < .1){
          s.style.strokeWeight = .01;
        } else {
          s.style.strokeWeight = updateStrokeWeight.getValue();
        }
        s.shape.setStrokeWeight(s.style.strokeWeight);
      }
    }
  }
  if (theControlEvent.isFrom(rotateShape)){
    for (Shape s : activeShapes){
      if (s.selected){
        float amount = (rotateShape.getValue()/180*PI) - s.heading;
        s.rotateShape(s.axis, amount);
      }
    }
  }
  if (theControlEvent.isFrom(scaleNoiseField) || theControlEvent.isFrom(translateNoiseField) || theControlEvent.isFrom(rotateNoiseDirection) || theControlEvent.isFrom(noiseMult)){
    for (Shape s : activeShapes){
      if (s.selected){
        s.noise.buildNoiseField(scaleNoiseField.getArrayValue(0), scaleNoiseField.getArrayValue(1), translateNoiseField.getArrayValue(0), translateNoiseField.getArrayValue(1), noiseMult.getValue());
        s = s.noise.updateShape(s);
      }
    }
  }
  if (theControlEvent.isFrom(noiseShape)){
    for (Shape s : activeShapes){
      if (s.selected){
        rotateNoiseShape.setValue(0);
        scaleNoiseShape.setValue(1, 1);
        translateNoiseShape.setValue(0, 0);
        s.noise.buildNoiseTrajectory((int)noiseShape.getValue(), s.trajectory.nodePath.size());
        s = s.noise.updateShape(s);
      }
    }
  }
  if (theControlEvent.isFrom(rotateNoiseShape)){
    for (Shape s : activeShapes){
      if (s.selected){
        float amount = (rotateNoiseShape.getValue()/180*PI) - s.noise.heading;
        s.noise.rotateNoiseShape(amount); 
        s = s.noise.updateShape(s);
      }
    }
  }
  if (theControlEvent.isFrom(scaleNoiseShape)){
    for (Shape s : activeShapes){
      if (s.selected){
        PVector amount = new PVector(scaleNoiseShape.getArrayValue(0)/s.noise.shapeSize.x, scaleNoiseShape.getArrayValue(1)/s.noise.shapeSize.y);
        s.noise.scaleNoiseShape(amount); 
        s = s.noise.updateShape(s);
      }
    }
  }
  if (theControlEvent.isFrom(translateNoiseShape)){
    for (Shape s : activeShapes){
      if (s.selected){
        PVector amount = new PVector(translateNoiseShape.getArrayValue(0)-s.noise.translation.x, translateNoiseShape.getArrayValue(1)-s.noise.translation.y);
        s.noise.translateNoiseShape(amount); 
        s = s.noise.updateShape(s);
      }
    }
  }
  if (theControlEvent.isFrom(translateNoiseAxis)){
    for (Shape s : activeShapes){
      if (s.selected){
        s.noise.noiseAxis.pos.set(150+translateNoiseAxis.getArrayValue(0), 150+translateNoiseAxis.getArrayValue(1)); 
      }
    }
  }
  if (theControlEvent.isFrom(commitNoise)){
    for (Shape s : activeShapes){
      if (s.selected){
        s.noise.originalTraj = s.trajectory.copyTrajectory();
        //reset noise settings
      }
    }
  }
  //if (theControlEvent.isFrom(animateShape)){
  //  for (Shape s : activeShapes){
  //    if (s.selected){
  //      activeAnimations.add(s.shapeToAnimation());
  //      whichTab = 2;
  //    }
  //  }
  //}
  if (theControlEvent.isFrom(randomizeVerts)){
    for (Shape s : activeShapes){
      if (s.selected){
        s.randomizeVertices();
      }
    }
  }
}

class DragButton extends Controller<DragButton>{
  PVector pos;
  PVector diff;
  DragButton(ControlP5 cp5, String theName, PVector start) {
    super(cp5, theName);
    pos = start.copy();
  }

  void onPress(){
    diff = new PVector(mouseX, mouseY);
    diff.sub(pos);
  }

  void onDrag(){
    pos= new PVector(mouseX, mouseY).sub(diff).copy();
    singleShapeMenu.setPosition((int)pos.x, (int)pos.y);
  }
}
