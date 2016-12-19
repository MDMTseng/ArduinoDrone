

class mFixture{
  PVector pos=new PVector();
  PVector speed=new PVector();
  float size;
  
  float mess;
  color c;
  
  void update(mFixtureEnv env)
  {
  }
    
  void handleCollideExceedNormal(PVector normalExcced,mFixture collideObj)
  {
  }
  
  void draw(float offsetX,float offsetY)
  {
    fill(c);
    stroke(c);
    ellipse(pos.x+offsetX,-pos.y+offsetY, size, size);
    
    
    fill(255);
    stroke(255);
    line(pos.x+offsetX,-pos.y+offsetY,pos.x+5*speed.x+offsetX,-(pos.y+5*speed.y)+offsetY );
  }
}


  class ConsciousCenter
  {
    float in_energy;
    float in_exhustedLevel;
    float in_currentSpeed;
    float in_peerInfo;
    float in_eyesBeam[]=new float[5];
    
    float inout_mem[]=new float[0];
    
    float ou_turnLeft;
    float ou_turnRight;
    float ou_speedUp;
    float ou_speedDown;
    float ou_expectReward;
    
    s_neuron_net nn = new s_neuron_net(new int[]{4+in_eyesBeam.length+inout_mem.length,25,20,15,5+inout_mem.length});
    int histC=0;
    float InX[][]=new float[30][nn.input.length];
    float OuY[][]=new float[InX.length][nn.output.length];
    
    
    
    float energy;
  
    ConsciousCenter expShareList[];
    void set_expShareList(ConsciousCenter expShareList[])
    {
      this.expShareList=expShareList;
    }
    
    ConsciousCenter()
    {
      init();
    }
      
    void init()
    {
      in_energy=0;
      in_exhustedLevel=0;
      in_currentSpeed=0;
      in_peerInfo=0;
      for(int i=0;i<in_eyesBeam.length;i++)
      {
        in_eyesBeam[i]=0;
      }
      for(int i=0;i<inout_mem.length;i++)
      {
        inout_mem[i]=0;
      }
    }
    int skipIdx=0;
    
    void histReset()
    {
      skipIdx=0;
      histC=0;
    }
        
    int InoutIdx=0;
    void UpdateNeuronInput()
    {
      skipIdx=(skipIdx+1)%2;
      if(skipIdx==0)
      {
        histC++;
        if(histC>InX.length)histC=InX.length;
        InoutIdx++;
        InoutIdx%=InX.length;
      }
      int i=0;
      
      InX[InoutIdx][i++]=in_energy;
      InX[InoutIdx][i++]=in_exhustedLevel;
      InX[InoutIdx][i++]=in_currentSpeed;
      InX[InoutIdx][i++]=in_peerInfo;
      for(int j=0;j<in_eyesBeam.length;j++)
      {
        InX[InoutIdx][i++]=in_eyesBeam[j];
      }
      
      
      for(int j=0;j<inout_mem.length;j++)
      {
        InX[InoutIdx][i++]=inout_mem[j];
      }
      
      
      
      for(int j=0;j<InX[InoutIdx].length;j++)
      {
        nn.input[j].latestVar=InX[InoutIdx][j];
      }
      nn.calc();
      
      for(int j=0;j<OuY[InoutIdx].length;j++)
      {
        OuY[InoutIdx][j]=nn.output[j].latestVar;
      }
      i=0;
      if(random(0,1)>0.80)
      {
        OuY[InoutIdx][0]+=(random(0,1)>0.5)?100:-100;
      }
      if(random(0,1)>0.80)
      {
        OuY[InoutIdx][2]+=(random(0,1)>0.5)?100:-100;
      }
      ou_turnLeft=OuY[InoutIdx][i++];
      ou_turnRight=OuY[InoutIdx][i++];
      ou_speedUp=OuY[InoutIdx][i++];
      ou_speedDown=OuY[InoutIdx][i++];
      
      
      for(int j=0;j<inout_mem.length;j++)
      {
        inout_mem[j]=OuY[InoutIdx][i++];
      }
    }
    
    int expeienceWIdx=0;
    float eInX[][]=new float[100][nn.input.length];
    float eOuY[][]=new float[eInX.length][nn.output.length];
    
    /*
    (s(tate),a(ct),r(eward),s'(tate next))
    
    
    
    
    */
    
    float S_tate[][]=new float[100][nn.input.length];
    float A_ct[][]=new float[S_tate.length][nn.output.length];
    float S_tate_next[][]=new float[S_tate.length][nn.input.length];
    float R_eward[]=new float[S_tate.length];
    
    void pushExperienceX(float eInXSample[],float eOuYSample[])
    {
      for(int i=0;i<eInXSample.length;i++)
      {
        eInX[expeienceWIdx][i]=eInXSample[i];
      }
      
      for(int i=0;i<eOuYSample.length;i++)
      {
        eOuY[expeienceWIdx][i]=eOuYSample[i];
      }
      
      expeienceWIdx++;
      if(expeienceWIdx>=eInX.length)
      {
        expeienceWIdx=0;
      }
      
    }
    
    void ReinforcementTraining(float rewardLevel,int iter)//+ for reward
    {
      if(histC<3)return;
      if(rewardLevel>1)rewardLevel=1;
      if(rewardLevel<-1)rewardLevel=-1;
      
      float centerX;
      int rIdx=InoutIdx;
      
      float rewardLevel_Rotate=rewardLevel;
      float rewardFuture_Rotate=0;
      float rewardLevel_Speed=rewardLevel;
      float rewardFuture_Speed=0;
      
      float alpha=0.9;
      float garma=0.5;
      for(int i=0;i<histC;i++)
      {
        int selIdx;
        float tmp;
        
        selIdx=(OuY[rIdx][0]>OuY[rIdx][1])?0:1;
        if(OuY[rIdx][0]>50)OuY[rIdx][0]-=100;
        if(OuY[rIdx][0]<-50)OuY[rIdx][0]+=100;
        
        OuY[rIdx][selIdx]=(alpha)*OuY[rIdx][selIdx]+(1-alpha)*(rewardLevel_Rotate+(garma)*rewardFuture_Rotate);
        rewardFuture_Rotate=(OuY[rIdx][0]>OuY[rIdx][1])?OuY[rIdx][0]:OuY[rIdx][1];
        rewardLevel_Rotate=0;
        OuY[rIdx][1-selIdx]=Float.POSITIVE_INFINITY;  
          
        
        selIdx=(OuY[rIdx][2]>OuY[rIdx][3])?2:3;
        if(OuY[rIdx][2]>50)OuY[rIdx][2]-=100;
        if(OuY[rIdx][2]<-50)OuY[rIdx][2]+=100;
        OuY[rIdx][selIdx]=(alpha)*OuY[rIdx][selIdx]+(1-alpha)*(rewardLevel_Speed+(garma)*rewardFuture_Speed);
        rewardFuture_Speed=(OuY[rIdx][2]>OuY[rIdx][3])?OuY[rIdx][2]:OuY[rIdx][3];
        rewardLevel_Speed=0;
        
        OuY[rIdx][5-selIdx]=Float.POSITIVE_INFINITY;  
        //if(i<10)println(">>"+i+" i:"+selIdx+">"+OuY[rIdx][2]+"<>"+OuY[rIdx][3]);
        
        /*centerX=(OuY[rIdx][0]+OuY[rIdx][1])/100;
        OuY[rIdx][0]-=centerX;
        OuY[rIdx][1]-=centerX;
        
        centerX=(OuY[rIdx][2]+OuY[rIdx][3])/100;
        OuY[rIdx][2]-=centerX;
        OuY[rIdx][3]-=centerX;*/
        
        OuY[rIdx][4]=rewardLevel;
        
        if((i<15&&(random(0,1)>0.8))||i==0)
          pushExperienceX(InX[rIdx],OuY[rIdx]);
        //alpha*=0.5;
        rIdx--;
        if(rIdx<0)rIdx+=InX.length;
      }
      
      float lRate =0.1;
      nn.TestTrain(InX,OuY,InoutIdx,histC,lRate,false,true);
      
      //nn.Update_dW(lRate/histC);
      nn.TestTrain(eInX,eOuY,eInX.length-1,eInX.length,lRate,false,true);
      if(expShareList!=null)
      for(int i=0;i<expShareList.length;i++)
      {
        if(expShareList[i]==this)continue;
        if(random(0,1)>0.9)
          expShareList[i].nn.TestTrain(eInX,eOuY,eInX.length-1,eInX.length,lRate,false,true);
          
        
      }
      
    }
    void BoostingTraining(float alpha)//+ for reward
    {
      int rIdx=InoutIdx;
      for(int i=0;i<InX.length;i++)
      {
          for(int j=0;j<InX[i].length;j++)
          {
            InX[rIdx][j]+=random(-alpha,alpha);
          }
          
          rIdx--;
          if(rIdx<0)rIdx+=InX.length;
      }
      
      
      //training(InX,OuY,1,0.1);
    }

    
  
  }
  

