class NeuralC{

  mCreatureEnv env=new mCreatureEnv(860,500);
  mCreature cres[] = new mCreature[5];
  ConsciousCenter ccset[] = new ConsciousCenter[cres.length];
  
  
  Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
  
  NeuralC()
  {
    
    
    
    for(int i=0;i<cres.length;i++)
    {
      cres[i]=new mCreature();
      env.addCreature(cres[i]);
    }
    
    
    
    for(int i=0;i<ccset.length;i++)
    {
      ccset[i]=cres[i].CC;
    }
    
    
    for(int i=0;i<ccset.length;i++)
    {
      cres[i].CC.set_expShareList(ccset);
    }
    
    
  }

  int simCount=1;
  boolean gatX=false;
  void draw(){
    if(gatX||simCount<=0)return;
    
    strokeWeight(3);
    background(0);
    int hH=height/2;
    int hW=width/2;
    //drawNN.drawNN(cre.CC.nn,10,10,550,350);

    
    for(int i=0;i<simCount;i++)
    {    
      fill(0, 0, 0,90);
      rect(0,0,width,height);
      env.simulate();
    }
    env.draWorld();
    
    cres[0].c=color(180,150,180);
    drawNN.drawNN(cres[0].CC.nn,10,500,550,350);
    //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
  }
  void keyPressed()
  {
    
    if (key == CODED) {
      if (keyCode == UP) {
        simCount++;
      } else if (keyCode == DOWN) {
        simCount--;
      } 
    } else {
      for(mCreature cre:cres)
        cre.guideGate=!cre.guideGate;
    }
  }  
}