

class mFixture{
  PVector pos=new PVector();
  PVector speed=new PVector();
  float size;
  
  float mess;
  color c;
  
  void update(mFixtureEnv env)
  {
  }
  void preUpdate(mFixtureEnv env)
  {
  }
  void postUpdate(mFixtureEnv env)
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
    
    s_neuron_net nn = new s_neuron_net(new int[]{4+in_eyesBeam.length+inout_mem.length,20,15,4+inout_mem.length});
    int histC=0;
    float InX[][]=new float[2][nn.input.length];
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
      skipIdx=(skipIdx+1)%1;
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
    
    class ExpData
    {
      /*
      (s(tate),a(ct),r(eward),s'(tate next))
      */
        
      float S_tate[];//current input
      float A_ct[];//output act decision
      float R_eward;
      float S_tate_next[];//next input after current act
      
      ExpData(int stateDim,int actDim)
      {
        S_tate=new float[stateDim];
        S_tate_next=new float[stateDim];
        A_ct=new float[actDim];
      }
      
      
      ExpData(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])
      {
        ExpLink(S_tate,A_ct,R_eward,S_tate_next);
      }
      
      
      void ExpAssign(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])
      {
        this.R_eward=R_eward;
        for(int i=0;i<S_tate.length;i++)
        {
          this.S_tate[i]=S_tate[i];
          if(S_tate_next==null)
           this.S_tate_next[i]=0;
          else
           this.S_tate_next[i]=S_tate_next[i];
        }
        for(int i=0;i<A_ct.length;i++)
        {
          this.A_ct[i]=A_ct[i];
        }
      }
      void ExpLink(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])
      {
        this.S_tate=S_tate;
        this.A_ct=A_ct;
        this.R_eward=R_eward;
        this.S_tate_next=S_tate_next;
      }
    }
    class QLearningCore
    {
      int expWIdx=0;
      ExpData expReplaySet[];
      QLearningCore(int size, int stateDim,int actDim)
      {
        expReplaySet=new ExpData[size];
        for(int i=0;i<expReplaySet.length;i++)
        {
          expReplaySet[i]=new ExpData(stateDim,actDim);
        }
      }
      
      void pushExp(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])//for terminal state set S_tate_next to null
      {
        expReplaySet[expWIdx].ExpAssign(S_tate,A_ct,R_eward,S_tate_next);
        if(++expWIdx>=expReplaySet.length)expWIdx=0;
      }
      
      void actExplain(float q_nx[],ExpData ed) throws Exception
      {
        throw new Exception("You have to Override actExplain method");
      }
      
      float Q_nx[];
      void QlearningTrain(s_neuron_net nn,ExpData ed,float lRate)
      {
        if(Q_nx==null||Q_nx.length<nn.output.length)Q_nx=new float[nn.output.length];
        
        //Q(s,a)=r(s,a)+garmma*max_a'_(Q(s',a'))
        //Get Q(s',a')=>Q_nx
        for(int i=0;i<nn.input.length;i++)nn.input[i].latestVar=ed.S_tate_next[i];
        nn.calc();
        for(int i=0;i<nn.output.length;i++)Q_nx[i]=nn.output[i].latestVar;
        
        try{
          actExplain(Q_nx, ed);
          float Q_x[]=Q_nx;
          nn.TestTrain(ed.S_tate,Q_x,lRate,false,true);
        }
        catch (Exception e) 
        {
        }
      }
      
    }
    
    QLearningCore QL=new QLearningCore(100, InX[0].length, OuY[0].length){
     void actExplain(float q_nx[],ExpData ed)
      {
        //r(s,a)+garmma*max_a'_(Q_nx) => Q_nx
        //if(ed.R_eward!=0)print(ed.R_eward);
        float garmma=0.95;
        
        int selIdx=(ed.A_ct[0]>ed.A_ct[1])?0:1;
        float maxQ_next_act=(q_nx[0]>q_nx[1])?q_nx[0]:q_nx[1];
        q_nx[selIdx]=(ed.R_eward+(garmma)*maxQ_next_act);
        q_nx[1-selIdx]=Float.NaN;  
          
        
        selIdx=(ed.A_ct[2]>ed.A_ct[3])?2:3;
        maxQ_next_act=(q_nx[2]>q_nx[3])?q_nx[2]:q_nx[3];
        q_nx[selIdx]=(ed.R_eward+(garmma)*maxQ_next_act);
        q_nx[5-selIdx]=Float.NaN;  
        
        for(int i=4;i<q_nx.length;i++)//other don't care
          q_nx[i]=Float.NaN;  
          
      }
    };
    
    ExpData thisExp=new ExpData(0,0);
    void ReinforcementTraining(float reward,int iter)//+ for reward
    {
      int currentIdx=InoutIdx;
      int prevIdx=currentIdx-1;
      if(prevIdx<0)prevIdx+=InX.length;
      float state[]=InX[prevIdx];
      float act[]=OuY[prevIdx];
      float nstate[]=InX[currentIdx];
      thisExp.ExpLink(state,act,reward,nstate);
      
      if(reward!=0||random(0,1)>0.8)
      {
        println(reward);
        QL.pushExp(state,act,reward,nstate);
      }
      QL.QlearningTrain(nn,thisExp,0.1);
      
      for(int i=0;i<10;i++)
        QL.QlearningTrain(nn,QL.expReplaySet[(int)random(0,QL.expReplaySet.length)],0.1);
      
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
    Reward=-5;
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
  
  float Reward=0;
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
    if(lifeTime>500&&minDist>100)
    {
      lifeTime=0;
      Reward=0.2;
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
      Reward=-0.2;
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
  
  void preUpdate(mFixtureEnv env)
  {
    Reward=0;
  }
  void postUpdate(mFixtureEnv env)
  {
    CC.nn.PreTrainProcess(0.01);
    CC.ReinforcementTraining(Reward,1);
    Reward=0;
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
        
        //collideCre.CC.in_peerInfo+=CC.ou_expectReward/distret;
        
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