class mFIXStruct extends mFixture
{
  mFIXStruct()
  {
    size=Float.POSITIVE_INFINITY;
    mess=Float.POSITIVE_INFINITY;
  }
}


class mEnergyUp extends mFixture
{
  mEnergyUp()
  {
    size=8;
    mess=0.1;
  }
}
  
  
class mCreature extends mFixture{
  
  mCreature()
  {
    reset();
  }
  
  void reset()
  {
    size=20;
    mess=1;
    pos.x=random(-300,300);
    pos.y=random(-300,300);
    speed.x=random(-2,2);
    speed.y=random(-2,2);
    c=color(random(0,255),random(0,255),random(0,255),100);
    CC.init();
    CC.in_energy=1;
    
  }

  ConsciousCenter CC=new ConsciousCenter();
  
  void handleCollideExceedNormal(PVector normalExcced,mFixture collideObj)
  {
    float crashLevel=normalExcced.mag();
    if((collideObj instanceof mCreature) )
    {
      mCreature cobj=(mCreature)collideObj;
      if(cobj.lifeTime<5)return;
    }
    else
    {
    }
    
    CC.ReinforcementTraining(-1,1);
    CC.histReset();
    lifeTime=0;
    pos.x=random(-200,200);
    pos.y=random(-200,200);
    speed.x=random(-1,1);
    speed.y=random(-1,1);
    
  }
  
  
  protected void rotation_speed(float d)
  {
    float x,y;
    float cos=cos(d),sin=sin(d);
    x= cos*speed.x-sin*speed.y;
    y= sin*speed.x+cos*speed.y;
    
    speed.x=x;
    speed.y=y;
  }
  boolean guideGate=false;
  //HistDataDraw turnHist=new HistDataDraw(1500);
  //HistDataDraw speedHist=new HistDataDraw(1500);
  int speedLowC=0;
  
