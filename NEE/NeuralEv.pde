import java.util.Collections;

class NeuralEv{

  mFixtureEnv env=new mFixtureEnv(860,500);
  mCreatureEv cres[] = new mCreatureEv[35];
  
  
  int honorListsL;
  ArrayList <mCreatureEv> honorLists=new ArrayList <mCreatureEv>();
  ArrayList <mCreatureEv> deadList=new ArrayList <mCreatureEv>();
  Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
  
  HistDataDraw memHist[]=new HistDataDraw[10];
  HistDataDraw inHist[]=new HistDataDraw[memHist.length];
  NeuralEv()
  {
    
    
    
    for(int i=0;i<cres.length;i++)
    {
      cres[i]=new mCreatureEv();
      env.addCreature(cres[i]);
    }
    
    
    
    for(int i=0;i<memHist.length;i++)
    {
      inHist[i]=new HistDataDraw(50);
      memHist[i]=new HistDataDraw(50);
    }
    honorListsL=30;
    for(int i=0;i<honorListsL;i++)
    {
      honorLists.add(new mCreatureEv());
    }
  }
  
  int getMaxFitnessIdx(mCreatureEv cand[])
  {
        
    int maxIdx=0;
    float maxFitness=0;
    for(int i=0;i<cand.length;i++)
    {
      if(maxFitness<cand[i].getFitness())
      {
        maxFitness=cand[i].getFitness();
        maxIdx=i;
      }
    }
    
    return maxIdx;
    
  }
    
  
    
  
  void GetHornorListTopX(ArrayList <mCreatureEv> SortedList,int topX)
  {
    int start=(int)(topX);
    for(int i=start;i<SortedList.size();i++)
    {
      SortedList.remove(i--);
    }
  }      
    
  mCreatureEv GetGoodFitCre(ArrayList <mCreatureEv> SortedList)
  {
    mCreatureEv cre=SortedList.get(0);
    float maxNum=0;

    for(mCreatureEv cand:SortedList)
    {
      float tmp=random(0,cand.getFitness());
      if(maxNum<tmp)
      {
        cre=cand;
        maxNum=tmp;
      }
    }
    return cre;
  }    
  
  int GetGoodFitCreIdx(mCreatureEv cand[],float threshold)
  {
    int maxIdx=0;
    float maxNum=0;

    for(int i=0;i<cand.length;i++)
    {
      if(cand[i].getFitness()<threshold)continue;
      float tmp=random(0,cand[i].getFitness());
      if(maxNum<tmp)
      {
        maxIdx=i;
        maxNum=tmp;
      }
    }
    return maxIdx;
  }

  int simCount=1;
  boolean gatX=false;
  
  float maxFitnessRec=0;
  int loopC=0;
  
  void creatANewGen()
  {
    
  }
  
  int MaxloopC=1000;
  int GEN=0;
  void draw(){
    if(gatX||simCount<=0)return;
    strokeWeight(3);
    background(0);
    int hH=height/2;
    int hW=width/2;
    //drawNN.drawNN(cre.CC.nn,10,10,550,350);

    
    mCreatureEv parentList[]=new mCreatureEv[2];
    float parentFitness[]=new float[parentList.length];
    for(mCreatureEv cre:cres)
    {
      if(cre.CC.in_energy<0||MaxloopC<=0)
      {
        if(env.rmCreature(cre))
        {
          deadList.add(cre);
        }
      }
    }
    if(deadList.size()>=1)
    {
      println("DIE out GEN:"+GEN++);
      MaxloopC=60000;
      
      float minFitnessInHonorList=honorLists.get(honorLists.size()-1).getFitness();
      
      for(mCreatureEv dcre:deadList)
      {
        if(minFitnessInHonorList<dcre.getFitness())
        {
          honorLists.add(new mCreatureEv(dcre));
        }
      }
      
      
      
      
      Collections.sort(honorLists);
      GetHornorListTopX(honorLists,honorListsL);
      for(mCreatureEv dcre:honorLists)
      {
        println("Top:"+dcre.getFitness());
      }
      
      float maxFitness=honorLists.get(0).getFitness();
      if(maxFitnessRec<maxFitness)
      {
        maxFitnessRec=maxFitness;
        
        println("MaxLT::"+maxFitnessRec+"  energy:"+deadList.get(0).CC.in_energy);
      }
      
      for(mCreatureEv dcre:deadList)
      {
        {
          for(int i=0;i<parentList.length;i++)
          {
            parentList[i]=GetGoodFitCre(honorLists);
            parentFitness[i]=(parentList[i].getFitness());
          }
          dcre.birth(parentList,parentFitness);
        }
      }
      for(mCreatureEv dcre:deadList)      
      {
        env.addCreature(dcre);
      }
      deadList.clear();
    }
    
    for(int i=0;i<simCount;i++)
    {    
      MaxloopC--;
      env.simulate();
      if(i%(simCount/10+1)==0)
        env.draWorld();
    }
    env.draWorld();
    
    
    
    
    
    cres[0].c=color(180,150,180);
    drawNN.drawNN(cres[0].CC.nn,10,500,550,350);
    
    int NNN=4;
    int Y=250;
    for(int i=0;i<NNN;i++)
    {
      
      stroke(i*255/NNN,255-i*255/NNN,(180+i*255/NNN)%255);
      memHist[i].Draw(cres[0].CC.nn.output[i].latestVar*50,width/2,Y,width/2,300);
      Y+=50;
    }
    stroke(255,255,255);
    inHist[0].Draw(cres[0].CC.in_peerInfo*50,width/2,Y,width/2,300);
      Y+=50;
    stroke(255,0,0);
    inHist[1].Draw(cres[0].CC.ou_expectReward*50,width/2,Y,width/2,300);
    //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
  }
  
  boolean guideG=false;
  void keyPressed()
  {
    
    if (key == CODED) {
      if (keyCode == UP) {
        simCount*=2;
        simCount++;
        if(simCount>200)simCount=200;
      } else if (keyCode == DOWN) {
        simCount/=2;
      } 
    } else {
      guideG=!guideG;
      for(mCreature cre:cres)
      {
        cre.guideGate=guideG;
      }
      println(guideG);
    }
  }  
}