class Ship extends Obj {
  HashMap<String, Boolean> keys; 
  float angularThrust = 90;
  float linearThrust = 100;
  float lastDebugToggle = 0;
  float rotationThreshold = radians(5);  
  
  public Ship(PVector position, PVector speed, float angle) {
    super(position, speed, angle);
    keys = new HashMap<String, Boolean>();
  }
  
  public Ship(PVector position, float angle) {
    this(position, new PVector(0, 0), angle);
  }
  
  public Ship(PVector position) {
    this(position, new PVector(0, 0), 0);
  }
  
  public Ship(float x, float y, float vx, float vy, float a)
  {
    this(new PVector(x,y), new PVector(vx, vy), a);
  }
  
  public Ship(float x, float y, float a)
  {
    this(new PVector(x,y), new PVector(0, 0), a);
  }
  
  public Ship(float x, float y)
  {
    this(new PVector(x,y), new PVector(0, 0), 0);
  }
  
  @Override
  public void drawShape() {
    stroke(255);
    fill(255);
    triangle( - 10, 20, 10, 20, 0, -20);
  }
  
  void TreatKey(String Key, Boolean Value) {
    keys.put(Key.toUpperCase(),Value);
  }
  
  public void inputs() {
    this.acceleration.set(0,0);
    this.angularAcceleration = 0;
    //this.angularSpeed = 0;
    
    if (keys.getOrDefault("Z",false)) {
      this.acceleration.add(PVector.fromAngle(this.angle).setMag(linearThrust));
    }
    
    if (keys.getOrDefault("S",false)) {
      this.acceleration.sub(PVector.fromAngle(this.angle).setMag(linearThrust));
    }
    
    if (keys.getOrDefault("E",false)) {
      this.acceleration.add(PVector.fromAngle(this.angle + HALF_PI).setMag(linearThrust));
    }
    
    if (keys.getOrDefault("A",false)) {
      this.acceleration.sub(PVector.fromAngle(this.angle + HALF_PI).setMag(linearThrust));
    }
    
    if (keys.getOrDefault("B",false)) {
      float speedAngle = this.speed.heading();
      
      this.angularAcceleration = -(angularSpeed / 2);
      this.acceleration.sub(PVector.fromAngle(speedAngle).setMag(linearThrust));
    }
    
    if (keys.getOrDefault("D",false) && !keys.getOrDefault("Q",false)) {
      angularAcceleration = radians(angularThrust);
    }
    else if (keys.getOrDefault("Q",false)) {
      angularAcceleration = -radians(angularThrust);
    }
    
    float now = millis();
    if ((now - lastDebugToggle) > 2000 && keys.getOrDefault("F",false)) {
      lastDebugToggle = now;
      this.debug = !this.debug;
    }
  }
  
  public void seekBearingPlus(Obj target, Obj next, Obj nextnext) {
    PVector targetPos = target.position.copy();
    PVector nextPos = next.position.copy();
    PVector nextnextPos = nextnext.position.copy();
    
    PVector[] trajBezier = getBezier(
      this.position,
      targetPos,
      nextPos,
      nextnextPos
     );    
    
    float stopingDistance = pow(this.speed.mag(), 2) / (this.linearThrust * 2);
    float stopingDistanceAtMaxSpeed = pow(this.maxSpeed, 2) / (this.linearThrust * 2);
    float bias = this.speed.mag() * PI/this.maxAngularSpeed;
    PVector aim = pointBezierAt(
      trajBezier, 
      stopingDistance >= this.position.dist(targetPos) - bias ? max(this.maxSpeed, stopingDistanceAtMaxSpeed) : this.position.dist(targetPos)
    );
    
    //PVector desiredVelocity = trajBezier[1].copy().sub(this.position)
    PVector desiredVelocity = aim.copy().sub(this.position)
     .limit(this.maxSpeed); 
    
    //PVector p = this.position.copy().add(trajBezier[1].copy().sub(this.position).limit(this.maxSpeed));
    fill(50,255,100);
    PVector p = this.speed.copy().setMag(stopingDistance).add(this.position);
    circle(p.x, p.y, 8);   

    fill(50,100,255);
    circle(aim.x, aim.y, 10);  

    noFill();
    beginShape();
    vertex(trajBezier[0].x, trajBezier[0].y);
    bezierVertex(trajBezier[1].x, trajBezier[1].y, trajBezier[2].x, trajBezier[2].y, trajBezier[3].x, trajBezier[3].y);
    endShape();
    
    this.seek(desiredVelocity, target);
  }
  
