
s_neuron_net nn = new s_neuron_net(new int[]{1,15,15,2});

  
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

float InX[]=new float[20];
float OuY[][]=new float[2][InX.length];





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

HistDataDraw ErrHist=new HistDataDraw(1500);
float XRange=1;
void setup() {
  size(640, 860);
  background(255);
  //noLoop();
  
  
}

float scrollingSpeed=1;
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      scrollingSpeed *= 1.5;
    } else if (keyCode == DOWN) {
      scrollingSpeed /= 1.5;
    } 
    scrollingSpeed+=1;
  } else {
    scrollingSpeed = 0;
  }
}

int TrainCount=0;
float scrollingCount=0;


void draw(){
  strokeWeight(3);
  background(0);
  int hH=height/2;
  int hW=width/2;
  scrollingCount+=scrollingSpeed;
  
  
  for(int i=0;i<InX.length;i++)
  {
    InX[i]=XRange*i/InX.length;//random(0,10);

    OuY[0][i]=sin(InX[i]*30/(XRange*XRange)+scrollingCount/4200.0)*0.5+0.5;//sin(InX[i]*InX[i]*30/(XRange*XRange)+scrollingCount/2200.0)*0.4-0.5+InX[i];//*0.4+0.45;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    
    OuY[0][i]=(float)Math.pow(OuY[0][i]>0?OuY[0][i]:-OuY[0][i],0.2)*(OuY[0][i]>0?1:-1);
    OuY[1][i]=sin(InX[i]*InX[i]*20/(XRange*XRange)+scrollingCount/1200.0)*0.4+0.5;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    //OuY[1][i]=(float)Math.pow(OuY[1][i],11)*0.8;
  }
  
  
  float err=nn.TestTrain(InX,OuY,25);
  ErrHist.Draw(err*5000,0,300,width,500);
  TrainCount+=25;
  drawNN(nn,10,10,550,350);
}


void X1() {
  strokeWeight(3);
  background(0);
  int hH=height/2;
  int hW=width/2;
  scrollingCount+=scrollingSpeed;
  
  
  for(int i=0;i<InX.length;i++)
  {
    InX[i]=XRange*i/InX.length;//random(0,10);

    OuY[0][i]=sin(InX[i]*30/(XRange*XRange)+scrollingCount/4200.0)*0.5+0.5;//sin(InX[i]*InX[i]*30/(XRange*XRange)+scrollingCount/2200.0)*0.4-0.5+InX[i];//*0.4+0.45;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    
    OuY[0][i]=(float)Math.pow(OuY[0][i]>0?OuY[0][i]:-OuY[0][i],0.2)*(OuY[0][i]>0?1:-1);
    OuY[1][i]=sin(InX[i]*InX[i]*20/(XRange*XRange)+scrollingCount/1200.0)*0.4+0.5;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    //OuY[1][i]=(float)Math.pow(OuY[1][i],11)*0.8;
  }
  
  
  float err=nn.TestTrain(InX,OuY,25);
  TrainCount+=25;
  

  float preVar_hidden[]=new float[nn.hidden[0].length];
  
  float preVar_hidden2[]=new float[nn.hidden[1].length];
  float preVar=0;
  float preVar2=0;
  
  float NeuOutOffet=600;
  for (int i = 0; i < width; i += 5) {
    nn.SetCalcNeuronInputData(XRange*i/width);
    
    float tmp,tmp2;
    for(int n=0;n<preVar_hidden.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(255,0,0,50);
      tmp=nn.hidden[0][n].latestVar*100;
      line(i,preVar_hidden[n]+hH,i+5,-tmp+hH);
      preVar_hidden[n]=-tmp;
    }
    
    for(int n=0;n<preVar_hidden2.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(0,255,255,50);
      tmp=nn.hidden[1][n].latestVar*100;
      line(i,preVar_hidden2[n]+hH,i+5,-tmp+hH);
      preVar_hidden2[n]=-tmp;
    }
    
    stroke(250);
    tmp=-nn.output[0].latestVar*100;
    tmp2=-nn.output[1].latestVar*100;
    //line(preVar+hW,preVar2+hH,tmp+hW,tmp2+hH);
    
    line(i,preVar+NeuOutOffet,i+5,tmp+NeuOutOffet);
    line(i,preVar2+NeuOutOffet,i+5,tmp2+NeuOutOffet);
    //line(preVar+hW,preVar2+hH,tmp+hW,tmp2+hH);
    preVar=tmp;
    preVar2=tmp2;
  }
  
  
  stroke(100);
  for (int i = 1; i < InX.length; i ++) {
    //line(InX[i-1]*width/10,-OuY[i-1]*100+hH,InX[i]*width/10,-OuY[i]*100+hH);
    //ellipse(OuY[0][i]*200+hW,OuY[1][i]*200+hH, 5, 5);
    for (int j = 0; j < OuY.length; j ++) {
      stroke(128, (j+1) *255/ OuY.length,150,100);
      
      ellipse(InX[i]*width/XRange+5,-OuY[j][i]*100+NeuOutOffet, 5, 5);
    }
    /*line(
    OuY[0][i]*200+hW,OuY[1][i]*200+hH,
    OuY[0][i-1]*200+hW,OuY[1][i-1]*200+hH);  */
  }
  
  drawNN(nn,10,10,550,350);
  //System.out.printf("ERR:%1.5f C:%05d\n",err,TrainCount);
  //if(err>-0.005)noLoop();
  //noLoop();
}