class NeuralTest{

s_neuron_net nn = new s_neuron_net(new int[]{2,10,10,10,10,2});

  

float InX[][]=new float[150][nn.input.length];
float OuY[][]=new float[InX.length][nn.output.length];
Draw_s_neuron_net drawNN=new Draw_s_neuron_net();

float XRange=1;


void InXOuYSetUp1(float n,float InX[][],float OuY[][])
{
  
  float freqX=sin(n)*2;
  
  for(int i=0;i<InX.length/2;i++)
  {
      float x,y;
      float t=(InX.length/2-i+1)*1.0/InX.length;
      x=(float)sin((float)(t*Math.PI*(8*freqX)+3.1+n))*t;
      y=(float)cos((float)(t*Math.PI*(8*freqX)+3.1+n))*t;
      InX[i][0]=x;
      InX[i][1]=y;
      
      OuY[i][0]=1;
      OuY[i][1]=0;
  }
  
  for(int i=InX.length/2;i<InX.length;i++)
  {
      float x,y;
      float t=(i-InX.length/2)*1.0/InX.length;
      x=(float)sin((float)(t*Math.PI*(8*freqX)+n))*t;
      y=(float)cos((float)(t*Math.PI*(8*freqX)+n))*t;
      InX[i][0]=x;
      InX[i][1]=y;
      
      OuY[i][0]=0;
      OuY[i][1]=1;
  }
  

}


void InXOuYSetUp2(float n,float InX[][],float OuY[][])
{
  
  float freqX=sin(n)*2;
  
  for(int i=0;i<InX.length/2;i++)
  {
      float x,y;
      float t=(InX.length/2-i+1)*1.0/InX.length;
      x=(float)sin((float)(t*Math.PI*15+n))*t-0.1;
      y=(t-0.25)*2;
      InX[i][0]=x;
      InX[i][1]=y;
      
      OuY[i][0]=1;
      OuY[i][1]=-1;
  }
  
  for(int i=InX.length/2;i<InX.length;i++)
  {
      float x,y;
      float t=(i-InX.length/2)*1.0/InX.length;
      x=-(float)sin((float)(t*Math.PI*15+3.14159+n))*t+0.1;
      y=(t-0.25)*2;
      InX[i][0]=x;
      InX[i][1]=y;
      
      OuY[i][0]=-1;
      OuY[i][1]=1;
  }
  
}

void InXOuYRandomOrder(float InX[][],float OuY[][])
{
  
  for(int i=0;i<InX.length;i++)
  {
    int swapIdx=(int)Math.floor(random(0,1-0.0001)*InX.length);
    float tmp;
    tmp=InX[i][0];
    InX[i][0]=InX[swapIdx][0];
    InX[swapIdx][0]=tmp;
    tmp=InX[i][1];
    InX[i][1]=InX[swapIdx][1];
    InX[swapIdx][1]=tmp;
    
    tmp=OuY[i][0];
    OuY[i][0]=OuY[swapIdx][0];
    OuY[swapIdx][0]=tmp;
    
    tmp=OuY[i][1];
    OuY[i][1]=OuY[swapIdx][1];
    OuY[swapIdx][1]=tmp;
  }
    
}
void InXOuYAddNoise(float InX[][],float OuY[][],float Noise)
{
  for(int i=0;i<InX.length;i++)
  {
      InX[i][0]+=random(-1,1)*Noise;
      InX[i][1]+=random(-1,1)*Noise;
      
  }
}
float scrollingSpeed=0.0005*0;



int TrainCount=0;
float scrollingCount=-0.75;


HistDataDraw ErrHist=new HistDataDraw(1500);
HistDataDraw SRateHist=new HistDataDraw(1500);
DataFeedDraw DFDOutI0=new DataFeedDraw();
DataFeedDraw DFDOutI1=new DataFeedDraw();

DataFeedDraw DFDOut0=new DataFeedDraw();
DataFeedDraw DFDOut1=new DataFeedDraw();
DataFeedDraw2D DFD2D=new DataFeedDraw2D();


int CCC=0;
void X2(){
  
    strokeWeight(3);
    background(0);
  int hH=height/2;
  int hW=width/2;
  
  if(CCC%1==0)
    InXOuYSetUp1(scrollingCount,InX,OuY);
  CCC++;
 //InXOuYAddNoise(InX,OuY,0.02);
 InXOuYRandomOrder(InX,OuY); 
  
  drawNN.drawNN(nn,10,10,550,350);
  
  
  int DrawYAdj=150;
  
  int gridSize=20;
  for(int i=0;i<gridSize;i++)for(int j=0;j<gridSize;j++)
  {
    
    nn.input[0].latestVar=1.0*j/gridSize-0.5;
    nn.input[1].latestVar=1.0*i/gridSize-0.5;
    float timesx=1;
    nn.input[0].latestVar*=timesx;
    nn.input[1].latestVar*=timesx;
    nn.calc();
    nn.input[0].latestVar/=timesx;
    nn.input[1].latestVar/=timesx;
    
    if(nn.output[0].latestVar>nn.output[1].latestVar)
    {
      fill(0,255,128,20);
      stroke(0,255,128,20);
    }
    else
    {
      fill(255,0,128,20);
      stroke(255,0,128,20);
    }
    ellipse((nn.input[0].latestVar)*2*200+hW,(nn.input[1].latestVar)*2*200+hH+DrawYAdj, 200/gridSize, 200/gridSize);
    
    
  }
  int successCount=0;
  for(int i=0;i<InX.length;i++)
  {
    for(int j=0;j<InX[i].length;j++)
    {
      nn.input[j].latestVar=InX[i][j];
    }
    nn.calc();
    
    if(nn.output[0].latestVar>nn.output[1].latestVar)
    {
      if(OuY[i][0]==1)successCount++;
      fill(0,255,128,100);
      stroke(0,255,128,100);
    }
    else
    {
      if(OuY[i][1]==1)successCount++;
      fill(0,255,128,100);
      stroke(255,0,128,100);
    }
    ellipse((InX[i][0])*2*200+hW,(InX[i][1])*2*200+hH+DrawYAdj, 8, 8);
    /*
    stroke(255,255,128,50);
    DFDOut0.Draw(nn.output[0].latestVar*200,i,InX.length,0,300,width,300);
    stroke(255,128,255,50);
    DFDOut1.Draw(nn.output[0].latestVar/(nn.output[1].latestVar+nn.output[0].latestVar)*200,i,InX.length,0,300,width,300);*/
    
  }
  
  /*for(int i=0;;i++)
  for(int i=0;i<InX.length;i++)
  {
    nn.TestTrainRecNN(InX[i],OuY[i],0.5,false,1,0);
  }*/
  
  boolean crossEn=false;
  float lrate=0.1;
  
  float err=nn.TestTrain(InX,OuY,25,lrate);
  
  
  
  stroke(0,255,0,100);
  ErrHist.Draw((float)Math.log(err+1)*1000,0,300,width,500);
  stroke(128,128,0,100);
  
  //if(1.0*successCount/InX.length>0.80)
    scrollingCount+=scrollingSpeed;
  SRateHist.Draw(sqrt(nn.hidden[1][3].ADss[5])*20,0,700,width,100);
  TrainCount+=25;
  //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      scrollingSpeed *= 1.5;
      scrollingSpeed+=0.0001;
    } else if (keyCode == DOWN) {
      scrollingSpeed /= 1.5;
    } 
  } else {
    scrollingSpeed = 0;
  }
}


}