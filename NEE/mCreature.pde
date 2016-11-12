

class mFixture{
  PVector pos=new PVector();
  PVector speed=new PVector();
  float size;
  
  float mess;
  color c;
  
  void update(mFixtureEnv env)
  {
  }
    
  void handleCollideExceedNormal(PVector normalExcced)
  {
  }
  
}


  class ConsciousCenter
  {
    float in_energy;
    float in_exhustedLevel;
    float in_currentSpeed;
    float in_eyesBeam[]=new float[5];
    
    float inout_mem[]=new float[2];
    
    float ou_turnSpeed;
    float ou_speedAdj;
    
    s_neuron_net nn = new s_neuron_net(new int[]{3+in_eyesBeam.length+inout_mem.length,8,8,2+inout_mem.length});
    float InX[][]=new float[10][nn.input.length];
    float OuY[][]=new float[InX.length][nn.output.length];
    
    float energy;
  
    ConsciousCenter expShareList[];
    void set_expShareList(ConsciousCenter expShareList[])
    {
      this.expShareList=expShareList;
    }
      
    
    int skipIdx=0;
        
    int InoutIdx=0;
    void UpdateNeuronInput()
    {
      skipIdx=(skipIdx+1)%5;
      if(skipIdx==0)
      {
        InoutIdx++;
        InoutIdx%=InX.length;
      }
      int i=0;
      
      InX[InoutIdx][i++]=in_energy;
      InX[InoutIdx][i++]=in_exhustedLevel;
      InX[InoutIdx][i++]=in_currentSpeed;
      in_exhustedLevel/=1.01;
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
        in_exhustedLevel*=0.99;
        //greX=-2*OuY[0][InoutIdx];
        greX=(in_eyesBeam[in_eyesBeam.length-2]+in_eyesBeam[in_eyesBeam.length-1])-(in_eyesBeam[0]+in_eyesBeam[1]);
        memAdj=1.01;
      }
      else
      {
        in_exhustedLevel+=.1;
        greX=((in_eyesBeam[in_eyesBeam.length-2]+in_eyesBeam[in_eyesBeam.length-1])>(in_eyesBeam[0]+in_eyesBeam[1])?-0.8:0.8);
        memAdj=-0.8;
      }
      
      
      float alpha=1;
      int rIdx=InoutIdx;
      for(int i=0;i<InX[0].length;i++)
      {
          OuY[rIdx][0]=OuY[rIdx][0]*(1-alpha)+(alpha)*(greX);
            

          /*if(stimulationLevel<0&&speedAbs<1||
          stimulationLevel>0&&speedAbs>3
          )
          {
            
            //println("OK...........");
    
          }
          else*/
          OuY[rIdx][1]=OuY[rIdx][1]*(1-alpha)+(alpha)*stimulationLevel;
          
          memAdj=1*(1-alpha)+(alpha)*memAdj;
          
          for(int j=0;j<inout_mem.length;j++)
          {
            OuY[rIdx][j+2]*=memAdj;
          }
          alpha/=1.5;
          rIdx--;
          if(rIdx<0)rIdx+=InX.length;
      }
      
      float lRate =(stimulationLevel)>0? 0.2:0.5;
      training(InX,OuY,iter,lRate);
      if(expShareList!=null&&stimulationLevel<0)
      for(int i=0;i<expShareList.length;i++)
      {
        if(expShareList[i]==this)continue;
        expShareList[i].training(InX,OuY,iter/3+1,lRate*0.8);
        
      }
      
    }
    void BoostingTraining()//+ for reward
    {
      float alpha=0.1;
      int rIdx=InoutIdx;
      for(int i=0;i<InX[0].length;i++)
      {
          
          OuY[0][rIdx]+=random(-alpha,alpha);

          OuY[1][rIdx]+=random(-alpha,alpha);
          
          
          for(int j=0;j<inout_mem.length;j++)
          {
            OuY[j+2][rIdx]+=random(-alpha,alpha);
          }
          rIdx--;
          if(rIdx<0)rIdx+=InX[0].length;
      }
      
      
      training(InX,OuY,1,0.01);
    }
    float training(float InX[][],float OuY[][],int iter,float lRate)
    {
      float memLoopTrain=1;
      
      for(int i=0;i<memLoopTrain;i++)
      {
        nn.TestTrain(InX,OuY,iter,lRate,false);
      }
      
      
      return  0;
    }
  }
  
class mCreature extends mFixture{
  
  mCreature()
  {
    size=30;
    mess=1;
    pos.x=random(-300,300);
    pos.y=random(-300,300);
    speed.x=random(-10,10);
    speed.y=random(-10,10);
    c=color(random(0,255),random(0,255),random(0,255),100);
    
    
    CC.in_energy=1;
  }

  ConsciousCenter CC=new ConsciousCenter();
  
  void handleCollideExceedNormal(PVector normalExcced)
  {
   // println("Hit");
    
    
    float crashLevel=normalExcced.mag()+2;
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      //println("CC.in_eyesBeam["+i+"]="+CC.in_eyesBeam[i]);

    }
    CC.StimulationTraining(-crashLevel*2,1);
    
  }
  
  
  private void rotation_speed(float d)
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
  void update(mFixtureEnv env)
  {
          
    float velocity=prePos.dist(pos);
    prePos.set(pos);
    if(velocity<0.05)
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
    
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      float dist=env.testBeamCollide(pos,speedAngle+spreadAngle*PI/180*i, ret_intersect);
      if(minDist>dist)minDist=dist;
      if(maxDist<dist)maxDist=dist;
      CC.in_eyesBeam[i]=100/dist;
      
      //ellipse(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2, 15, 15);
      //line(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2,pos.x+env.frameW/2,-pos.y+env.frameH/2);

    }
   // minDist=(minDist+maxDist)/2;
    if(!guideGate&&minDist>200)
    {
      float d=((minDist)-200)/200;
      if(d>1)d=1;
      CC.StimulationTraining(d,1);
      
    }
      
    CC.UpdateNeuronInput();
    
    CC.in_energy*=0.9999;
    
    if(CC.ou_turnSpeed>-0.1&&CC.ou_turnSpeed<0.1)
    {
      
      if(random(0,1)>0.5)
        CC.BoostingTraining();
    
    }
    
    rotation_speed(2*CC.ou_turnSpeed*PI/180);
    
    //stroke(0,255,0,100);
    //turnHist.Draw(CC.ou_turnSpeed*10,0,300,width,500);
    
    speed.mult(map(CC.ou_speedAdj,1,-1,1.1,1/1.1));
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    
    CC.in_currentSpeed=speedAbs/2;
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