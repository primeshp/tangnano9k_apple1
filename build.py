#!/usr/bin/env python3

from migen import *
from litex.build.generic_platform import *
from litex.build.gowin.platform import GowinPlatform
from uart import UART
from math import log2
from migen.genlib.resetsync import AsyncResetSynchronizer


# Make sure gowin tools are in the PATH using "export PATH=$PATH:~/gowin/IDE/bin"
# FTDI Connections FTDI TX(Orange) -->FPGA 25, FTDI RX(Yellow) -->FPGA 26, FTDI CTS(Brown) -->FPGA 27
# Apple Test Program 0: A9 0 AA 20 EF FF E8 8A 4C 2 0 <return>
# To cold start BASIC E000R, to Warm Start BASIC  E2B3R
 


#  Constants
RAM_SIZE       = 0x8000  # 32KB of RAM starting from 0x0000 - 15 bit Address
WOZMON_START   = 0xFF00  # 256 Bytes ROM starting from FF00 - 8 Bit Address
BASIC_START    = 0xE000  # BASIC ROM Start Address
BASIC_SIZE     = 0x1000  # BASIC ROM Size 4K
KBD            = 0xD010  # Keyboard register
KBDCR          = 0xD011  # Keyboard Control
DSP            = 0xD012  # Display Register
DSPCR          = 0XD013  # Display Control Register
LEDREG         = 0xD014  # LED Control Register...write only

#Read the WOZMON ROM
with open("./software/wozmon.bin",mode='rb') as file:
    wozmon_content = bytearray(file.read())
print("Read the file sucessfully")


#Read the BASIC ROM
with open("./software/a1basic.bin",mode='rb') as file:
    basic_content = bytearray(file.read())
print("Read the file sucessfully")


# IOs ----------------------------------------------------------------------------------------------

_io = [
    # Leds
    ("user_led", 0, Pins("10"), IOStandard("LVCMOS18")),
    ("user_led", 1, Pins("11"), IOStandard("LVCMOS18")),
    ("user_led", 2, Pins("13"), IOStandard("LVCMOS18")),
    ("user_led", 3, Pins("14"), IOStandard("LVCMOS18")),
    ("user_led", 4, Pins("15"), IOStandard("LVCMOS18")),
    ("user_led", 5, Pins("16"), IOStandard("LVCMOS18")),

    ("user_btn", 0, Pins("3"), IOStandard("LVCMOS33")),

    ("clk27", 0, Pins("52"), IOStandard("LVCMOS33")),
    ("cpu_reset", 0, Pins("4"), IOStandard("LVCMOS33")),
    
    # This is the UART based Serial. This does not have HW Flow Control
    #("serial", 0,
    #    Subsignal("rx", Pins("18")),
    #    Subsignal("tx", Pins("17")),
    #    IOStandard("LVCMOS33")
    #),
    
    ("serial", 0,
        Subsignal("rx", Pins("25")),
        Subsignal("tx", Pins("26")),
        Subsignal("rts_n", Pins("27")),
        Subsignal("cts_n", Pins("28")),
       IOStandard("LVCMOS33")
    ),
  
]


# Platform -----------------------------------------------------------------------------------------

class Platform(GowinPlatform):
    default_clk_name   = "clk27"
    default_clk_period = 1e9/27e6
    
    def __init__(self,toolchain="gowin"):
        GowinPlatform.__init__(self, "GW1NR-LV9QN88PC6/I5", _io, toolchain=toolchain, devicename="GW1NR-9C")
        self.toolchain.options["use_mspi_as_gpio"] = 1


# Design -------------------------------------------------------------------------------------------

platform = Platform()
leds =[]
for i in range(6):
    leds.append(platform.request("user_led",i))
    

platform.add_source("verilog-6502/cpu_65c02.v")  
platform.add_source("verilog-6502/ALU.v")  

sys_clk_freq = int(27e6)
serial0 = platform.request("serial")
rst_n = platform.request("cpu_reset", 0)



