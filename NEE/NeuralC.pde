class NeuralC{

  mCreatureEnv env=new mCreatureEnv();
  mCreature cres[] = new mCreature[5];
  
  
  Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
  
  NeuralC()
  {
    for(int i=0;i<cres.length;i++)
    {
      cres[i]=new mCreature();
      env.addCreature(cres[i]);
    }
  }

  void draw(){
    int hH=height/2;
    int hW=width/2;
    //drawNN.drawNN(cre.CC.nn,10,10,550,350);
    
    
    
    env.simulate();
    env.draWorld();
    //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
  }
  void keyPressed()
  {
    for(mCreature cre:cres)
      cre.guideGate=!cre.guideGate;
  }  
}