# heart-blockage-detection-fnn
Feedforward Neural Network-based ECG analysis system for heart blockage detection using AD8232 sensor data and MATLAB.
#  Heart Blockage Detection using Feedforward Neural Network (FNN)

This repository contains the MATLAB implementation, ECG dataset structure, and final report for a heart blockage detection system using a Feedforward Neural Network (FNN). The project uses real-time ECG signals acquired from the AD8232 sensor and applies machine learning techniques to classify heart conditions.

---

##  Project Overview

Cardiovascular diseases, especially heart blockages, require early and accurate detection to reduce mortality. This project proposes an automated ECG classification system using a Feedforward Neural Network to detect:
- 1st-degree heart block
- 2nd-degree heart block
- 3rd-degree heart block
- Normal ECG rhythm

The model is trained on a clean, labeled dataset of ECG recordings collected using the AD8232 sensor and achieves **96.3% test accuracy**.

---

##  Features Used

The input to the FNN consists of the following statistical features extracted from the ECG data:
- Average Heart Rate (bpm)
- Median Heart Rate
- Mean ECG Amplitude
- Standard Deviation of ECG Amplitude

---

##  Technologies Used

- **MATLAB R2023a**
  - Deep Learning Toolbox
  - Signal Processing Toolbox
  - Statistics and Machine Learning Toolbox
- **Hardware:**
  - AD8232 ECG Sensor
  - Arduino Uno (for data acquisition)
- **Dataset Format:** Excel (.xlsx/.csv)
- **System Specs:**
  - AMD Ryzen 5 5600H
  - 16 GB RAM
  - NVIDIA GeForce RTX 2050
  - Windows 11 (64-bit)

---

##  Repository Structure

