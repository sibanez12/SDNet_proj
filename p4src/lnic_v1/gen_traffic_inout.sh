#!/bin/bash

SDNET_DIR=../../SDNet_proj/SDNet_proj.srcs/sources_1/ip/sdnet_0

python gen_traffic_in_pkts.py
run-p4bm-sdnet -p 9090 -l ./example_design -s ./cli_commands.txt -j ${SDNET_DIR}/main.json
