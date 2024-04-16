import fisica.*;

Toc toc;


//Simulation s = new Simulation("1-basique", 100, 50, 100, 40, 4, 5);
//Simulation s = new Simulation("2-amelioration-avant", 150, 50, 100, 40, 4, 5);
//Simulation s = new Simulation("3-amelioration-apres", 100, 50, 150, 40, 4, 5);
//Simulation s = new Simulation("4-amelioration-contrainte", 100, 80, 100, 40, 4, 5);
//Simulation s = new Simulation("5-market-contrainte", 100, 50, 25, 40, 4, 5);
//Simulation s = new Simulation("6-cadence", 100, 50, 100, 40, 8, 0);
Simulation s = new Simulation("7-small-batches", 100, 50, 100, 20, 2, 5);


class Simulation {  
  String name;
  int durationSec = 10;
  
  float workstation_1_height;
  float workstation_2_height;
  float workstation_3_height;
  float batch_size;
  int pop_frequency;
  float deltaY;
  
  Simulation(String name, float h1, float h2, float h3, float bs, int pop_frequency, float deltaY) {
    this.name = name;
    this.workstation_1_height = h1;
    this.workstation_2_height = h2;
    this.workstation_3_height = h3;
    this.batch_size = bs;
    this.pop_frequency = pop_frequency;
    this.deltaY = deltaY;
  }
}


void setup() {
  size(800, 400);
  smooth();
  Fisica.init(this);
  toc = new Toc();
}


void draw() {
  background(255);
  print(s.pop_frequency + "\n");
  if (/*mousePressed &&*/ (frameCount % s.pop_frequency == 0)) {
    toc.addProduct();
  }
  toc.update();
  toc.render();
  saveFrame(s.name + "/#######.png");
  
  if (s.durationSec > 0 && millis() / 1000 >= s.durationSec) {
    exit();
  }
}


class Toc {
  FWorld world;
  ValueStream valueStream;
  ArrayList<FBody> products;
  int sold = 0;
  
  Toc() {
    world = new FWorld();
    world.setGravity(300, 0);
    valueStream = new ValueStream(world);
    products = new ArrayList();
  }
  
  void addProduct() {
    FCircle b = new FCircle(s.batch_size);
    b.setPosition(0, height / 2 + s.deltaY * cos(millis() / 1000));
    //b.setPosition(0, mouseY);
    b.setStroke(0);
    b.setStrokeWeight(2);
    b.setFill(255);
    b.setFriction(0);
    b.setRestitution(0.8);
    //b.setForce(5, 0);
    b.setVelocity(20, 0);
    world.add(b);
    products.add(b);
  }
  
  void update() {
    ArrayList<FBody> soldProducts = new ArrayList();
    for (FBody p: products) {
      if (p.getX() > width) {
        soldProducts.add(p);
      }
    }
    for (FBody p: soldProducts) {
        sold += 1;
        world.remove(p);
        products.remove(p);
    }
    world.step();
  }
  
  void render() {
    world.draw();
    textSize(20);
    textAlign(RIGHT);
    fill(0);
    text(sold, width - 40, height - 20);
  }
}

class ValueStream {
  FWorld world;
  FPoly top;
  FPoly bot;

  ValueStream(FWorld world) {
    float y = height / 2;
    float offset = 5000;
    top = new FPoly();
    top.setStatic(true);
    top.setFill(200);
    top.setStroke(255);
    top.setStrokeWeight(0);
    top.setFriction(0);
    top.vertex(-offset, 0);
    top.vertex(-offset, y - s.workstation_1_height);
    top.vertex(width * 2/8, y - s.workstation_1_height);
    top.vertex(width * 3/8, y - s.workstation_2_height);
    top.vertex(width * 5/8, y - s.workstation_2_height);
    top.vertex(width * 6/8, y - s.workstation_3_height);
    top.vertex(width * 8/8, y - s.workstation_3_height);
    top.vertex(width * 8/8, 0);
    top.setGrabbable(false);
    world.add(top);
    
    bot = new FPoly();
    bot.setStatic(true);
    bot.setFill(200);
    bot.setStroke(255);
    bot.setStrokeWeight(0);
    bot.setFriction(0);
    bot.vertex(-offset, height);
    bot.vertex(-offset, y + s.workstation_1_height);
    bot.vertex(width * 2/8, y + s.workstation_1_height);
    bot.vertex(width * 3/8, y + s.workstation_2_height);
    bot.vertex(width * 5/8, y + s.workstation_2_height);
    bot.vertex(width * 6/8, y + s.workstation_3_height);
    bot.vertex(width * 8/8, y + s.workstation_3_height);
    bot.vertex(width * 8/8, height);
    bot.setGrabbable(false);
    world.add(bot);
    
    this.world = world;
  }
}
