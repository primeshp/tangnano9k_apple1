#!/usr/bin/env python3
import os
#To flash -- os.system("openFPGALoader -b tangnano9k -f ./build/top.fs")
os.system("openFPGALoader -b tangnano9k  ./build/top.fs")