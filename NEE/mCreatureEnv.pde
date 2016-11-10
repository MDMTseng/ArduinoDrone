class mCreatureEnv{
  
  ArrayList <mCreature> mCre=new ArrayList <mCreature>();
  
  float frameW,frameH;
  
  mCreatureEnv()
  {
    frameW=860;
    frameH=860;
    
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
    
    float collideAmount=0;
    PVector collideVec=new PVector();
    
    if(cre.pos.x-cre.size/2<-frameW/2)
    {
      collideVec.x=frameW/2+(cre.pos.x-cre.size/2);
    }
    else if(cre.pos.x+cre.size/2>frameW/2)
    {
      collideVec.x=(cre.pos.x+cre.size/2)-frameW/2;
    }
    
    if(cre.pos.y-cre.size/2<-frameH/2)
    {
      collideVec.y=frameH/2+(cre.pos.y-cre.size/2);
    }
    else if(cre.pos.y+cre.size/2>frameH/2)
    {
      collideVec.y=(cre.pos.y+cre.size/2)-frameH/2;
    }
    if(collideVec.x!=0||collideVec.y!=0)
    {
      collideAmount++;
      ret_normalExcced.add(collideVec);
      
    }
    for(mCreature xcre:mCre)
    {
      if(xcre==cre)continue;
      collideVec.set(cre.pos);
      
      collideVec.sub(xcre.pos);
      if(collideVec.mag()<(xcre.size+cre.size)/2)
      {
        collideVec.mult(-xcre.mess/(xcre.mess+cre.mess)*0.2);
        collideAmount+=0.2;
        ret_normalExcced.add(collideVec);
      }
    }
    
    if(collideAmount>0)
    {
      ret_normalExcced.div(1);
      return true;
    }
    
    return false;
  }
  
  int getquadrant (float angle_rad)
  {
    float angle_deg=angle_rad/PI*180;
    angle_deg%=360;
    if(angle_deg<0)angle_deg+=360;
    
    
    return (int)(angle_deg/90)+1;
    
  }
  
  float testBeamCreCollide(  PVector position, PVector vec2dest, mCreature cre,PVector ret_intersect)
  {
    /*PVector dX=new PVector(100*cos(angle_rad),100*sin(angle_rad));
    float a=dX.x;
    float b=dX.y;
    float c=-position.y*a-position.x*b;
    if()
    */
    PVector dX=new PVector();
    dX.set(cre.pos);
    dX.sub(position);
    
    float dot=dX.dot(vec2dest);
    if(dot<0)return Float.POSITIVE_INFINITY;
    dX.set(vec2dest);
    dX.mult(dot);
    dX.add(position);
   
    float dist=Float.POSITIVE_INFINITY;
    if(dX.dist(cre.pos)<cre.size*2)
    {
      dist=position.dist(cre.pos);
      ret_intersect.set(vec2dest);
      ret_intersect.mult(dist);
      ret_intersect.add(position);
    }
    
    return dist;
  }
  
  float testBeamCollide(PVector position,float angle_rad,PVector ret_intersect)
  {
    PVector intersect=new PVector();
    PVector EnvBound1=new PVector();
    PVector EnvBound2=new PVector();
    int vec_quadrant= getquadrant ( angle_rad);
    float minDist=Float.POSITIVE_INFINITY;
    final PVector orientation=new PVector(cos(angle_rad),sin(angle_rad));
    
    PVector position2=new PVector();
    position2.set(orientation);
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
    
    for(mCreature cre:mCre)
    {
      if(cre.pos==position)continue;
      float dist=testBeamCreCollide(position,orientation,cre,intersect);
      if(dist<minDist)
      {
        isCollide=true;
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
    if(ret_normalExcced.x!=0)cre.speed.x+=-0.01*cre.speed.x;
    if(ret_normalExcced.y!=0)cre.speed.y+=-0.01*cre.speed.y;
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
      fill(cre.c);
      stroke(cre.c);
      ellipse(cre.pos.x+frameW/2,-cre.pos.y+frameH/2, cre.size, cre.size);
      
      
      fill(255);
      stroke(255);
      line(cre.pos.x+frameW/2,-cre.pos.y+frameH/2,cre.pos.x+5*cre.speed.x+frameW/2,-(cre.pos.y+5*cre.speed.y)+frameH/2 );
    }
  }
  
}