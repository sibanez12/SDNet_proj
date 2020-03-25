#!/bin/bash

sudo ip tuntap add mode tap dev tap0
sudo ip link set tap0 up
