class NeuralC{

  mFixtureEnv env=new mFixtureEnv(860,500);
  mCreature cres[] = new mCreature[12];
  ConsciousCenter ccset[] = new ConsciousCenter[cres.length];
  
  
  Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
  
  HistDataDraw memHist[]=new HistDataDraw[10];
  HistDataDraw inHist[]=new HistDataDraw[memHist.length];
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
    
    for(int i=0;i<memHist.length;i++)
    {
      inHist[i]=new HistDataDraw(50);
      memHist[i]=new HistDataDraw(50);
    }
  }

  int simCount=1;
  boolean gatX=false;
  
  int loopC=0;
  void draw(){
    if(gatX||simCount<=0)return;
    
    strokeWeight(3);
    background(0);
    int hH=height/2;
    int hW=width/2;
    //drawNN.drawNN(cre.CC.nn,10,10,550,350);

    
    for(int i=0;i<simCount;i++)
    {    
      //fill(0, 0, 0,90);
      //rect(0,0,width,height);
      env.simulate();
    }
    env.draWorld();
    
    cres[0].c=color(180,150,180);
    drawNN.drawNN(cres[0].CC.nn,10,500,550,350);
    
    int NNN=3;
    int Y=250;
    for(int i=0;i<NNN;i++)
    {
      
      stroke(i*255/NNN,255-i*255/NNN,(180+i*255/NNN)%255);
      memHist[i].Draw(cres[0].CC.nn.output[i].latestVar*50,width/2,Y,width/2,300);
      Y+=50;
    }
      Y+=50;
    stroke(255,255,255);
    inHist[0].Draw(cres[0].CC.in_peerInfo*50,width/2,Y,width/2,300);
      Y+=50;
    stroke(255,0,0);
    inHist[1].Draw(cres[0].CC.ou_sendInfo*50,width/2,Y,width/2,300);
    //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
  }
  
  boolean guideG=false;
  void keyPressed()
  {
    
    if (key == CODED) {
      if (keyCode == UP) {
        simCount*=2;
        simCount++;
        if(simCount>100)simCount=100;
      } else if (keyCode == DOWN) {
        simCount/=2;
      } 
    } else {
      guideG=!guideG;
      for(mCreature cre:cres)
      {
        cre.guideGate=guideG;
        cre.CC.set_expShareList(guideG?null:ccset);
      }
      println(guideG);
    }
  }  
}