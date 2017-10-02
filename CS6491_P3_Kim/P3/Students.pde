
// Part 1
pts getTangentPoints(pt S, pt E, pt L, pt R) {
  pt M = getMedialAxis(L, V(S, L), E, d(E, R));
  pt Lprime = P(M, d(M, L), U(V(M, E)));
  pt O = P(L, V(L, Lprime).mul(0.5));
  pt A = P(M, n2(V(L,M))/d(M,O), U(V(M,O)));
  
  pts hat = new pts();
  hat.declare();
  hat.addPt(L);
  hat.addPt(A);
  hat.addPt(Lprime);

  return hat;
}


pts getArcClockPts(pt A, pt B, pt C, int n) {
  pts p = new pts();
  p.declare();
  
  float angleInBetween = clockwiseAnglePos(V(B,A), V(B,C));
  float step = angleInBetween / (n-1);
  
  for (int i = 0; i < n; ++i) {
    p.addPt(R(A, i*step, B));
  }
  return p;
}


// Part 1 and 2
pt getMedialAxis(pt P0, vec T0, pt C1, float c1) {
  T0 = U(T0);
  vec C1P0 = V(C1,P0);
  float d = (sq(c1) - sq(d(C1,P0))) / (2*(dot(T0, C1P0) - c1));
  pt X = P(P0).add(d, T0);
  return X;
}


pts getCircleArcInHat(pt PA, pt B, pt PC, int n) {// draws circular arc from PA to PB that starts tangent to B-PA and ends tangent to PC-B
  pts p = new pts();
  p.declare();
  float e = (d(B,PC)+d(B,PA))/2;
  pt A = P(B,e,U(B,PA));
  pt C = P(B,e,U(B,PC));
  vec BA = V(B,A), BC = V(B,C);
  float d = dot(BC,BC) / dot(BC, V(BA).add(V(BC)));
  pt X = P(B,d,V(BA).add(V(BC)));
  vec XA = V(X,A), XC = V(X,C); 
  float a = clockwiseAngle(XA,XC), da=a/(n-1);
  for (int i = 0; i < n; ++i) {
    p.addPt(R(A, i*da, X));
  }
  return p;
}   

float clockwiseAngle(vec a, vec b) {
    float dot = dot(a, b);
    float det = a.x*b.y - a.y*b.x;
    float angle = atan2(det, dot);
    return angle;
}

float clockwiseAnglePos(vec a, vec b) {
    float angle = clockwiseAngle(a, b);
    if (angle < 0) return angle + TAU;
    return angle;
}