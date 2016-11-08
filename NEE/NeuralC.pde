class NeuralC{

  s_neuron_net nn = new s_neuron_net(new int[]{2,3,3,33,3,3,2});
  
    
  
  float InX[][]=new float[nn.input.length][150];
  float OuY[][]=new float[nn.output.length][InX[0].length];
  
  Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
  
  int TrainCount=0;
  
  HistDataDraw ErrHist=new HistDataDraw(1500);


  void X2(){
    int hH=height/2;
    int hW=width/2;
    drawNN.drawNN(nn,10,10,550,350);
    
    float err=nn.TestTrain(InX,OuY,25);
    stroke(0,255,0,100);
    ErrHist.Draw((float)Math.log(err+1)*1000,0,300,width,500);
    stroke(128,128,0,100);
    
    TrainCount+=25;
    //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
  }


}