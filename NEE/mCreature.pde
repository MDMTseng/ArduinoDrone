

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
    float in_eyesBeam[]=new float[10];
    
    float inout_mem[]=new float[3];
    
    float ou_turnSpeed;
    float ou_speedAdj;
    float ou_sendInfo;
    
    s_neuron_net nn = new s_neuron_net(new int[]{4+in_eyesBeam.length+inout_mem.length,5,10,10,3+inout_mem.length});
    float InX[][]=new float[20][nn.input.length];
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
        
    int InoutIdx=0;
    void UpdateNeuronInput()
    {
      skipIdx=(skipIdx+1)%3;
      if(skipIdx==0)
      {
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
      ou_turnSpeed=OuY[InoutIdx][i++];
      
      //rotation_speed(ou_turnSpeed*3.1/180);
      ou_speedAdj=OuY[InoutIdx][i++];
      ou_sendInfo=OuY[InoutIdx][i++];
      
      for(int j=0;j<inout_mem.length;j++)
      {
        inout_mem[j]=OuY[InoutIdx][i++];
      }
    }
    
    void StimulationTraining(float stimulationLevel,int iter)//+ for reward
    {
      if(stimulationLevel>10)stimulationLevel=10;
      if(stimulationLevel<-10)stimulationLevel=-10;
      stimulationLevel/=10;
      //stimulationLevel=stimulationLevel*stimulationLevel*stimulationLevel;
      
      float greX=0;
      float memAdj=0;
      if(stimulationLevel>0)
      {
        in_exhustedLevel*=0.5;
        //greX=-2*OuY[0][InoutIdx];
        greX=(in_eyesBeam[in_eyesBeam.length-2]+in_eyesBeam[in_eyesBeam.length-1])-(in_eyesBeam[0]+in_eyesBeam[1]);
        memAdj=1;
      }
      else
      {
        in_exhustedLevel+=.1;
        greX=((in_eyesBeam[in_eyesBeam.length-2]+in_eyesBeam[in_eyesBeam.length-1])>(in_eyesBeam[0]+in_eyesBeam[1])?-0.8:0.8);
        memAdj=-0.5;
      }
      
      
      float alpha=1;
      int rIdx=InoutIdx;
      for(int i=0;i<InX[0].length;i++)
      {
          OuY[rIdx][0]=OuY[rIdx][0]*(1-alpha)+(alpha)*(greX);

          OuY[rIdx][1]=OuY[rIdx][1]*(1-alpha)+(alpha)*stimulationLevel;
          
          OuY[rIdx][2]=stimulationLevel>0?1:-1;
          memAdj=1*(1-alpha)+(alpha)*memAdj;
          for(int j=0;j<inout_mem.length;j++)
          {
            OuY[rIdx][j+3]*=memAdj;
          }


          alpha/=1.1;
          rIdx--;
          if(rIdx<0)rIdx+=InX.length;
      }
      
      float lRate =(stimulationLevel)>0? 0.5:1;
      training(InX,OuY,iter,lRate);
      if(expShareList!=null)
      for(int i=0;i<expShareList.length;i++)
      {
        if(expShareList[i]==this)continue;
        expShareList[i].training(InX,OuY,iter/3+1,lRate*0.8);
        
      }
      
    }
    void BoostingTraining(float alpha)//+ for reward
    {
      int rIdx=InoutIdx;
      for(int i=0;i<OuY.length;i++)
      {
          for(int j=0;j<OuY[i].length;j++)
          {
            OuY[rIdx][j]+=random(-alpha,alpha);
          }
          
          rIdx--;
          if(rIdx<0)rIdx+=InX.length;
      }
      
      
      training(InX,OuY,1,0.5);
    }
    float training(float InX[][],float OuY[][],int iter,float lRate)
    {
      float memLoopTrain=1;
      
      for(int i=0;i<memLoopTrain;i++)
      {
        
        nn.PreTrainProcess(lRate);
        /*for(int j=0;j<iter;j++)
        {
          for(int k=0;k<InX.length;k++)
          {
            nn.TestTrainRecNN(InX[j],OuY[j],lRate,false,5,inout_mem.length);
          }
        }*/
        
        
        nn.TestTrain(InX,OuY,iter,lRate);
      }
      
      return  0;
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
  
  void handleCollideExceedNormal(PVector normalExcced)
  {
   // println("Hit");
    if(guideGate)return;
    
    float crashLevel=normalExcced.mag()+2;
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      //println("CC.in_eyesBeam["+i+"]="+CC.in_eyesBeam[i]);

    }
    CC.StimulationTraining(-crashLevel*5,1);
    
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
  
  boolean isfellBad=false;
  void update(mFixtureEnv env)
  {
    
    if(!isfellBad&&CC.ou_sendInfo<-0.5)
    {
      isfellBad=true;
        println("FeelBad....");
    }
    else if(isfellBad&&CC.ou_sendInfo>0.5)
    {
      isfellBad=false;
        println("It's good Now....");
    }
    
    CC.in_peerInfo*=0.6;
    float velocity=prePos.dist(pos);
    prePos.set(pos);
    if(velocity<0.001)
    {  
      speedLowC++;
      if(speedLowC>120)
      {
        
        pos.x=random(-100,100);
        pos.y=random(-100,100);
            
        speed.x=random(-10,10);
        speed.y=random(-10,10);
        speedLowC=0;
      }
    }
    else
    {
      speedLowC=0;
    }
      
    
    
    float spreadAngle=20;
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
      CC.in_eyesBeam[i]=100/distret;
      if(retCollide[0] instanceof mCreature)
      {
        mCreature collideCre = (mCreature)retCollide[0];
        
        collideCre.CC.in_peerInfo+=CC.ou_sendInfo;
      }
      //ellipse(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2, 15, 15);
      //line(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2,pos.x+env.frameW/2,-pos.y+env.frameH/2);

    }
   // minDist=(minDist+maxDist)/2;
    if(!guideGate&&minDist>200)
    {
      float d=((minDist)-200)/200;
      if(d>1)d=1;
      CC.StimulationTraining(d/5,1);
      
    }
      
    CC.UpdateNeuronInput();
    
    CC.in_energy*=0.9999;
    
   
    
    
    //stroke(0,255,0,100);
    //turnHist.Draw(CC.ou_turnSpeed*10,0,300,width,500);
    
    speed.mult(map(CC.ou_speedAdj,1,-1,1.1,1/1.1));
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    CC.in_currentSpeed=speedAbs/2;
    rotation_speed((0.5+CC.in_currentSpeed)*CC.ou_turnSpeed*PI/180);
    
    //stroke(128,200,0,100);
    //speedHist.Draw(CC.ou_speedAdj*10,0,300,width,500);
    
    
    if(speedAbs>3)
    {
      speed.mult(0.9);
    }
    else if(speedAbs<0.5)
      speed.mult(random(1.1,1.2));

    
    pos.add(speed);
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
    CC.nn.PreTrainProcess(0.1);
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
    lifeTime++;
    
    
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
        
        collideCre.CC.in_peerInfo+=CC.ou_sendInfo/distret;
        
        //collideCre.CC.in_energy+=0.001/distret;
        CC.in_energy+=0.01/distret/CC.in_eyesBeam.length;
        CC.in_eyesBeam[i]=100/distret;
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
    
    
 
    speed.mult(map(CC.ou_speedAdj,1,-1,1.1,1/1.1));
    speeUpC+=CC.ou_speedAdj;
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    //CC.in_energy-=0.001/speedAbs;
    CC.in_currentSpeed=speedAbs/2;
    rotation_speed((0.3+CC.in_currentSpeed)*CC.ou_turnSpeed*PI/180);
    turnX+=CC.ou_turnSpeed;
    
    {
      float absTurnX=(turnX>0)?turnX:-turnX;
      CC.in_energy-=0.0000001*absTurnX;
    }
    //stroke(128,200,0,100);
    //speedHist.Draw(CC.ou_speedAdj*10,0,300,width,500);
    
    if(CC.in_energy>0.8&&random(0,1)>0.8&&HitMark==0){
      //println("Hit:"+preFiness);
      CC.BoostingTraining(0.5);
    }
   
      
    if(speedAbs>3)
    {
      speed.mult(0.9);
    }
    else if(speedAbs<0.5)
      speed.mult(random(1.1,1.2));

    lifeTime+=speed.mag()/5;
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