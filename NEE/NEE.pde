
class s_neuron{
  public float SumVar;
  public float latestVar;
  
  
  public int post_neuron_L;
  public s_neuron post_neuron_list[];
  public float W[];
  
  public int pre_neuron_L_BK;
  public int pre_neuron_L;
  public s_neuron pre_neuron_list[];
    
    
  s_neuron()
  {
    this(0);
  }
  s_neuron(int defaultNum)
  {
    pre_neuron_L = 0;
    post_neuron_L = 0;
    pre_neuron_list = new s_neuron[defaultNum];
    post_neuron_list = new s_neuron[defaultNum];
    W = new float[post_neuron_list.length];
  }
  
  void SetDisable(boolean disable)
  {
    if(disable)
    {
      latestVar = 0;
      pre_neuron_L=0;
    }
    else
    {
      pre_neuron_L=pre_neuron_L_BK;
    }
  }
  int GetActual_pre_neuron_L()
  {
    return pre_neuron_L_BK;
  }
  void add_pre_neuron(s_neuron pre_neuron,float weight)
  {
    if(pre_neuron_list.length<(pre_neuron_L+1))
    {
      float oldW[] = W;
      s_neuron oldList[] = pre_neuron_list;
      pre_neuron_list = new s_neuron[oldList.length*2];//extend L
      W = new float[pre_neuron_list.length];//extend L
      
      for(int i=0;i<pre_neuron_L;i++)
      {
        pre_neuron_list[i]=oldList[i];
        W[i]=oldW[i];
      }
      oldList = null;//clean
      oldW = null;
    }
    pre_neuron_list[pre_neuron_L]=pre_neuron;//append
    pre_neuron.add_post_neuron(this);
    W[pre_neuron_L]=weight;
    pre_neuron_L++;
    pre_neuron_L_BK=pre_neuron_L;
  }
  
  void aggregateValue()
  {
    if(pre_neuron_L == 0)return;
    latestVar = 0;
    SumVar = 0;
    for(int i=0;i<pre_neuron_L;i++)
    {
      SumVar+=pre_neuron_list[i].latestVar*W[i];
    }
    latestVar=(float)exciteF(SumVar);
  }
  
  
  float CosSimilarW(s_neuron node)
  {
    if(pre_neuron_L!=node.pre_neuron_L)
      return 0;
    float absW=0,absW2=0,XX=0;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L;i++)
    {
      absW+=W[i]*W[i];
      absW2+=node.W[i]*node.W[i];
      XX+=node.W[i]*W[i];
    }
    absW=(float)Math.sqrt(absW);
    absW2=(float)Math.sqrt(absW2);
    
    XX = XX/(absW*absW2);
    absW=(absW>absW2)?absW/absW2:absW2/absW;
    return XX/absW;
  }
  
  float XSimilarW(s_neuron node)
  {
    if(pre_neuron_L!=node.pre_neuron_L)
      return 0;
    float absW=0,absW2=0,XX=1;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L;i++)
    {
      absW=W[i]*W[i];
      absW2=node.W[i]*node.W[i];
      if(W[i]*node.W[i]<0)return 1000;
      XX*=(absW>absW2)?absW/absW2:absW2/absW;
    }
    
    return XX;
  }
  float rmsW()
  {
    float sumW=0;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L;i++)
    {
      sumW+=W[i]*W[i];
    }
    return (float)Math.sqrt(sumW/pre_neuron_L);
  }
  protected void add_post_neuron(s_neuron post_neuron)
  {
    if(post_neuron_list.length<(post_neuron_L+1))
    {
      s_neuron oldList[] = post_neuron_list;
      post_neuron_list = new s_neuron[oldList.length*2];//extend L
      
      for(int i=0;i<post_neuron_L;i++)
      {
        post_neuron_list[i]=oldList[i];
      }
      oldList = null;//clean
    }
    post_neuron_list[post_neuron_L]=post_neuron;//append
    post_neuron_L++;
  }
  public double exciteF(double x) {
    return (1/( 1 + Math.pow(Math.E,(-1*x))))*2-1;
  }
  
  public double d_exciteF(double sigmoid_var) {
    sigmoid_var=(sigmoid_var+1)/2;
    double slop=2*sigmoid_var*(1-(sigmoid_var));
    return slop+0.01;
  }
}

