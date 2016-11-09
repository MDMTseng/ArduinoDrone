class mCreature{
  
  float posX,posY;
  float speedX,speedY;
  
  PVector pos=new PVector();
  PVector speed=new PVector();
  float angle;
  float size;
  
  
  
  
  /*
  input:
  hungry level   0~1 long term negtive effect
  exhusted level 0~1  short turn negtive effect
  eyes beam 1  threat level (high)1 ~ -1 (low) = obj specific/dist 
  eyes beam 2
  eyes beam 3
  eyes beam 4
  eyes beam 5
  
  
  output:
  
  turn speed -1~1 * 1 degree/update
  speed adjust (accelerate) -1~1 => 1.01 ~ 1/1.01 
  
  
  
  */
  
  
  int InoutIdx=0;
  
  
  class ConsciousCenter
  {
    s_neuron_net nn = new s_neuron_net(new int[]{7,10,10,3,2});
    float InX[][]=new float[nn.input.length][5];
    float OuY[][]=new float[nn.output.length][InX[0].length];
    
    float energy;
  
  
    float in_hungryLevel;
    float in_exhustedLevel;
    float in_eyesBeam[]=new float[5];
      
      
    float ou_turnSpeed;
    float ou_speedAdj;
      
    void UpdateNeuronInput()
    {
      InoutIdx++;
      InoutIdx%=InX[0].length;
      int i=0;
      
      InX[i++][InoutIdx]=in_hungryLevel;
      InX[i++][InoutIdx]=in_exhustedLevel;
      
      for(int j=0;j<in_eyesBeam.length;j++)
      {
        InX[i++][InoutIdx]=in_eyesBeam[j];
      }
      
      for(int j=0;j<InX.length;j++)
      {
        nn.input[j].latestVar=InX[j][InoutIdx];
      }
      nn.calc();
      
      for(int j=0;j<OuY.length;j++)
      {
        OuY[j][InoutIdx]=nn.output[j].latestVar;
      }
      
      ou_turnSpeed=OuY[0][InoutIdx];
      
      rotation_speed(ou_turnSpeed*3.1/180);
      ou_speedAdj=OuY[1][InoutIdx];
      speed.mult(map(ou_speedAdj,1,-1,1.1,0.8));
      
    }
    
    void StimulationTraining(float stimulationLevel)//+ for reward
    {
      if(stimulationLevel>10)stimulationLevel=10;
      if(stimulationLevel<-10)stimulationLevel=-10;
      stimulationLevel/=10;
      //stimulationLevel=stimulationLevel*stimulationLevel*stimulationLevel;
      
      float greX=0;
      if(stimulationLevel>0)
      {
        greX=-OuY[0][InoutIdx]*0.7;
      }
      else
      {
        greX=OuY[0][InoutIdx]+(OuY[0][InoutIdx]>0?0.2:-0.2);
        
      }
      
      int rIdx=InoutIdx;
      for(int i=InX[0].length-1;i>-1;i--)
      {
          OuY[0][InoutIdx]=greX;
          OuY[1][InoutIdx]+=stimulationLevel*10;
          
          
        
        rIdx--;
        if(rIdx<0)rIdx+=InX[0].length;
      }
      
      float err=nn.TestTrain(InX,OuY,1);
    }
  }
  
  
  mCreature()
  {
    size=50;
    pos.x=10;
    speed.x=5;
    speed.y=5;
    
  }
  
  

  ConsciousCenter CC=new ConsciousCenter();
  
  void handleCollideExceedNormal(PVector normalExcced)
  {
    println("Hit");
    
    
    float crashLevel=normalExcced.mag();
    
    CC.StimulationTraining(-crashLevel*10);
    
    
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
  
  void update(mCreatureEnv env)
  {
    CC.in_hungryLevel=0;
    CC.in_exhustedLevel=0;
    
    float spreadAngle=5;
    PVector ret_intersect=new PVector();
    float speedAngle=atan2(speed.y,speed.x)-spreadAngle*PI/180*(CC.in_eyesBeam.length-1)/2;
    
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      float dist=env.testBeamCollide(pos,speedAngle+spreadAngle*PI/180*i, ret_intersect);
      
      CC.in_eyesBeam[i]=1/dist;
      if(dist<1000)
      {
        ellipse(ret_intersect.x+300,-ret_intersect.y+300, 15, 15);
        float d=(dist-200)/200;
        if(d>1)d=1;
        if(i==CC.in_eyesBeam.length/2&&random(0,1)>0.99)CC.StimulationTraining(d);
      }
      
    }
    
    
    CC.UpdateNeuronInput();
    
    rotation_speed(CC.ou_turnSpeed*PI/180);
    //speed.mult(CC.ou_speedAdj);
    float speedAbs=speed.mag();
    if(speedAbs>5)
      speed.mult(0.8);
    
    
    pos.add(speed);
  }
  
  
}