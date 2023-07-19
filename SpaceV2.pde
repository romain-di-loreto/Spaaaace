final int framerate = 120;

Ship ship, ship2;
ArrayList<Obj> objs;
int currentTarget = 0;
int currentTarget2 = 0;
float threshold = 40;
float p = 600;

int score1 = 0, score2 = 0;

void settings() {
  //size(2000,2000, P2D);
  fullScreen(P2D);
}

// void setup(){  
//   frameRate(framerate);
//   ship = new Ship(100, 100);
//   ship2 = new Ship(100, 100);
//   // ship = new Ship(width/2 - p/2, height/2 - p/2);
//   // ship2 = new Ship(width/2 - p/2, height/2 - p/2);

//   objs = new ArrayList<Obj>();
//   for(int i = 0; i < 6; i++) objs.add(new Obj(random(width), random(height)));
// }

void setup(){  
  frameRate(framerate);
  ship = new Ship(random(width), random(height));

  objs = new ArrayList<Obj>();
  for(int i = 0; i < 6; i++) objs.add(new Obj(random(width), random(height)));
}

// void setup() {
//   frameRate(framerate);
//   ship = new Ship(100, 100);
//   ship2 = new Ship(100, 100);
//   // ship = new Ship(width/2 - p/2, height/2 - p/2);
//   // ship2 = new Ship(width/2 - p/2, height/2 - p/2);

//   objs.add(new Obj(width/2 - p/2, height/2 - p/2));
//   objs.add(new Obj(width/2 + p/2, height/2 - p/2));
//   objs.add(new Obj(width/2 + p/2, height/2 + p/2));
//   objs.add(new Obj(width/2 - p/2, height/2 + p/2));
// }



// void draw()
// {
//   background(0);

//   if(PVector.dist(objs.get(currentTarget).position, ship.position) < threshold) {
//     score1++;
//     // objs.get(currentTarget).position.set(new PVector(random(width), random(height)));
//     currentTarget = (currentTarget + 1) % objs.size();
//   }    
  
//   if(PVector.dist(objs.get(currentTarget2).position, ship2.position) < threshold) {
//     score2++;
//     currentTarget2 = (currentTarget2 + 1) % objs.size();
//   }
  
//   fill(255);
//   for( Obj o : objs) o.draw();
    
//   ship.draw();
//   ship.update();
//   ship2.draw();
//   ship2.update();
//   // ship.inputs();
  
//   float heading = ship.getHeadingDegrees();
//   float direction = ship.getSpeedHeadingDegrees();
//   float aoa = ship.getAOADegrees(); 
//   float a = ship.angularSpeed;
//   float s = ship.speed.mag();
  
//   //ship.pathFind(objs.get(currentTarget), objs.get((currentTarget + 1) % 2));
//   // ship.seekTarget(objs.get(currentTarget));
//   ship2.seekTarget(objs.get(currentTarget2));
//   // ship.seekBearing(
//   //   objs.get(currentTarget), 
//   //   objs.get((currentTarget + 1) % objs.size())
//   // );
//   ship.seekBearingPlus(
//     objs.get(currentTarget), 
//     objs.get((currentTarget + 1) % objs.size()),
//     objs.get((currentTarget + 2) % objs.size())
//   );
//   //ship.seek(o);
  
//   //println("Heading : " + nf(heading, 0, 1) + "   Direction : " + nf(direction, 0, 1) + "   AOA : " + nf(aoa, 0, 1) + "  a : " + a + "  s : " + s);
//   println("ship1 : " + score1 + " - ship2 : " + score2);
// }

// void draw() {
//   background(0);

//   ship.seekTarget(new Obj(mouseX, mouseY));
//   ship.update();
//   ship.draw();
// }

void draw() {
  background(0);

  if(currentTarget < objs.size() && PVector.dist(objs.get(currentTarget).position, ship.position) < threshold) {
    currentTarget++;
  }  

  switch (objs.size() - currentTarget) {
    case 2 : 
      ship.seekBearing(
        objs.get(currentTarget), 
        objs.get(currentTarget + 1)
      );
      break;
    case 1 :
      ship.seekTarget(objs.get(currentTarget));
      break;
    case 0 : 
      ship.seekTarget(ship);
      break;
    default : 
      ship.seekBearingPlus(
        objs.get(currentTarget), 
        objs.get(currentTarget + 1),
        objs.get(currentTarget + 2)
      );
      break;
  }
  
  fill(255);
  for( Obj o : objs) o.draw();
  
  ship.update();
  ship.draw();
}

void keyPressed() {
  ship.TreatKey("" + key, true);
}

void keyReleased() {
  ship.TreatKey("" + key, false);
  if(currentTarget == objs.size())
    currentTarget = 0;
}
