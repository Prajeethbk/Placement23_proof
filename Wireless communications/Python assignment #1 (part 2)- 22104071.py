#Prajeeth Babu Kodru
#22104071

import numpy as np;
import numpy.random as nr;
import matplotlib.pyplot as plt;

blocklength=1000;
nblocks=1000;
No=1;
Ebdb=np.arange(5,61,4);
Eb= 10**(Ebdb/10);
SNR=2*Eb/No;
SNRdb=10*np.log10(SNR);
BER=np.zeros(len(Ebdb));    #Simulated BER initialization
BERa=np.zeros(len(Ebdb));   #Analytical BER initialization
for blk in range(nblocks):
 bitsi=nr.randint(2,size=blocklength);  #Random values 0,1
 bitsq=nr.randint(2,size=blocklength);
 qpsk=(2*bitsi-1)+1j*(2*bitsq-1);   #QPSK generation
 n=nr.normal(0,np.sqrt(No/2),blocklength)+1j*nr.normal(0,np.sqrt(No/2),blocklength);
 h=nr.normal(0,np.sqrt(No/2),blocklength)+1j*nr.normal(0,np.sqrt(No/2),blocklength);
 for k in range(len(Ebdb)):
  t_s=np.sqrt(Eb[k])*qpsk;  #transmitted signal
  r_s=h*t_s+n;  #received signal=Transmitted signal + noise
  eqsy=1/h*r_s;
  Rbiti=(np.real(eqsy)>0);
  Ibitq=(np.imag(eqsy)>0);
  BER[k]=BER[k]+np.sum(Rbiti!=bitsi)+np.sum(Ibitq!=bitsq); 
 
BER=BER/(2*blocklength*nblocks);
BERa=0.5*(1-np.sqrt(SNR/(2+SNR)));  #Average BER
plt.yscale('Log'); 
plt.plot(SNRdb,BER,'b')
plt.plot(SNRdb,BERa,'g--^')
plt.grid(1,which='both')
plt.suptitle('BER FOR RAYELIGH FADING')
plt.xlabel('SNR(db)')
plt.ylabel('BER')
plt.legend(["Simulated BER","Analytical BER"],loc ="lower left") 
