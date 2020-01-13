@echo off
REM ****************************************************************************
REM Vivado (TM) v2018.2.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed May 29 11:07:57 -0400 2019
REM SW Build 2348494 on Mon Oct  1 18:25:44 MDT 2018
REM
REM Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
call xsim vga_driver_part3_1_tb_behav -key {Behavioral:sim_1:Functional:vga_driver_part3_1_tb} -tclbatch vga_driver_part3_1_tb.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0