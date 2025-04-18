import os
import numpy as np
from scipy import signal

#os.makedirs("../data", exist_ok=True)
#fir
fir_coeffs = signal.firwin(numtaps=16, cutoff=0.1)
fir_fixed = np.round(fir_coeffs * (1 << 15)).astype(int)
np.savetxt("../data/fir_coeffs.txt", fir_fixed, fmt="%d")

#iir
b, a = signal.iirfilter(2, 0.1, btype='low', ftype='butter')
iir_fixed = np.round(np.array([b[0], b[1], b[2], a[1], a[2]]) * (1 << 15)).astype(int)
np.savetxt("../data/iir_coeffs.txt", iir_fixed, fmt="%d")
