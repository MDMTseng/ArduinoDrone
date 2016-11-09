class NeuralC{

  mCreatureEnv env=new mCreatureEnv();
  mCreature cre = new mCreature();
  
  
  Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
  
  NeuralC()
  {
    
    env.addCreature(cre);
  }

  void draw(){
    int hH=height/2;
    int hW=width/2;
    drawNN.drawNN(cre.CC.nn,10,10,550,350);
    
    
    
    env.simulate();
    env.draWorld();
    //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
  }


}