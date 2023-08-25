#Prajeeth Babu Kodru
#22104071

import numpy as np;
import numpy.random as nr;
import matplotlib.pyplot as plt;
from scipy.stats import norm
blocklength=10000;#No. of symbols
nblocks=10000; #No. of blocks
No=1;#Noise power
Ebdb=np.arange(1,11.11,1); #array of 1 to 11
Eb= 10**(Ebdb/10); #symbol energy per bit in db scale
SNR=2*Eb/No;
SNRdb=10*np.log10(SNR); #conversion of SNR to dB
BER=np.zeros(len(Ebdb));    #Simulated BER
BERa=np.zeros(len(Ebdb));   #Analytical BER 

for i in range(nblocks):
 bitsi=nr.randint(2,size=blocklength);  #Random bits 0 and 1
 bitsq=nr.randint(2,size=blocklength);
 qpsk=(2*bitsi-1)+1j*(2*bitsq-1); #QPSK symbol generation
 n=nr.normal(0,np.sqrt(No/2),blocklength)+1j*nr.normal(0,np.sqrt(No/2),blocklength); #noise
 for j in range(len(Ebdb)):
  txs=np.sqrt(Eb[j])*qpsk;   #Transmitted signal
  rxs=txs+n; #received signal = transmitted + AWGN noise y=x+n
  Dbiti=(np.real(rxs)>0);#Decode inphase
  Dbitq=(np.imag(rxs)>0);
  BER[j]=BER[j]+np.sum(Dbiti!=bitsi)+np.sum(Dbitq!=bitsq);#Bit error rate
 
BER=BER/(2*blocklength*nblocks); #No. of bits 1000*1000*2
BERa=1-norm.cdf(np.sqrt(SNR));  #Analytical BER
plt.yscale('Log');  #to take log scale in y-axis
plt.plot(SNRdb,BER,'b')
plt.plot(SNRdb,BERa,'g--^') #green colour dashed line with triangle
plt.grid(1,which='both')
plt.suptitle('BER FOR AWGN')
plt.xlabel('SNR(db)')
plt.ylabel('BER')
plt.legend(["Simulated BER","Analytical BER"],loc ="lower left")
 
