void setup() {
  size(640, 860);
  background(255);
  //noLoop();
  
}
NeuralTest nt = new NeuralTest();
void draw()
{
  strokeWeight(3);
  background(0);

  nt.X2();
}

float scrollingSpeed=0.000;


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      scrollingSpeed *= 1.5;
      scrollingSpeed+=0.0001;
    } else if (keyCode == DOWN) {
      scrollingSpeed /= 1.5;
    } 
  } else {
    scrollingSpeed = 0;
  }
}