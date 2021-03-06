
interface s_neuron_actFunc{
  public double value(s_neuron node,double x) ;
  
  public double derivativeOnOutput(s_neuron node,double func_var);
}

class s_neuron_actFunc_tanh implements s_neuron_actFunc{
  public double value(s_neuron node,double x) {
    return (1/( 1 + Math.pow(Math.E,(-1*x))))*2-1;
  }
  
  public double derivativeOnOutput(s_neuron node,double func_var) {
    func_var=(func_var+1)/2;
    double slop=2*func_var*(1-(func_var));
    return (slop+0.0002)/1.0001;
  }
}
class s_neuron_actFunc_sigmoid implements s_neuron_actFunc{
  public double value(s_neuron node,double x) {
    return (1/( 1 + Math.pow(Math.E,(-1*x))));
  }
  
  public double derivativeOnOutput(s_neuron node,double func_var) {
    double slop=func_var*(1-(func_var));
    return slop;
  }
}
class s_neuron_actFunc_ReLU implements s_neuron_actFunc{
  public double value(s_neuron node,double x) {
    return (x>0)?x:0.01*x;
  }
  
  public double derivativeOnOutput(s_neuron node,double func_var) {
    return func_var>0? 1:0.01;
  }
}

class s_neuron_actFunc_LeakyReLU implements s_neuron_actFunc{
  public double value(s_neuron node,double x) {
    return (x>0)?x:0.1*x;
  }
  
  public double derivativeOnOutput(s_neuron node,double func_var) {
    return func_var>0? 1:0.1;
  }
}

class s_neuron_actFunc_Softmax implements s_neuron_actFunc{
  public double value(s_neuron node,double x) {
    return (x>0)?x:0.01*x;
  }
  
  public double derivativeOnOutput(s_neuron node,double func_var) {
    return func_var>0? 1:0.001;
  }
}


class s_neuron{
  public float SumVar;
  public float latestVar;
  public float trainError;
  
  s_neuron_actFunc actFun=null;
  public int post_neuron_L;
  public s_neuron post_neuron_list[];
  public float W[];
  public float dW[];
  public float ADss[];
  public float LPW[];
  
  public int pre_neuron_L_BK;
  public int pre_neuron_L;
  public s_neuron pre_neuron_list[];
    
    
  s_neuron(s_neuron_actFunc actFun)
  {
    this(0,actFun);
  }
  s_neuron(int defaultNum,s_neuron_actFunc actFun)
  {
    Set_actFun(actFun);
    pre_neuron_L = 0;
    post_neuron_L = 0;
    pre_neuron_list = new s_neuron[defaultNum];
    post_neuron_list = new s_neuron[defaultNum];
    W = new float[post_neuron_list.length];
    dW = new float[W.length];
    ADss = new float[W.length];
    LPW = new float[W.length];
  }
  