  PVector prePos=new PVector();
  
  float turnAcc = 0;
  float speedAbs;
  float turnAmount=0;
  int rewardC=0;
  
  float lifeTime=0;
  boolean isfellBad=false;
  mFixtureEnv env=null;
  float eye_spreadAngle=15;
  
  mFixture retCollide[]=new mFixture[1];
  void update(mFixtureEnv env)
  {
     this.env=env;
    CC.in_peerInfo*=0.6;
    float velocity=prePos.dist(pos);
    prePos.set(pos);
      
    
    PVector ret_intersect=new PVector();
    float speedAngle=atan2(speed.y,speed.x)-eye_spreadAngle*PI/180*(CC.in_eyesBeam.length-1)/2;
    
    float minDist=Float.POSITIVE_INFINITY;
    float maxDist=0;
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      float distret=env.testBeamCollide(pos,speedAngle+eye_spreadAngle*PI/180*i,ret_intersect, retCollide);
      if(minDist>distret)minDist=distret;
      if(maxDist<distret)maxDist=distret;
      CC.in_eyesBeam[i]=100/distret;
      if(retCollide[0] instanceof mCreature)
      {
        mCreature collideCre = (mCreature)retCollide[0];
        
        //collideCre.CC.in_peerInfo+=CC.ou_expectReward;
      }

    }
    //println("minDist="+minDist);
   // minDist=(minDist+maxDist)/2;
    if(lifeTime>2000&&minDist>100)
    {
      lifeTime=0;
      CC.ReinforcementTraining(0.7,1);
    }
      
    CC.UpdateNeuronInput();
    
