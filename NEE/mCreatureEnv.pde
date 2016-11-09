class mCreatureEnv{
  
  ArrayList <mCreature> mCre=new ArrayList <mCreature>();
  
  float frameW,frameH;
  
  mCreatureEnv()
  {
    frameW=600;
    frameH=600;
    
  }
  
  void addCreature(mCreature cre)
  {
    mCre.add(cre);
  }
  boolean testEnvCollide(final mCreature cre,PVector ret_normalExcced)
  {
    ret_normalExcced.x=0;
    ret_normalExcced.y=0;
    ret_normalExcced.z=0;
    
    if(cre.pos.x-cre.size/2<-frameW/2)
    {
      ret_normalExcced.x=-frameW/2-(cre.pos.x-cre.size/2);
      return true;
    }
    
    if(cre.pos.x+cre.size/2>frameW/2)
    {
      ret_normalExcced.x=(cre.pos.x+cre.size/2)-frameW/2;
      return true;
    }
    
    if(cre.pos.y-cre.size/2<-frameH/2)
    {
      ret_normalExcced.x=-frameH/2-(cre.pos.y-cre.size/2);
      return true;
    }
    
    
    if(cre.pos.y+cre.size/2>frameH/2)
    {
      ret_normalExcced.x=(cre.pos.y+cre.size/2)-frameH/2;
      return true;
    }
    
    return false;
  }
  
  void simulateCollide(mCreature cre,final PVector ret_normalExcced)
  {
    /*PVector normal=new PVector(ret_normalExcced.x,ret_normalExcced.y,ret_normalExcced.z);
    normal.normalize();
    
    
    PVector reflect = cre.pos.sub(normal.dot());*/
   // if(ret_normalExcced.x>0)
    cre.pos.add(ret_normalExcced);
    if(ret_normalExcced.x!=0)cre.pos.x=-cre.pos.x;
    if(ret_normalExcced.y!=0)cre.pos.y=-cre.pos.y;
  }
  
  
  void simulate()
  {
    PVector ret_normalExcced=new PVector();
    for(mCreature cre:mCre)
    {
      if(testEnvCollide(cre,ret_normalExcced))
      {
        simulateCollide(cre,ret_normalExcced);
      }
    }
  }
  
  void draWorld()
  {
    for(mCreature cre:mCre)
    {
      println(cre.pos.x);
      ellipse(cre.pos.x+frameW/2,cre.pos.y+frameH/2, cre.size, cre.size);
    }
  }
  
}