  void Set_actFun(s_neuron_actFunc actFun)
  {
    this.actFun=actFun;
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
  float t=1;
 /* void Update_dW(float learningRate)//ADAM
  {
    float beta1=0.8;
    float beta2=0.8;
    
    t+=0.01;
    
    float emph=0.01;
    for(int i=0;i<GetActual_pre_neuron_L();i++)
    {
      LPW[i]=LPW[i]*beta1+dW[i]*(1-beta1);
      ADss[i]=ADss[i]*beta2+dW[i]*dW[i]*(1-beta2);
      
      W[i]+=LPW[i]*learningRate/(sqrt(ADss[i])+emph);
      
      dW[i]=0;
    }
  }*/
  void Update_dW(float learningRate)//ADAGRAD
  {
    for(int i=0;i<GetActual_pre_neuron_L();i++)
    {
      LPW[i]=LPW[i]*0.9+dW[i]*0.1;
      ADss[i]+=dW[i]*dW[i];
      float sqrtAdss=sqrt(ADss[i]);
      W[i]+=LPW[i]*learningRate/(sqrtAdss+0.00001);
      //print(W[i]+">>>>");
      float dW2=dW[i]*dW[i];
      if(dW2>1)dW2=1;
      dW2=(dW2+0.001)*0.001;
      ADss[i]*=1-dW2;
      dW[i]=0;
    }
  }
  
  void add_pre_neuron(s_neuron pre_neuron,float weight)
  {
    if(pre_neuron_list.length<(pre_neuron_L+1))
    {
      float oldW[] = W;
      s_neuron oldList[] = pre_neuron_list;
      pre_neuron_list = new s_neuron[oldList.length*2+1];//extend L
      W = new float[pre_neuron_list.length];//extend L
      dW = new float[W.length];
      ADss = new float[W.length];
      LPW = new float[W.length];
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
  
  float rmsW_noDC()
  {
    float sumW=0;
    //CosSim = v1.*v2./(|v1||v2|)
    for(int i=0;i<pre_neuron_L-1;i++)
    {
      sumW+=W[i]*W[i];
    }
    return (float)Math.sqrt(sumW/(pre_neuron_L-1));
  }
  
  protected void add_post_neuron(s_neuron post_neuron)
  {
    if(post_neuron_list.length<(post_neuron_L+1))
    {
      s_neuron oldList[] = post_neuron_list;
      post_neuron_list = new s_neuron[oldList.length*2+1];//extend L
      
      for(int i=0;i<post_neuron_L;i++)
      {
        post_neuron_list[i]=oldList[i];
      }
      oldList = null;//clean
    }
    post_neuron_list[post_neuron_L]=post_neuron;//append
    post_neuron_L++;
  }
  void train(boolean crossEn)
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
    
    float dPdZ = trainError;
    trainError=0;
    float dZdY = crossEn?1:(float)actFun.derivativeOnOutput(this,latestVar);
    float dPdY = dPdZ*dZdY;
    for (int j=0;j<pre_neuron_L;j++)
    {
      float dYdW = pre_neuron_list[j].latestVar;
      float dX=dPdY*dYdW;
      pre_neuron_list[j].trainError+=dPdY*(W[j]);
      dW[j]+=dX;
    }
  }
  
  
  void reset_state()
  {
    
  }
  void aggregateValue()
  {
    if(pre_neuron_L == 0)return;
    SumVar = 0;
    for(int i=0;i<pre_neuron_L;i++)
    {
      SumVar+=pre_neuron_list[i].latestVar*W[i];
    }
    latestVar=(float)actFun.value(this,SumVar);
  }
  
}


class s_neuron_rec extends s_neuron{
  float res_hist[]=new float[100];
  int res_hist_idx=0;
  
  s_neuron_rec(int defaultNum,s_neuron_actFunc actFun)
  {
    super(defaultNum,actFun);
    add_pre_neuron(this,0.7);
    reset_state();
  }
  s_neuron_rec(s_neuron_actFunc actFun)
  {
    this(0,actFun);
  }
   
  void train(boolean crossEn)
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
    
    float dPdZ = trainError;
    trainError=0;
    float dZdY = crossEn?1:(float)actFun.derivativeOnOutput(this,latestVar);
    float dPdY = dPdZ*dZdY;
    if(res_hist_idx>0)
    {
      res_hist_idx--;
      latestVar=res_hist[res_hist_idx];
    }
    else
    {
      latestVar=0;
    }
    //print(">>"+latestVar);
    for (int j=0;j<pre_neuron_L;j++)
    {
      float dYdW = pre_neuron_list[j].latestVar;
    //print(","+dYdW);
      float dX=dPdY*dYdW;
      pre_neuron_list[j].trainError+=dPdY*(W[j]);
      dW[j]+=dX;
    }
    //println();
  }
  
  void aggregateValue()
  {
    if(pre_neuron_L == 0)return;
    if(res_hist_idx<res_hist.length)
      res_hist[res_hist_idx++]=latestVar;
    SumVar = 0;
    for(int i=0;i<pre_neuron_L;i++)
    {
      SumVar+=pre_neuron_list[i].latestVar*W[i];
    }
    latestVar=(float)actFun.value(this,SumVar);
  }
  
  void reset_state()
  {
    res_hist_idx=0;
  }
}



class s_neuron_net{
  ArrayList <s_neuron[]> ns;
  s_neuron one_offset;
  s_neuron input[];
  s_neuron hidden[][];
  s_neuron output[];
  s_neuron_actFunc actFun_tanh=new s_neuron_actFunc_tanh();
  s_neuron_actFunc actFun_ReLU=new s_neuron_actFunc_ReLU();
  s_neuron_actFunc actFun_LeakyReLU=new s_neuron_actFunc_LeakyReLU();
  s_neuron_actFunc actFun_sigmoid=new s_neuron_actFunc_sigmoid();
  
