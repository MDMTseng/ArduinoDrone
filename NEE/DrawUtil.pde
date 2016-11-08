
class Draw_s_neuron_net{
  
  
  void drawNN(s_neuron_net nnet,int x,int y,int w,int h)
  {
    int layerNum=nnet.ns.size();
    for(int i=layerNum-1;i!=0;i--)
    {
      s_neuron layerNodes[]=nnet.ns.get(i);
      for(int j=0;j<layerNodes.length;j++)
      {
        int x_start=w/layerNodes.length/2;
        int x_start_pre=w/(layerNodes[j].pre_neuron_L-1)/2;
        
        for(int k=0;k<layerNodes[j].pre_neuron_L-1;k++)
        {
          float d=layerNodes[j].W[k];
          if(d<0)d=-d;
          int drawColor=(int)(Math.log(d+1)*100);
          if(drawColor>100)drawColor=100;
          if(layerNodes[j].W[k]>0)
            stroke(0,255,0,drawColor);
          else
            stroke(255,0,0,drawColor);
          
          line(
            x+j*w/layerNodes.length+x_start    , y+i*h/layerNum, 
            x+k*w/(layerNodes[j].pre_neuron_L-1)+x_start_pre, y+(i-1)*h/layerNum
          );
        }
      }
    }
    
    for(int i=0;i<layerNum;i++)
    {
      s_neuron layerNodes[]=nnet.ns.get(i);
      int x_start=w/layerNodes.length/2;
      for(int j=0;j<layerNodes.length;j++)
      {
        ellipse(x+j*w/layerNodes.length+x_start, y+i*h/layerNum, 5, 5);
      }
    }  
  }

}





class HistDataDraw{
  
  float Hist[];
  HistDataDraw(int L)
  {
    Hist=new float[L];
  }
  int HistH=0;
  void Draw(float newData,int x,int y,int w,int h) {
    
    Hist[HistH]=newData;
    HistH=(HistH+1)%Hist.length;
    
    line(x,y,x+w,y);
    line(x,y+h,x+w,y+h);
    int PreadH=0;
    int readH=HistH;
    for(int i=1;i<Hist.length-1;i++)
    {
      PreadH=readH;
      readH=(readH+1)%Hist.length;
      
      line(i*w/Hist.length+x,(h-Hist[PreadH])+y,
      (i+1)*w/Hist.length+x,(h-Hist[readH])+y);
    }
  }
}

class DataFeedDraw{
  float PreData;
  void Draw(float newData,int idx,int idxTop,int x,int y,int w,int h) {
    line((idx-1)*w/idxTop+x,(h-PreData)+y,
         (idx)*w/idxTop+x,  (h-newData)+y);
    PreData=newData;
  }
}
class DataFeedDraw2D{
  float PreDataX;
  float PreDataY;
  void Draw(float newDataX,float newDataY,int x,int y,int w,int h) {
    line((newDataX)*w+x,(h-PreDataY)+y,
         (newDataX)*w+x,  (h-newDataY)+y);
    PreDataX=newDataX;
    PreDataY=newDataY;
  }
}