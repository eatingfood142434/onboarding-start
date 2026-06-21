<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project describes an SPI peripheral module which is used to control a PWM module. It takes in COPI, nCS, and SCLK from an SPI controller. The COPI is then read in 16 bit chunks via a shift register, which is then used to communicate to the PWM module and control things like which pins are active, which pins have PWM mode on, and the duty cycle of the PWM signal.

## How to test

Cocotb is used for testing. Install Icarus Verilog and Cocotb, then run make -B in the /test folder to run the tests in test.py.

## External hardware

No external hardware is used.
