# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import numpy as np
import matplotlib.pyplot as plt

blockLength=10000000;
nbins=1000;
h=(np.random.normal(0.0,1.0,blockLength)+1j*np.random.normal(0.0, 1.0, blockLength)); 
amp=np.abs(h)  #Take the absolute value
phi=np.angle(h)  #Take the angle

plt.figure(1)
plt.hist(amp,bins=nbins,density=True);
plt.suptitle('Rayleigh PDF')
plt.xlabel('x')
plt.ylabel('$f_A$(a)')

plt.figure(2)
plt.hist(phi,bins=nbins,density=True);
plt.suptitle('Phase PDF')
plt.xlabel('x')
plt.ylabel('$f_\Phi(\phi)$')
