class mCreatureEnv{
  
  ArrayList <mCreature> mCre=new ArrayList <mCreature>();
  
  float frameW,frameH;
  
  mCreatureEnv()
  {
    frameW=600;
    frameH=600;
    
  }
  boolean detectLineIntersecting(PVector a1,PVector a2,PVector b3,PVector b4,PVector ret_intersect)
  {
    float Denominator=(a1.x-a2.x)*(b3.y-b4.y)-(a1.y-a2.y)*(b3.x-b4.x);
    /*if(Denominator<0.000001&&Denominator>-0.000001)
      return false;*/
      
    float tmp1=a1.x*a2.y-a1.y*a2.x;
    float tmp2=b3.x*b4.y-b3.y*b4.x;
    
    float NumiratorX=tmp1*(b3.x-b4.x)-(a1.x-a2.x)*tmp2;
    
    float NumiratorY=tmp1*(b3.y-b4.y)-(a1.y-a2.y)*tmp2;
    
    ret_intersect.x=NumiratorX/Denominator;
    ret_intersect.y=NumiratorY/Denominator;
    
    if(
    Float.isNaN(ret_intersect.x)||
    Float.isNaN(ret_intersect.y)||
    ret_intersect.x==Float.POSITIVE_INFINITY||
    ret_intersect.x==-Float.NEGATIVE_INFINITY||
    ret_intersect.y==Float.POSITIVE_INFINITY||
    ret_intersect.y==-Float.NEGATIVE_INFINITY
    
    )return false;
    
    return true;
  }
  void addCreature(mCreature cre)
  {
    mCre.add(cre);
  }
  boolean testEnvCollide(final mCreature cre,PVector ret_normalExcced)
  {
    ret_normalExcced.mult(0);
    
    if(cre.pos.x-cre.size/2<-frameW/2)
    {
      ret_normalExcced.x=frameW/2+(cre.pos.x-cre.size/2);
    }
    else if(cre.pos.x+cre.size/2>frameW/2)
    {
      ret_normalExcced.x=(cre.pos.x+cre.size/2)-frameW/2;
    }
    
    if(cre.pos.y-cre.size/2<-frameH/2)
    {
      ret_normalExcced.y=frameH/2+(cre.pos.y-cre.size/2);
    }
    else if(cre.pos.y+cre.size/2>frameH/2)
    {
      ret_normalExcced.y=(cre.pos.y+cre.size/2)-frameH/2;
    }
    if(ret_normalExcced.x!=0||ret_normalExcced.y!=0)return true;
    
    return false;
  }
  
  int getquadrant (float angle_rad)
  {
    float angle_deg=angle_rad/PI*180;
    angle_deg%=360;
    if(angle_deg<0)angle_deg+=360;
    
    if(angle_deg<90)return 1;
    if(angle_deg<180)return 2;
    if(angle_deg<270)return 3;
    return 4;
    
  }
  
  
  float testBeamCollide(PVector position,float angle_rad,PVector ret_intersect)
  {
    PVector intersect=new PVector();
    PVector EnvBound1=new PVector();
    PVector EnvBound2=new PVector();
    int vec_quadrant= getquadrant ( angle_rad);
    float minDist=Float.POSITIVE_INFINITY;
    PVector position2=new PVector(100*cos(angle_rad),100*sin(angle_rad));
    position2.add(position);
    /*
        2
     ______
     |     |
    3|     | 1
     |_____|
        4
    
    */
    
    
    EnvBound1.x= frameW/2;
    EnvBound1.y= frameH/2;
    
    EnvBound2.x= frameW/2;
    EnvBound2.y=-frameH/2;
    
    boolean isCollide=false;
    if((vec_quadrant==1||vec_quadrant==4)&&
    detectLineIntersecting(position,position2,EnvBound1,EnvBound2,intersect)
    )
    {
      isCollide=true;
      float dist=intersect.dist(position);
      if(dist<minDist)
      {
        ret_intersect.set(intersect);
        minDist=dist;
      }
    }
    
    EnvBound2.x= -frameW/2;
    EnvBound2.y=  frameH/2;
    if((vec_quadrant==1||vec_quadrant==2)&&
    detectLineIntersecting(position,position2,EnvBound1,EnvBound2,intersect)
    )
    {
      isCollide=true;
      float dist=intersect.dist(position);
      if(dist<minDist)
      {
        ret_intersect.set(intersect);
        minDist=dist;
      }
    }
    
    
    EnvBound1.x= -frameW/2;
    EnvBound1.y= -frameH/2;
    if((vec_quadrant==2||vec_quadrant==3)&&
    detectLineIntersecting(position,position2,EnvBound1,EnvBound2,intersect)
    )
    {
      isCollide=true;
      float dist=intersect.dist(position);
      if(dist<minDist)
      {
        ret_intersect.set(intersect);
        minDist=dist;
      }
    }
    EnvBound2.x= frameW/2;
    EnvBound2.y=-frameH/2;
    
    if((vec_quadrant==3||vec_quadrant==4)&&
    detectLineIntersecting(position,position2,EnvBound1,EnvBound2,intersect)
    )
    {
      isCollide=true;
      float dist=intersect.dist(position);
      if(dist<minDist)
      {
        ret_intersect.set(intersect);
        minDist=dist;
      }
    }
    
    if(!isCollide)return Float.POSITIVE_INFINITY;
    return minDist;
  }
  
  void simulateCollide(mCreature cre,final PVector ret_normalExcced)
  {
    /*PVector normal=new PVector(ret_normalExcced.x,ret_normalExcced.y,ret_normalExcced.z);
    normal.normalize();
    
    
    PVector reflect = cre.pos.sub(normal.dot());*/
   // if(ret_normalExcced.x>0)
    cre.pos.sub(ret_normalExcced);
    if(ret_normalExcced.x!=0)cre.speed.x=-cre.speed.x;
    if(ret_normalExcced.y!=0)cre.speed.y=-cre.speed.y;
  }
  
  
  void simulate()
  {
    PVector ret_normalExcced=new PVector(0,0,0);
    
    for(mCreature cre:mCre)
    {
      cre.update(this);
    }
    
    for(mCreature cre:mCre)
    {
      if(testEnvCollide(cre,ret_normalExcced))
      {
        simulateCollide(cre,ret_normalExcced);
        cre.handleCollideExceedNormal(ret_normalExcced);
      }
    }
  }
  
  void draWorld()
  {
    for(mCreature cre:mCre)
    {
      ellipse(cre.pos.x+frameW/2,-cre.pos.y+frameH/2, cre.size, cre.size);
    }
  }
  
}