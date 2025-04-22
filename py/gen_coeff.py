import numpy as np
from scipy import signal
import os


#thinking about making this variable and have cheby1, cheby2, butterworth, and elliptic filters
#might calcualte coeffs with math

#If phase linearity is critical and ripples are unacceptable: Butterworth (higher order might be needed).
#If a steep transition band is needed for a limited order and some passband ripple is acceptable: Chebyshev Type I.
#If a steep transition band is needed and passband flatness is critical, but stopband ripple is acceptable: Chebyshev Type II.
#If minimizing filter order is the absolute priority, and both passband and stopband ripples, as well as non-linear phase, are acceptable: Elliptic.

# target directory relative to the project root
DATA_DIR = 'data'
os.makedirs(DATA_DIR, exist_ok=True)
fir_coeff_path = os.path.join(DATA_DIR, "fir_coeffs.txt")

# --- FIR ---
print(f"Saved FIR coefficients to: {fir_coeff_path}")

# --- IIR ---
print("Calculating IIR coefficients...")
b, a = signal.iirfilter(2, 0.1, btype='low', ftype='butter')
print(f"  SciPy float b: {b}")
print(f"  SciPy float a: {a}")

coeffs_to_scale = np.array([b[0], b[1], b[2], a[1], a[2]])

# Scale by 2^15
scaled_coeffs = coeffs_to_scale * (1 << 15)

# Round and convert to standard Python intes
iir_fixed = np.round(scaled_coeffs).astype(int)
print(f"  Calculated fixed-point coeffs (decimal): {iir_fixed}") # should show [-51151, 21016] for a1, a2

# Define path and save as decimal ints
iir_coeff_path = os.path.join(DATA_DIR, "iir_coeffs.txt")
np.savetxt(iir_coeff_path, iir_fixed, fmt="%d")
print(f"Saved IIR coefficients (DECIMAL) to: {iir_coeff_path}")
