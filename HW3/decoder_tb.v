// this is a test bench feeds initial instruction and data
// the processor output is not verified

`timescale 1 ns/10 ps

`define CYCLE 5 // You can modify your clock frequency
`define END_CYCLE 30 // You can modify your maximum cycles
`define PAT_LENGTH 23

`define IMEM_INIT   "./pattern/instruction.txt"
`define ITYPE_ANS  "./pattern/instruction_type_ans.txt"
`define IFORMAT_ANS "./pattern/instruction_format_ans.txt"

`ifdef RTL
	`include "CHIP.v"
`elsif SYN
	`include "./Netlist/CHIP_syn.v"
	`include "tsmc13.v"
	`define SDF
	`define SDFFILE "./Netlist/CHIP_syn.sdf"
`endif

module RISCV_tb;

    reg         clk, rst_n ;

    wire [31:2] mem_addr_I ;
    wire [31:0] mem_rdata_I;
	wire [22:0] instruction_type;
	wire [ 4:0] instruction_format;
    
    reg  [31:0] mem_data_ans [0:31];
	reg  [ 4:0] mem_IFORMAT[0:`PAT_LENGTH-1];
	reg  [22:0] mem_ITYPE[0:`PAT_LENGTH-1];
    integer i, k, error_num;

    CHIP chip0(
        clk,
        rst_n,
        // for mem_I
        mem_addr_I,
        mem_rdata_I,
		// for result output
		instruction_type,
		instruction_format);

    // Instruction memory
	ROM128x32 i_rom(
		.addr(mem_addr_I[8:2]),
		.data(mem_rdata_I)
	);

    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, chip0);
    `endif
	
    initial begin
        $fsdbDumpfile("RISCV.fsdb");            
        $fsdbDumpvars(0,RISCV_tb,"+mda");

        $display("------------------------------------------------------------");
        $display("START!!! Simulation Start .....");
        $display("------------------------------------------------------------\n");
		$display("                        Correct ans              Your ans");
        clk = 1;
        rst_n = 1'b1;
		error_num = 0;
		k = 0;
        #(`CYCLE*0.5) rst_n = 1'b0;
        #(`CYCLE*2.0) rst_n = 1'b1;

		$readmemb (`IFORMAT_ANS, mem_IFORMAT);
		$readmemb (`ITYPE_ANS,  mem_ITYPE);

        #(`CYCLE*`END_CYCLE)
        $display("============================================================\n");
        $display("Simulation time is longer than expected.");
        $display("The test result is .....FAIL :(\n");
        $display("============================================================\n");
        $finish;
    end
	

	always @(negedge clk) begin
		if (mem_addr_I > 1'b0) begin
			if (mem_IFORMAT[k] !== instruction_format) begin
				error_num = error_num + 1;
				$display("Error!   Execution %2d                     %b                    %b", k+1, mem_IFORMAT[k], instruction_format);
			end
			else
				$display("Success! Execution %2d                     %b                    %b", k+1, mem_IFORMAT[k], instruction_format);
			if (mem_ITYPE[k] !== instruction_type) begin
				error_num = error_num + 1;
				$display("Error!   Execution %2d   %b  %b", k+1, mem_ITYPE[k], instruction_type);
			end
			else
				$display("Success! Execution %2d   %b  %b", k+1, mem_ITYPE[k], instruction_type);
			k = k + 1;
		end
		if (k>=`PAT_LENGTH) begin
			if( error_num > 0 )begin
				$display("============================================================\n");
				$display("    FAIL! There are %02d errors at functional simulation !   \n", error_num);
				$display("============================================================\n");
			end
			else begin
			`ifdef RTL
				$display("===========================================The RTL result is PASS===========================================");
				$display("                                                     .,*//(((//*,.                                ");          
				$display("                                             *(##((((((((((((###((((((##(.                                  ");
				$display("                                       ./##((#####(((((((O*      .(#(((((((##*                              ");
				$display("                                   ./#((((O.       *O(((#           /((((((((((#(                           ");
				$display("                                 ##(((((#.           (##             *#(((((((((((#,                        ");
				$display("                              *#(((((((#/             //              *(((((((((((((#*                      ");
				$display("                            /((((((((((#    (@&        (  .(/*(,       #((((((((((((((#,                    ");
				$display("                          /(((((((((((((   ,& ((       O (.     (      (.*/##(((((((((((#                   ");
				$display("                        .#(((((((((((((#   .&O       O/              /       #O#(((((((#,                 ");
				$display("                       (#(((((((((((#(,**    (/        **.            /    .(*     ##(((((#.                ");
				$display("                      /((((((((((#,     ,,           (OOOOOO/       ,/  .(,          (#((((#,               ");
				$display("                     #(((((#OOO*          **       ,OOO/*#OOO&(((/,  *(           ,(/. #((((#               ");
				$display("                    ,(((((((#.   .*(/.       .,**,.#OO#  /OOOO(   */.        ,(/.  .,*, ,((((/              ");
				$display("                   .#((((((/           .*(/.       /OOOOOOOOOO,         .(/.     (.     .((#,             ");
				$display("                   ((((((#*                         .OOOOOOOO      .//,                   ,(((#             ");
				$display("                   #((((#.    ..,*/((((/*..             .(.                                #((#             ");
				$display("                   #(((#/,((/(/                          /,          ((//**,,...           #((#.            ");
				$display("                   #(((O*              .,/(/             ,/                               .##(#.            ");
				$display("                   #((#      .*((/*.                      (                              /**#(#*/((/*       ");
				$display("                   #((O  ..                               ( .,,**///**,,..             (/  *#(#       ,*    ");
				$display("                   #(((*                           ,/#OOOOOOOOOOOOOOOOOOOOOOOOOOOO&/,      (((O         (   ");
				$display("                   /#((O(                   ,(OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO(        O(#(          ,  ");
				$display("                   .#((#,,(.         .*#OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO(        ,((#.         .,  ");
				$display("                    ,(((O     ..,&OO)OOO              Success! !!         OO)OOOO         #((,          (   ");
				$display("                     #(((/       .OOOOOOOOOOOOOOOOOOOOOOO#(//////////((OOOOOOOO(         #((O(.       /,    ");
				$display("                      (((#(        /OOOOOOOOOOOO&O(/////////////////////////#&(         ,((O((((##O/,       ");
				$display("                       #(((*         (OOOOOOO(//////////////////////////////#.         *#(O(((((((#         ");
				$display("                        *(((#          /OO#///////////////////////////////(*          ,#(O(((((((#*         ");
				$display("                         .#((#.          .((////////////////////////////(/           /##O((((((((/          ");
				$display("                           /#((*            .##//////////////////////(#.            ((#(((((((((#           ");
				$display("            ,(*...,(*        (#(#,              .(#(/////////////(#/.              O(#(((((((((#            ");
				$display("          ,,         ,(        /O(#,                   ..,,,,.     ..,*//(##OOOOOOO&((((((((((#             ");
				$display("         *,            *         .(#((.      ..,,*/(##OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO((((((((((              ");
				$display("         (             #(((((####(//OOOOOOOOOOOOOOOOOOOO#OO*..,,**((/*,..  *O((((((((((((#/               ");
				$display("         /,            #(((((((((((((((#O&OOOO&(/*,...   #/,.,*((((((.         /#(((O(((((#.                ");
				$display("          *.         .#((((((((((((((((((((((/          /(*..,(O#,..*.           #((#((((/                  ");
				$display("            */,   .(O((((((((((((((((((((((#*            (.../OO#...(            ,O((#(#.                   ");
				$display("                   .(#(((((((((((((((((((((,             .(....(*..#.             /((O.                     ");
				$display("                       /##((((((((((((((((#                 ,((#(,                .#(#      ,/(((*.         ");
				$display("                           ,(##((((((((((#(                .,*/(((((///********#   O(#   //        ,(       ");
				$display("                                .(##(((((#/    .*((/*..                        (.  O(#./*            /*     ");
				$display("                                    (((((((    ,                               (   #(OO               ,.    ");
				$display("                                   ,O(((((#    (.                             ,.  ((((                 (    ");
				$display("                               *(..OO((((((O.   (                            **  #((#                  /.   ");
				$display("                             /*  /#(O(((((((#,   /*                         (  .#((O.                  *,   ");
				$display("                           ,(   .#((((((((((((#,   //                    *(   (((((/                   /,   ");
				$display("                          ,.    ((((((((((((((((#(.   *(/.         .,/(,   *O(((((#.                   (.   ");
				$display("                         /*     #((((((((((((((((((#O/,                ,(#((((((((O                    /    ");
				$display("                         *      #((((((((((((((((((((((((#########O##(((((((((((((#                   *     ");
				$display("                        /       ((((((((((((((((((((((((((((((((((((((((((((((((((#.                 ,/     ");
				$display("                        (        #(((((((((((((((((((((((((((((((((((((((((((((((((/                .*      ");
				$display("                        (         (((((((((((((((((((((((##(/*,..        ..,*((###(#/              /*       ");
				$display("                        *           .##(((((((((((###*.                              (           *(         ");
				$display("                         /                  (                                          /(,...,//.           ");
				$display("                          *.              /.                                                                ");
				$display("                            */.       .(/                                                                   ");
				$display("                                .,,,.                                                                       ");
			`elsif SYN
				$display("======================================The SYN result is PASS======================================");
				$display("	                                          */((/,**/*/*                                          ");
				$display("                              ..     .,(#((8@@8@88OO/*/#(/.                                       ");
				$display("                          *(#OO##((#8O88@8###O(OO((/***,/(.                                       ");
				$display("                         /#O*/**/#O888O,8#,#(8@8*O((///*#/,                                       ");
				$display("                        .(O#*//#O##O####88#O#O#(/*/(##(/(/.                                       ");
				$display("                         *##8#((#####,/88888888888888O ,#((*                                      ");
				$display("                           ,(###O#,,/@@@@@@@@@@@@@@888...(((/                                     ");
				$display("                           /##OOO****#8@@@@@@@@@888@8,... #((,                                    ");
				$display("                           ##OO8/*//////@@@@@@@@@8@**,.,,.O#(.                                    ");
				$display("                           O#8O8(/((#(/*//****//****,,**,.###                                     ");
				$display("                           (O8OO8(/((###((////////(8(,,,.(#((.                                    ");
				$display("                         ./O888888#((((///O@@88OO#(,,,,,/##(#(*                                   ");
				$display("                      ,(O8O888888888(((((///*********,,#####OO((,                                 ");
				$display("                  ./((##OO888888888888@O#(//(/((////#O#((#(#O#((((*                               ");
				$display("             .(#(#####(###O888OOO8##OOO##O88888O#(///****((##8O##((/(.                            ");
				$display("          ,/#(##(##O###(###OOO(##((///(///(/****,**,,,****/##O8O8#(((//,                          ");
				$display("        /#(####(##OOO##O##88O#O##(/***,***//*/*,*.,,,,*****,#((8OOO#(((/*                         ");
				$display("       (####OO(/(#/*//(#OOOO8OO(//**//***,*,**,,,,,,*,,,,.,,,##O88OO##(#(*                        ");
				$display("       .#(###((((((/***#(888OOOO#((/(**,,***,***,.,,*,*,.,,*,/O8#(8O###((/,                       ");
				$display("          ,OO#OOOOOO#*  OOOOO#(#(//***,*****.*,,,,*,,,,...,,,*#O#(###(((//.                       ");
				$display("               8#((     *OOO#####*/******,,,,*/*,,.,.,,,.,.,.#O/(/##(/(#(*                        ");
				$display("               /O((      (8OOOOOOO*//*(/***,***/*,*,..,.,*,,(#O* *(#(#((*                         ");
				$display("               .O#(.     .O88888OOOO(((///**/////***,,**,/(##O##. *##(.                           ");
				$display("                O#/*     ,OO8OO8888OOOOO##////**/***(##(O#(#####/                                 ");
				$display("                ##((     ,OOOOO8OOOOOO8888O#O####OO8OOOO##(#(##(/                                 ");
				$display("                (#((      OOO#8O8OO#OOO##O888/.8O8OOOOO#O#OO##((.                                 ");
				$display("                .O#(      /OOOOOOOOOO#OOO##(#/*OO#O8O#O#####(((((,                                ");
				$display("                 O#(/  ..,(#OOO#O#OOOO##(#((/**/OOOOO##O#####(/((*                                ");
				$display("               ..8#((    .,/(#OOOOOOOOO#O#/,..,**(#O8O#O####(((//.                                ");
			`endif
			end
			$finish;
		end
	end
        
    always #(`CYCLE*0.5) clk = ~clk;
        
endmodule


module ROM128x32 (
	addr,
	data
);
	input [6:0] addr;
	output [31:0] data;
	reg [31:0] data;
	reg [31:0] mem [0:127];
		
	integer i;
	initial begin
		// Initialize the instruction memory
		$readmemh (`IMEM_INIT, mem);
		$display("Reading instruction memory......");
	end	
	
	always @(addr) data = mem[addr];
	
endmodule