  float XRand(float x1,float x2)
  {
    float rand=random(x1,1);
    return random(0,1)>x2?rand:-rand;
  }
  
  s_neuron_net(int netDim[])
  {
    s_neuron netX[][]=new s_neuron[netDim.length][];
    
    for(int i=0;i<netDim.length;i++)
    {
      netX[i]=new s_neuron[netDim[i]];
      s_neuron_actFunc actFun=(i==netDim.length-1)?actFun_tanh:actFun_LeakyReLU;
      for(int j=0;j<netX[i].length;j++)
      {
        netX[i][j] = new s_neuron(1,actFun);
      }
    }
    Init(netX);
    
  }
  s_neuron_net(s_neuron netX[][])
  {
    
    Init(netX);
  }
  void Init(s_neuron netX[][])
  {
    if(netX.length<2)
      return;
    one_offset =  new s_neuron(1,actFun_tanh); 
    one_offset.latestVar=1;
    
    ns = new ArrayList <s_neuron[]>();
    
    for(int i=0;i<netX.length;i++)
    {
      ns.add(netX[i]);
    }
    
    input=netX[0];
    
    hidden=new s_neuron[netX.length-2][];
    for(int i=0;i<hidden.length;i++)
    {
      hidden[i]=netX[i+1];
    }
    
    output=netX[netX.length-1];
    
    s_neuron prelayer[]=null;
    s_neuron currentlayer[]=ns.get(0);
    
    
    for(int i=1;i<ns.size();i++)
    {
      prelayer=currentlayer;
      currentlayer=ns.get(i);
      
      for(int j=0;j<currentlayer.length;j++)
      {
        for(int k=0;k<prelayer.length;k++)
        {
          currentlayer[j].add_pre_neuron(prelayer[k],XRand(0,0.5));
        }
        currentlayer[j].add_pre_neuron(one_offset ,XRand(0,0.5));
      }
    }
  }
  
    
  void NeuronNodeRevive(s_neuron layer[],float maxW_threshold,float growthSpeed)
  {
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW_noDC()>maxW_threshold)continue;
      
