
void setup() {
  size(860, 860);
  background(255);
  frameRate(30);
}
NeuralTest nt = new NeuralTest();
NeuralEv nv=new NeuralEv();
reCTest reC=new reCTest();
void draw()
{
   
 // nt.X2();
  //nv.draw();
  reC.update();
}

float scrollingSpeed=0.000;


void keyPressed() {
  nv.keyPressed();
  nt.keyPressed();
  reC.keyPressed();
}