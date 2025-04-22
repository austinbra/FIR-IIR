import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
import os # Import os module

# --- Configuration ---
#  directories relative to the project root
DATA_DIR = 'data'
PY_OUTPUT_DIR = os.path.join(DATA_DIR, 'py_output') # Define the new output dir

# Create the py_output directory if it doesn't exist
os.makedirs(PY_OUTPUT_DIR, exist_ok=True)
print(f"Ensured directory exists: {PY_OUTPUT_DIR}")

# Input/Output Files using os.path.join
INPUT_FILE = os.path.join(DATA_DIR, "input_samples.txt")
FIR_OUT_FILE = os.path.join(DATA_DIR, "fir_output.txt")
IIR_OUT_FILE = os.path.join(DATA_DIR, "iir_output.txt")

# python out
PY_FIR_EXPECTED_FILE = os.path.join(PY_OUTPUT_DIR, "fir_expected.txt")
PY_IIR_EXPECTED_FILE = os.path.join(PY_OUTPUT_DIR, "iir_expected.txt")

# --- Scaling Factors (should match  latest Verilog & gen script) ---
INPUT_SCALE_BITS = 8
INPUT_SCALE = 1 << INPUT_SCALE_BITS

FIR_COEFF_SCALE_BITS = 15
FIR_OUTPUT_SCALE_BITS = INPUT_SCALE_BITS + FIR_COEFF_SCALE_BITS # 8 + 15 = 23
FIR_OUTPUT_SCALE = 1 << FIR_OUTPUT_SCALE_BITS

IIR_COEFF_SCALE_BITS = 15
IIR_OUTPUT_SCALE_BITS = INPUT_SCALE_BITS # 8 (Based on corrected Verilog)
IIR_OUTPUT_SCALE = 1 << IIR_OUTPUT_SCALE_BITS

# --- Load Data ---
print(f"Loading input: {INPUT_FILE}")
x_fixed = np.loadtxt(INPUT_FILE)
x = x_fixed / INPUT_SCALE # Unscale input

print(f"Loading Verilog FIR output: {FIR_OUT_FILE}")
fir_y_fixed = np.loadtxt(FIR_OUT_FILE)
fir_y = fir_y_fixed / FIR_OUTPUT_SCALE # Unscale Verilog FIR output

print(f"Loading Verilog IIR output: {IIR_OUT_FILE}")
iir_y_fixed = np.loadtxt(IIR_OUT_FILE)
iir_y = iir_y_fixed / IIR_OUTPUT_SCALE # Unscale Verilog IIR output

# --- Python reference Calculation ---
print("Calculating Python FIR reference...")
fir_coeffs_float = signal.firwin(numtaps=16, cutoff=0.1) # Use float coeffs
fir_expected = signal.lfilter(fir_coeffs_float, [1.0], x)

print("Calculating Python IIR reference...")
b_float, a_float = signal.iirfilter(2, 0.1, btype='low', ftype='butter') # Use float coeffs
iir_expected = signal.lfilter(b_float, a_float, x)

# --- Save Python Reference Data ---
# Use a float format specifier like "%f" or scientific notation "%e"
np.savetxt(PY_FIR_EXPECTED_FILE, fir_expected, fmt="%f")
print(f"Saved Python FIR expected output to: {PY_FIR_EXPECTED_FILE}")
np.savetxt(PY_IIR_EXPECTED_FILE, iir_expected, fmt="%f")
print(f"Saved Python IIR expected output to: {PY_IIR_EXPECTED_FILE}")


# --- Plotting ---
print("Generating plot...")
plt.figure(figsize=(12, 8))

# Plot FIR filter results with unfiltered data
plt.subplot(2, 1, 1)
plt.plot(x, label="Unfiltered Input", color='gray', alpha=0.7)
plt.plot(fir_expected, label="Python FIR Ref", color='blue')
plt.plot(fir_y, label="Verilog FIR Out", linestyle="--", color='red')
plt.title("FIR Filter Output Comparison")
plt.legend()
plt.grid(True)

# Plot IIR filter results with unfiltered data
plt.subplot(2, 1, 2)
plt.plot(x, label="Unfiltered Input", color='gray', alpha=0.7)
plt.plot(iir_expected, label="Python IIR Ref", color='blue')
plt.plot(iir_y, label="Verilog IIR Out", linestyle="--", color='red')
plt.title("IIR Filter Output Comparison")
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig(os.path.join(PY_OUTPUT_DIR, "filter_comparison.png"))
plt.show()
print("Plot displayed and saved.")
