class World {
  public Ship ship;
  
  public World() {}
  
  public void draw() {
    ship.draw();
  }
  
  public void createShip(float x, float y) {
    this.ship = new Ship(x + width/2, y + width/2);
  }
  
  public void update() {
    ship.update();
    ship.inputs();
  }
  
  public float transformAngle(float angle){
    return (TWO_PI + angle + HALF_PI) % TWO_PI;
  }
  
  public PVector transform(PVector v) {
    return v.copy().rotate(-HALF_PI).add(new PVector(width/2, height/2));
  }
  
  public void TreatKey(String Key, Boolean Value) {
    ship.TreatKey(Key, Value);
  }
  
}