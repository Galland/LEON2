Leon project for Avnet Xilinx V2P20 Development Board
Author: Michele Portolan, TIMA Laboratory, portolan@imag.fr
Last Modified 7 October 2004


This release is composed of five files:

	leon_avnet.npl: ISE 6.3.01i project file
	leon_avnet.vhd: Wrapper for Leon to adapt it the board requirements
	leon_avnet.ucf: Pin Mapping file
	leon_avnet.cdf: Configuration file for Impact
	leon_avnet.xcf: User constraint file. Could be used to enable Incremental Synthesis (default is off)
	
So far I had not been able to make a working Makefile for command-line synthesis: I always get error from "par"