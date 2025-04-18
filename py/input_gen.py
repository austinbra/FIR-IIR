
import os
os.makedirs("../data", exist_ok=True)
import numpy as np

#noisy sinusoidal input
x = np.sin(2 * np.pi * 0.01 * np.arange(100)) + 0.3 * np.random.randn(100)
x_fixed = np.round(x * (1 << 8)).astype(int)
np.savetxt("../data/input_samples.txt", x_fixed, fmt="%d")
print("Input samples are saved.")