class mFixtureEnv{
  mFIXStruct mf=new mFIXStruct();
  ArrayList <mFixture> mCre=new ArrayList <mFixture>();
  
  float frameW,frameH;
  
  mFixtureEnv(int env_width,int env_height)
  {
    frameW=env_width;
    frameH=env_height;
    
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
    ret_intersect.x==Float.NEGATIVE_INFINITY||
    ret_intersect.y==Float.POSITIVE_INFINITY||
    ret_intersect.y==Float.NEGATIVE_INFINITY
    
    )return false;
    
    return true;
  }
  boolean addCreature(mFixture cre)
  {
    return mCre.add(cre);
  }
  boolean rmCreature(mFixture cre)
  {
    return mCre.remove(cre);
  }
  mFixture testEnvCollide(final mFixture cre,PVector ret_normalExcced)
  {
    ret_normalExcced.mult(0);
    mFixture collideObj=null;
    float collideAmount=0;
    PVector collideVec=new PVector();
    
    
    
    for(mFixture xcre:mCre)
    {
      if(xcre==cre)continue;
      collideVec.set(cre.pos);
      
      collideVec.sub(xcre.pos);
      if(collideVec.mag()<(xcre.size+cre.size)/2)
      {
        collideObj=xcre;
        collideVec.mult(-xcre.mess/(xcre.mess+cre.mess)*0.5);
        collideAmount+=0.2;
        ret_normalExcced.add(collideVec);
      }
    }
    
    collideVec.mult(0);
    
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
    
    if(collideAmount!=0)
    {
      collideObj=mf;
    }
    
    if(collideAmount>0)
    {
      ret_normalExcced.div(1);
      return collideObj;
    }
    
    return null;
  }
  
  int getquadrant (float angle_rad)
  {
    float angle_deg=angle_rad/PI*180;
    angle_deg%=360;
    if(angle_deg<0)angle_deg+=360;
    
    
    return (int)(angle_deg/90)+1;
    
  }
  
  float testBeamCreCollide(  PVector position, PVector vec2dest, mFixture cre,PVector ret_intersect)
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
   
    float closestDist=dX.dist(cre.pos);
    
    
    
    
    float r=cre.size*2;//x0.5
    
    
    
    if(closestDist<r)
    {
      closestDist=position.dist(cre.pos);
      ret_intersect.set(vec2dest);
      ret_intersect.mult(closestDist);
      ret_intersect.add(position);
      return closestDist;
    }
    
    return Float.POSITIVE_INFINITY;
  }
  
  float testBeamCollide(PVector position,float angle_rad,PVector ret_intersect,mFixture collideObj[])
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
    
    collideObj[0]=null;
    
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
    if(isCollide)
      collideObj[0]=mf;
    
    
    for(mFixture cre:mCre)
    {
      if(cre.pos==position)continue;
      float dist=testBeamCreCollide(position,orientation,cre,intersect);
      if(dist<minDist)
      {
        isCollide=true;
        collideObj[0]=cre;
        ret_intersect.set(intersect);
        minDist=dist;
      }
      
    }
    
    
    if(!isCollide)minDist= Float.POSITIVE_INFINITY;
    
    return minDist;
  }
  
  void simulateCollide(mFixture cre,final PVector ret_normalExcced)
  {
    /*PVector normal=new PVector(ret_normalExcced.x,ret_normalExcced.y,ret_normalExcced.z);
    normal.normalize();
    
    
    PVector reflect = cre.pos.sub(normal.dot());*/
   // if(ret_normalExcced.x>0)
    
    cre.pos.sub(ret_normalExcced);
    //if(ret_normalExcced.x!=0)cre.speed.x+=-0.5*ret_normalExcced.x;
    //if(ret_normalExcced.y!=0)cre.speed.y+=-0.5*ret_normalExcced.y;
  }
  
  
  void simulate()
  {
    PVector ret_normalExcced=new PVector(0,0,0);
    
    for(mFixture cre:mCre)
    {
      cre.update(this);
    }
    
    for(mFixture cre:mCre)
    {
      mFixture collideObj=testEnvCollide(cre,ret_normalExcced);
      if(collideObj!=null)
      {
        simulateCollide(cre,ret_normalExcced);
        cre.handleCollideExceedNormal(ret_normalExcced,collideObj);
      }
    }
  }
  
  void draWorld()
  {
    
    for(mFixture cre:mCre)
    {
      cre.draw(frameW/2,frameH/2);
      
    }
  }
  
}