      float maxW=0;
      int maxWIdx=0;
      for (int j=0;j<layer[i].GetActual_pre_neuron_L()-1;j++) 
      {
        float d=layer[i].W[j];
        
        layer[i].W[j]+=random(-1,1)*0.00001;
        layer[i].W[j]*=random(1,growthSpeed);
        d=d*d;
        if(maxWIdx<d)
        {
          maxW=d;
          maxWIdx=j;
        }
      }
    }
    
  }
  
  
  void NeuronNodePolarizing(s_neuron layer[],float maxW_threshold)
  {
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW_noDC()>maxW_threshold)continue;
      
      for (int j=0;j<layer[i].GetActual_pre_neuron_L()-1;j++) 
      {
        float tmpX=layer[i].W[j];
        if(tmpX<0)tmpX=-tmpX;
        if(tmpX>maxW_threshold)
          layer[i].W[j]*=random(1.0,1.1);
        else
          layer[i].W[j]/=random(1.0,1.1);
      }
    }
    
  }
  
  void AttractSimNode(s_neuron layer[],float CosSimValve,float alpha)
  {
    
    if(layer[0].pre_neuron_L>2)
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW()<0.7)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        float CosSim=layer[i].CosSimilarW(layer[j]);
        int sign=(CosSim>0)?1:-1;
        if(CosSim<0)CosSim=-CosSim;
        if(CosSim>CosSimValve)
        {
          float tmp=(CosSim-CosSimValve)*(1-CosSimValve);
          float attractAlpha=1-(1-alpha)*tmp*tmp;
          
          System.out.printf("C%02d:%f...\n ",layer[j].GetActual_pre_neuron_L(),CosSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            tmp = layer[j].W[k];
            layer[j].W[k]=tmp*attractAlpha+layer[i].W[k]*(1-attractAlpha)*sign;
            layer[i].W[k]=layer[i].W[k]*attractAlpha+tmp*(1-attractAlpha)*sign;
          }
        }
      }
        
    }
    
  }
   
  void AttractSimNode2(s_neuron layer[],float CosSimValve,float c)
  {
    
    if(layer[0].pre_neuron_L>2)
    for (int i=0;i<layer.length;i++)
    {
      if(layer[i].rmsW()<0.7)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        float CosSim=layer[i].CosSimilarW(layer[j]);
        float sign=CosSim>0?1:-1;
        float oriCosSim=CosSim;
        if(CosSim<0)CosSim=-CosSim;
        if(CosSim>CosSimValve)
        {
          //System.out.printf("C%02d:%f...\n ",layer[j].GetActual_pre_neuron_L(),oriCosSim);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            layer[i].W[k]*=sign;
            
            float tmpj = layer[j].W[k];
            float tmpi = layer[i].W[k];
            float tdiff=tmpj-tmpi;
            
            if(tdiff>0)
            {
              tmpi=(tdiff<c)? tdiff:c;
              tmpj=-tmpi;
            }
            else
            {
              tmpj=(-tdiff<c)? tdiff:c;
              
              tmpi=-tmpj;
            }
            
            layer[j].W[k]+=tmpj;
            layer[i].W[k]+=tmpi;
            
            layer[i].W[k]*=sign;
          }
        }
      }
        
    }
    
  }
  void TrimSimNode(s_neuron layer[],float CosSimValve)
  {
    
    if(layer[0].pre_neuron_L>2)
    for (int i=0;i<layer.length;i++)
    {
      //if(layer[i].rmsW()<1)continue;
      for (int j=i+1;j<layer.length;j++) 
      {
        //if(layer[j].rmsW()<1)continue;
        float CosSim=layer[i].CosSimilarW(layer[j]);
         int sign=1;
        if(CosSim<0)
        {
          CosSim=-CosSim;
          sign=-1;
        }
        if(CosSim>CosSimValve)
        {
          System.out.printf("W%d>%d>:%f...\n ",i,j,CosSim*sign);
          for (int k=0;k<layer[j].GetActual_pre_neuron_L();k++)
          {
            //System.out.printf("%f,%f  ",layer[j].W[k],layer[i].W[k]);
            layer[j].W[k]=(sign*layer[i].W[k]+layer[j].W[k])/2;
            layer[j].ADss[k]=(layer[i].ADss[k]+layer[j].ADss[k])/2;
            layer[j].LPW[k]=(layer[i].LPW[k]+layer[j].LPW[k])/2;
            layer[i].W[k]= XRand(0,0.5)/2;
            layer[i].ADss[k]=layer[j].ADss[k];
          }
          //System.out.printf("\n ");
          
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
            pnode.W[n1_idx]+=pnode.W[n2_idx]*sign;
            pnode.ADss[n1_idx]+=pnode.ADss[n2_idx];
            pnode.LPW[n1_idx]+=pnode.LPW[n2_idx]*sign;
            pnode.W[n2_idx]=0;
            pnode.ADss[n2_idx]=5;
          }
          return;
          //break;
        }
      }
        
    }
    
  }
  int CCCC=0;
  void SupressS(s_neuron layer[],float alpha)
  {
    CCCC++;
    for (int i=0;i<layer.length;i++)
    {
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
        //int k=(CCCC/6)%(layer.length);
        
        //layer[i].W[j]=(i==k)?(cos(2*(i*j)*PI/(layer[i].pre_neuron_L-1)/layer.length)):0;
        layer[i].W[j]=d*(alpha)+(1-alpha)*d*(cos(2*(i*j)*PI/(layer[i].pre_neuron_L-1)/layer.length)+1)/2;
          
      }
    }
    
  }
  void SupressL2(s_neuron layer[],float alpha)
  {
    for (int i=0;i<layer.length;i++)
    {
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
        //int k=(CCCC/6)%(layer.length);
        
        //layer[i].W[j]=(i==k)?(cos(2*(i*j)*PI/(layer[i].pre_neuron_L-1)/layer.length)):0;
        layer[i].W[j]=d*(1-alpha);
          
      }
    }
    
  }
  
  void SupressL1X(s_neuron layer[],float rate)
  {
    for (int i=0;i<layer.length;i++)
    {
      float xr=0;
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
       
        xr+=(d>0)?d:-d;
          
      }
      
      xr/=layer[i].pre_neuron_L-1;
      for (int j=0;j<layer[i].pre_neuron_L-1;j++)
      {
        float d=layer[i].W[j];
        if(d<0) layer[i].W[j]+=rate*xr;
        else    layer[i].W[j]-=rate*xr;
        
        if(layer[i].W[j]*d<0)layer[i].W[j]=0;
          
      }
    }
    
  }
  void PreTrainProcess(float rate)
  {
   // RandomDropOut(0.01);
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      s_neuron layer[]=this.ns.get(i);
      SupressL2(layer,rate*0.01);
      SupressL1X(layer,rate*0.001);
    }
    
    /*for (int i=this.ns.size()-1;i!=0;i--)
    {
      s_neuron layer[]=this.ns.get(i);
      //AttractSimNode(layer,0.70,0.80);
      AttractSimNode2(layer,0.80,0.01*rate);
      TrimSimNode(layer,0.99);
      //NeuronNodePolarizing(this.ns.get(i),0.9);
      NeuronNodeRevive(layer,0.8,1+rate/50);
    }*/
  }

  //BufferL = Train_1(this.ns.get(i),Error,ErrorL,Buffer);
  void Train_Layer(s_neuron layer[],boolean crossEn)
  {
    for (int i=0;i<layer.length;i++) {
      layer[i].train( crossEn);
    }
    return;
  }
  
  void softMax()
  {
    float sum=0;
    for (int i=0;i<output.length;i++)
    {
      sum+=(output[i].latestVar+1)/2;
      //float absErr=Error[i]>0?Error[i]:-Error[i];
      //Error[i]=(float)Math.exp(absErr*absErr*absErr)/5*(Error[i]>0?1:-1);
    }
    
    for (int i=0;i<output.length;i++)
    {
      output[i].latestVar=((output[i].latestVar+1)/sum)-1;
      //float absErr=Error[i]>0?Error[i]:-Error[i];
      //Error[i]=(float)Math.exp(absErr*absErr*absErr)/5*(Error[i]>0?1:-1);
    }
    
  }
  
  
  void Update_dW(float learningRate)
  {
    for (s_neuron[] layer: this.ns)
    {
      for (s_neuron node:layer)
      {
        node.Update_dW(learningRate);
      }
    }
  }
  
  void Train_S(float lRate,boolean crossEn,boolean update_dW)
  {
    // softMax();
    
    
    for (int i=this.ns.size()-1;i!=0;i--)
    {
      Train_Layer(this.ns.get(i),crossEn&&(i==this.ns.size()-1));
    }
    if(update_dW)
      Update_dW(lRate);
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
  
  float calcError()
  {
    float out=0;
    for (int i=0;i<output.length;i++)
    {
      float tmp = output[i].trainError;
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
  
  float TestTrain(float InXSet[][],float OuYSet[][],int iter,float lRate)
  {
    return TestTrain( InXSet, OuYSet, iter, lRate, false,true);
  }
  
  float TestTrain(float InXSet[][],float OuYSet[][],int iter,float lRate,boolean crossEn,boolean update_dW)
  {
    float aveErr=0;
    float aveErrC=0;
    //lRate*=50;
    //lRate/=1.2;
    for(int i=0;i<iter;i++)
    {
      PreTrainProcess(lRate/5);
      for(int j=0;j<InXSet.length;j++)
      {
        aveErr+=TestTrain( InXSet[j], OuYSet[j], lRate, crossEn,update_dW);
        aveErrC++;
        
      }
    }
    return aveErr/aveErrC;
  }
  
  
  
  float TestTrain(float InXSet[][],float OuYSet[][],int headIdx,int histL,float lRate,boolean crossEn,boolean update_dW)
  {
    float aveErr=0;
    float aveErrC=0;
    //lRate*=50;
    //lRate/=1.2;
    
    for(int j=0;j<histL;j++)
    {
      PreTrainProcess(lRate);
      aveErr+=TestTrain( InXSet[headIdx], OuYSet[headIdx], lRate, crossEn,update_dW);
      aveErrC++;
      
      headIdx--;
      if(headIdx<0)headIdx+=InXSet.length;
      
    }
    return aveErr/aveErrC;
  }
  float TestTrain(float InX[],float OuY[],float lRate,boolean crossEn,boolean update_dW)
  {
    //if(InX[idx]==Float.NEGATIVE_INFINITY)continue;
    
    for(int k=0;k<input.length;k++)
    {
      input[k].latestVar=InX[k];
    }
    this.calc();
    
    for(int k=0;k<output.length;k++)
    {
          
      if(Float.isNaN(OuY[k]))
        output[k].trainError=0;
      else  
        output[k].trainError=OuY[k]-output[k].latestVar;
    }
    
    
    return TrainErr(lRate,crossEn,update_dW);
    
  }
  
  float TrainErr(float lRate,boolean crossEn,boolean update_dW)//To use this you need to set trainError at output layer
  {
    one_offset.trainError = 0;
    
    //print("\n");
    float ErrorPow=-calcError();
    Train_S(lRate,crossEn,update_dW);
    
    return ErrorPow;
  }
  
  void BPTT(float InX[][],float ExpY[][], float DesY[][],int endIdx,int seqL,float lRate,boolean crossEn)
    {

      int curIdx=endIdx;
      for(int j=0;j<seqL;j++)
      {
        
        curIdx-=1;
        if(curIdx<0)curIdx+=InX.length;
        
        float curX[]=InX[curIdx];
        float curExpY[]=ExpY[curIdx];
        float curDesY[]=DesY[curIdx];
        
        
        for(int k=0;k<input.length;k++)
        {
          input[k].latestVar=curX[k];
        }
        
        for(int k=0;k<output.length;k++)
        {
          output[k].trainError=(curDesY[k]-curExpY[k]);
        }
        
        
        for (int k=this.ns.size()-2;k>=0;k--)
        {
          s_neuron layer[]=this.ns.get(k);
          for (int m=0;m<layer.length;m++)
          {
            layer[m].trainError = 0;
          }
        }
        Train_S(lRate,crossEn,false);
      }
      //  Update_dW(lRate);
      //println();
    }
    
    
    void BPTT2(float InX[][],float ExpY[][], float DesY[][],int endIdx,int seqL,float lRate,boolean crossEn)
    {

      int curIdx=endIdx;
      for(int j=0;j<seqL;j++)
      {
        
        curIdx-=1;
        if(curIdx<0)curIdx+=InX.length;
        
        float curX[]=InX[curIdx];
        float curExpY[]=ExpY[curIdx];
        float curDesY[]=DesY[curIdx];
        
        
        for(int k=0;k<input.length;k++)
        {
          input[k].latestVar=curX[k];
        }
        
        for(int k=0;k<output.length;k++)
        {
          if(j==0)
            output[k].trainError=(curDesY[k]-curExpY[k]);
          else
            output[k].trainError=0;
            
        }
        
        
        for (int k=this.ns.size()-2;k>=0;k--)
        {
          s_neuron layer[]=this.ns.get(k);
          for (int m=0;m<layer.length;m++)
          {
            layer[m].trainError = 0;
          }
        }
        Train_S(lRate,crossEn,false);
      }
      //  Update_dW(lRate);
      //println();
    }
  
    void TestTrainRecNNx_(float InX[][],float OuY[][],int endIdx,int seqL,float lRate,boolean crossEn,int memNum)
    {
      //if(InX[idx]==Float.NEGATIVE_INFINITY)continue;
      
      
      TestTrain(InX[endIdx],OuY[endIdx],lRate,crossEn,false);
      
      //float ErrorPow=-calcError();

      /*
       
           ____________
       ----|           |---
       ----|           |---
    mem----|___________|--- mem
         |               |
         |_____mem_______|
  
      inErr(tmp) = DestOut - outVar (only mem)
      loop{
        outVar = DestOut -inErr(tmp)   (only mem)
        Clear all trainError
        outErr = DestOut - outVar     (ALL)  => mem's outErr will be inErr
        TRAIN...
      }
      */
      
      seqL--;
      int curIdx=endIdx;
      float discountF=1;
      for(int j=0;j<seqL;j++)
      {
        
        curIdx-=1;
        if(curIdx<0)curIdx+=InX.length;
        
        for(int k=0;k<output.length;k++)
        {
          input[k].latestVar=InX[curIdx][k];
        }
        this.calc();
        
        
        float ixx=0;
        
        
        
        
        discountF*=991.8;
        for(int k=0;k<output.length-memNum;k++)
        {
          output[k].trainError=(OuY[curIdx][k]-output[k].latestVar)/discountF;
          
        }
        
        ixx=0;
        for(int k=0;k<memNum;k++)
        {
          float err=input[input.length-1-k].trainError;
          //if(err>1)err=1;
          //else if(err<-1)err=-1;
          output[output.length-1-k].trainError=err;
          ixx+=err*err;
        }
        ixx=sqrt(ixx)/memNum;
        ixx/=3;
        if(ixx>1)
        {
          for(int k=0;k<memNum;k++)
          {
            output[output.length-1-k].trainError/=ixx;
          }
        }
        println(ixx+",");
        /*ixx=sqrt(ixx);
        */
        //println();

        //softMax();
        
        for (int k=this.ns.size()-2;k>=0;k--)//last layer will be set later
        {
          s_neuron layer[]=this.ns.get(k);
          for (int m=0;m<layer.length;m++)
          {
            layer[m].trainError = 0;
          }
        }
        Train_S(lRate,crossEn,false);
      
        
      }
      //  Update_dW(lRate);
      //println();
    }
  
    
    int RetRandomSel(float chance[])
    {
      int maxIdx=0;
      float maxNum=0;
      
      for(int i=0;i<chance.length;i++)
      {
        float tmp=random(0,chance[i]);
        if(maxNum<tmp)
        {
          maxIdx=i;
          maxNum=tmp;
        }
      }
      return maxIdx;
      
    }
    
    boolean GeneticCrossNN(s_neuron_net parents[],float fitness[])
    {//no dynamic node change
    
      for (int i=ns.size()-1;i>=0;i--)
      {
        s_neuron layer[]=ns.get(i);
        for (int k=0;k<layer.length;k++)
        {
          s_neuron node=layer[k];
          int selIdx=RetRandomSel(fitness);
          for (int m=0;m<node.pre_neuron_L;m++)
          {
            node.W[m]=parents[selIdx].ns.get(i)[k].W[m];
          }
        }
      }
      return false;
    }
    void AddNNNoise(float noiseLevel)
    {//no dynamic node change
    
      for (int i=ns.size()-1;i>=0;i--)
      {
        s_neuron layer[]=ns.get(i);
        for (int k=0;k<layer.length;k++)
        {
          s_neuron node=layer[k];
          for (int m=0;m<node.pre_neuron_L;m++)
          {
            node.W[m]+=random(-noiseLevel,noiseLevel);
          }
        }
      }
    }
    void AddNNmutate(float mutateChance)
    {//no dynamic node change
    
      for (int i=ns.size()-1;i>=0;i--)
      {
        s_neuron layer[]=ns.get(i);
        for (int k=0;k<layer.length;k++)
        {
          s_neuron node=layer[k];
          for (int m=0;m<node.pre_neuron_L;m++)
          {
            if(random(0,1)<mutateChance)
              node.W[m]=random(-node.W[m]*1,node.W[m]*1);
          }
        }
      }
    }
}


class ExpData
{
  /*
  (s(tate),a(ct),r(eward),s'(tate next))
  */
    
  float S_tate[];//current input
  float A_ct[];//output act decision
  float R_eward;
  float S_tate_next[];//next input after current act
  
  ExpData(int stateDim,int actDim)
  {
    S_tate=new float[stateDim];
    S_tate_next=new float[stateDim];
    A_ct=new float[actDim];
  }
  
  
  ExpData(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])
  {
    ExpLink(S_tate,A_ct,R_eward,S_tate_next);
  }
  
  
  void ExpAssign(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])
  {
    this.R_eward=R_eward;
    for(int i=0;i<S_tate.length;i++)
    {
      this.S_tate[i]=S_tate[i];
      if(S_tate_next==null)
       this.S_tate_next[i]=0;
      else
       this.S_tate_next[i]=S_tate_next[i];
    }
    for(int i=0;i<A_ct.length;i++)
    {
      this.A_ct[i]=A_ct[i];
    }
  }
  void ExpLink(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])
  {
    this.S_tate=S_tate;
    this.A_ct=A_ct;
    this.R_eward=R_eward;
    this.S_tate_next=S_tate_next;
  }
}
class RLearningCore
{
  int expWIdx=0;
  int expSetAvalibleL;
  ExpData expReplaySet[];
  RLearningCore(int size, int stateDim,int actDim)
  {
    expReplaySet=new ExpData[size];
    for(int i=0;i<expReplaySet.length;i++)
    {
      expReplaySet[i]=new ExpData(stateDim,actDim);
    }
    expSetAvalibleL=0;
  }
  
