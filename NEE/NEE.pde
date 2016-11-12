
void setup() {
  size(860, 860);
  background(255);
  
}
NeuralTest nt = new NeuralTest();
NeuralC nc=new NeuralC();
void draw()
{
   
  //nt.X2();
  nc.draw();
}

float scrollingSpeed=0.000;


void keyPressed() {
  nc.keyPressed();
}