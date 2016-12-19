
void setup() {
  size(860, 860);
  background(255);
  frameRate(30);
}
NeuralTest nt = new NeuralTest();
NeuralEv nv=new NeuralEv();
NeuralC nvc=new NeuralC();
reCTest reC=new reCTest();
void draw()
{
   
  //nt.X2();
  nvc.draw();
  //reC.update();
}

float scrollingSpeed=0.000;


void keyPressed() {
  //nv.keyPressed();
  nvc.keyPressed();
  nt.keyPressed();
  //reC.keyPressed();
}