  void pushExp(float S_tate[],float A_ct[],float R_eward,float S_tate_next[])//for terminal state set S_tate_next to null
  {
    expReplaySet[expWIdx].ExpAssign(S_tate,A_ct,R_eward,S_tate_next);
    if(++expWIdx>=expReplaySet.length)expWIdx=0;
    if(expSetAvalibleL<expReplaySet.length)expSetAvalibleL++;
  }
  
  int getAvalibleExpSize()
  {
    return expSetAvalibleL;
  }
  
  void actExplain(float q_nx[],ExpData ed) throws Exception
  {
    throw new Exception("You have to Override actExplain method");
  }
  
  float R_nx[];
  void RlearningTrain(s_neuron_net nn,ExpData ed,float lRate,boolean dW_update)
  {
    if(R_nx==null||R_nx.length!=nn.output.length)R_nx=new float[nn.output.length];
    
    //Q(s,a)=r(s,a)+garmma*max_a'_(Q(s',a'))
    //Get Q(s',a')=>Q_nx
    for(int i=0;i<nn.input.length;i++)nn.input[i].latestVar=ed.S_tate_next[i];
    nn.calc();
    for(int i=0;i<nn.output.length;i++)R_nx[i]=nn.output[i].latestVar;
    
    try{
      actExplain(R_nx, ed);
      float R_x[]=R_nx;
      nn.TestTrain(ed.S_tate,R_x,lRate,false,dW_update);
    }
    catch (Exception e) 
    {
      println(e);
    }
  }
    
