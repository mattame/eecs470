//                                                                      //
//  Description :  instruction execute (EX) stage of the pipeline;      //
//                 given the instruction command code CMD, select the   //
//                 proper input A and B for the ALU, compute the result,// 
//                 and compute the condition for branches, and pass all //
//                 the results down the pipeline. MWB                   // 
//                                                                      //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

//
// The Output Arbiter
//
// Given the output of each module in the EX stage
// This issues the two most important instructions onward
// And stalls the rest
//
// This module is purely combinational
//
module arbiter(		  // Inputs
				// Branch (on bus 1)
				ex_branch_valid_out
				// ALU 1 Bus
				ex_alu_IR_out_1,
				ex_alu_NPC_out_1,
				ex_alu_dest_reg_out_1,
				ex_alu_result_out_1,
				ex_alu_valid_out_1,
				// ALU 2 Bus
				ex_alu_IR_out_2,
				ex_alu_NPC_out_2,
				ex_alu_dest_reg_out_2,
				ex_alu_result_out_2,
				ex_alu_valid_out_2,
				// Multiplier 1 Bus
				ex_mult_IR_out_1,
				ex_mult_NPC_out_1,
				ex_mult_dest_reg_out_1,
				ex_mult_result_out_1,
				ex_mult_valid_out_1,
				// Multiplier 2 Bus
				ex_mult_IR_out_2,
				ex_mult_NPC_out_2,
				ex_mult_dest_reg_out_2,
				ex_mult_result_out_2,
				ex_mult_valid_out_2,
				
			   // Outputs
				stall_bus_1,
				stall_bus_2,
				// Bus 1
				ex_IR_out_1,
				ex_NPC_out_1,
				ex_dest_reg_out_1,
				ex_result_out_1,
				ex_valid_out_1,
				// Bus 2
				ex_IR_out_2,
				ex_NPC_out_2,
				ex_dest_reg_out_2,
				ex_result_out_2,
				ex_valid_out_2
			  );
				  
	input [31:0] ex_alu_IR_out_1;
	input [63:0] ex_alu_NPC_out_1;
	input  [4:0] ex_alu_dest_reg_out_1;
	input [63:0] ex_alu_result_out_1;
	input		 ex_alu_valid_out_1;
				  
	input [31:0] ex_alu_IR_out_2;
	input [63:0] ex_alu_NPC_out_2;
	input  [4:0] ex_alu_dest_reg_out_2;
	input [63:0] ex_alu_result_out_2;
	input		 ex_alu_valid_out_2;
				  
	input [31:0] ex_mult_IR_out_1;
	input [63:0] ex_mult_NPC_out_1;
	input  [4:0] ex_mult_dest_reg_out_1;
	input [63:0] ex_mult_result_out_1;
	input		 ex_mult_valid_out_1;
				  
	input [31:0] ex_mult_IR_out_2;
	input [63:0] ex_mult_NPC_out_2;
	input  [4:0] ex_mult_dest_reg_out_2;
	input [63:0] ex_mult_result_out_2;
	input		 ex_mult_valid_out_2;
	
	output		  stall_bus_1;
	output		  stall_bus_2;
	
	output [31:0] ex_IR_out_1;
	output [63:0] ex_NPC_out_1;
	output  [4:0] ex_dest_reg_out_1;
	output [63:0] ex_result_out_1;
	output		  ex_valid_out_1;
		
	output [31:0] ex_IR_out_2;
	output [63:0] ex_NPC_out_2;
	output  [4:0] ex_dest_reg_out_2;
	output [63:0] ex_result_out_2;
	output		  ex_valid_out_2;
	
	always @*
	begin	
		//Output mux 1
		case(ex_mult_valid_out_1)
			1'b1: 
			begin
				ex_IR_out_1 		= ex_mult_IR_out_1;
				ex_NPC_out_1 		= ex_mult_NPC_out_1;
				ex_dest_reg_out_1 	= ex_mult_dest_reg_out_1;
				ex_result_out_1 	= ex_mult_result_out_1;
				ex_valid_out_1		= 1;
				stall_bus_1 		= 1;
			end
			1'b0:
			begin
				
				ex_IR_out_1 		= ex_alu_IR_out_1;
				ex_NPC_out_1 		= ex_alu_NPC_out_1;
				ex_dest_reg_out_1 	= ex_alu_dest_reg_out_1;
				ex_result_out_1 	= ex_alu_result_out_1;
				ex_valid_out_1		= ex_alu_valid_out_1;
				stall_bus_1 		= 0;
			end
		endcase
		//Output mux 2
		case(ex_mult_valid_out_2)
			1'b1: 
			begin
				ex_IR_out_2 		= ex_mult_IR_out_2;
				ex_NPC_out_2 		= ex_mult_NPC_out_2;
				ex_dest_reg_out_2 	= ex_mult_dest_reg_out_2;
				ex_result_out_2 	= ex_mult_result_out_2;
				ex_valid_out_2		= 1;
				stall_bus_2 		= 1;
			end
			1'b0:
			begin
				ex_IR_out_2 		= ex_alu_IR_out_2;
				ex_NPC_out_2 		= ex_alu_NPC_out_2;
				ex_dest_reg_out_2 	= ex_alu_dest_reg_out_2;
				ex_result_out_2 	= ex_alu_result_out_2;
				ex_valid_out_2		= ex_alu_valid_out_2;
				stall_bus_2 		= 0;
			end
		endcase
	end
	

	/* --- GLOBAL OUTPUT BUSSES
	wire	used_bus_1, used_bus_2;	
	// Branch > Load > Multiply > ALU
	// Currently only Multiply and ALU implemented
	// Yes I know it's ugly as hell.
	always @*
	begin
		used_bus_1 			= 0;
		ex_IR_out_1			= 32'h0;
		ex_NPC_out_1		= 64'h0;
		ex_dest_reg_out_1	= 5'h0;
		ex_result_out_1		= 64'h0;
		ex_valid_out_1		= 0;
		
		used_bus_2			= 0;
		ex_IR_out_2			= 32'h0;
		ex_NPC_out_2		= 64'h0;
		ex_dest_reg_out_2	= 5'h0;
		ex_result_out_2		= 64'h0;
		ex_valid_out_2		= 0;	
		
		stall_alu_1 = 0;
		stall_alu_2 = 0;
		
		if(ex_mult_valid_out_1 == 1) {
			used_bus_1 			= 1;
			ex_IR_out_1 		= ex_mult_IR_out_1;
			ex_NPC_out_1 		= ex_mult_NPC_out_1;
			ex_dest_reg_out_1 	= ex_mult_dest_reg_out_1;
			ex_result_out_1 	= ex_mult_result_out_1;
			ex_valid_out_1		= 1;
		}
		
		if(ex_mult_valid_out_2 == 1) {
			if(used_bus_1 == 0){
				used_bus_1 			= 1;
				ex_IR_out_1 		= ex_mult_IR_out_2;
				ex_NPC_out_1 		= ex_mult_NPC_out_2;
				ex_dest_reg_out_1 	= ex_mult_dest_reg_out_2;
				ex_result_out_1 	= ex_mult_result_out_2;
				ex_valid_out_1		= 1;
			} else {
				used_bus_2 			= 1;
				ex_IR_out_2 		= ex_mult_IR_out_2;
				ex_NPC_out_2 		= ex_mult_NPC_out_2;
				ex_dest_reg_out_2 	= ex_mult_dest_reg_out_2;
				ex_result_out_2 	= ex_mult_result_out_2;
				ex_valid_out_2		= 1;
			}
		}
		
		if(ex_alu_valid_out_1 == 1) {
			if(used_bus_1 == 0){
				used_bus_1 			= 1;
				ex_IR_out_1 		= ex_alu_IR_out_1;
				ex_NPC_out_1 		= ex_alu_NPC_out_1;
				ex_dest_reg_out_1 	= ex_alu_dest_reg_out_1;
				ex_result_out_1 	= ex_alu_result_out_1;
				ex_valid_out_1		= 1;
			} else if(used_bus_2 == 0){
				used_bus_1 			= 1;
				ex_IR_out_1 		= ex_alu_IR_out_1;
				ex_NPC_out_1 		= ex_alu_NPC_out_1;
				ex_dest_reg_out_1 	= ex_alu_dest_reg_out_1;
				ex_result_out_1 	= ex_alu_result_out_1;
				ex_valid_out_1		= 1;
			} else {
				stall_alu_1 = 1;
			}
		}
		
		if(ex_alu_valid_out_2 == 1) {
			if(used_bus_1 == 0){
				used_bus_1 			= 1;
				ex_IR_out_1 		= ex_alu_IR_out_2;
				ex_NPC_out_1 		= ex_alu_NPC_out_2;
				ex_dest_reg_out_1 	= ex_alu_dest_reg_out_2;
				ex_result_out_1 	= ex_alu_result_out_2;
				ex_valid_out_1		= 1;
			} else if(used_bus_2 == 0){
				used_bus_1 			= 1;
				ex_IR_out_1 		= ex_alu_IR_out_2;
				ex_NPC_out_1 		= ex_alu_NPC_out_2;
				ex_dest_reg_out_1 	= ex_alu_dest_reg_out_2;
				ex_result_out_1 	= ex_alu_result_out_2;
				ex_valid_out_1		= 1;
			} else {
				stall_alu_2 = 1;
			}
		}
	end
	*/

	
