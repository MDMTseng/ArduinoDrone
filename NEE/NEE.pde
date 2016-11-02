
class s_neuron{
  public float latestVar;
  
  
  public int post_neuron_L;
  public s_neuron post_neuron_list[];
  public float W[];
  
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
  }
  
  void aggregateValue()
  {
    if(pre_neuron_L == 0)return;
    latestVar = 0;
    for(int i=0;i<pre_neuron_L;i++)
    {
      latestVar+=pre_neuron_list[i].latestVar*W[i];
    }
    latestVar=(float)exciteF(latestVar);
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
    return (1/( 1 + Math.pow(Math.E,(-1*x))));
  }
  
  public double d_exciteF(double sigmoid_var) {
    
    sigmoid_var=(sigmoid_var);
    double slop=sigmoid_var*(1-(sigmoid_var));
    return slop;
  }
}

class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron ones[]=new s_neuron[4];
  s_neuron input[] =new s_neuron[1];
  s_neuron hidden[] =new s_neuron[5];
  public s_neuron hidden2[] =new s_neuron[20];
  public s_neuron hidden3[] =new s_neuron[21];
  public s_neuron output[] =new s_neuron[1];
  
  float XRand(float x1,float x2)
  {
    float rand=random(0.8,1);
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
    
    
    
    /*prelayer=hidden2;
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
    ns.add(currentlayer);*/
    
    
    
    prelayer=hidden2;
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
  
  float [] Train_1(s_neuron layer[],float Error[])
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
    if(Error.length!=layer.length)return null;
    
    float PErr[] = new float[layer[0].pre_neuron_L-1];
    
    for(int i=0;i<PErr.length;i++)PErr[i]=0;
    
    float lRate;
    float limit =0.4;
    for (int i=0;i<Error.length;i++) {
      float dPdZ = Error[i];
      
      lRate = dPdZ*limit;
      if(lRate<0)lRate=-lRate;
      float dropO=1;//random(0, 1)>0.005? 1:0.4;
      
      lRate=limit;//*(random(0.5, 1.1));//(float)Math.log(limit*dropO+1);
      
      
      float dZdY = (float)layer[i].d_exciteF(layer[i].latestVar);
      for (int j=0;j<layer[i].pre_neuron_L;j++)
      {
        float dYdW = layer[i].pre_neuron_list[j].latestVar;
        
        if(j!=layer[i].pre_neuron_L-1)
        {
          PErr[j]+=dPdZ*dZdY*(layer[i].W[j])/Error.length;
        }
        layer[i].W[j]+=dPdZ*dZdY*dYdW*lRate;
        
      }
    }
    return PErr;
  }
  
  void Train_S(float expected_output[])
  {
    if(output.length!=expected_output.length)return;
    float Error[] = new float[expected_output.length];
    for (int i=0;i<Error.length;i++)
    {
      Error[i] = expected_output[i] - output[i].latestVar;
    }
    
    
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      Error = Train_1(this.ns.get(i),Error);
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
  
  float TestTrain(float InX[],float OuY[],int iter)
  {
    float maxErr=0;
    float expectedOut[]=new float[output.length];
    for(int i=0;i<iter;i++)
    {
      maxErr=0;
      int maxErrIdx=InX.length/2;
      for(int j=0;j<InX.length;j++)
      {
        int idx=j;//(int)Math.floor(random(0,InX.length-0.0001));
        input[0].latestVar=InX[idx];
        expectedOut[0]=OuY[idx];
        
        this.calc();
        
        float ErrorPow=-calcError(expectedOut);
        if(ErrorPow>maxErr){
          maxErr=ErrorPow;
          maxErrIdx = idx;
        }
        //System.out.printf("------Error:%f\n",ErrorPow);*/
        Train_S(expectedOut);
      }
     
      for(int j=0;j<1;j++)
      {
        
        input[0].latestVar=InX[maxErrIdx];
        expectedOut[0]=OuY[maxErrIdx];
        this.calc();
        Train_S(expectedOut);
      }
    }
    
    return -maxErr;
    
   /* for(int j=0;j<InX.length;j++)
    {
      input[0].latestVar=InX[j];
      expectedOut[0]=OuY[j];
      
      this.calc();
      
      float ErrorPow=calcError(expectedOut);
      System.out.printf("------Error:%f\n",ErrorPow);
      this.printStruct();
      System.out.printf("------OuY[j]:%f\n",OuY[j]);
    
      System.out.printf("=========================\n\n");
    }*/
   
    
    
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
        if(layerNodes[j].W[k]>0)
          stroke(0,255,0,(int)(Math.log(layerNodes[j].W[k]+1)*100));
        else
          stroke(255,0,0,(int)(-Math.log(layerNodes[j].W[k]+1)*100));
        
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

float InX[]=new float[80];
float OuY[]=new float[InX.length];

void setup() {
  size(640, 860);
  background(255);
  //noLoop();
  
  for(int i=0;i<InX.length;i++)
  {
    InX[i]=10.0*i/InX.length;
    OuY[i]=(i>(InX.length/6)&&i<(InX.length*5/6))?(sin(InX[i]*InX[i]/5-TrainCount/2000.0))>0?1:0: 0;//(i>(InX.length/5)&&i<(InX.length*4/5))?(InX[i]-0.2)*4: 0;
  }
  
  
}

int TrainCount=0;
void draw() {
  strokeWeight(3);
  background(0);
  int hH=height/2;
  
  
  
  
  float err=nn.TestTrain(InX,OuY,250);
  TrainCount+=250;
  
  float preVar_hidden[]=new float[nn.hidden.length];
  
  float preVar_hidden2[]=new float[nn.hidden2.length];
  float preVar=0;
  for (int i = 0; i < width; i += 5) {
    nn.SetCalcNeuronInputData(10.0*i/width);
    
    float tmp;
    for(int n=0;n<preVar_hidden.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(255,0,0,50);
      tmp=nn.hidden[n].latestVar*100;
      line(i,preVar_hidden[n]+hH,i+5,-tmp+hH);
      preVar_hidden[n]=-tmp;
    }
    
    for(int n=0;n<preVar_hidden2.length;n++)
    {
      //stroke((n+5)*255/(preVar_hidden.length+5),0,0);
      stroke(0,255,255,50);
      tmp=nn.hidden2[n].latestVar*100;
      line(i,preVar_hidden2[n]+hH,i+5,-tmp+hH);
      preVar_hidden2[n]=-tmp;
    }
    
    stroke(250);
    tmp=nn.output[0].latestVar*100;
    line(i,preVar+hH,i+5,-tmp+hH);
    preVar=-tmp;
  }
  
  
  stroke(100);
  for (int i = 1; i < InX.length; i ++) {
    line(InX[i-1]*width/10,-OuY[i-1]*100+hH,InX[i]*width/10,-OuY[i]*100+hH);
  }
  
  drawNN(nn,10,10,550,350);
  System.out.printf("ERR:%1.5f C:%05d\n",err,TrainCount);
  //if(err>-0.005)noLoop();
  //noLoop();
}