    CC.in_energy*=0.9999;
    
   
    
    
    //stroke(0,255,0,100);
    //turnHist.Draw(CC.ou_turnSpeed*10,0,300,width,500);
    if(CC.ou_speedUp>CC.ou_speedDown)
    {
      speed.mult(1.01);
    }
    else
    {
      speed.mult(1/1.01);
    }
    
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    CC.in_currentSpeed=speedAbs/2;
    
    float turn=CC.ou_turnLeft>CC.ou_turnRight?1:-1;
    
    rotation_speed(turn*PI/180);
    turnAmount+=turn;
    
    if(turnAmount>500||turnAmount<-500)
    {
      turnAmount=0;
      
      lifeTime=0;
      CC.ReinforcementTraining(-0.8,1);
    }
    //stroke(128,200,0,100);
    //speedHist.Draw(CC.ou_speedAdj*10,0,300,width,500);
    
    
    if(speedAbs>3)
    {
      speed.mult(0.9);
    }
    else if(speedAbs<0.5)
      speed.mult(random(1.1,1.2));

    lifeTime+=speedAbs/5+0.5;
    
    pos.add(speed);
  }
  
  void draw(float offsetX,float offsetY)
  {
    
    stroke(c,50);
    fill(c,50);
    
    PVector ret_intersect=new PVector();
    float speedAngle=atan2(speed.y,speed.x)-eye_spreadAngle*PI/180*(CC.in_eyesBeam.length-1)/2;
    
    if(env!=null)
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      env.testBeamCollide(pos,speedAngle+eye_spreadAngle*PI/180*i,ret_intersect, retCollide);
      ellipse(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2, 15, 15);
      line(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2,pos.x+env.frameW/2,-pos.y+env.frameH/2);

    }
    
    fill(c);
    stroke(c);
    
    ellipse(pos.x+offsetX,-pos.y+offsetY, size, size);
    
    
    fill(255);
    stroke(255);
    line(pos.x+offsetX,-pos.y+offsetY,pos.x+5*speed.x+offsetX,-(pos.y+5*speed.y)+offsetY );
    
    noFill();
    
    
  }
  
}


  
class mCreatureEv extends mCreature implements Comparable<mCreatureEv>{
  
  int lifeTime=0;
  float turnX=0;
  float speeUpC=0;
  int seeOtherC=0;
  int HitMark=0;
  
  public int compareTo(mCreatureEv other) {
      return Float.compare(other.getFitness(),getFitness());// name.compareTo(other.name);
  }
  
  
  void clone(mCreatureEv from)
  {
    
    s_neuron_net nn_from[]=new s_neuron_net[1];
    float fitness[] =new float[1];
    nn_from[0]=from.CC.nn;
    fitness[0]=from.getFitness();
    CC.nn.GeneticCrossNN(nn_from,fitness);
    revive();
    
    turnX=from.turnX;
    speeUpC=from.speeUpC;
    lifeTime=from.lifeTime;
    seeOtherC=from.seeOtherC;
    
  }
  
  mCreatureEv()
  {
    super();
    revive();
  }
  mCreatureEv(mCreatureEv parents[],float fitness[])
  {
    this();
    birth(parents,fitness);
  }
  
  mCreatureEv(mCreatureEv cloneFrom)
  {
    this();
    clone(cloneFrom);
  }
  void revive()
  {
    reset();
    lifeTime=0;
    turnX=0;
    seeOtherC=0;
    speeUpC=0;
    CC.in_energy=0.5;
    size=10;
    HitMark=0;
  }
  
  void birth(mCreatureEv parents[],float fitness[])
  {
    s_neuron_net nn_parents[]=new s_neuron_net[parents.length];
    for(int i=0;i<nn_parents.length;i++)
    {
      nn_parents[i]=parents[i].CC.nn;
    }
    CC.nn.GeneticCrossNN(nn_parents,fitness);
    if(random(0,1)>0.5)CC.nn.AddNNNoise(0.03);
    if(random(0,1)>0.7)CC.nn.AddNNmutate(0.1);
    CC.nn.PreTrainProcess(0.01);
    revive();
    
  }
  
  
  ConsciousCenter CC=new ConsciousCenter();
  
