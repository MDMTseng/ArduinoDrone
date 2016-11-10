class mCreature{
  
  float posX,posY;
  float speedX,speedY;
  float mess;
  
  PVector pos=new PVector();
  PVector speed=new PVector();
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
    s_neuron_net nn = new s_neuron_net(new int[]{7,8,7,2});
    float InX[][]=new float[nn.input.length][15];
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
      in_exhustedLevel/=1.01;
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
      
      //rotation_speed(ou_turnSpeed*3.1/180);
      ou_speedAdj=OuY[1][InoutIdx];
      
    }
    
    void StimulationTraining(float stimulationLevel,int iter)//+ for reward
    {
      if(stimulationLevel>10)stimulationLevel=10;
      if(stimulationLevel<-10)stimulationLevel=-10;
      stimulationLevel/=10;
      //stimulationLevel=stimulationLevel*stimulationLevel*stimulationLevel;
      
      float greX=0;
      if(stimulationLevel>0)
      {
        greX=0;
      }
      else
      {
        in_exhustedLevel-=.1;
        greX=OuY[0][InoutIdx]+(in_eyesBeam[4]>in_eyesBeam[0]?-2:2);
        
      }
      
      int rIdx=InoutIdx;
      for(int i=0;i<InX[0].length;i++)
      {
          OuY[0][rIdx]=greX;


          /*if(stimulationLevel<0&&speedAbs<1||
          stimulationLevel>0&&speedAbs>3
          )
          {
            
            //println("OK...........");
    
          }
          else*/
          OuY[1][rIdx]+=stimulationLevel;
          
          
        
          rIdx--;
          if(rIdx<0)rIdx+=InX[0].length;
      }
      
      float err=nn.TestTrain(InX,OuY,iter,0.05);
    }
  }
  
  
  mCreature()
  {
    size=50;
    mess=1;
    pos.x=random(-100,100);
    pos.y=random(-100,100);
    speed.x=random(-10,10);
    speed.y=random(-10,10);
    
  }
  
  

  ConsciousCenter CC=new ConsciousCenter();
  
  void handleCollideExceedNormal(PVector normalExcced)
  {
    println("Hit");
    
    
    float crashLevel=normalExcced.mag()+2;
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      println("CC.in_eyesBeam["+i+"]="+CC.in_eyesBeam[i]);

    }
    CC.StimulationTraining(-crashLevel*3,5);
    
    
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
  HistDataDraw turnHist=new HistDataDraw(1500);
  HistDataDraw speedHist=new HistDataDraw(1500);
  float speedAbs;
  void update(mCreatureEnv env)
  {
    CC.in_hungryLevel=0;
    
    float spreadAngle=20;
    PVector ret_intersect=new PVector();
    float speedAngle=atan2(speed.y,speed.x)-spreadAngle*PI/180*(CC.in_eyesBeam.length-1)/2;
    
    float minDist=Float.POSITIVE_INFINITY;
    float maxDist=0;
    for(int i=0;i<CC.in_eyesBeam.length;i++)
    {
      
      float dist=env.testBeamCollide(pos,speedAngle+spreadAngle*PI/180*i, ret_intersect);
      if(minDist>dist)minDist=dist;
      if(maxDist<dist)maxDist=dist;
      CC.in_eyesBeam[i]=10/dist;
      ellipse(ret_intersect.x+env.frameW/2,-ret_intersect.y+env.frameH/2, 15, 15);

    }
   // minDist=(minDist+maxDist)/2;
    if(!guideGate&&minDist>100)
    {
      float d=(minDist-100)/100;
      if(d>2)d=2;
      d*=4;
      CC.StimulationTraining(d,1);
      
    }
      
    CC.UpdateNeuronInput();
    
    
    
    
    rotation_speed(1*CC.ou_turnSpeed*PI/180);
    
    stroke(0,255,0,100);
    turnHist.Draw(CC.ou_turnSpeed*10,0,300,width,500);
    
    speed.mult(map(CC.ou_speedAdj,1,-1,1.1,1/1.1));
    //speed.mult(CC.ou_speedAdj);
    speedAbs=speed.mag();
    
    stroke(128,200,0,100);
    speedHist.Draw(CC.ou_speedAdj*10,0,300,width,500);
    
    
    if(speedAbs>10)
      speed.mult(0.9);
    else if(speedAbs<0.1)
      speed.mult(random(1.5,1.7));
      
    
    
    pos.add(speed);
  }
  
  
}