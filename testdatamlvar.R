library(vars)
library(arm)
library(mvtnorm)
library(lme4)

#meanvarcompSelf
#meancoef1
##########################
cormatrix=function(x,np){
  CC.int=matrix(x,np,np,byrow=TRUE)
  diag(CC.int)<-1
  return(CC.int) 
  
}

cormatrix2=function(x,np){
  CC.int=matrix(x,np,np,byrow=TRUE)
  CC.int=CC.int+t(CC.int)
  diag(CC.int)<-1
  return(CC.int) 
  
}



Multilevel_var=function(
    
  
  i=1
  np=21
  nT=50
  int=rep(c(1.87,1.04),10)
  sd.int=rep(c(1.10,1.029),10)
  CC.int=cormatrix(0.4,20)
  SD=rep(c(.1,.1,.1,.1,.1,.1,.1,.1,.1,.1),40)# leidt tot een hele slechte sigma_sim  
  SD=rep(c(.06,.1,0.02,.6,.1,.02,.06,.1,.02,.06),40)
  SD=rep(c(.13,.13,.13,.14,.2,.13,.13,.13,.2,.15),40)
  SD=rep(c(.00000002,.00000001,0.0000001,.0000008,.000006,.00004,.00006,.00001,.00002,.0003),40)
  #cor=cormatrix(0.4,9);
  #x=c(0.1,0.4,0.35),
  #cor=cormatrix2(x,9),
  corr=cormatrix(0.4,np*np)
  cor=cormatrix(0.4,np*np)
  eps=cormatrix(0.4,np)
  #c(1.31,1.56,1.9)
  diag.eps=rep(c(1.01,1.0056),10)
  Nrep=1
  N=150
)
{
  
  
  N=N#number of subjects
  nT=nT# aantal tijdspunten
  np=np# aantal variabelen
  int=matrix(int,np,byrow=T)#intercept for both functions
  VV.int=diag(sd.int)
  CC.int=CC.int
  Sigma.int=VV.int%*%CC.int%*%VV.int
  #A=matrix(mean,np,np,byrow=T)# mean transitie matrix. zometeen schattingen uit een multivariaat verderling, maaer omdat die stationair moet zijn, wordt soms opnieuw getrokken dus kan zijn dat je ook met veel pp niet de precieze getallen terug krijgt
  #VV=diag(SD)# between person/populatie sd, hoe hoger dit is hoe meer individuel variatie je veronderstelt
  #CC=corr# correlatie tussen effecten, variabiliteit### is dit correct? np*np?####
  #Sigma=VV%*%CC%*%VV# dus om covariantie te krijgen moet je van corr=cov/sdx+sdy doen dus corr*sdx*sdy. om te zorgen dat je de juiste manier vermenigvuldigt moet je voor en na vermenigvuldigen zodat elk element van correlatie matrix met sdx en sdy vermenigvuldigt wordt. variantie covariantie matrix. cov2cor(Sigma)# om te checken of het gelukt is 
  
  
  diag.epss=diag(diag.eps)
  Sigma.eps=diag.epss%*%eps%*%diag.epss
  Sigma.eps
  
  #residuen VRAAG: OMDAT JE ER TWEE HEBT waarom geven we de errors niet aan, aan de hand van een distributie bijv. error=rnorm(60,mean=0,sd=1), maar dan RMVNORM, onverklaarde variantie?
  #waarom maken we de covariantiematrix niet zoals de andere sigma
  #dit lijkt meer op een correlatie matrix met die enen
  #zie voorbeels sigma van rmvnorm:sigma <- matrix(c(4,2,2,3), ncol=2)
  
  
  
  
  ####VRAAG OVER SIGMA.eps#############
  #cov(resid(model1[[1]]),resid(model1[[3]])[1:8807])# in de simulatie komt dit getal van het idee dat alles sterk met elkaar correleert namelijk 0.4 dus dit getal is gebaseerd op de correlatie van 0.4 die je altijd hebt genomen!: .572/sqrt(1.31*1.56) =0.4!
  
  
  est=list()# geschatten componenten komen hier in
  est$A=array(0,c(np,np,Nrep))
  est$varmatrix.A=array(0,c(np,np,Nrep))
  est$se.A=array(0,c(np,np,Nrep))
  est$res=array(0,c(np,np,Nrep))
  est$res.cor=array(0,c(np,np,Nrep)) 
  est$cov = array(0,c(np*np,np*np,Nrep))
  est$cor = array(0,c(np*np,np*np,Nrep))
  est$int=array(0,c(np,Nrep))
  est$se.int=array(0,c(np,Nrep))
  est$cov.int=array(0,c(np,np,Nrep))
  est$cor.int = array(0,c(np,np,Nrep))
  est$varmatrix =array(0,c(np*np,np*np,Nrep))
  
  
  est_MV=list()# geschatten componenten komen hier in
  est_MV$A=array(0,c(np,np,Nrep))
  est_MV$se.A=array(0,c(np,np,Nrep))
  est_MV$res=array(0,c(np,np,Nrep))
  est_MV$res.cor=array(0,c(np,np,Nrep)) 
  est_MV$cov = array(0,c(np*np,np*np,Nrep))
  est_MV$cor = array(0,c(np*np,np*np,Nrep))
  est_MV$int=array(0,c(np,Nrep))
  est_MV$se.int=array(0,c(np,Nrep))
  est_MV$cov.int=array(0,c(np,np,Nrep))
  est_MV$cor.int = array(0,c(np,np,Nrep))
  
  
  
  
  
  
  
  allmod=list()
  for (i in 1:Nrep){
    print(i)
    allmod[[i]]=list()
    
    Asubj=list()
    s=list()# s stands for sigma
    for (pp in 1:N){
      
      #  print(pp)
      conv=FALSE   # eigenwaarde copmlexe getallen popleveren met de symetrie van de matrix (imaginaire eigenwaarden=leidden tot oscillaties?)
      while (!conv){
        s[[pp]]=matrix(rmvnorm(1,sigma=Sigma),np,np,byrow=T)# dus mean 0 en sigma is de covariance matrix, dus dit is de persoonlijke variabiliteit van de sterkte van de betas
        
        Asubj[[pp]]=A+s[[pp]]# dus mean 0 en sigma is de covariance matrix, dus dit is de persoonlijke variabiliteit van de sterkte van de betas
        if (max(abs(eigen(Asubj[[pp]])$values))<1) conv=TRUE# hier wordt dus gecheked of het proces dat getrokken is stationair is, dus eigenvalues moeten onder de 1 zijn.anders wordt opnieuw getrokken
        print(conv)
      }
      
      
    }
    #dus hier maak je de varcov matrix van de random effects aan
    
    
    Intsubj=list()
    for (pp in 1:N){
      Intsubj[[pp]]=int+matrix(rmvnorm(1,sigma=Sigma.int),np,byrow=T)# dus mean 0 en sigma is de covariance matrix, dus dit is de persoonlijke variabiliteit van de sterkte van de betas
      
      # print(pp)
    }
    
    
    
    
    data1=matrix(0,nT*N,2+(np*2),byrow=T)# always an column depending on deamount of variables you have
    # 3 datasets because we have 3 variables
    
    for (pp in 1:N){
      #print(pp)
      x=matrix(0,np,nT,byrow=T)
      x[,1]=rmvnorm(1,sigma=Sigma.eps)
      for (tt in 2:nT){
        x[,tt] = Intsubj[[pp]]+ Asubj[[pp]]%*%x[,tt-1] + matrix(rmvnorm(1,sigma=Sigma.eps),np,1,byrow=T) 
        
      }
      #burn in van 100 
      #correlaties tussen de errors weg
      
      
      data1[((pp-1)*nT+1):(pp*nT),1]=pp
      
      
      data1[((pp-1)*nT+1):(pp*nT),2]=1:nT # adding session numbers
      
      for (g in 3:(np+2)){
        
        data1[((pp-1)*nT+1):(pp*nT),g]=x[(g-2),]
        
      }
      
      for (h in (np+3):((np+3)+(np-1))){
        
        
        
        data1[((pp-1)*nT+1):(pp*nT),h]=c(NA,x[(h-(np+2)),1:(nT-1)])# data wordt hier gelagged
        
      }
      
    }
    
    
    
    data1=as.data.frame(data1)
    
    
    
    
    colnames(data1)=c("pp","t",paste("y",1:np,sep=""),paste("y",1:np,"L",sep=""))
    
    plot.ts(data1[data1$pp==1,13:22])
    
    Varmatrix=matrix(0,N,np*np,byrow=TRUE)
    for (hh in 1:N){
      for (gg in 1:np){
        Varmatrix[hh,(1+(np*(gg-1))):(np*gg)]=coef(VAR(data1[data1$pp==hh,3:(3+(np-1))]))[paste("y",gg,sep="")][[1]][1:np]
        print(hh)
        #print(gg)
        
      }     }
    #est$varmatrix.A[,,i]= matrix(apply(Varmatrix,2,mean),np,np,byrow=TRUE)
    
    #est$varmatrix[,,i]=cov(Varmatrix)
    
    
    
    plot(as.vector(A),as.vector(matrix(apply(Varmatrix,2,mean),np,np,byrow=TRUE)))
    abline(0,1)
    
    plot(as.vector(Sigma),as.vector(cov(Varmatrix)))
    abline(0,1)
    
    
    coln=colnames(data1)[3:22]
    colnL=colnames(data1)[23:42]
    
    model_LM= function (x,J){
      model=list()
      for (j in 1:J){
        
        ff <- as.formula(paste(coln[j]," ~ ","(" ,paste(colnL, collapse= "+"),")"))
        model[[j]]<-lm(ff,data=x)
        print(j)
      }
      return(model)}
    
    
    model1=model_LM(x=data1,20)#
    
    
    coef1=data.frame(matrix(unlist(lapply(model1,coef),use.names=FALSE),byrow=TRUE,ncol=21)) 
    coef=as.matrix(coef1[,-1])
    plot(as.vector(A),as.vector(coef))
    abline(0,1)
    A1=as.vector(A)
    A11=A1[-which(diag(A)==A)]
    coeff=as.vector(coef)
    coefff=coeff[-which(diag(coef)==coef)]
    
    plot(A11,coefff)
    abline(0,1)
    
    
    
    model=list()
    coef1=list()#here is the list for the coefficients you will use for making the network
    se.coef1=list()#here you put in the SE 
    dev1=list()
    bic1=list()#BIC values of every model
    coefran1=list()#the random effects per subject (there are always only 2 random effects per analysis)
    se.coefran1=list()#the SE of the random effects 
    varcor1=list()# the variance covariance matrix
    resid1=list()#the residuals of the mode 
    
    allcol=paste(colnL,collapse="+")#here you take the lagged variables and make them ready for the formula by putting "+" between them.
    pred1=paste("(",allcol,")",sep="")
    for (j in 1:20){
      model[[j]]=list()
      coefran1[[j]]=list()
      se.coefran1[[j]]=list()
      varcor1[[j]]=list()
      for (k in 1:20){
        if (j != k){
          print(c(j,k))
          pred1temp = paste(pred1,"+","(",colnL[j],"+",colnL[k],"|pp)",sep="")# the full prediction list (also with e.g. group variables such as different therapies), notice that ther is j and k, j is for the fixed effects and k for defining the random effects.
          ff=as.formula(paste(coln[j],"~",pred1temp,sep=""))#the final formula (ff) that you canput into the multilevel function "lmer"
          model[[j]][[k]]<-lmer(ff,data=data1,control=list(maxIter=800),REML=FALSE)
          coefran1[[j]][[k]]=ranef(model[[j]][[k]])$pp
          se.coefran1[[j]][[k]]=se.ranef(model[[j]][[k]])$pp
          varcor1[[j]][[k]]=sigma.hat(model[[j]][[k]])
        }
      }
      print(c(j,k))
      model[[j]][[j]]<-NULL
      Nc=length(lapply(model[[j]],fixef)[[1]])
      #coef1[[j]]=matrix(NA,Nvar-1,Nc)#-1
      coef1[[j]]=data.frame(matrix(unlist(lapply(model[[j]],fixef),use.names=FALSE),byrow=TRUE,ncol=Nc))
      se.coef1[[j]]=data.frame(matrix(unlist(lapply(model[[j]],se.fixef),use.names=FALSE),byrow=TRUE,ncol=Nc))
      dev1[[j]]=unlist(lapply(model[[j]],deviance),use.names=FALSE)
      bic1[[j]]=unlist(lapply(model[[j]],BIC),use.names=FALSE)
      #resid1[[j]]=matrix(unlist(lapply(model[[j]],resid),use.names=FALSE),byrow=TRUE,ncol=(Nvar-1))
      
      colnames(coef1[[j]])=names(fixef(model[[j]][[1]]))
      colnames(se.coef1[[j]])=names(fixef(model[[j]][[1]]))
      #save(coef1,se.coef1,coefran1,se.coefran1,varcor1,model,file="ResultsBDI1.RData")
    }
    
    Nvar=20
    meancoef1=matrix(unlist(lapply(coef1,function(x){apply(x,2,mean)}),use.names=FALSE),byrow=TRUE,Nvar,Nc)
    meanse.coef1=matrix(unlist(lapply(se.coef1,function(x){apply(x,2,mean)}),use.names=FALSE),byrow=TRUE,Nvar,Nc)
    
    colnames(meancoef1)=names(fixef(model[[j]][[1]]))
    colnames(meanse.coef1)=names(fixef(model[[j]][[1]]))
    
    meancoef=meancoef1[,-1]
    
    plot(as.vector(A),as.vector(meancoef))
    cor(as.vector(A),as.vector(meancoef))
    
    M=matrix(0,20,20)
    for (j in 1:20){
      M[j,j]=mean(unlist(lapply(model[[j]],function(x){VV= VarCorr(x)$pp[c(5)]})))# the self loop sd
      
      M[j,-j]=unlist(lapply(model[[j]],function(x){VV= VarCorr(x)$pp[9]}))# every row are the arrows to a node
      
    }
    
    Sigma_2=matrix(diag(Sigma),20,20,byrow=TRUE)
    
    plot(as.vector(Sigma_2),as.vector(M))
    cor(as.vector(Sigma_2),as.vector(M))
    
    
    
    
    
    modelt=list()
    coef1t=list()#here is the list for the coefficients you will use for making the network
    se.coef1t=list()#here you put in the SE 
    dev1t=list()
    bic1t=list()#BIC values of every model
    coefran1t=list()#the random effects per subject (there are always only 2 random effects per analysis)
    se.coefran1t=list()#the SE of the random effects 
    varcor1t=list()# the variance covariance matrix
    resid1t=list()#the residuals of the mode 
    
    allcol=paste(colnL,collapse="+")#here you take the lagged variables and make them ready for the formula by putting "+" between them.
    pred1=paste("(",allcol,")",sep="")
    predd=list(paste(paste(colnL[1:5],collapse="+"),sep=""),paste(paste(colnL[6:10],collapse="+"),sep=""),paste(paste(colnL[11:15],collapse="+"),sep=""),paste(paste(colnL[16:20],collapse="+"),sep=""))
    for (j in 1:20){
      modelt[[j]]=list()
      coefran1t[[j]]=list()
      se.coefran1t[[j]]=list()
      varcor1t[[j]]=list()
      for (k in 1:4){
        #if (j != k){
        print(c(j,k))
        pred1temp = paste(pred1,"+","(",colnL[j],"+",predd[[k]][1],"|pp)",sep="")# the full prediction list (also with e.g. group variables such as different therapies), notice that ther is j and k, j is for the fixed effects and k for defining the random effects.
        ff=as.formula(paste(coln[j],"~",pred1temp,sep=""))#the final formula (ff) that you canput into the multilevel function "lmer"
        modelt[[j]][[k]]<-lmer(ff,data=data1,control=list(maxIter=800),REML=FALSE)
        coefran1t[[j]][[k]]=ranef(model[[j]][[k]])$pp
        se.coefran1t[[j]][[k]]=se.ranef(model[[j]][[k]])$pp
        varcor1t[[j]][[k]]=sigma.hat(model[[j]][[k]])
      }
      #}
      print(c(j,k))
      modelt[[j]][[j]]<-NULL
      Nc=length(lapply(modelt[[j]],fixef)[[1]])
      #coef1[[j]]=matrix(NA,Nvar-1,Nc)#-1
      coef1t[[j]]=data.frame(matrix(unlist(lapply(modelt[[j]],fixef),use.names=FALSE),byrow=TRUE,ncol=Nc))
      se.coef1t[[j]]=data.frame(matrix(unlist(lapply(modelt[[j]],se.fixef),use.names=FALSE),byrow=TRUE,ncol=Nc))
      dev1t[[j]]=unlist(lapply(modelt[[j]],deviance),use.names=FALSE)
      bic1t[[j]]=unlist(lapply(modelt[[j]],BIC),use.names=FALSE)
      #resid1[[j]]=matrix(unlist(lapply(model[[j]],resid),use.names=FALSE),byrow=TRUE,ncol=(Nvar-1))
      
      colnames(coef1t[[j]])=names(fixef(modelt[[j]][[1]]))
      colnames(se.coef1t[[j]])=names(fixef(modelt[[j]][[1]]))
      #save(coef1,se.coef1,coefran1,se.coefran1,varcor1,model,file="ResultsBDI1.RData")
    }
    
    meancoef1t=matrix(unlist(lapply(coef1t,function(x){apply(x,2,mean)}),use.names=FALSE),byrow=TRUE,Nvar,Nc)
    meanse.coef1t=matrix(unlist(lapply(se.coef1,function(x){apply(x,2,mean)}),use.names=FALSE),byrow=TRUE,Nvar,Nc)
    
    colnames(meancoef1t)=names(fixef(modelt[[j]][[1]]))
    colnames(meanse.coef1)=names(fixef(model[[j]][[1]]))
    
    meancoeft=meancoef1t[,-1]
    
    plot(as.vector(A),as.vector(meancoeft))
    cor(as.vector(A),as.vector(meancoeft))
    
    Mt=matrix(0,20,20)
    for (j in 1:20){
      coll=colnL
      Mt[j,j]=mean(unlist(lapply(modelt[[j]],function(x){VV= diag(VarCorr(x)$pp)[2]})))# the self loop sd
      abd=which(coll[]==paste("y",j,"L",sep=""))
      coll=coll[-abd]
      Mt[j,-j]=unlist(lapply(modelt[[j]],function(x){VV= diag(VarCorr(x)$pp)[-1]}))[coll]# every row are the arrows to a node
      
    }
    
    Sigma_2=matrix(diag(Sigma),20,20,byrow=TRUE)
    
    plot(as.vector(Sigma_2),as.vector(Mt))
    cor(as.vector(Sigma_2),as.vector(Mt))
  }
  