endmodule
/*
module arbiter_base(req,en,gnt,req_up);
        input [1:0] req;
        input en;
        output [1:0] gnt;
        output req_up;

        assign req_up = req[1] | req[0];
        assign gnt[1] = en & req[1];
        assign gnt[0] = en & req[0] & ~req[1];

endmodule
*/
//
// The Multiplier Stage
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module has sequential logic
//
module mult_stage(clock, reset,
                  IR_in, NPC_in, dest_reg_in, product_in,  mplier_in,  mcand_in,  start,
                  IR_out, NPC_out, dest_reg_out, product_out, mplier_out, mcand_out, done);

  input clock, reset, start;
  input [63:0] product_in, mplier_in, mcand_in, NPC_in;
  input [31:0] IR_in;
  input [4:0]  dest_reg_in;

  output done;
  output [63:0] product_out, mplier_out, mcand_out, NPC_out;
  output [31:0] IR_out;
  output [4:0]  dest_reg_out;

  reg  [63:0] prod_in_reg, partial_prod_reg;
  wire [63:0] partial_product, next_mplier, next_mcand;

  reg [63:0] mplier_out, mcand_out, NPC_out;
  reg [31:0] IR_out;
  reg [4:0]  dest_reg_out;
  reg done;

  assign product_out = prod_in_reg + partial_prod_reg;

  assign partial_product = mplier_in[15:0] * mcand_in;

  assign next_mplier = {16'b0,mplier_in[63:16]};
  assign next_mcand = {mcand_in[47:0],16'b0};

  always @(posedge clock)
  begin
    prod_in_reg      <= #1 product_in;
    partial_prod_reg <= #1 partial_product;
    mplier_out       <= #1 next_mplier;
    mcand_out        <= #1 next_mcand;
	IR_out			 <= #1 IR_in;
	NPC_out			 <= #1 NPC_in;
	dest_reg_out	 <= #1 dest_reg_in;
  end

  always @(posedge clock)
  begin
    if(reset)
      done <= #1 1'b0;
    else
      done <= #1 start;
  end

endmodule                                                                                                                                                                

//
// The Multiplier
//
// given the command code CMD and proper operands A and B, compute the
// product of A and B
//
// This module has four stages, propogating a "done" throughout.
// When the third stage outputs "done", it signals a stall command
// which stalls the pipeline behind it and prevents a structural hazard
// at the end of the EX stage.
//


module mult(clock, reset, IR_in, NPC_in, dest_reg_in, mplier, mcand, valid_in, IR_out, NPC_out, dest_reg_out, product, valid_out);

  input clock, reset, valid_in;
  input [63:0] mcand, mplier, NPC_in;
  input [31:0] IR_in;
  input [4:0]  dest_reg_in;

  output [63:0] product, NPC_out;
  output [31:0] IR_out;
  output [4:0]  dest_reg_out;
  output valid_out;

  wire [63:0] mcand_out, mplier_out;
  wire [(3*64)-1:0] internal_products, internal_mcands, internal_mpliers, internal_NPCs;
  wire [(3*32)-1:0] internal_IRs;
  wire [(3*5)-1:0]  internal_dest_regs;
  wire [2:0] internal_dones;

  mult_stage mstage [3:0]
    (//Input
	 .clock(clock),
     .reset(reset),
	 .IR_in({internal_IRs,IR_in}),
	 .NPC_in({internal_NPCs,NPC_in}),
	 .dest_reg_in({internal_dest_regs,dest_reg_in}),
     .product_in({internal_products,64'h0}),
     .mplier_in({internal_mpliers,mplier}),
     .mcand_in({internal_mcands,mcand}),
     .start({internal_dones,valid_in}),
	 //Outputs
	 .IR_out({IR_out,internal_IRs}),
	 .NPC_out({NPC_out,internal_NPCs}),
	 .dest_reg_out({dest_reg_out,internal_dest_regs}),
     .product_out({product,internal_products}),
     .mplier_out({mplier_out,internal_mpliers}),
     .mcand_out({mcand_out,internal_mcands}),
     .done({valid_out,internal_dones})
    );

endmodule

//
// The ALU
//
// given the command code CMD and proper operands A and B, compute the
// result of the instruction
//
// This module is purely combinational
//

module alu(//Inputs
           opa,
           opb,
           func,
           
           // Output
           result
          );

  input  [63:0] opa;
  input  [63:0] opb;
  input   [4:0] func;
  output [63:0] result;

  reg    [63:0] result;

    // This function computes a signed less-than operation
  function signed_lt;
    input [63:0] a, b;
    
    if (a[63] == b[63]) 
      signed_lt = (a < b); // signs match: signed compare same as unsigned
    else
      signed_lt = a[63];   // signs differ: a is smaller if neg, larger if pos
  endfunction

  always @*
  begin
    case (func)
      `ALU_ADDQ:   result = opa + opb;
      `ALU_SUBQ:   result = opa - opb;
      `ALU_AND:    result = opa & opb;
      `ALU_BIC:    result = opa & ~opb;
      `ALU_BIS:    result = opa | opb;
      `ALU_ORNOT:  result = opa | ~opb;
      `ALU_XOR:    result = opa ^ opb;
      `ALU_EQV:    result = opa ^ ~opb;
      `ALU_SRL:    result = opa >> opb[5:0];
      `ALU_SLL:    result = opa << opb[5:0];
      `ALU_SRA:    result = (opa >> opb[5:0]) | ({64{opa[63]}} << (64 -
                             opb[5:0])); // arithmetic from logical shift
      // `ALU_MULQ:   result = opa * opb;
      `ALU_CMPULT: result = { 63'd0, (opa < opb) };
      `ALU_CMPEQ:  result = { 63'd0, (opa == opb) };
      `ALU_CMPULE: result = { 63'd0, (opa <= opb) };
      `ALU_CMPLT:  result = { 63'd0, signed_lt(opa, opb) };
      `ALU_CMPLE:  result = { 63'd0, (signed_lt(opa, opb) || (opa == opb)) };
      default:     result = 64'hdeadbeefbaadbeef; // here only to force
                                                  // a combinational solution
                                                  // a casex would be better
    endcase
  end
endmodule // alu

//
// BrCond module
//
// Given the instruction code, compute the proper condition for the
// instruction; for branches this condition will indicate whether the
// target is taken.
//
// This module is purely combinational
//
module brcond(// Inputs
              opa,        // Value to check against condition
              func,       // Specifies which condition to check

              // Output
              cond        // 0/1 condition result (False/True)
             );

  input   [2:0] func;
  input  [63:0] opa;
  output        cond;
  
  reg           cond;

  always @*
  begin
    case (func[1:0]) // 'full-case'  All cases covered, no need for a default
      2'b00: cond = (opa[0] == 0);  // LBC: (lsb(opa) == 0) ?
      2'b01: cond = (opa == 0);     // EQ: (opa == 0) ?
      2'b10: cond = (opa[63] == 1); // LT: (signed(opa) < 0) : check sign bit
      2'b11: cond = (opa[63] == 1) || (opa == 0); // LE: (signed(opa) <= 0)
    endcase
  
     // negate cond if func[2] is set
    if (func[2])
      cond = ~cond;
  end
endmodule // brcond
