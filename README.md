
# Overview

A simple Vivado project to test SDNet.

# Building

```
$ cd scripts/
$ vivado -mode batch -source build_proj.tcl
```

# Run Simulation

1. Open up the project with the Vivado GUI.
2. Click "Run Simulation" in the Flow Navigator.
3. Add signals of interest to the waveform.
4. Click "Run All" (the play button).
5. Inject packets into the simulation. For example:
```
$ cd sw/
$ sudo bash
# python send_lnic_pkts.py
```

