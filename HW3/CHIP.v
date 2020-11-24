////////////////////////////////////////
//Title: RISC V Decoder
//Last Updated date: 11/21, 2020
////////////////////////////////////////
module CHIP(clk,
            rst_n,
            // for mem_I
            mem_addr_I,
            mem_rdata_I,
			// for result output
			instruction_type,
			instruction_format,
			);

    input         clk, rst_n        ;
    output [31:2] mem_addr_I        ;
    input  [31:0] mem_rdata_I       ; //Opcode:[6:0], funct3:[14:12], funct7 31:25
	output [22:0] instruction_type  ;
	output [ 4:0] instruction_format;

    //reg declaration
    reg [31:2] mem_addr_I_r, mem_addr_I_w;
    reg [22:0] instruction_type_r, instruction_type_w;
    reg [4:0] instruction_format_r, instruction_format_w;


    assign mem_addr_I = mem_addr_I_r;
    assign instruction_type = instruction_type_r;
    assign instruction_format = instruction_format_r;

    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem_addr_I_r <= 0;
            instruction_type_r <= 0;
            instruction_format_r <= 0;
        end
        else begin
            mem_addr_I_r <= mem_addr_I_w;
            instruction_type_r <= instruction_type_w;
            instruction_format_r <= instruction_format_w;
        end
    end

    //PC = PC + 4
    always@(*) begin
        mem_addr_I_w = mem_addr_I_r + 1;
    end

    //Decode Part
    always@(*) begin
        instruction_type_w = instruction_type_r;
        instruction_format_w = instruction_format_r;

        case(mem_rdata_I[5:4])
            2'b00: begin //ld
                instruction_type_w = {4'b0, 1'b1, 18'b0};
                instruction_format_w = {5'b01000};
            end
            2'b01:begin
                instruction_format_w = {5'b01000};
                case(mem_rdata_I[14:12])
                    3'b000: instruction_type_w = {6'b0, 1'b1, 16'b0}; //addi
                    3'b001: instruction_type_w = {11'b0, 1'b1, 11'b0}; //slli
                    3'b010: instruction_type_w = {7'b0, 1'b1, 15'b0}; //slti
                    3'b100: instruction_type_w = {8'b0, 1'b1, 14'b0}; //xori
                    3'b101: begin
                        case(mem_rdata_I[30])
                            1'b0: instruction_type_w = {12'b0 ,1'b1 ,10'b0}; //srli
                            1'b1: instruction_type_w = {13'b0, 1'b1, 9'b0}; //srai
                            default: instruction_type_w = {23'b0};
                        endcase
                    end
                    3'b110: instruction_type_w = {9'b0, 1'b1, 13'b0}; //ori
                    3'b111: instruction_type_w = {10'b0, 1'b1, 12'b0}; //andi
                    default: instruction_type_w = {23'b0};
                endcase
            end
            2'b10: begin
                case(mem_rdata_I[3:2])
                    2'b00: begin
                        case(mem_rdata_I[13:12])
                            2'b00: begin
                                instruction_type_w = {2'b0, 1'b1, 20'b0}; //beq
                                instruction_format_w = {5'b00010};
                            end
                            2'b01: begin
                                instruction_type_w = {3'b0, 1'b1, 19'b0}; //bne
                                instruction_format_w = {5'b00010};
                            end
                            2'b11: begin
                                instruction_type_w = {5'b0, 1'b1, 17'b0}; //sd
                                instruction_format_w = {5'b00100}; //????????????????
                            end
                            default: begin
                                instruction_type_w = {23'b0};
                                instruction_format_w = {5'b0};
                            end
                        endcase
                    end
                    2'b01: begin
                        instruction_type_w = {1'b0, 1'b1, 21'b0}; //jalr
                        instruction_format_w = {5'b01000};
                    end
                    2'b11: begin
                        instruction_type_w = {1'b1, 22'b0}; //jal
                        instruction_format_w = {5'b00001};
                    end
                    default: begin
                        instruction_type_w = {23'b0};
                        instruction_format_w = {5'b0};
                    end
                endcase
            end
            2'b11: begin
                instruction_format_w = {5'b10000};
                case(mem_rdata_I[14:12])
                    3'b000: begin
                        case(mem_rdata_I[30])
                            1'b0: instruction_type_w = {14'b0, 1'b1, 8'b0}; //add
                            1'b1: instruction_type_w = {15'b0, 1'b1, 7'b0}; //sub
                            default: instruction_type_w = {23'b0};
                        endcase
                    end
                    3'b001: instruction_type_w = {14'b0, 1'b1, 6'b0}; //sll
                    3'b010: instruction_type_w = {17'b0, 1'b1, 5'b0}; //slt
                    3'b100: instruction_type_w = {18'b0, 1'b1, 4'b0}; //xor
                    3'b101: begin
                        case(mem_rdata_I[30])
                            1'b0: instruction_type_w = {19'b0, 1'b1, 3'b0}; //srl
                            1'b1: instruction_type_w = {20'b0, 1'b1, 2'b0}; //sra
                            default: instruction_type_w = {23'b0};
                        endcase 
                    end
                    3'b110: instruction_type_w = {21'b0, 1'b1, 1'b0}; //or
                    3'b111: instruction_type_w = {22'b0, 1'b1}; //and
                    default: instruction_type_w = {23'b0};
                endcase
            end
            default: begin
                instruction_type_w = {23'b0};
                instruction_format_w = {5'b0};
            end
        endcase
    end

endmodule
