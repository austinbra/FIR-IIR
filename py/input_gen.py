import numpy as np
import os

# target directory relative to the project root
DATA_DIR = 'data'
os.makedirs(DATA_DIR, exist_ok=True)

# noisy sinusoidal signal
np.random.seed(0) # for reproducibility
x = np.sin(2 * np.pi * 0.01 * np.arange(100)) + 0.3 * np.random.randn(100)
x_fixed = np.round(x * (1 << 8)).astype(int) # Scale by 2^8

input_path = os.path.join(DATA_DIR, "input_samples.txt") # Use os.path.join
np.savetxt(input_path, x_fixed, fmt="%d")
print(f"Input samples saved to: {input_path}")

#a plot of the input signal
try:
    import matplotlib.pyplot as plt
    plt.figure(figsize=(10, 4))
    plt.plot(x)
    plt.title("Input Signal (Noisy Sinusoid)")
    plt.grid(True)
    
    # Create py_output dir if it dont exist
    py_output_dir = os.path.join(DATA_DIR, 'py_output')
    os.makedirs(py_output_dir, exist_ok=True)
    
    # Save it
    plt.savefig(os.path.join(py_output_dir, "input_signal.png"))
    plt.show()
    print("Input signal plot saved.")
except ImportError:
    print("Matplotlib not available, skipping plot generation.")