class soc_6502(Module):
    
    def __init__(self): 

        clk       = Signal()
        reset_sig = Signal()
        AB        = Signal(16)
        DI        = Signal(8)
        DO        = Signal(8)
        WE        = Signal()
        IRQ       = Signal(reset=0)
        NMI       = Signal(reset=0)
        RDY       = Signal(reset=1) # Ready signal. Pauses CPU when RDY=0 
        SYNC      = Signal()
        
        
        cpu_clk_sig =Signal()
        cpu_clk_sig = ClockSignal(cd="sys" )
        reset_sig = ResetSignal(cd="sys" )
        
        
        # Create 6502 CPU & UART -------------------------------------------------------------------------------------------
        self.specials.cpu = Instance("cpu_65c02",i_clk=cpu_clk_sig,i_reset=~rst_n,o_AB = AB, i_DI=DI, o_DO=DO, o_WE=WE, i_IRQ=IRQ, i_NMI=NMI , i_RDY=RDY,o_SYNC=SYNC)
        uart = UART(serial=serial0, clk_freq=int(sys_clk_freq),baud_rate=115200)
        self.submodules += uart 
        
       
        # Create ROM for WOZMON -------------------------------------------------------------------------------------------
        wozmonrom              = Memory(width=8,depth=0x100,init=wozmon_content) 	   #ROM will be from 0xFF00-0xFFFF bottom 256B
        wozmonrom_rd_port      = wozmonrom.get_port(async_read=True)
        self.specials         += [wozmonrom ,wozmonrom_rd_port]
        
        # Create RAM Memory -------------------------------------------------------------------------------------------
        ram                    = Memory(width=8,depth=RAM_SIZE) 	                    #RAM will be from 0x0000-0x1FFF 8KB
        ram_rd_port            = ram.get_port(async_read=True)
        ram_wr_port            = ram.get_port(write_capable=True)
        self.specials         += [ram,ram_rd_port,ram_wr_port]
        
        # Create BASIC ROM
        basic                    = Memory(width=8,depth=BASIC_SIZE,init=basic_content) 	#Basic ROM is in 0xE000-0xEFFF 4K
        basic_rd_port            = basic.get_port(async_read=True)
        self.specials         += [basic,basic_rd_port]
            
        # Connect Reset and Clock -------------------------------------------------------------------------------------
        self.comb +=[
            clk.eq(ClockSignal(cd='sys')), 
            reset_sig.eq(ResetSignal(cd='sys'))
        ]
        
        
        ram_addr_width = int(log2(RAM_SIZE))
        basic_addr_width = int(log2(BASIC_SIZE))
        
        # Connect Memory to Address and Data bus ------------------------------------------------------------------------
        self.comb +=[wozmonrom_rd_port.adr.eq(AB[0:8]),
                     ram_rd_port.adr.eq(AB[0:ram_addr_width]),
                     basic_rd_port.adr.eq(AB[0:basic_addr_width]),
                     ram_wr_port.dat_w.eq(DO)           
                     ] 
        
        self.comb +=[If((AB<RAM_SIZE),ram_wr_port.we.eq(WE),ram_wr_port.adr.eq(AB[0:ram_addr_width]))] 
      
        
        # Modify the keyboard inputs to match Wozmon (all Uppercase, Backspace replaced by _ and all characters have MSB set)
        mod_keyboard = Signal(8)
        self.comb +=[ If((uart.rx_data[0:7]>96) &(uart.rx_data[0:7]<123),mod_keyboard.eq(uart.rx_data[0:7]-32)). # Lower case converted to Upper case
                     Else(mod_keyboard.eq(uart.rx_data[0:7]))]                                                   # Upper case
        


        #RAM,ROM and IO Read
        self.sync +=[
                    If((~WE) & (AB>(WOZMON_START-1)), DI.eq(wozmonrom_rd_port.dat_r)),
                    If((~WE) & (AB<RAM_SIZE), DI.eq(ram_rd_port.dat_r)),
                    If((~WE) & (AB>(BASIC_START-1)) & (AB<(BASIC_START+BASIC_SIZE+1)), DI.eq(basic_rd_port.dat_r)),
                    If((~WE) & (AB==KBD),DI.eq(mod_keyboard|(0b1<<7)),uart.rx_ack.eq(1)).Else(uart.rx_ack.eq(0)),
                    If((~WE) & (AB==KBDCR),DI.eq(uart.rx_ready<<7 | 0b0000001)),
                    If((~WE) & (AB==DSP),DI.eq((~uart.tx_ack)<<7))                         
        ]
        
        #IO Writes
        self.sync +=[
                    If(WE & (AB==0xD014),
                       leds[0].eq(~DO[0]), leds[1].eq(~DO[1]),
                       leds[2].eq(~DO[2]), leds[3].eq(~DO[3]),leds[4].eq(~DO[4]),leds[5].eq(~DO[5])),
                    If(WE & (AB==DSP), uart.tx_data.eq(Cat(DO[0:7],0b0)),uart.tx_ready.eq(1)).Else(uart.tx_ready.eq(0))    
                     
        ]
        
        self.comb +=[serial0.rts_n.eq(~uart.canreceive)] #If UART in middle of RX ot TX signal busy

 
# Create our module (fpga description)
module = soc_6502()


# Build --------------------------------------------------------------------------------------------

platform.build(module)
