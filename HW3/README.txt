Update: 2020/11/13
This testbench supports RTL and SYN

============ Files Description ==============

  Netlist/			-- For synthesis output files
  pattern/			-- RTL&SYN pattern files
    - instruction					-- Instructions generate by RARS 64 bit mode
    - instruction_format_ans.txt	-- Testbench answer
    - instruction_type_ans.txt		-- Testbench answer
  Report/			-- For synthesis output report files
  sample/			-- Some RTL example
	- findmax/		-- Run it: ncverilog testfixture.v findmax.v +access+r
	- matvec2x2/	-- Run it: ncverilog testfixture.v matvec2x2.v +access+r +define+tb1 +notimingchecks
  .cshrc			-- enovironment file for csh mode(Put it at the top folder of your work station)
  .synopsys_dc		-- file for synthesis
  CHIP.v			-- Your HW main file
  CHIP_syn.sdc		-- Constraints for synthesis
  decoder_tb		-- Testbench for RTL and Synthesis
  run.tcl			-- tcl file for synthesis
  README

============ Environment Setting ==============
Source (environment in NTU):
    >	source /usr/cad/cadence/cshrc
    >	source /usr/cad/synopsys/CIC/verdi.cshrc
    >	source /usr/cad/synopsys/CIC/synthesis.cshrc

	or put the .cshrc file in your top folder ./b07xxx/.cshrc, it will source automatically next time you log in.

RTL simulation:
    >	ncverilog decoder_tb.v +define+RTL +access+r
    
--------------------------------------------------------------------------
Files for synthesis:
- .synopsys_dc.setup
- CHIP_syn.sdc

Synthesis command:
- Open Design Compiler:
    > dc_shell
- In Design Compiler:
    dc_shell> source run.tcl
	or run the tcl file line by line to prevent setting error

- Check if your design passes timing slack:
    dc_shell> report_timing
- Check area:
    dc_shell> report_area
- Close Design Compiler:
    dc_shell> exit
    
--------------------------------------------------------------------------
Post-synthesis simulation:
- Check if you have a SDF file in Netlist folder (CHIP_syn.sdf)
- Check if you have a library file (tsmc13.v)
- Note: To copy tsmc13.v to your current directory (environment in NTU):
    >   cp /home/raid7_2/course/cvsd/CBDK_IC_Contest/CIC/Verilog/tsmc13.v .

- Run:
    >	ncverilog decoder_tb.v +define+SYN +access+r