  public void seekBearing(Obj target, Obj next) {
    PVector targetPos = target.position.copy();
    PVector nextPos = next.position.copy();
    
    PVector[] trajBezier = getBezier(
      this.position,
      targetPos,
      targetPos.copy().lerp(nextPos,0.9),
      nextPos
     );    
    
    float stopingDistance = pow(this.speed.mag(), 2) / (this.linearThrust * 2);
    float bias = this.speed.mag() * PI/this.maxAngularSpeed;
    PVector aim = pointBezierAt(
      trajBezier, 
      stopingDistance >= this.position.dist(targetPos) - bias ? this.maxSpeed : this.position.dist(targetPos)
    );
    
    //PVector desiredVelocity = trajBezier[1].copy().sub(this.position)
    PVector desiredVelocity = aim.copy().sub(this.position)
     .limit(this.maxSpeed); 
    
    //PVector p = this.position.copy().add(trajBezier[1].copy().sub(this.position).limit(this.maxSpeed));
    fill(50,255,100);
    PVector p = this.speed.copy().setMag(stopingDistance).add(this.position);
    circle(p.x, p.y, 8);  

    fill(50,100,255);
    circle(aim.x, aim.y, 10);    
    
    noFill();
    beginShape();
    vertex(trajBezier[0].x, trajBezier[0].y);
    bezierVertex(trajBezier[1].x, trajBezier[1].y, trajBezier[2].x, trajBezier[2].y, trajBezier[3].x, trajBezier[3].y);
    endShape();
    
    this.seek(desiredVelocity, target);
  }
  
  public void seekTarget(Obj target) {
    PVector targetPos = target.position.copy();
    
    // float stopingDistance = pow(this.speed.mag(), 2) / (this.linearThrust * 2);
    PVector desiredVelocity = targetPos.copy().sub(this.position);
    desiredVelocity.limit(this.maxSpeed);
    
    float stopingDistance = pow(this.speed.mag(), 2) / (this.linearThrust * 2);
    float bias = this.speed.mag() * PI/this.maxAngularSpeed;
    if(this.position.dist(targetPos) - bias <= stopingDistance)
      desiredVelocity.sub(this.speed);

    fill(50,255,100);
    PVector p = this.speed.copy().setMag(stopingDistance).add(this.position);
    circle(p.x, p.y, 8); 
    
    line(this.position.x, this.position.y, targetPos.x, targetPos.y);
    
    this.seek(desiredVelocity, target);
  }
  
