```markdown
# Fixed-Point FIR & IIR Digital Filters in Verilog

## Overview
This project implements both FIR (Finite Impulse Response) and IIR (Infinite Impulse Response) digital filters in Verilog, using fixed-point arithmetic suitable for FPGA or ASIC implementation. Filter coefficients and test signals are generated via Python scripts (`gen_coeff.py` and `input_gen.py`) using SciPy, then loaded into a Verilog testbench via file I/O (`$fopen`, `$fscanf`, `$fwrite`). Simulations are compiled and run with Icarus Verilog (`iverilog`/`vvp`).

## Features
- 2nd-order Butterworth IIR filter (Direct Form I) with Q15 coefficients  
- Simple FIR filter implementation for comparison  
- Python scripts to design filters and generate test vectors  
- Verilog testbench reads input samples and coefficients from text files  
- Outputs written to text files for post-processing or comparison  

## Prerequisites
- **Icarus Verilog** (`iverilog`, `vvp`) installed and on your PATH  
  - On Windows PowerShell:  
    ```powershell
    $env:Path += ";C:\iverilog\bin"
    ```
- **Python 3.x** with NumPy & SciPy:
  ```bash
  pip install numpy scipy
  ```

## Usage

1. **Generate filter coefficients**  
   Designs a 2nd-order Butterworth low-pass filter, scales to Q15, and writes `data/iir_coeffs.txt`:
   ```bash
   python py/gen_coeff.py
   ```

2. **(Optional) Generate input samples**  
   If your Python script is configured to produce `data/input_samples.txt`:
   ```bash
   python py/input_gen.py
   ```

3. **Compile Verilog testbenches**  
   ```bash
   iverilog -g2012 -o testbench/fir_tb.vvp \
       fir_filter.v testbench/fir_tb.v

   iverilog -g2012 -o testbench/iir_tb.vvp \
       iir_filter.v testbench/iir_tb.v
   ```

4. **Run simulations**  
   - FIR filter:
     ```bash
     vvp testbench/fir_tb.vvp > data/fir_output.txt
     ```
   - IIR filter:
     ```bash
     vvp testbench/iir_tb.vvp > data/iir_output.txt
     ```

5. **Debug tracing**  
   To capture debug prints from the IIR testbench:
   ```bash
   vvp testbench/iir_tb.vvp > iir_debug_output.txt
   ```

6. **Verify results**  
   Compare Verilog outputs against Python golden reference:
   ```bash
   python py/check_output.py
   ```

## How It Works

- **`gen_coeff.py`**  
  Uses SciPy’s `signal.iirfilter` to design a Butterworth IIR, scales numerator (`b`) and denominator (`a`) coefficients by 2¹⁵ (Q15), rounds to integers, and writes them to `data/iir_coeffs.txt`.

- **`iir_filter.v`**  
  Implements the IIR difference equation  
  ```verilog
  y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2]
         - a1*y[n-1] - a2*y[n-2]
  ```  
  All multiplies/accumulates in fixed-point and shifts right by 15 bits to compensate scaling.

- **`testbench/iir_tb.v`**  
  - Opens `data/iir_coeffs.txt` and `data/input_samples.txt` via `$fopen`.  
  - Reads coefficients and samples with `$fscanf`.  
  - Feeds samples to the filter each clock cycle.  
  - Writes outputs to `data/iir_output.txt` via `$fwrite`.  
  - Uses `$strobe` to print time, inputs, accumulator, and outputs for debugging.

## Next Steps
- Extend to variable filter orders or other filter types (high-pass, band-pass, Chebyshev, elliptic).  
- Implement cascaded biquad sections for higher-order stability.  
- Integrate input generation (`input_gen.py`) to produce sine waves, noise, or custom test patterns.

---

By following this workflow, you can rapidly prototype and verify fixed-point digital filters in Verilog, leveraging Python for coefficient design and test-vector generation.  
```
