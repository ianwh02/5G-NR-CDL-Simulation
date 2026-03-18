# Simulation Code

This folder contains all simulation code for the 5G NR downlink end-to-end framework. All scripts require the MATLAB helper functions in the same directory.

## Main Scripts

| Script | Description |
|--------|-------------|
| `pp_throughput_withCSIwithHARQwithsubarray.m` | **Final version** — Option 1Y with 512-element subarray virtualisation |
| `throughput_withCSIwithHARQ.m` | Option 3 with HARQ, CSI feedback, and channel estimation |
| `throughput_withCSInoHARQ.m` | Baseline without HARQ (used to measure HARQ performance impact) |
| `pp2_throughput_withCSIwithHARQ.m` | 8-layer dual-codeword variant with imperfect channel estimator (50 frames) |
| `pp3_throughput_withCSIwithHARQ.m` | TDL-C channel variant with TDL compatibility handling |
| `plotPerformanceMetrics.m` | Post-processing: loads `.mat` files from `results/` and plots throughput/BLER figures |
