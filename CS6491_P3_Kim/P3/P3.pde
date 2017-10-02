//  ******************* Tango dancer 3D 2016 ***********************
boolean 
  animating=true, 
  PickedFocus=false, 
  center=true, 
  showViewer=false, 
  showControl=true, 
  showOrigin = true,
  b1 = true,
  b2 = true,
  b3 = false,
  b4 = false,
  b5 = false;
float 
  t=0, 
  s=0;
int
  f=0, maxf=2*30, level=4, method=5;
String SDA = "angle";
float defectAngle=0;
pts P = new pts(); // polyloop in 3D
// pts Q = new pts(); // second polyloop in 3D
// pts R = new pts(); // inbetweening polyloop L(P,t,Q);

vec X_AXIS = V(1, 0, 0);
vec Y_AXIS = V(0, 1, 0);
vec Z_AXIS = V(0, 0, 1);

int numPerimeterPts = 60;
  
void setup() {
    myFace = loadImage("data/Kim.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
    textureMode(NORMAL);          
    size(1600, 900, P3D); // P3D means that we will do 3D graphics
    P.declare();
    P.resetOnCircle(4,100);
    P.loadPts("data/pts");
    smooth();
    frameRate(60);
}

void draw() {
  background(white);
  hint(ENABLE_DEPTH_TEST);

  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
    
    pt S=P.G[0], E=P.G[1], L=P.G[2], R=P.G[3]; // named points defined for convenience
    setView();  // see pick tab
    showFloor(); // draws dance floor as yellow mat
    doPick(); // sets Of and axes for 3D GUI (see pick Tab)
    P.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
    if(showControl) {fill(grey); P.drawBalls(10);}  // draw control polygon 
    fill(yellow,100); P.showPicked(); 


    if (showOrigin) {
      noStroke();
      fill(red); arrow(P(0,0,0), 200, X_AXIS, 10);
      fill(green); arrow(P(0,0,0), 200, Y_AXIS, 10);
      fill(blue); arrow(P(0,0,0), 200, Z_AXIS, 10);
    }
   

    // Draw Disks ======================================================================================================
    float s = d(S, L), e = d(E, R);
    if (b1) {
      noStroke(); fill(black); cylinderSection(S,L,3); cylinderSection(E,R,3);
      pts SDisk = new pts(); SDisk.declare();
      pts LDisk = new pts();LDisk.declare();
      
      int diskPts = 36;
      float step = TWO_PI/diskPts;
      for(float a=0; a<diskPts; ++a) {
        SDisk.addPt(R(L, a*step, S));
        LDisk.addPt(R(R, a*step, E));
      }
      
      fill(red);   SDisk.drawClosedCurve(2);
      fill(green); LDisk.drawClosedCurve(2);
    }


    // Draw Caplets ====================================================================================================
    // Hat Points to create caplets
    pts LHat = getTangentPoints(S, E, L, R);
    pts RHat = getTangentPoints(E, S, R, L);

    // Code for part 1: 4 arc perimeter points used in b1    
    int nn = numPerimeterPts/4;
    pts SArc     = getArcClockPts(RHat.G[2], S, LHat.G[0], nn);
    pts EArc     = getArcClockPts(LHat.G[2], E, RHat.G[0], nn);
    pts greyPts  = getCircleArcInHat(LHat.G[0], LHat.G[1], LHat.G[2], nn+2);
    pts brownPts = getCircleArcInHat(RHat.G[0], RHat.G[1], RHat.G[2], nn+2);
    
    // 15 points on disk arcs.  17 points on caplets and then removing the ends
    // This prevents disk arc ends and caplet ends from overlapping.
    greyPts.pv = greyPts.nv-1;
    greyPts.deletePicked();
    greyPts.pv = 0;
    greyPts.deletePicked();
    
    brownPts.pv = brownPts.nv-1;
    brownPts.deletePicked();
    brownPts.pv = 0;
    brownPts.deletePicked();

    if(b2) {
      pts B = new pts(); B.declare();
      beginShape();
        noStroke(); fill(comboTan);
        for (int i = 0; i < SArc.nv; ++i)     { v(SArc.G[i]);     }
        for (int i = 0; i < greyPts.nv; ++i)  { v(greyPts.G[i]);  }
        for (int i = 0; i < EArc.nv; ++i)     { v(EArc.G[i]);     }
        for (int i = 0; i < brownPts.nv; ++i) { v(brownPts.G[i]); }
      endShape();

      noFill(); strokeWeight(5);
    }


    // Exact Medial Axis M of W.  This assumes appropriate user input ==================================================
    pt B = getMedialAxis(R, V(E,R), S, s);
    pt G = getMedialAxis(L, V(S,L), E, e);
        
    float angleInBetween = clockwiseAngle(V(B, RHat.G[0]), V(B, RHat.G[2]));  // asumming acute angle
    float stepAngle = angleInBetween/(nn+1);
    float gl = (d(G, E) < d(G, LHat.G[2])) ? -d(G, LHat.G[2]) : d(G, LHat.G[2]); // sign is important.  same sign or different sign d value  
    
    // Medial Axis points
    pts medialAxisPts = new pts();
    medialAxisPts.declare();
    for (int i = 0; i < nn+2; ++i) {
      vec BR = V(B, R);
      vec RE = V(R, E);
      float re = (dot(BR, RE) >= 0) ? d(R, E) : -d(R, E);
      BR = V(B, R(R, i*stepAngle, B));
      RE = U(BR).normalize().mul(re);    // RE always points to E
      pt RR = P(B).add(BR);
      
      medialAxisPts.addPt(getMedialAxis(RR, RE, G, gl));
    }

    if(b3) {  
      noStroke(); fill(magenta);
      medialAxisPts.drawBalls(4);
    }


    // Uniform Arc Transversals ========================================================================================
    if(b4) {
      noStroke(); fill(yellow);
      for (int i = 0; i < nn; ++i) {
        getCircleArcInHat(brownPts.G[i], medialAxisPts.G[i], greyPts.G[nn-1-i], 15).drawOpenCurve(1);
      }
      
      for (int i = 0; i < nn/2; ++i) {
        getCircleArcInHat(SArc.G[i], S, SArc.G[nn-1-i], 15).drawOpenCurve(1);
        getCircleArcInHat(EArc.G[i], E, EArc.G[nn-1-i], 15).drawOpenCurve(1);
      }
    }
    
    
    // 3D circular Quad Mesh  ==========================================================================================
    import java.util.*;
    int quadCirclePts = 16;
    float circStep = TAU/quadCirclePts;
    List<pt[]> _quadMesh = new ArrayList<pt[]>();
    
    // Green Side
    for (int i = 0; i < (nn+1)/2; ++i) {
      pt left = SArc.G[i];
      pt right = SArc.G[nn-i-1];
      pt mid = P(left, 0.5, right);
      vec MIDLEFT = U(V(mid, left));
      
      pt[] temp = new pt[quadCirclePts];
      for (int j = 0; j < quadCirclePts; ++j) {
        temp[j] = R(left, j*circStep, Z_AXIS, MIDLEFT, mid);
      }
      _quadMesh.add(0, temp);
    }
    
    // Middle
    for (int i = 0; i < nn; ++i) {
      pt left = brownPts.G[nn-i-1];
      pt right = greyPts.G[i];
      pt mid = P(left, 0.5, right);
      vec MIDLEFT = U(V(mid, left));
      
      pt[] temp = new pt[quadCirclePts];
      for (int j = 0; j < quadCirclePts; ++j) {
        temp[j] = R(left, j*circStep, Z_AXIS, MIDLEFT, mid);
      }
      _quadMesh.add(temp);
    }
    
    // Red Side
    for (int i = 0; i < (nn+1)/2; ++i) {
      pt left = EArc.G[nn-i-1];
      pt right = EArc.G[i];
      pt mid = P(left, 0.5, right);
      vec MIDLEFT = U(V(mid, left));
      
      pt[] temp = new pt[quadCirclePts];
      for (int j = 0; j < quadCirclePts; ++j) {
        temp[j] = R(left, j*circStep, Z_AXIS, MIDLEFT, mid);
      }
      _quadMesh.add(temp);
    }

    pt[][] quadMesh = _quadMesh.toArray(new pt[_quadMesh.size()][quadCirclePts]);
    if (b5) {
      // Fill quadstrip from circle to next circle
      stroke(comboBlue, 120); strokeWeight(5); fill(comboBlue, 120);
      for (int r = 0; r < quadMesh.length-1; ++r) {
        beginShape(QUAD_STRIP);
          for (int c = 0; c <= quadCirclePts; ++c) {
            v(quadMesh[r  ][c%quadCirclePts]);
            v(quadMesh[r+1][c%quadCirclePts]);
          }
        endShape();
      }
      
      // if nn is even, then the ends will have gaps.  This is to fill the gap.
      if (nn % 2 == 0) {
        beginShape();
          for (int c = 0; c < quadCirclePts; ++c) {
            v(quadMesh[0][c]);
            v(quadMesh[0][c]);
          }
        endShape(CLOSE);
        beginShape();
          for (int c = 0; c < quadCirclePts; ++c) {
            v(quadMesh[quadMesh.length-1][c]);
            v(quadMesh[quadMesh.length-1][c]);
          }
        endShape(CLOSE);
      }
    }
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas


  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible
  // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
  if(mousePressed) {stroke(cyan); strokeWeight(3); noFill(); ellipse(mouseX,mouseY,20,20); strokeWeight(1);}
  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX+14,mouseY+20,26,26); fill(red); text(key,mouseX-5+14,mouseY+4+20); strokeWeight(1); }
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  change=true;
  }