class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron ones[]=new s_neuron[4];
  s_neuron input[] =new s_neuron[1];
  s_neuron hidden[] =new s_neuron[3];
  public s_neuron hidden2[] =new s_neuron[15];
  public s_neuron hidden3[] =new s_neuron[6];
  public s_neuron output[] =new s_neuron[2];
  
  float XRand(float x1,float x2)
  {
    float rand=random(x1,1);
    return random(0,1)>x2?rand:-rand;
  }
  s_neuron_net()
  {
    
    for(int i=0;i<ones.length;i++)
    {
      ones[i] = new s_neuron(1);
      ones[i].latestVar = 1;
    }
    
    
    
    ns = new ArrayList <s_neuron[]>();
    
    for(int i=0;i<input.length;i++)
    {
      input[i] = new s_neuron(1);
      input[i].latestVar = 1;
    }
    ns.add(input);
    
    s_neuron prelayer[]=input;
    s_neuron currentlayer[]=hidden;
    
    
    for(int i=0;i<currentlayer.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5));
      }
      currentlayer[i].add_pre_neuron(ones[0],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
    
    prelayer=hidden;
    currentlayer=hidden2;
    for(int i=0;i<currentlayer.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5));
      }
      currentlayer[i].add_pre_neuron(ones[1],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
    
    
    prelayer=hidden2;
    currentlayer=hidden3;
    for(int i=0;i<hidden3.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5));
      }
      currentlayer[i].add_pre_neuron(ones[2],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
    
    
    prelayer=hidden3;
    currentlayer=output;
    for(int i=0;i<output.length;i++)
    {
      currentlayer[i] = new s_neuron(1);
      for(int j=0;j<prelayer.length;j++)
      {
        currentlayer[i].add_pre_neuron(prelayer[j],XRand(0,0.5));
      }
      currentlayer[i].add_pre_neuron(ones[3],XRand(0,0.5));
    }
    ns.add(currentlayer);
    
  }
  void TrimSimNode(s_neuron layer[])
  {
    
    if(layer[0].pre_neuron_L>1)
    for (int i=0;i<layer.length;i++)
    {
      //if(layer[i].rmsW()<1)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        //if(layer[j].rmsW()<1)continue;
        float CosSim=layer[i].CosSimilarW(layer[j]);
        float xSim=CosSim;
        xSim=(xSim-0.8)/(1-0.8);
        xSim=(xSim>0)?xSim:0;
        //float absCos = cosSim>0?cosSim:-cosSim;
        xSim=(float)Math.pow(xSim,1);
        float rand=random(0,1);
        if(xSim>rand)
        {
          System.out.printf("Die::Reborn...cs:%f..%f..\n ",CosSim,xSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            System.out.printf("%f,%f  ",layer[j].W[k],layer[i].W[k]);
            layer[j].W[k]=(layer[i].W[k]+layer[j].W[k])/2;
            layer[i].W[k]= XRand(0,0.5);
          }
          System.out.printf("\n ");
          
          for (int k=0;k<layer[j].post_neuron_L;k++)
          {
            s_neuron pnode=layer[j].post_neuron_list[k];
            int n1_idx=-1,n2_idx=-1;
            for(int m=0;m<pnode.GetActual_pre_neuron_L()-1&&(n1_idx==-1||n2_idx==-1);m++)
            {
              if(layer[j]==pnode.pre_neuron_list[m])
                n1_idx = m;
              else if(layer[i]==pnode.pre_neuron_list[m])
                n2_idx = m;
            }
            pnode.W[n1_idx]+=pnode.W[n2_idx];
            pnode.W[n2_idx]=XRand(0,0.5);
          }
        }
      }
        
    }
    
  }
  
  //BufferL = Train_1(this.ns.get(i),Error,ErrorL,Buffer);
  int Train_1(s_neuron layer[],float Error[],int ErrorL,float Buffer[])
  {
    //     Y=XW 
    // X -W--> |Sig| ->Z
    //                 expect output d  
    //                 P=-0.5*(d-Z)^2
    //
    //dP/dW = dP/dZ* dZ/dY*dY/dW
    //
    //dP/dZ = d-Z
    //dZ/dY = Sigmoid(Y)'
    //dY/dW = X
    
    //System.out.printf("Error.length %d  layer.length %d",Error.length,layer.length);
    if(ErrorL!=layer.length)return -1;
    
    //float PErr[] = new float[layer[0].pre_neuron_L-1];
    
    int BufferL=layer[0].pre_neuron_L-1;
    for(int i=0;i<BufferL;i++)Buffer[i]=0;
    
    float limit =0.03;
    float lRate=limit;
    
    
    
    float WAve =0;
    
    for (int i=0;i<ErrorL;i++) {
      float dPdZ = Error[i];
      
     /* lRate = dPdZ*limit;
      if(lRate<0)lRate=-lRate;
      float dropO=1;//random(0, 1)>0.005? 1:0.4;*/
      
     // lRate=limit;//*(random(0.5, 1.1));//(float)Math.log(limit*dropO+1);
      
      
      float dZdY = (float)layer[i].d_exciteF(layer[i].latestVar);
      float dPdY = dPdZ*dZdY;
      for (int j=0;j<layer[i].pre_neuron_L;j++)
      {
        float dYdW = layer[i].pre_neuron_list[j].latestVar;
        
        if(j!=layer[i].pre_neuron_L-1)
        {
          Buffer[j]+=dPdY*(layer[i].W[j]);
          WAve+=layer[i].W[j];
        }
        layer[i].W[j]+=dPdY*dYdW*lRate;
      }
    }
    WAve/=ErrorL*(layer[0].pre_neuron_L-1);
    
    for (int i=0;i<ErrorL;i++) 
    {
     for (int j=0;j<layer[i].GetActual_pre_neuron_L()-1;j++)
      {
          float alphaX=0.999999;
          layer[i].W[j]=(layer[i].W[j]*alphaX-WAve*(1-alphaX));//+random(-0.001,0.001);
          //layer[i].W[j]*=alphaX;
          
      }
    }
    
    
    return BufferL;
  }
  
  void Train_S(float expected_output[])
  {
    if(output.length!=expected_output.length)return;
    float Error[] = new float[50];
    int ErrorL=0;
    float Buffer[] = new float[50];
    int BufferL=0;
    
    ErrorL = output.length;
    for (int i=0;i<output.length;i++)
    {
      Error[i] = expected_output[i] - output[i].latestVar;
      //float absErr=Error[i]>0?Error[i]:-Error[i];
      //Error[i]=(float)Math.exp(absErr*absErr*absErr)/5*(Error[i]>0?1:-1);
    }
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      BufferL = Train_1(this.ns.get(i),Error,ErrorL,Buffer);
      if(BufferL<=0)break;
      float TmpBuf[];
      TmpBuf=Buffer;
      Buffer=Error;
      Error=TmpBuf;
      
      int TmpBufL;
      TmpBufL=BufferL;
      BufferL=ErrorL;
      ErrorL=TmpBufL;
      
    }
    for (int i=this.ns.size()-2;i!=0;i--)
    {
      TrimSimNode(this.ns.get(i));
    }
    
  }
  
  
  void calc()
  {
    //System.out.printf(">>W>> ");
    int x=0;
    for (s_neuron[] layer : this.ns) {
      for (int i=0;i<layer.length;i++)
      {
        /*for (int j=0;j<layer[i].pre_neuron_L;j++)
        {
          System.out.printf("%f ",layer[i].W[j]);
          
        }*/
        layer[i].aggregateValue();
      }
      x++;
    }
    //System.out.printf("\n");
  }
  
  float calcError(float expected_output[])
  {
    float out=0;
    for (int i=0;i<expected_output.length;i++)
    {
      float tmp = expected_output[i] - output[i].latestVar;
      
      out += tmp*tmp;
    }
    return -out/2;
    
  }
  
  void RandomDropOut(float dropoutChance)
  {
    for (int i=1;i<this.ns.size()-1;i++)//Only dropout hidden layer
    {
      s_neuron[] layer = this.ns.get(i);
      for(int j=0;j<layer.length;j++)
      {
        if(random(0,1)<dropoutChance)
        {
          layer[j].SetDisable(true);
        }
        else
        {
          layer[j].SetDisable(false);
        }
      }
    }
  }
  
  float TestTrain(float InX[],float OuY[][],int iter)
  {
     // RandomDropOut(0.003);
    float maxErr=0;
    float expectedOut[]=new float[output.length];
    for(int i=0;i<iter;i++)
    {
      maxErr=0;
      int maxErrIdx=InX.length/2;
      for(int j=InX.length-1;j!=0;j--)
      {
        int idx=j;//(int)Math.floor(random(0,InX.length-0.0001));
        if(InX[idx]==Float.NEGATIVE_INFINITY)continue;
        input[0].latestVar=InX[idx];
        for(int k=0;k<OuY.length;k++)
          expectedOut[k]=OuY[k][idx];
        
        this.calc();
        
        float ErrorPow=-calcError(expectedOut);
        if(ErrorPow>maxErr){
          maxErr=ErrorPow;
          maxErrIdx = idx;
        }
        //System.out.printf("------Error:%f\n",ErrorPow);*/
        Train_S(expectedOut);
      }
     
    }
    
    return -maxErr;
  }
  void SetCalcNeuronInputData(float x)
  {
    
    input[0].latestVar=x;
    
    this.calc();
  }
  
  void printOut()
  {
    for(int i=0;i<output.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,output[i].latestVar);
    }
    System.out.printf("\n");
  }
  
  
  void printStruct()
  {
    System.out.printf("\ninput::\n");
    for(int i=0;i<input.length;i++)
    {
      System.out.printf("[%2d]:%f  ",i,input[i].latestVar);
    }
    System.out.printf("\nhidden::\n");
    for(int i=0;i<hidden.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,hidden[i].latestVar);
    }
    System.out.printf("\nhidden2::\n");
    for(int i=0;i<hidden2.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,hidden2[i].latestVar);
    }
    System.out.printf("\noutput::\n");
    for(int i=0;i<output.length;i++)
    {
      System.out.printf("[%2d]:%f ",i,output[i].latestVar);
    }
    System.out.printf("\n");
  }
  
}