  void actExplainX(float q_err[],float q_cx[],float q_nx[],ExpData ed) throws Exception
  {
    throw new Exception("You have to Override actExplain method");
  }
  
  float R_cx[];
  float R_err[];
  void RlearningTrainX(s_neuron_net nn,ExpData ed,float lRate,boolean dW_update)
  {
    if(R_nx==null||R_nx.length!=nn.output.length)R_nx=new float[nn.output.length];
    if(R_cx==null||R_cx.length!=nn.output.length)R_cx=new float[nn.output.length];
    if(R_err==null||R_err.length!=nn.output.length)R_err=new float[nn.output.length];
    
    for(int i=0;i<nn.input.length;i++)nn.input[i].latestVar=ed.S_tate_next[i];
    nn.calc();
    for(int i=0;i<nn.output.length;i++)R_nx[i]=nn.output[i].latestVar;
    
    
    for(int i=0;i<nn.input.length;i++)nn.input[i].latestVar=ed.S_tate[i];
    nn.calc();
    for(int i=0;i<nn.output.length;i++)R_cx[i]=nn.output[i].latestVar;
    
    try{
      actExplainX(R_err,R_cx,R_nx, ed);
      
      for(int k=0;k<nn.output.length;k++)
      {
          nn.output[k].trainError=R_err[k];
      }
      nn.TrainErr(lRate,false,dW_update);
    }
    catch (Exception e) 
    {
      println(e);
    }
  }
  
}