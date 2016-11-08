class NeuralTest{

s_neuron_net nn = new s_neuron_net(new int[]{2,3,3,33,3,3,2});

  

float InX[][]=new float[nn.input.length][150];
float OuY[][]=new float[nn.output.length][InX[0].length];
Draw_s_neuron_net drawNN=new Draw_s_neuron_net();

float XRange=1;


void InXOuYSetUp1(float n,float InX[][],float OuY[][])
{
  
  float freqX=sin(n)*2;
  
  for(int i=0;i<InX[0].length/2;i++)
  {
      float x,y;
      float t=(InX[0].length/2-i+5)*1.0/InX[0].length;
      x=(float)sin((float)(t*Math.PI*(8*freqX)+3.1+n))*t;
      y=(float)cos((float)(t*Math.PI*(8*freqX)+3.1+n))*t;
      InX[0][i]=x;
      InX[1][i]=y;
      
      OuY[0][i]=0;
      OuY[1][i]=1;
  }
  
  for(int i=InX[0].length/2;i<InX[0].length;i++)
  {
      float x,y;
      float t=(5+i-InX[0].length/2)*1.0/InX[0].length;
      x=(float)sin((float)(t*Math.PI*(8*freqX)+n))*t;
      y=(float)cos((float)(t*Math.PI*(8*freqX)+n))*t;
      InX[0][i]=x;
      InX[1][i]=y;
      
      OuY[0][i]=1;
      OuY[1][i]=0;
  }
  
  
  for(int i=0;i<0*InX[0].length;i++)
  {
    int swapIdx=(int)Math.floor(random(0,1-0.0001)*InX[0].length);
    float tmp;
    tmp=InX[0][i];
    InX[0][i]=InX[0][swapIdx];
    InX[0][swapIdx]=tmp;
    tmp=InX[1][i];
    InX[1][i]=InX[1][swapIdx];
    InX[1][swapIdx]=tmp;
    
    tmp=OuY[0][i];
    OuY[0][i]=OuY[0][swapIdx];
    OuY[0][swapIdx]=tmp;
    
    tmp=OuY[1][i];
    OuY[1][i]=OuY[1][swapIdx];
    OuY[1][swapIdx]=tmp;
  }
    
}



void InXOuYSetUp2(float n,float InX[][],float OuY[][])
{
  
  float freqX=sin(n)*4;
  
  for(int i=0;i<InX[0].length/2;i++)
  {
      float x,y;
      float t=i*1.0/InX[0].length;
      x=(float)sin((float)(t*Math.PI*(8+freqX)+n))*t+0.4;
      y=t*2;
      InX[0][i]=x;
      InX[1][i]=y;
      
      OuY[0][i]=0;
      OuY[1][i]=1;
  }
  
  for(int i=InX[0].length/2;i<InX[0].length;i++)
  {
      float x,y;
      float t=(InX[0].length-i)*1.0/InX[0].length;
      x=(float)sin((float)(t*Math.PI*(8+freqX)+n))*t+0.6;
      y=t*2;
      InX[0][i]=x;
      InX[1][i]=y;
      
      OuY[0][i]=1;
      OuY[1][i]=0;
  }
}
void InXOuYAddNoise(float InX[][],float OuY[][],float Noise)
{
  for(int i=0;i<InX[0].length;i++)
  {
      InX[0][i]+=random(-1,1)*Noise;
      InX[1][i]+=random(-1,1)*Noise;
      
      //OuY[0][i]=random(-1,1)*Noise;
      //OuY[1][i]=random(-1,1)*Noise;
  }
}
float scrollingSpeed=0.000;



int TrainCount=0;
float scrollingCount=-0.2;


HistDataDraw ErrHist=new HistDataDraw(1500);
HistDataDraw SRateHist=new HistDataDraw(1500);
DataFeedDraw DFDOutI0=new DataFeedDraw();
DataFeedDraw DFDOutI1=new DataFeedDraw();

DataFeedDraw DFDOut0=new DataFeedDraw();
DataFeedDraw DFDOut1=new DataFeedDraw();
DataFeedDraw2D DFD2D=new DataFeedDraw2D();


int CCC=0;
void X2(){
  int hH=height/2;
  int hW=width/2;
  
  if(CCC%1==0)
    InXOuYSetUp1(scrollingCount,InX,OuY);
  CCC++;
  InXOuYAddNoise(InX,OuY,0.005);
  /*for(int i=0;i<InX[0].length;i++)
  {
    if(OuY[0][i]==1)
    {
      stroke(0,255,0);
    }
    else
    {
      stroke(255,0,0);
    }
    ellipse((InX[0][i]-0.5)*2*190+hW,(InX[1][i]-0.5)*2*190+hH, 5, 5);
  }
  */
  
  drawNN.drawNN(nn,10,10,550,350);
  
  
  int DrawYAdj=150;
  
  int gridSize=20;
  for(int i=0;i<gridSize;i++)for(int j=0;j<gridSize;j++)
  {
    nn.input[0].latestVar=1.0*j/gridSize-0.5;
    nn.input[1].latestVar=1.0*i/gridSize-0.5;
    
    nn.calc();
    
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
  for(int i=0;i<InX[0].length;i++)
  {
    for(int j=0;j<InX.length;j++)
    {
      nn.input[j].latestVar=InX[j][i];
    }
    nn.calc();
    
    if(nn.output[0].latestVar>nn.output[1].latestVar)
    {
      if(OuY[0][i]==1)successCount++;
      fill(0,255,128,100);
      stroke(0,255,128,100);
    }
    else
    {
      if(OuY[1][i]==1)successCount++;
      fill(0,255,128,100);
      stroke(255,0,128,100);
    }
    ellipse((InX[0][i])*2*200+hW,(InX[1][i])*2*200+hH+DrawYAdj, 8, 8);
    
    //stroke(255,255,128,50);
    //DFDOut0.Draw(nn.output[0].latestVar*200,i,InX[0].length,0,300,width,300);
    //stroke(255,128,255,50);
    //DFDOut1.Draw(nn.output[0].latestVar/(nn.output[1].latestVar+nn.output[0].latestVar)*200,i,InX[0].length,0,300,width,300);
    
  }
  
  
  float err=nn.TestTrain(InX,OuY,25);
  stroke(0,255,0,100);
  ErrHist.Draw((float)Math.log(err+1)*1000,0,300,width,500);
  stroke(128,128,0,100);
  
  if(1.0*successCount/InX[0].length>0.80)
    scrollingCount+=scrollingSpeed;
  SRateHist.Draw(100.0*successCount/InX[0].length,0,700,width,100);
  TrainCount+=25;
  //if((TrainCount/25)%10==0) nn.RandomDropOut(0.003);
}


void X1() {
  int hH=height/2;
  int hW=width/2;
  
  
  for(int i=0;i<InX[0].length;i++)
  {
    InX[0][i]=XRange*i/InX[0].length;//random(0,XRange);

    OuY[0][i]=sin(InX[0][i]*30/(XRange*XRange)+scrollingCount/4200.0)*0.5+0.5;//sin(InX[i]*InX[i]*30/(XRange*XRange)+scrollingCount/2200.0)*0.4-0.5+InX[i];//*0.4+0.45;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    
    OuY[0][i]=(float)Math.pow(OuY[0][i]>0?OuY[0][i]:-OuY[0][i],0.2)*(OuY[0][i]>0?1:-1);
    OuY[1][i]=sin(InX[0][i]*InX[0][i]*20/(XRange*XRange)+scrollingCount/1200.0)>0?1:0;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    //OuY[1][i]=(float)Math.pow(OuY[1][i],11)*0.8;
  }
  
  
  float err=nn.TestTrain(InX,OuY,55);
  stroke(0,255,0);
  ErrHist.Draw(err*5000,0,300,width,500);
  TrainCount+=55;
  

  float preVar_hidden[]=new float[nn.hidden[0].length];
  
  float preVar_hidden2[]=new float[nn.hidden[1].length];
  float preVar=0;
  float preVar2=0;
  
  float NeuOutOffet=600;
  for (int i = 0; i < width; i += 5) {
    for(int j=0;j<InX.length;j++)
    {
      nn.input[j].latestVar=XRange*i/width;
    }
    nn.calc();
    
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
  for (int i = 1; i < InX[0].length; i ++) {
    //line(InX[i-1]*width/10,-OuY[i-1]*100+hH,InX[i]*width/10,-OuY[i]*100+hH);
    //ellipse(OuY[0][i]*200+hW,OuY[1][i]*200+hH, 5, 5);
    for (int j = 0; j < OuY.length; j ++) {
      stroke(128, (j+1) *255/ OuY.length,150,100);
      ellipse(InX[0][i]*width/XRange+5,-OuY[j][i]*100+NeuOutOffet, 5, 5);
    }
    /*line(
    OuY[0][i]*200+hW,OuY[1][i]*200+hH,
    OuY[0][i-1]*200+hW,OuY[1][i-1]*200+hH);  */
  }
  
  drawNN.drawNN(nn,10,10,550,350);
  //System.out.printf("ERR:%1.5f C:%05d\n",err,TrainCount);
  //if(err>-0.005)noLoop();
  //noLoop();
}

}