s_neuron_net nn = new s_neuron_net();

  
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

float InX[]=new float[70];
float OuY[][]=new float[2][InX.length];

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
void draw() {
  strokeWeight(3);
  background(0);
  int hH=height/2;
  int hW=width/2;
  scrollingCount+=scrollingSpeed;
  
  
  for(int i=0;i<InX.length;i++)
  {
    InX[i]=XRange*i/InX.length;//random(0,10);

    OuY[0][i]=InX[i]*2-1;//sin(InX[i]*InX[i]*30/(XRange*XRange)+scrollingCount/2200.0)*0.4-0.5+InX[i];//*0.4+0.45;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    OuY[1][i]=sin(InX[i]*InX[i]*20/(XRange*XRange)+scrollingCount/1200.0)>0?0.8:-0.8;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
    //OuY[1][i]=(float)Math.pow(OuY[1][i],11)*0.8;
  }
  
  
  float err=nn.TestTrain(InX,OuY,25);
  TrainCount+=25;
  
  float preVar_hidden[]=new float[nn.hidden2.length];
  
  float preVar_hidden2[]=new float[nn.hidden3.length];
  float preVar=0;
  float preVar2=0;
  for (int i = 0; i < width; i += 5) {
    nn.SetCalcNeuronInputData(XRange*i/width);
    
    float tmp,tmp2;
    for(int n=0;n<preVar_hidden.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(255,0,0,50);
      tmp=nn.hidden2[n].latestVar*100;
      line(i,preVar_hidden[n]+hH,i+5,-tmp+hH);
      preVar_hidden[n]=-tmp;
    }
    
    for(int n=0;n<preVar_hidden2.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(0,255,255,50);
      tmp=nn.hidden3[n].latestVar*100;
      line(i,preVar_hidden2[n]+hH,i+5,-tmp+hH);
      preVar_hidden2[n]=-tmp;
    }
    
    stroke(250);
    tmp=nn.output[0].latestVar*200;
    tmp2=nn.output[1].latestVar*200;
    line(preVar+hW,preVar2+hH,tmp+hW,tmp2+hH);
    preVar=tmp;
    preVar2=tmp2;
  }
  
  
  stroke(100);
  stroke(128,128,150,100);
  for (int i = 1; i < InX.length; i ++) {
    //line(InX[i-1]*width/10,-OuY[i-1]*100+hH,InX[i]*width/10,-OuY[i]*100+hH);
    ellipse(OuY[0][i]*200+hW,OuY[1][i]*200+hH, 5, 5);
    /*for (int j = 0; j < OuY.length; j ++) 
      ellipse(InX[i]*width/XRange+5,-OuY[j][i]*100+hH, 5, 5);*/
    /*line(
    OuY[0][i]*200+hW,OuY[1][i]*200+hH,
    OuY[0][i-1]*200+hW,OuY[1][i-1]*200+hH);  */
  }
  
  drawNN(nn,10,10,550,350);
  //System.out.printf("ERR:%1.5f C:%05d\n",err,TrainCount);
  //if(err>-0.005)noLoop();
  //noLoop();
}