 class reC
  {
    float in_X;
    float inout_mem[]=new float[3];
    
    float ou_Y;
    
    s_neuron_net nn = new s_neuron_net(new int[]{1+inout_mem.length,15,15,1+inout_mem.length});
    float InX[][]=new float[1][nn.input.length];
    float OuY[][]=new float[InX.length][nn.output.length];
    
  
    reC()
    {
      init();
    }
      
    void init()
    {
      in_X=0;
      ou_Y=0;
      for(int i=0;i<inout_mem.length;i++)
      {
        inout_mem[i]=0;
      }
    }
    
    
    int skipIdx=0;
        
    int InoutIdx=0;
    void UpdateNeuronInput()
    {
      skipIdx=(skipIdx+1)%1;
      if(skipIdx==0)
      {
        InoutIdx++;
        InoutIdx%=InX.length;
      }
      int i=0;
      
      InX[InoutIdx][i++]=in_X;
      
      for(int j=0;j<inout_mem.length;j++)
      {
        InX[InoutIdx][i++]=inout_mem[j];
      }
      
      for(int j=0;j<InX[InoutIdx].length;j++)
      {
        nn.input[j].latestVar=InX[InoutIdx][j];
      }
      nn.calc();
      
      for(int j=0;j<OuY[InoutIdx].length;j++)
      {
        OuY[InoutIdx][j]=nn.output[j].latestVar;
      }
      i=0;
      ou_Y=OuY[InoutIdx][i++];
      for(int j=0;j<inout_mem.length;j++)
      {
        inout_mem[j]=OuY[InoutIdx][i++];
      }
    }
   

    float training(float InX[][],float OuY[][],int iter,float lRate)
    {
      float memLoopTrain=1;
      
      for(int i=0;i<memLoopTrain;i++)
      {
        
        nn.PreTrainProcess(lRate);
        for(int k=0;k<InX.length;k++)
        {
          nn.TestTrainRecNN(InX[k],OuY[k],lRate,false,iter,inout_mem.length);
        }
      }
      
      return  0;
    }
    
    
    float training(float InX[],float OuY[],int iter,float lRate)
    {
      nn.PreTrainProcess(lRate);
      nn.TestTrainRecNN(InX,OuY,lRate,false,iter,inout_mem.length);
      
      return  0;
    }
   void SetOuY(float ouY[])
    {
      for(int i=0;i<ouY.length;i++)
      {
        OuY[InoutIdx][i]=ouY[i];
      }
    } 
    float training(int iter,float lRate)
    {
          training(InX,OuY, iter, lRate);
      return  0;
    }
  }
  
  
  class reCTest
  {
    
    Draw_s_neuron_net drawNN=new Draw_s_neuron_net();
    reC rec=new reC();
    float InX[]=new float[rec.nn.input.length];
    float OuY[]=new float[rec.nn.output.length];
    
    reCTest()
    {
      init();
    }
    void init()
    {
      for(int i=0;i<InX.length;i++)InX[i]=0;
      for(int i=0;i<OuY.length;i++)OuY[i]=0;
      for(int i=0;i<MEMHist.length;i++)MEMHist[i]=new HistDataDraw(100);
    }
    

    HistDataDraw TarHist=new HistDataDraw(100);
    HistDataDraw OutHist=new HistDataDraw(100);
    HistDataDraw MEMHist[]=new HistDataDraw[rec.inout_mem.length];
    
    boolean trainStop=false;
    float t=1;
    void update()
    {
      strokeWeight(3);
      background(0);
      //if(!trainStop)
        t+=0.05;
      InX[0]=(t%(1))*2-1;
      OuY[0]=sin(t*2*PI)>0?1:-1;
      
      rec.in_X=0;
      rec.UpdateNeuronInput();
      rec.SetOuY(OuY);
      drawNN.drawNN(rec.nn,10,10,550,350);
      stroke(0,255,0);
      TarHist.Draw(OuY[0]*50,0,600,width,100);
      stroke(255,255,0);
      OutHist.Draw(rec.ou_Y*50,0,600,width,100);
      stroke(255,0,0);
      for(int i=0;i<MEMHist.length;i++)
        MEMHist[i].Draw(rec.inout_mem[i]*50,0,200+i*100,width,100);
      if(!trainStop)
        rec.training(10,0.1);
    }
    void keyPressed()
    {
      
      if (key == CODED) {
        if (keyCode == UP) {
         
        } else if (keyCode == DOWN) {
        }
      } else {
        trainStop=!trainStop;
      }
    } 
  }