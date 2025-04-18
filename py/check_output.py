# py/check_output.py

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

x = np.loadtxt("../data/input_samples.txt") / (1 << 8)
fir_y = np.loadtxt("../data/fir_output.txt") / (1 << 15)
iir_y = np.loadtxt("../data/iir_output.txt") / (1 << 15)

#python sim
fir_coeffs = signal.firwin(numtaps=16, cutoff=0.1)
fir_expected = signal.lfilter(fir_coeffs, [1.0], x)

b, a = signal.iirfilter(2, 0.1, btype='low', ftype='butter')
iir_expected = signal.lfilter(b, a, x)

# Plot
plt.figure(figsize=(10, 6))
plt.subplot(2, 1, 1)
plt.plot(fir_expected, label="Python FIR")
plt.plot(fir_y, label="Verilog FIR", linestyle="--")
plt.title("FIR Filter Output")
plt.legend()
plt.grid(True)

plt.subplot(2, 1, 2)
plt.plot(iir_expected, label="Python IIR")
plt.plot(iir_y, label="Verilog IIR", linestyle="--")
plt.title("IIR Filter Output")
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.show()