  public void seek(PVector desiredVelocity, Obj target) {
    PVector targetPos = target.position.copy();
    PVector currentVelocity = this.speed.copy();
    PVector intermediateVelocity = desiredVelocity.copy().sub(currentVelocity);
    
    boolean aligned = PVector.sub(desiredVelocity, currentVelocity).mag() < 0.1;
    
    float desiredRotation =  getAngleBetweenVectors(aligned ? desiredVelocity : intermediateVelocity, PVector.fromAngle(this.angle));
    
    this.angularSpeed = map(desiredRotation, -PI, PI, -this.maxAngularSpeed, this.maxAngularSpeed);  
    
    if (!aligned) {
      float desiredAcceleration = min(intermediateVelocity.mag(), this.maxSpeed);
      float acceleration = map(desiredAcceleration*2, 0, this.maxSpeed, 0, this.linearThrust);
      // this.acceleration.add(PVector.fromAngle(this.angle).setMag(acceleration));
      this.acceleration = PVector.fromAngle(this.angle).setMag(acceleration).limit(this.linearThrust);
      float factor = this.acceleration.dot(this.acceleration.copy().setHeading(intermediateVelocity.heading()));
      //this.acceleration.setMag(factor);
      factor = factor < 0 ? 0 : sqrt(factor);
      this.acceleration.setMag(factor);
    }
    
    //debug text
    fill(0, 408, 612);
    textSize(20);
    text("FPS : " + round(frameRate) , 20, 50);
    text("Heading : " + nf(degrees(this.angle), 0, 2) , 20, 75);
    text("desiredHeading : " + nf(degrees(desiredVelocity.heading()), 0, 2) , 20, 100);
    text("desiredRotation : " + nf(degrees(desiredRotation), 0, 2) , 20, 125);
    text("alignement : " + PVector.sub(desiredVelocity, currentVelocity).mag() , 20, 150);
    
    //debug vector bubles
    fill(0);
    circle(targetPos.x, targetPos.y, 8);
    fill(255,0,0);
    circle(currentVelocity.x + this.position.x, currentVelocity.y + this.position.y, 8);
    fill(255,0,255);
    circle(currentVelocity.copy().setMag(this.maxSpeed).x + this.position.x, currentVelocity.copy().setMag(this.maxSpeed).y + this.position.y, 5);
    fill(0,255,0);
    circle(desiredVelocity.x + this.position.x, desiredVelocity.y + this.position.y, 8);
    fill(0,0,255);
    circle(intermediateVelocity.x + currentVelocity.x + this.position.x, intermediateVelocity.y + currentVelocity.y + this.position.y, 5);
  }
  
  float getAngleBetweenVectors(PVector v1, PVector v2) {
    float angle = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
    if (angle < -  PI) {
      angle += TWO_PI;
    } else if (angle > PI) {
      angle -= TWO_PI;
    }
    return - angle;
  }
  
  PVector[] getBezier(PVector P0, PVector P1,  PVector P2, PVector P3) {
    PVector[] bezier = new PVector[4];
    bezier[0] = P0.copy();
    bezier[3] = P3.copy();
    
    // measure chord lengths
    float c1 = bezier[0].dist(P1);;
    float c2 = P1.dist(P2);
    float c3 = P2.dist(bezier[3]);
    
    // make curve segment lengths proportional to chord lengths
    float t1 = c1 / (c1 + c2 + c3);
    float t2 = (c1 + c2) / (c1 + c2 + c3);
    float a = t1 * (1 - t1) * (1 - t1) * 3;
    float b = (1 - t1) * t1 * t1 * 3;
    float d = t2 * (1 - t2) * (1 - t2) * 3;    
    float e = (1 - t2) * t2 * t2 * 3;
    
    float c = P1.x - (bezier[0].x * pow(1 - t1, 3.0)) - (bezier[3].x * pow(t1, 3));
    float f = P2.x - (bezier[0].x * pow(1 - t2, 3.0)) - (bezier[3].x * pow(t2, 3));
    float g = P1.y - (bezier[0].y * pow(1 - t1, 3.0)) - (bezier[3].y * pow(t1, 3));
    float h = P2.y - (bezier[0].y * pow(1 - t2, 3.0)) - (bezier[3].y * pow(t2, 3));
    
    bezier[2] = new PVector(
     (c - a / d * f) / (b - a * e / d),
     (g - a / d * h) / (b - a * e / d)
     );
    bezier[1] = new PVector(
     (c - (b * bezier[2].x)) / a,
     (g - (b * bezier[2].y)) / a
     );
    
    return bezier;
  }
  
  PVector pointBezier(PVector[] B, float t) {   
    PVector a = B[0].copy().mult(pow(1 - t,3));
    PVector b = B[1].copy().mult(3 * t * pow(1 - t,2));
    PVector c = B[2].copy().mult(3 * (1 - t) * pow(t,2));
    PVector d = B[3].copy().mult(pow(t,3));
    
    return a.add(b).add(c).add(d);
  }
  
  PVector pointBezierAt(PVector[] B, float d) {
    int maxStep = 500;
    
    PVector prev = B[0].copy();
    PVector next = prev.copy();
    float dist = 0;
    for (float i = 0; i < 1 && dist < d; i += 1f / maxStep) {
      next = pointBezier(B, i);
      dist += prev.dist(next); 
      prev = next.copy();
    }   
    
    return prev;
  }
}