  void handleCollideExceedNormal(PVector normalExcced,mFixture collideObj)
  {
    float mag=normalExcced.mag();
    if((collideObj instanceof mCreatureEv) )
    {
      CC.in_energy-=0.002*mag;
      HitMark+=20;
    }
    else
    {
      CC.in_energy-=0.03*mag;
      HitMark=255;
    }
      
  }
  
  float turnAcc = 0;
  float speedAbs;
  
  float getFitness()
  {
    float turnAmount=turnX>0?turnX:-turnX;
    return lifeTime-turnAmount*2+speeUpC/4;
  }
  
  boolean isfellBad=false;
  void update(mFixtureEnv env)
  {
    float spreadAngle=100/CC.in_eyesBeam.length;
    PVector ret_intersect=new PVector();
    float speedAngle=atan2(speed.y,speed.x)-spreadAngle*PI/180*(CC.in_eyesBeam.length-1)/2;
    
    float minDist=Float.POSITIVE_INFINITY;
    float maxDist=0;
    stroke(c,100);
    fill(c,100);
    
    mFixture retCollide[]=new mFixture[1];
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      float distret=env.testBeamCollide(pos,speedAngle+spreadAngle*PI/180*i,ret_intersect, retCollide);
      if(minDist>distret)minDist=distret;
      if(maxDist<distret)maxDist=distret;
     
      //ellipse(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2, 15, 15);
      //line(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2,pos.x+env.frameW/2,-pos.y+env.frameH/2);
      if(retCollide[0] instanceof mCreatureEv)
      {
        mCreatureEv collideCre = (mCreatureEv)retCollide[0];
        
        collideCre.CC.in_peerInfo+=CC.ou_expectReward/distret;
        
        //collideCre.CC.in_energy+=0.001/distret;
        CC.in_energy+=0.01/distret/CC.in_eyesBeam.length;
        CC.in_eyesBeam[i]=-100/distret;
      }
      else
      {
         CC.in_eyesBeam[i]=-100/distret;
      }

    
    }
   // CC.in_energy*=0.95;
    //if(CC.in_energy>1)CC.in_energy=1;
    CC.in_peerInfo*=0.9;
    CC.UpdateNeuronInput();
    
    
    
     
    //stroke(0,255,0,100);
    //turnHist.Draw(CC.ou_turnSpeed*10,0,300,width,500);
    if(CC.ou_speedUp>CC.ou_speedDown)
    {
      speed.mult(1.01);
    }
    else
    {
      speed.mult(1/1.01);
    }
    
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    CC.in_currentSpeed=speedAbs/2;
    
    float turn=CC.ou_turnLeft>CC.ou_turnRight?1:-1;
    
    
    
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    //CC.in_energy-=0.001/speedAbs;
    CC.in_currentSpeed=speedAbs/2;
    rotation_speed(turn*PI/180);
    turnX+=turn;
    
    {
      float absTurnX=(turnX>0)?turnX:-turnX;
      CC.in_energy-=0.0000001*absTurnX;
    }
    //stroke(128,200,0,100);
    //speedHist.Draw(CC.ou_speedAdj*10,0,300,width,500);
    
    if(CC.in_energy>0.8&&random(0,1)>0.8&&HitMark==0){
      //println("Hit:"+preFiness);
      CC.BoostingTraining(0.2);
    }
   
      
    if(speedAbs>3)
    {
      speed.mult(0.9);
    }
    else if(speedAbs<0.5)
      speed.mult(1.1);

    lifeTime+=speed.mag()/5+0.5;
    pos.add(speed);
  }
  void draw(float offsetX,float offsetY)
  {
    fill(c);
    stroke(c);
    ellipse(pos.x+offsetX,-pos.y+offsetY, size, size);
    
    
    fill(255);
    stroke(255);
    line(pos.x+offsetX,-pos.y+offsetY,pos.x+5*speed.x+offsetX,-(pos.y+5*speed.y)+offsetY );
    
    noFill();
    
    
    if(HitMark>0)
    {
      stroke(255,50,150);
      
    }
    HitMark=HitMark*13/14;
    arc(pos.x+offsetX,-pos.y+offsetY,size+2+HitMark/10, size+2+HitMark/10, 0, 2*CC.in_energy*PI);
  }
  
}