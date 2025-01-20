# Microchip FPGA UJTAG Tutorial

1/15/2025 D. W. Hawkins (dwh@caltech.edu)

## Introduction

This repository contains a Microchip UJTAG tutorial.

Directory           | Contents
--------------------|-----------
doc                 | Tutorial document
designs             | Libero SoC designs
ip                  | Intellectual Property (IP)
stp                 | STAPL scripts
references          | Reference documentation

# Git LFS Installation

This repository was created using the github web interface, then checked out using Windows 10 WSL, and git LFS was installed using

~~~
$ git clone git@github.com:d-hawkins/microchip_jtag_tutorial.git
$ cd microchip_jtag_tutorial/
$ git lfs install
~~~

The .gitattributes file from another repo was then copied to this repo, and that file checked in.

~~~
$ git add .gitattributes
$ git commit -m "Git LFS tracking" .gitattributes
$ git push
~~~

The .gitattributes file contains file extension patterns for the majority of binary file types that could be checked into the repo (additional patterns can be added as needed).

