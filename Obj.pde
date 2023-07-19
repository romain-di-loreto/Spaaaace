class Obj {
  PVector position;
  PVector speed;
  PVector acceleration;
  float maxSpeed = 200;
  float angle;
  float angularSpeed = 0;
  float angularAcceleration = 0;
  float maxAngularSpeed = radians(720);
  boolean debug = false;
  
  double interval;
  
  public Obj(PVector position, PVector speed, float angle) {
    this.position = position;
    this.speed = speed;
    this.angle = angle;
    acceleration = new PVector(0,0);
  }
  
  public Obj(PVector position, float angle) {
    this(position, new PVector(0, 0), angle);
  }
  
  public Obj(PVector position) {
    this(position, new PVector(0, 0), 0);
  }
  
  public Obj(float x, float y, float vx, float vy, float a)
  {
    this(new PVector(x,y), new PVector(vx, vy), a);
  }
  
  public Obj(float x, float y, float a)
  {
    this(new PVector(x,y), new PVector(0, 0), a);
  }
  
  public Obj(float x, float y)
  {
    this(new PVector(x,y), new PVector(0, 0), 0);
  }
  
  public float getHeading() {
    return this.angle;
  }
  
  public float getHeadingDegrees() {
    return degrees(this.angle);
  }
  
  public float getSpeedHeading() {
    return(2 * PI + this.speed.heading()) % (2 * PI);
  }
  
  public float getSpeedHeadingDegrees() {
    return degrees(this.getSpeedHeading());
  }
  
  public float getAOA() {
    return this.getSpeedHeading() - this.angle;
  }
  
  public float getAOADegrees() {
    return degrees(this.getAOA());
  }
  
  public void draw() {
    translate(position.x, position.y);
    rotate(angle + HALF_PI);    
    this.drawShape();   
    rotate( -angle - HALF_PI);
    translate( -position.x, -position.y);
    
    if (this.debug)
      this.drawDebug();
  }
  
  public void drawDebug() {
    PVector d = this.position.copy().sub(PVector.fromAngle(this.angle).setMag(20));
    PVector n = this.position.copy().sub(PVector.fromAngle(this.angle + HALF_PI).setMag(20));
    PVector s = this.position.copy().add(this.speed);
    stroke(0,100,255);
    line(this.position.x, this.position.y, d.x, d.y);
    stroke(255,0,0);
    line(this.position.x, this.position.y, n.x, n.y);
    stroke(0, 255, 0);
    line(this.position.x, this.position.y, s.x, s.y);
  }
  
  public void drawShape() { circle(0,0,10);}
  
  public void update() {
    interval = 1 / frameRate;
    
    this.position.add(this.speed.copy().mult((float)interval));
    this.speed.add(this.acceleration.copy().mult((float)interval));
    this.speed.setMag(min(maxSpeed, this.speed.mag()));
    this.angularSpeed += angularAcceleration * interval;
    if (this.angularSpeed < 0)
      this.angularSpeed = max( -maxAngularSpeed, this.angularSpeed);
    else
      this.angularSpeed = min(maxAngularSpeed, this.angularSpeed);
    this.angle += angularSpeed * interval;
    this.angle += TWO_PI;
    this.angle %= TWO_PI;
  }
}
