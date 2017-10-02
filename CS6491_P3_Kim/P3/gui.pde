void keyPressed() 
	{
//  if(key=='`') picking=true; 
	if(key=='?') scribeText=!scribeText;
	if(key=='!') snapPicture();
	if(key=='~') filming=!filming;
	if(key=='[') {showControl=!showControl;}
  if(key=='r') {keyPressed = false; mousePressed = false;};

  if(key=='o') showOrigin = !showOrigin;
  if(key=='1') b1 = !b1;
  if(key=='2') b2 = !b2;
	if(key=='3') b3 = !b3;
	if(key=='4') b4 = !b4;
	if(key=='5') b5 = !b5;
	if(key==',') {level=max(level-1,0); f=0;}
	if(key=='.') {level++;f=0;}

	if(key=='i') P.insertClosestProjection(Of); // Inserts new vertex in P that is the closeset projection of O
	if(key=='w') P.savePts("data/pts");   // save vertices to pts
	if(key=='l') P.loadPts("data/pts"); 
	if(key=='a') {animating=!animating; P.setFifo();}// toggle animation
	if(key=='#') exit();
	if(key=='=') {}
	change=true;   // to save a frame for the movie when user pressed a key 
	}

void mouseWheel(MouseEvent event) 
	{
	dz -= 10*event.getCount();
	change=true;
	}

void mousePressed() 
	{
	if (!keyPressed) {P.set_pv_to_pp(); println("picked vertex "+P.pp);}
	change=true;
	}
	
void mouseMoved() 
	{
	//if (!keyPressed) 
	if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
	if (keyPressed && key=='`') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
	change=true;
	}
	
void mouseDragged() 
	{
	if (!keyPressed) P.setPickedTo(Of); 
//  if (!keyPressed) {Of.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
	if (keyPressed && key==CODED && keyCode==SHIFT) {Of.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
	if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
	if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
	if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
	if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
	if (keyPressed && key=='t')  // move focus point on plane
		{
		if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
		else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
		}
	if (keyPressed && key=='T')  // move focus point vertically
		{
		if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
		else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
		}
	change=true;
	}  

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
	scribeHeader(title,0); scribeHeaderRight(name); 
	fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
}

void displayFooter() { // Displays help text at the bottom
	scribeFooter(guide,1); 
	scribeFooter(menu,0); 
}

String title ="Fleshing our strokes", name ="Joonho Kim",
	menu="?:help, !:picture, ~:(start/stop)capture, space:rotate, `/wheel:closer, t/T:target, #:quit",
	guide="click&drag:pick&slide on floor, xz/XZ:move/ALL, o: coordinate axis, l:load, w:write, press '1', '2', '3', '4', or '5' to toggle disks, boundary, Medial Axis, Arc Transversals, or quad mesh."; // user's guide