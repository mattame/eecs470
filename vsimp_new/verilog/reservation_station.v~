

///////////////////////////////////////////////////////////////////////////////
// This file will hold module definitions of the reservation station table.  //
// The main module utilizes multiple individual reservation station modules. //
///////////////////////////////////////////////////////////////////////////////

`define SD #1

// defined paramters //
`define NUM_RSES 16
`define NUM_RSES_MINUS_ONE 7
`define RS_EMPTY        3'b000
`define RS_WAITING_A    3'b001
`define RS_WAITING_B    3'b010
`define RS_WAITING_BOTH 3'b011
`define RS_READY        3'b100
`define RS_TEST         3'b111
`define RSTAG_NULL      8'hFF           
`define ZERO_REG         5'd0
`define NOOP_INST    32'h47ff041f

`define HISTORY_BITS 8

//`timescale 1ns/100ps


/////////////////////////////////////////////////
// individual reservation station entry module //
/////////////////////////////////////////////////
module reservation_station_entry(clock,reset,fill,                               // signals in

                           first_empty_filled_in,
                           second_empty_filled_in,
	                   filling_first,
	              	   filling_second,

                           // input busses //
                           dest_reg_in,
                           dest_tag_in,
                           rega_value_in,
                           regb_value_in,
                           waiting_taga_in,
                           waiting_tagb_in,                

                           // generic signals to just be passed on //
                           opa_select_in,
                           opb_select_in,
                           alu_func_in,
                           rd_mem_in,
                           wr_mem_in,
                           cond_branch_in,
                           uncond_branch_in,
                           NPC_in,
                           IR_in,
                           PPC_in,
                           pht_index_in,

                           // cdbs in //
                           cdb1_tag_in,cdb1_value_in,                
                           cdb2_tag_in,cdb2_value_in,

                           // outputs //
                           status_out,                                           // signals out
			                     age_out,
			                     first_empty_filled_out,
			                     second_empty_filled_out,
			                     first_empty,
			                     second_empty,					   
			                     dest_tag_out,
                           dest_reg_out,
                           rega_value_out,
                           regb_value_out,

                           // outputs for signals to simply be passed through
                           opa_select_out,
                           opb_select_out,
                           alu_func_out,
                           rd_mem_out,
                           wr_mem_out,
                           cond_branch_out,
                           uncond_branch_out,
                           NPC_out,
                           IR_out,
                           PPC_out,
                           pht_index_out

                           );

   // inputs //
   input wire clock;
   input wire reset;
   input wire fill;
   
   input wire first_empty_filled_in;  // for signal chain
   input wire second_empty_filled_in; // for signal chain
   input wire filling_first;    // current filling state from rs
   input wire filling_second;   // current filling state from rs
   wire filling_both;   // determined filling state from filling_first and filling_second
   wire filling_any;    // determined filling state from filling_first and filling_second
 
   input wire [4:0]  dest_reg_in;
   input wire [7:0]  dest_tag_in;
   input wire [63:0] rega_value_in;
   input wire [63:0] regb_value_in;
   input wire [7:0]  waiting_taga_in;
   input wire [7:0]  waiting_tagb_in;

   input wire [7:0]  cdb1_tag_in;
   input wire [7:0]  cdb2_tag_in;
   input wire [63:0] cdb1_value_in;
   input wire [63:0] cdb2_value_in;

   input wire [1:0]  opa_select_in;
   input wire [1:0]  opb_select_in;
   input wire [4:0]  alu_func_in;
   input wire        rd_mem_in;
   input wire        wr_mem_in;
   input wire        cond_branch_in;
   input wire        uncond_branch_in;
   input wire [63:0] NPC_in;
   input wire [31:0] IR_in;
   input wire [63:0] PPC_in;
   input wire [(`HISTORY_BITS-1):0] pht_index_in;

   // outputs //
   output reg  [2:0]  status_out;
   output reg  [7:0]  age_out;
   
   output wire first_empty_filled_out;    // output for signal chain
   output wire second_empty_filled_out;   // output for signal chain
   output wire first_empty;         // whether this entry is the first empty one or not
   output wire second_empty;        // whether this entry is the seocnd empty one or not
   
   output reg  [4:0]  dest_reg_out;
   output reg  [7:0]  dest_tag_out;
   output reg  [63:0] rega_value_out;
   output reg  [63:0] regb_value_out;

   output reg  [1:0]  opa_select_out;
   output reg  [1:0]  opb_select_out;
   output reg  [4:0]  alu_func_out;
   output reg         rd_mem_out;
   output reg         wr_mem_out;
   output reg         cond_branch_out;
   output reg         uncond_branch_out;
   output reg  [63:0] NPC_out;
   output reg  [31:0] IR_out;
   output reg  [63:0] PPC_out;
   output reg  [(`HISTORY_BITS-1):0] pht_index_out;

   // internal registers and wires //
   reg [2:0]  n_status;
   reg [4:0]  n_dest_reg;
   reg [7:0]  n_dest_tag;
   reg [7:0]    waiting_taga;
   reg [7:0]  n_waiting_taga;
   reg [7:0]    waiting_tagb;
   reg [7:0]  n_waiting_tagb; 
   reg [63:0] n_rega_value;
   reg [63:0] n_regb_value;
   reg [7:0]  n_age;

   reg [1:0]  n_opa_select_out;
   reg [1:0]  n_opb_select_out;
   reg [4:0]  n_alu_func_out;
   reg        n_rd_mem_out;
   reg        n_wr_mem_out;
   reg        n_cond_branch_out;
   reg        n_uncond_branch_out;
   reg [63:0] n_NPC;
   reg [31:0] n_IR;
   reg [63:0] n_PPC;
   reg [(`HISTORY_BITS-1):0] n_pht_index;

   wire taga_in_nonnull;     
   wire tagb_in_nonnull;
   wire taga_cur_nonnull;
   wire tagb_cur_nonnull;
   wire taga_in_match_cdb1_in;
   wire taga_in_match_cdb2_in;
   wire tagb_in_match_cdb1_in;
   wire tagb_in_match_cdb2_in;
   wire taga_cur_match_cdb1_cur;
   wire taga_cur_match_cdb2_cur;
   wire tagb_cur_match_cdb1_cur;
   wire tagb_cur_match_cdb2_cur;
   wire status_currently_empty;
   
   // combinational assignments for stuff used for next states //
   assign taga_in_nonnull        = (waiting_taga_in!=`RSTAG_NULL);
   assign tagb_in_nonnull        = (waiting_tagb_in!=`RSTAG_NULL);
   assign taga_cur_nonnull       = (waiting_taga!=`RSTAG_NULL);
   assign tagb_cur_nonnull       = (waiting_tagb!=`RSTAG_NULL);
   assign taga_in_match_cdb1_in  = (waiting_taga_in==cdb1_tag_in);
   assign taga_in_match_cdb2_in  = (waiting_taga_in==cdb2_tag_in);
   assign tagb_in_match_cdb1_in  = (waiting_tagb_in==cdb1_tag_in);
   assign tagb_in_match_cdb2_in  = (waiting_tagb_in==cdb2_tag_in); 
   assign taga_cur_match_cdb1_in = (waiting_taga==cdb1_tag_in);
   assign taga_cur_match_cdb2_in = (waiting_taga==cdb2_tag_in);
   assign tagb_cur_match_cdb1_in = (waiting_tagb==cdb1_tag_in);
   assign tagb_cur_match_cdb2_in = (waiting_tagb==cdb2_tag_in);
   assign status_currently_empty = (status_out==`RS_EMPTY);
   
   // purely combinational assignments for first_empty and second_empty stuff //
   assign first_empty  = (~first_empty_filled_in && status_currently_empty);
   assign second_empty = ( first_empty_filled_in && ~second_empty_filled_in && status_currently_empty);
   assign first_empty_filled_out  = (first_empty  || first_empty_filled_in);
   assign second_empty_filled_out = (second_empty || second_empty_filled_in);
   assign filling_both = (filling_first&&filling_second);
   assign filling_any  = (filling_first||filling_second); 

   // combinational logic to set next states //
   always@*
   begin

      if (fill)
      begin

         // stuff based on logic //
         n_waiting_taga = (taga_in_match_cdb1_in && taga_in_nonnull) ? `RSTAG_NULL  :
                         ((taga_in_match_cdb2_in && taga_in_nonnull) ? `RSTAG_NULL : waiting_taga_in);
         n_waiting_tagb = (tagb_in_match_cdb1_in && tagb_in_nonnull) ? `RSTAG_NULL  :
                         ((tagb_in_match_cdb2_in && tagb_in_nonnull) ? `RSTAG_NULL :  waiting_tagb_in);
         n_rega_value   = (taga_in_match_cdb1_in && taga_in_nonnull) ? cdb1_value_in :
                         ((taga_in_match_cdb2_in && taga_in_nonnull) ? cdb2_value_in : rega_value_in);
         n_regb_value   = (tagb_in_match_cdb1_in && tagb_in_nonnull) ? cdb1_value_in :
                         ((tagb_in_match_cdb2_in && tagb_in_nonnull) ? cdb2_value_in : regb_value_in);
         case ({ (n_waiting_taga!=`RSTAG_NULL), (n_waiting_tagb!=`RSTAG_NULL) })
            2'b00: n_status = `RS_READY;
            2'b01: n_status = `RS_WAITING_B;
            2'b10: n_status = `RS_WAITING_A;
            2'b11: n_status = `RS_WAITING_BOTH;
         endcase
	 n_age = (filling_both&&second_empty) ? 8'd2 : ( ((filling_any)&&(first_empty||second_empty)) ? 8'd1 : 8'd0 );
         
         // pass-throughs //
         n_dest_reg          = dest_reg_in;
	 n_dest_tag          = dest_tag_in;
         n_opa_select_out    = opa_select_in; 
         n_opb_select_out    = opb_select_in; 
         n_alu_func_out      = alu_func_in;
         n_rd_mem_out        = rd_mem_in;
         n_wr_mem_out        = wr_mem_in;
         n_cond_branch_out   = cond_branch_in;
         n_uncond_branch_out = uncond_branch_in;
         n_NPC               = NPC_in;
         n_IR                = IR_in;
         n_PPC               = PPC_in;
         n_pht_index         = pht_index_in;

      end
      else
      begin

         // stuff based on logic //
         n_waiting_taga = (taga_cur_match_cdb1_in && taga_cur_nonnull) ? `RSTAG_NULL : 
                         ((taga_cur_match_cdb2_in && taga_cur_nonnull) ? `RSTAG_NULL : waiting_taga);
         n_waiting_tagb = (tagb_cur_match_cdb1_in && tagb_cur_nonnull) ? `RSTAG_NULL : 
                         ((tagb_cur_match_cdb2_in && tagb_cur_nonnull) ? `RSTAG_NULL : waiting_tagb);
         n_rega_value   = (taga_cur_match_cdb1_in && taga_cur_nonnull) ? cdb1_value_in :
                         ((taga_cur_match_cdb2_in && taga_cur_nonnull) ? cdb2_value_in : rega_value_out);
         n_regb_value   = (tagb_cur_match_cdb1_in && tagb_cur_nonnull) ? cdb1_value_in : 
                         ((tagb_cur_match_cdb2_in && tagb_cur_nonnull) ? cdb2_value_in : regb_value_out);
         if (status_currently_empty)
         begin
            n_status = `RS_EMPTY;
            n_age    = 8'd0;
         end
         else
         begin
            case ({ (n_waiting_taga!=`RSTAG_NULL), (n_waiting_tagb!=`RSTAG_NULL) })
               2'b00: n_status = `RS_READY;
               2'b01: n_status = `RS_WAITING_B;
               2'b10: n_status = `RS_WAITING_A;
               2'b11: n_status = `RS_WAITING_BOTH;
            endcase
	    n_age = (filling_both) ? (age_out+8'd2) : ((filling_any) ? (age_out+8'd1) : age_out);
         end

         // pass-throughs //
         n_dest_reg          = dest_reg_out;
	 n_dest_tag          = dest_tag_out;
         n_opa_select_out    = opa_select_out;
         n_opb_select_out    = opb_select_out;
         n_alu_func_out      = alu_func_out;
         n_rd_mem_out        = rd_mem_out;
         n_wr_mem_out        = wr_mem_out;
         n_cond_branch_out   = cond_branch_out;
         n_uncond_branch_out = uncond_branch_out;
         n_NPC               = NPC_out;
         n_IR                = IR_out;
         n_PPC               = PPC_out;
         n_pht_index         = pht_index_out;

      end
   end

   // synopsys sync_set_reset "reset"

   // clock synchronous events //
   always@(posedge clock)
   begin
      if (reset)
      begin
         status_out        <= `SD `RS_EMPTY;
         dest_reg_out      <= `SD 5'd0;
	 dest_tag_out      <= `SD `RSTAG_NULL;
         waiting_taga      <= `SD `RSTAG_NULL;
         waiting_tagb      <= `SD `RSTAG_NULL;
         rega_value_out    <= `SD 64'd0;
         regb_value_out    <= `SD 64'd0;
         opa_select_out    <= `SD 2'b00;
         opb_select_out    <= `SD 2'b00;
         alu_func_out      <= `SD 5'd0;
         rd_mem_out        <= `SD 1'b0;
         wr_mem_out        <= `SD 1'b0;
         cond_branch_out   <= `SD 1'b0;
         uncond_branch_out <= `SD 1'b0;
	 age_out           <= `SD 8'd0;
         NPC_out           <= `SD 64'd0; 
         IR_out            <= `SD `NOOP_INST;
         PPC_out           <= `SD 64'd0;
         pht_index_out     <= `SD {`HISTORY_BITS{1'b0}};
      end
      else
      begin
         status_out        <= `SD n_status;
         dest_reg_out      <= `SD n_dest_reg;
	 dest_tag_out      <= `SD n_dest_tag;
         waiting_taga      <= `SD n_waiting_taga;
         waiting_tagb      <= `SD n_waiting_tagb;
         rega_value_out    <= `SD n_rega_value;
         regb_value_out    <= `SD n_regb_value;
         opa_select_out    <= `SD n_opa_select_out;
         opb_select_out    <= `SD n_opb_select_out;
         alu_func_out      <= `SD n_alu_func_out;
         rd_mem_out        <= `SD n_rd_mem_out;
         wr_mem_out        <= `SD n_wr_mem_out;
         cond_branch_out   <= `SD n_cond_branch_out;
         uncond_branch_out <= `SD n_uncond_branch_out;
	 age_out           <= `SD n_age;
         NPC_out           <= `SD n_NPC;
         IR_out            <= `SD n_IR;
         PPC_out           <= `SD n_PPC; 
         pht_index_out     <= `SD n_pht_index;
      end
   end

endmodule



// needed outputs from decode stage: //
//
// wire [63:0] id_rega_out;
// wire [63:0] id_regb_out;
// wire  [1:0] id_opa_select_out;
// wire  [1:0] id_opb_select_out;
// wire  [4:0] id_dest_reg_idx_out;
// wire  [4:0] id_alu_func_out;
// wire        id_rd_mem_out;
// wire        id_wr_mem_out;
// wire        id_cond_branch_out;
// wire        id_uncond_branch_out;
// wire        id_halt_out;
// wire        id_illegal_out;
// wire        id_valid_inst_out;
//
// FROM SCOTT:  //
//
// opa_select
// opb_select
// alu_func
// dest_reg
// cond_branch
// uncond_branch
// valid_inst
//

///////////////////////////////////////////
// the actual reservation station module //
///////////////////////////////////////////
module reservation_station(clock,reset,               // signals in

                           // signals and busses in for inst 1 (from id1) //
                           inst1_rega_value_in,
                           inst1_regb_value_in,
                           inst1_rega_tag_in,
                           inst1_regb_tag_in,
                           inst1_dest_reg_in,
                           inst1_dest_tag_in,
                           inst1_opa_select_in,
                           inst1_opb_select_in,
                           inst1_alu_func_in,
                           inst1_rd_mem_in,
                           inst1_wr_mem_in,
                           inst1_cond_branch_in,
                           inst1_uncond_branch_in,
                           inst1_NPC_in,
                           inst1_IR_in,
                           inst1_PPC_in,
                           inst1_pht_index_in,
                           inst1_valid,

                           // signals and busses in for inst 2 (from id2) //
                           inst2_rega_value_in,
                           inst2_regb_value_in,
                           inst2_rega_tag_in,
                           inst2_regb_tag_in,
                           inst2_dest_reg_in,
                           inst2_dest_tag_in,
                           inst2_opa_select_in,
                           inst2_opb_select_in,
                           inst2_alu_func_in,
                           inst2_rd_mem_in,
                           inst2_wr_mem_in,
                           inst2_cond_branch_in,
                           inst2_uncond_branch_in,
                           inst2_NPC_in,
                           inst2_IR_in,
                           inst2_PPC_in,
                           inst2_pht_index_in,
                           inst2_valid,

                           // cdb inputs //
                           cdb1_tag_in,
                           cdb2_tag_in,
                           cdb1_value_in,
                           cdb2_value_in,

                           // inputs from the ROB //
                           inst1_rega_rob_value_in,
                           inst1_regb_rob_value_in,
                           inst2_rega_rob_value_in,
                           inst2_regb_rob_value_in,

                           // stall signals in //
                           inst1_stall_in,
                           inst2_stall_in,

                           // signals and busses out for inst1 to the ex stage
                           inst1_rega_value_out,inst1_regb_value_out,
                           inst1_opa_select_out,inst1_opb_select_out,
                           inst1_alu_func_out,
                           inst1_rd_mem_out,inst1_wr_mem_out,
                           inst1_cond_branch_out,inst1_uncond_branch_out,
                           inst1_NPC_out,inst1_IR_out,
                           inst1_PPC_out,
                           inst1_pht_index_out,
                           inst1_valid_out,
                           inst1_dest_reg_out,
                           inst1_dest_tag_out,

                           // signals and busses out for inst2 to the ex stage
                           inst2_rega_value_out,inst2_regb_value_out,
                           inst2_opa_select_out,inst2_opb_select_out,
                           inst2_alu_func_out,
                           inst2_rd_mem_out,inst2_wr_mem_out,
                           inst2_cond_branch_out,inst2_uncond_branch_out,
                           inst2_NPC_out,inst2_IR_out,
                           inst2_PPC_out,
                           inst2_pht_index_out,
                           inst2_valid_out,
                           inst2_dest_reg_out,
                           inst2_dest_tag_out,

                           // signal outputs //
                           dispatch,
                         
                           // outputs for debugging //
                           first_empties,second_empties,states_out,fills,issue_first_states,issue_second_states,ages_out);


   // inputs //
   input wire clock;
   input wire reset;

   input wire [63:0] inst1_rega_value_in,inst1_regb_value_in;
   input wire [7:0]  inst1_rega_tag_in,inst1_regb_tag_in;
   input wire [4:0]  inst1_dest_reg_in;
   input wire [7:0]  inst1_dest_tag_in;
   input wire [1:0]  inst1_opa_select_in,inst1_opb_select_in;
   input wire [4:0]  inst1_alu_func_in;
   input wire        inst1_rd_mem_in,inst1_wr_mem_in;
   input wire        inst1_cond_branch_in,inst1_uncond_branch_in;
   input wire [63:0] inst1_NPC_in;
   input wire [31:0] inst1_IR_in;
   input wire [63:0] inst1_PPC_in;
   input wire [(`HISTORY_BITS-1):0] inst1_pht_index_in;
   input wire        inst1_valid;
   
   input wire [63:0] inst2_rega_value_in,inst2_regb_value_in;
   input wire [7:0]  inst2_rega_tag_in,inst2_regb_tag_in;
   input wire [4:0]  inst2_dest_reg_in;
   input wire [7:0]  inst2_dest_tag_in;
   input wire [1:0]  inst2_opa_select_in,inst2_opb_select_in;
   input wire [4:0]  inst2_alu_func_in;
   input wire        inst2_rd_mem_in,inst2_wr_mem_in;
   input wire        inst2_cond_branch_in,inst2_uncond_branch_in;
   input wire [63:0] inst2_NPC_in;
   input wire [31:0] inst2_IR_in;
   input wire [63:0] inst2_PPC_in;
   input wire [(`HISTORY_BITS-1):0] inst2_pht_index_in;
   input wire        inst2_valid;

   input wire [63:0] cdb1_value_in;
   input wire [7:0]  cdb1_tag_in;
   input wire [63:0] cdb2_value_in;
   input wire [7:0]  cdb2_tag_in;

   input wire inst1_stall_in;
   input wire inst2_stall_in;

   input wire [63:0] inst1_rega_rob_value_in;
   input wire [63:0] inst1_regb_rob_value_in;
   input wire [63:0] inst2_rega_rob_value_in;
   input wire [63:0] inst2_regb_rob_value_in;


   // outputs //
   output wire dispatch; 

   output wor [63:0] inst1_rega_value_out,inst1_regb_value_out;
   output wor [1:0]  inst1_opa_select_out,inst1_opb_select_out;
   output wor [4:0]  inst1_alu_func_out;
   output wor        inst1_rd_mem_out,inst1_wr_mem_out;
   output wor        inst1_cond_branch_out,inst1_uncond_branch_out;
   output wor [63:0] inst1_NPC_out;
   output wor [31:0] inst1_IR_out;
   output wor [63:0] inst1_PPC_out;
   output wor [(`HISTORY_BITS-1):0] inst1_pht_index_out;
   output wor        inst1_valid_out;
   output wor [4:0]  inst1_dest_reg_out;
   output wor [7:0]  inst1_dest_tag_out;

   output wor [63:0] inst2_rega_value_out,inst2_regb_value_out;
   output wor [1:0]  inst2_opa_select_out,inst2_opb_select_out;
   output wor [4:0]  inst2_alu_func_out;
   output wor        inst2_rd_mem_out,inst2_wr_mem_out;
   output wor        inst2_cond_branch_out,inst2_uncond_branch_out;
   output wor [63:0] inst2_NPC_out;
   output wor [31:0] inst2_IR_out;
   output wor [63:0] inst2_PPC_out;
   output wor [(`HISTORY_BITS-1):0] inst2_pht_index_out;
   output wor        inst2_valid_out;
   output wor [4:0]  inst2_dest_reg_out;
   output wor [7:0]  inst2_dest_tag_out;

   output wire [(`NUM_RSES*3-1):0] states_out;

   
   // internal wires for directly interfacing the rs entries //
   output wire [(`NUM_RSES-1):0] fills;
   reg  [(`NUM_RSES-1):0] resets;

   wire [(`NUM_RSES-1):0] first_empty_filleds;     // first/second empty links between rses
   wire [(`NUM_RSES-1):0] second_empty_filleds;
   
   reg [4:0]             dest_regs_in     [(`NUM_RSES-1):0];
   reg [7:0]             dest_tags_in     [(`NUM_RSES-1):0];
   reg [63:0]            rega_values_in   [(`NUM_RSES-1):0];
   reg [63:0]            regb_values_in   [(`NUM_RSES-1):0];
   reg [7:0]             waiting_tagas_in [(`NUM_RSES-1):0];
   reg [7:0]             waiting_tagbs_in [(`NUM_RSES-1):0];                

   reg [1:0]             opa_selects_in   [(`NUM_RSES-1):0];
   reg [1:0]             opb_selects_in   [(`NUM_RSES-1):0];
   reg [4:0]             alu_funcs_in     [(`NUM_RSES-1):0];
   reg [(`NUM_RSES-1):0] rd_mems_in;
   reg [(`NUM_RSES-1):0] wr_mems_in;
   reg [(`NUM_RSES-1):0] cond_branches_in;
   reg [(`NUM_RSES-1):0] uncond_branches_in;
   reg [63:0]            NPCs_in         [(`NUM_RSES-1):0];
   reg [31:0]            IRs_in          [(`NUM_RSES-1):0];
   reg [63:0]            PPCs_in         [(`NUM_RSES-1):0];
   reg [(`HISTORY_BITS-1):0] pht_indices_in [(`NUM_RSES-1):0];


   output wire [(`NUM_RSES*8-1):0] ages_out;
 
   wire [2:0]             statuses     [(`NUM_RSES-1):0];
   wire [7:0]             ages         [(`NUM_RSES-1):0];
   output wire [(`NUM_RSES-1):0] first_empties;    // bit to indicate whether an rs entry is the first empty one available 
   output wire [(`NUM_RSES-1):0] second_empties;   // bit to indicate whether an rs entry is the second empty one available
   
   wire [4:0]             dest_regs_out    [(`NUM_RSES-1):0];
   wire [7:0]             dest_tags_out    [(`NUM_RSES-1):0];
   wire [63:0]            rega_values_out  [(`NUM_RSES-1):0];
   wire [63:0]            regb_values_out  [(`NUM_RSES-1):0];
   
   wire [1:0]             opa_selects_out  [(`NUM_RSES-1):0];
   wire [1:0]             opb_selects_out  [(`NUM_RSES-1):0];
   wire [4:0]             alu_funcs_out    [(`NUM_RSES-1):0];
   wire [(`NUM_RSES-1):0] rd_mems_out ;
   wire [(`NUM_RSES-1):0] wr_mems_out;
   wire [(`NUM_RSES-1):0] cond_branches_out;
   wire [(`NUM_RSES-1):0] uncond_branches_out;
   wire [63:0]            NPCs_out         [(`NUM_RSES-1):0];
   wire [31:0]            IRs_out          [(`NUM_RSES-1):0];
   wire [63:0]            PPCs_out         [(`NUM_RSES-1):0];
   wire [(`HISTORY_BITS-1):0] pht_indices_out [(`NUM_RSES-1):0];

   wor  dispatch_available1;   // if slot 1 can be dispatched to (both slots 1 and 2 must be available for the rs to allow dispatch) 
   wor  dispatch_available2;   // if slot 2 can be dispatched to (both slots 1 and 2 must be available for the rs to allow dispatch)
   wor  filling1;
   wor  filling2;
   
   output wire [(`NUM_RSES-1):0] issue_first_states;   // indicates whether or not this rs entry should issue next (first out)
   output wire [(`NUM_RSES-1):0] issue_second_states;  // indicates whether or not this rs entry should issue next (second out)
   wire [(`NUM_RSES-1):0] ready_states;         // indicates whether or not this rs entry is currently ready to issue
   wire [(`NUM_RSES-1):0] comp_table [(`NUM_RSES-1):0];    // table of rs entry age comparisons 

 
   
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   // combinational logic for assigning rs outputs                                                       //
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
   genvar i,j;
   generate
      for (i=0; i<`NUM_RSES; i=i+1)
	  begin : ASSIGNOUTPUTS

			assign inst1_rega_value_out    = (issue_first_states[i] ? rega_values_out[i] : 64'd0);  
			assign inst1_regb_value_out    = (issue_first_states[i] ? regb_values_out[i] : 64'd0);
			assign inst1_opa_select_out    = (issue_first_states[i] ? opa_selects_out[i] : 2'd0);
			assign inst1_opb_select_out    = (issue_first_states[i] ? opb_selects_out[i] : 2'd0);
			assign inst1_alu_func_out      = (issue_first_states[i] ? alu_funcs_out[i] : 5'd0);
			assign inst1_rd_mem_out        = (issue_first_states[i] ? rd_mems_out[i] : 1'b0);
			assign inst1_wr_mem_out        = (issue_first_states[i] ? wr_mems_out[i] : 1'b0);
			assign inst1_cond_branch_out   = (issue_first_states[i] ? cond_branches_out[i] : 1'b0);
			assign inst1_uncond_branch_out = (issue_first_states[i] ? uncond_branches_out[i] : 1'b0);
                        assign inst1_NPC_out           = (issue_first_states[i] ? NPCs_out[i] : 64'd0);
                        assign inst1_IR_out            = (issue_first_states[i] ? IRs_out[i] : 32'd0); 
                        assign inst1_PPC_out           = (issue_first_states[i] ? PPCs_out[i] : 64'd0);
                        assign inst1_pht_index_out     = (issue_first_states[i] ? pht_indices_out[i] : {`HISTORY_BITS{1'b0}} );
			assign inst1_valid_out         = (issue_first_states[i] ? 1'b1 : 1'b0);
			assign inst1_dest_reg_out      = (issue_first_states[i] ? dest_regs_out[i] : 5'd0);
			assign inst1_dest_tag_out      = (issue_first_states[i] ? dest_tags_out[i] : 5'd0);

			assign inst2_rega_value_out    = (issue_second_states[i] ? rega_values_out[i] : 64'd0);  
			assign inst2_regb_value_out    = (issue_second_states[i] ? regb_values_out[i] : 64'd0);
			assign inst2_opa_select_out    = (issue_second_states[i] ? opa_selects_out[i] : 2'd0);
			assign inst2_opb_select_out    = (issue_second_states[i] ? opb_selects_out[i] : 2'd0);
			assign inst2_alu_func_out      = (issue_second_states[i] ? alu_funcs_out[i] : 5'd0);
			assign inst2_rd_mem_out        = (issue_second_states[i] ? rd_mems_out[i] : 1'b0);
			assign inst2_wr_mem_out        = (issue_second_states[i] ? wr_mems_out[i] : 1'b0);
			assign inst2_cond_branch_out   = (issue_second_states[i] ? cond_branches_out[i] : 1'b0);
			assign inst2_uncond_branch_out = (issue_second_states[i] ? uncond_branches_out[i] : 1'b0);
                        assign inst2_NPC_out           = (issue_second_states[i] ? NPCs_out[i] : 64'd0);
                        assign inst2_IR_out            = (issue_second_states[i] ? IRs_out[i] : 32'd0);
                        assign inst2_PPC_out           = (issue_second_states[i] ? PPCs_out[i] : 64'd0);
                        assign inst2_pht_index_out     = (issue_second_states[i] ? pht_indices_out[i] : {`HISTORY_BITS{1'b0}} );
			assign inst2_valid_out         = (issue_second_states[i] ? 1'b1 : 1'b0);
			assign inst2_dest_reg_out      = (issue_second_states[i] ? dest_regs_out[i] : 5'd0);
			assign inst2_dest_tag_out      = (issue_second_states[i] ? dest_tags_out[i] : 5'd0);
			
	  end
   endgenerate   


   
   /////////////////////////////////////////////////////////////////////////////////////////////
   // combinational logic to assign rs entry inputs, fill states, and dispatch availabilities //
   /////////////////////////////////////////////////////////////////////////////////////////////
   generate
      for (i=0; i<`NUM_RSES; i=i+1)
	  begin : ASSIGNRSINPUTS

                 assign fills[i] = ( dispatch && ((inst1_valid&&first_empties[i]) || (inst2_valid&&second_empties[i])) ); 

		 always@*
		 begin
		 
			 // pull from the first instruction slot //
			 if ( dispatch && inst1_valid && (first_empties[i]) )
			 begin
//                             fills[i]              = 1'b1;
                               if (inst1_rega_tag_in[7:6]==2'b01) begin   // ready-in-ROB: pull from the ROB versus the reg file
                                  rega_values_in[i]     = inst1_rega_rob_value_in;
                                  waiting_tagas_in[i]   = `RSTAG_NULL;
                               end else begin
                                  rega_values_in[i]     = inst1_rega_value_in;
                                  waiting_tagas_in[i]   = inst1_rega_tag_in;
                               end
                               if (inst1_regb_tag_in[7:6]==2'b01) begin   // ready-in-ROB: pull from the ROB versus the reg file
                                  regb_values_in[i]     = inst1_regb_rob_value_in;
                                  waiting_tagbs_in[i]   = `RSTAG_NULL;
                               end else begin
                                  regb_values_in[i]     = inst1_regb_value_in;
                                  waiting_tagbs_in[i]   = inst1_regb_tag_in;
                               end
                               dest_regs_in[i]       = inst1_dest_reg_in;
                               dest_tags_in[i]       = inst1_dest_tag_in;
                               opa_selects_in[i]     = inst1_opa_select_in;
                               opb_selects_in[i]     = inst1_opb_select_in;
                               alu_funcs_in[i]       = inst1_alu_func_in;
                               rd_mems_in[i]         = inst1_rd_mem_in;
                               wr_mems_in[i]         = inst1_wr_mem_in;
                               cond_branches_in[i]   = inst1_cond_branch_in;
                               uncond_branches_in[i] = inst1_uncond_branch_in;
                               NPCs_in[i]            = inst1_NPC_in;
                               IRs_in[i]             = inst1_IR_in;
                               PPCs_in[i]            = inst1_PPC_in;
                               pht_indices_in[i]     = inst1_pht_index_in;

                         end
				
                         // pull from the second instruction slot //
                         else if ( dispatch && inst2_valid && (second_empties[i]) )
                         begin
//                             fills[i]              = 1'b1;
                               if (inst2_rega_tag_in[7:6]==2'b01) begin   // ready-in-ROB: pull from the ROB versus the reg file
                                  rega_values_in[i]     = inst2_rega_rob_value_in;
                                  waiting_tagas_in[i]   = `RSTAG_NULL;
                               end else begin
                                  rega_values_in[i]     = inst2_rega_value_in;
                                  waiting_tagas_in[i]   = inst2_rega_tag_in;
                               end
                               if (inst2_regb_tag_in[7:6]==2'b01) begin   // ready-in-ROB: pull from the ROB versus the reg file
                                  regb_values_in[i]     = inst2_regb_rob_value_in;
                                  waiting_tagbs_in[i]   = `RSTAG_NULL;
                               end else begin
                                  regb_values_in[i]     = inst2_regb_value_in;
                                  waiting_tagbs_in[i]   = inst2_regb_tag_in;
                               end
                               dest_regs_in[i]       = inst2_dest_reg_in;
                               dest_tags_in[i]       = inst2_dest_tag_in;
                               opa_selects_in[i]     = inst2_opa_select_in;
                               opb_selects_in[i]     = inst2_opb_select_in;
                               alu_funcs_in[i]       = inst2_alu_func_in;
                               rd_mems_in[i]         = inst2_rd_mem_in;
                               wr_mems_in[i]         = inst2_wr_mem_in;
                               cond_branches_in[i]   = inst2_cond_branch_in;
                               uncond_branches_in[i] = inst2_uncond_branch_in;
                               NPCs_in[i]            = inst2_NPC_in;
                               IRs_in[i]             = inst2_IR_in;
                               PPCs_in[i]            = inst2_PPC_in;
                               pht_indices_in[i]     = inst2_pht_index_in;
                         end
                     
				 
                         // default case: no instruction being dispatched/ no rs entries being filled //
                         else
                         begin
//				fills[i]              = 1'b0;
				dest_regs_in[i]       = `ZERO_REG;
				dest_tags_in[i]       = `RSTAG_NULL;
				rega_values_in[i]     = 64'd0;
				regb_values_in[i]     = 64'd0;
				waiting_tagas_in[i]   = `RSTAG_NULL; 
				waiting_tagbs_in[i]   = `RSTAG_NULL;
				opa_selects_in[i]     = 2'd0;
				opb_selects_in[i]     = 2'd0;
				alu_funcs_in[i]       = 5'd0;
				rd_mems_in[i]         = 1'b0;
				wr_mems_in[i]         = 1'b0;
				cond_branches_in[i]   = 1'b0; 
              			uncond_branches_in[i] = 1'b0;
                                NPCs_in[i]            = 64'd0; 
                                IRs_in[i]             = 32'd0;
                                PPCs_in[i]            = 64'd0;
                                pht_indices_in[i]     = {`HISTORY_BITS{1'b0}};
                         end

                        // assign resets for all rs entries //
                        resets[i] = (reset || (issue_first_states[i] && ~inst1_stall_in) || (issue_second_states[i] && ~inst2_stall_in));
 
	     end
		 
             // assign the dispatch availabilities //
             assign dispatch_available1 = first_empties[i];    // note this is a wor, so it accumulates
             assign dispatch_available2 = second_empties[i];   // note this is a wor, so it accumulates		
		 
      end
   endgenerate
   
   // assign current dispatch snd filling states //
   assign dispatch = (dispatch_available1 && dispatch_available2);
   assign filling1 = (dispatch && inst1_valid);
   assign filling2 = (dispatch && inst2_valid);

   
   ///////////////////////////////////////////////////////////
   // combinational logic for assigning issue_first_states, //
   // issue_second_states, ready_states, and comp_table     //
   ///////////////////////////////////////////////////////////
   // FROM THIS CODE: //
   /////////////////////
//   generate
//      for (i=0; i<`NUM_RSES; i=i+1)
//      begin : ASSIGNSTATESOUTERLOOP
//
//         assign ready_states[i]        = (statuses[i]==`RS_READY);
//         assign issue_first_states[i]  = ready_states[i];              // note: issue_first_states and issue_second_states are wands, hence the effect here
//         assign issue_second_states[i] = ready_states[i]; 
//         assign issue_second_states[i] = ~issue_first_states[i];
//
//         for (j=0; j<`NUM_RSES; j=j+1)
//         begin : ASSIGNSTATESINNERLOOP
//            assign issue_first_states[i]  = (j==i) ? 1'b1 : (~ready_states[j] || comp_table[j][i]);   // exclusion cases for rs entry j
//            assign issue_second_states[i] = (j==i) ? 1'b1 : (~ready_states[j] || comp_table[j][i] || issue_first_states[j]);   // exclusion cases for rs entry j
//            assign comp_table[i][j]       = (ages[i]<ages[j]);   // is rs entry i newer than rs entry j?  
//         end
//   
//      end
//   endgenerate
   assign ready_states[0]     = (statuses[0]==`RS_READY);
   assign issue_first_states[0]  = ready_states[0]
          && (~ready_states[1] || comp_table[1][0]) 
          && (~ready_states[2] || comp_table[2][0]) 
          && (~ready_states[3] || comp_table[3][0]) 
          && (~ready_states[4] || comp_table[4][0]) 
          && (~ready_states[5] || comp_table[5][0]) 
          && (~ready_states[6] || comp_table[6][0]) 
          && (~ready_states[7] || comp_table[7][0]) 
          && (~ready_states[8] || comp_table[8][0]) 
          && (~ready_states[9] || comp_table[9][0]) 
          && (~ready_states[10] || comp_table[10][0]) 
          && (~ready_states[11] || comp_table[11][0]) 
          && (~ready_states[12] || comp_table[12][0]) 
          && (~ready_states[13] || comp_table[13][0]) 
          && (~ready_states[14] || comp_table[14][0]) 
          && (~ready_states[15] || comp_table[15][0]) 
   ;
   assign issue_second_states[0] = ready_states[0] && ~issue_first_states[0] 
          && (~ready_states[1] || comp_table[1][0] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][0] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][0] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][0] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][0] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][0] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][0] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][0] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][0] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][0] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][0] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][0] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][0] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][0] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][0] || issue_first_states[15]) 
   ;
   assign comp_table[0][0]       = (ages[0]<ages[0]); 
   assign comp_table[0][1]       = (ages[0]<ages[1]); 
   assign comp_table[0][2]       = (ages[0]<ages[2]); 
   assign comp_table[0][3]       = (ages[0]<ages[3]); 
   assign comp_table[0][4]       = (ages[0]<ages[4]); 
   assign comp_table[0][5]       = (ages[0]<ages[5]); 
   assign comp_table[0][6]       = (ages[0]<ages[6]); 
   assign comp_table[0][7]       = (ages[0]<ages[7]); 
   assign comp_table[0][8]       = (ages[0]<ages[8]); 
   assign comp_table[0][9]       = (ages[0]<ages[9]); 
   assign comp_table[0][10]       = (ages[0]<ages[10]); 
   assign comp_table[0][11]       = (ages[0]<ages[11]); 
   assign comp_table[0][12]       = (ages[0]<ages[12]); 
   assign comp_table[0][13]       = (ages[0]<ages[13]); 
   assign comp_table[0][14]       = (ages[0]<ages[14]); 
   assign comp_table[0][15]       = (ages[0]<ages[15]); 
   assign ready_states[1]     = (statuses[1]==`RS_READY);
   assign issue_first_states[1]  = ready_states[1]
          && (~ready_states[0] || comp_table[0][1]) 
          && (~ready_states[2] || comp_table[2][1]) 
          && (~ready_states[3] || comp_table[3][1]) 
          && (~ready_states[4] || comp_table[4][1]) 
          && (~ready_states[5] || comp_table[5][1]) 
          && (~ready_states[6] || comp_table[6][1]) 
          && (~ready_states[7] || comp_table[7][1]) 
          && (~ready_states[8] || comp_table[8][1]) 
          && (~ready_states[9] || comp_table[9][1]) 
          && (~ready_states[10] || comp_table[10][1]) 
          && (~ready_states[11] || comp_table[11][1]) 
          && (~ready_states[12] || comp_table[12][1]) 
          && (~ready_states[13] || comp_table[13][1]) 
          && (~ready_states[14] || comp_table[14][1]) 
          && (~ready_states[15] || comp_table[15][1]) 
   ;
   assign issue_second_states[1] = ready_states[1] && ~issue_first_states[1] 
          && (~ready_states[0] || comp_table[0][1] || issue_first_states[0]) 
          && (~ready_states[2] || comp_table[2][1] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][1] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][1] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][1] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][1] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][1] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][1] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][1] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][1] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][1] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][1] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][1] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][1] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][1] || issue_first_states[15]) 
   ;
   assign comp_table[1][0]       = (ages[1]<ages[0]); 
   assign comp_table[1][1]       = (ages[1]<ages[1]); 
   assign comp_table[1][2]       = (ages[1]<ages[2]); 
   assign comp_table[1][3]       = (ages[1]<ages[3]); 
   assign comp_table[1][4]       = (ages[1]<ages[4]); 
   assign comp_table[1][5]       = (ages[1]<ages[5]); 
   assign comp_table[1][6]       = (ages[1]<ages[6]); 
   assign comp_table[1][7]       = (ages[1]<ages[7]); 
   assign comp_table[1][8]       = (ages[1]<ages[8]); 
   assign comp_table[1][9]       = (ages[1]<ages[9]); 
   assign comp_table[1][10]       = (ages[1]<ages[10]); 
   assign comp_table[1][11]       = (ages[1]<ages[11]); 
   assign comp_table[1][12]       = (ages[1]<ages[12]); 
   assign comp_table[1][13]       = (ages[1]<ages[13]); 
   assign comp_table[1][14]       = (ages[1]<ages[14]); 
   assign comp_table[1][15]       = (ages[1]<ages[15]); 
   assign ready_states[2]     = (statuses[2]==`RS_READY);
   assign issue_first_states[2]  = ready_states[2]
          && (~ready_states[0] || comp_table[0][2]) 
          && (~ready_states[1] || comp_table[1][2]) 
          && (~ready_states[3] || comp_table[3][2]) 
          && (~ready_states[4] || comp_table[4][2]) 
          && (~ready_states[5] || comp_table[5][2]) 
          && (~ready_states[6] || comp_table[6][2]) 
          && (~ready_states[7] || comp_table[7][2]) 
          && (~ready_states[8] || comp_table[8][2]) 
          && (~ready_states[9] || comp_table[9][2]) 
          && (~ready_states[10] || comp_table[10][2]) 
          && (~ready_states[11] || comp_table[11][2]) 
          && (~ready_states[12] || comp_table[12][2]) 
          && (~ready_states[13] || comp_table[13][2]) 
          && (~ready_states[14] || comp_table[14][2]) 
          && (~ready_states[15] || comp_table[15][2]) 
   ;
   assign issue_second_states[2] = ready_states[2] && ~issue_first_states[2] 
          && (~ready_states[0] || comp_table[0][2] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][2] || issue_first_states[1]) 
          && (~ready_states[3] || comp_table[3][2] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][2] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][2] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][2] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][2] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][2] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][2] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][2] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][2] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][2] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][2] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][2] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][2] || issue_first_states[15]) 
   ;
   assign comp_table[2][0]       = (ages[2]<ages[0]); 
   assign comp_table[2][1]       = (ages[2]<ages[1]); 
   assign comp_table[2][2]       = (ages[2]<ages[2]); 
   assign comp_table[2][3]       = (ages[2]<ages[3]); 
   assign comp_table[2][4]       = (ages[2]<ages[4]); 
   assign comp_table[2][5]       = (ages[2]<ages[5]); 
   assign comp_table[2][6]       = (ages[2]<ages[6]); 
   assign comp_table[2][7]       = (ages[2]<ages[7]); 
   assign comp_table[2][8]       = (ages[2]<ages[8]); 
   assign comp_table[2][9]       = (ages[2]<ages[9]); 
   assign comp_table[2][10]       = (ages[2]<ages[10]); 
   assign comp_table[2][11]       = (ages[2]<ages[11]); 
   assign comp_table[2][12]       = (ages[2]<ages[12]); 
   assign comp_table[2][13]       = (ages[2]<ages[13]); 
   assign comp_table[2][14]       = (ages[2]<ages[14]); 
   assign comp_table[2][15]       = (ages[2]<ages[15]); 
   assign ready_states[3]     = (statuses[3]==`RS_READY);
   assign issue_first_states[3]  = ready_states[3]
          && (~ready_states[0] || comp_table[0][3]) 
          && (~ready_states[1] || comp_table[1][3]) 
          && (~ready_states[2] || comp_table[2][3]) 
          && (~ready_states[4] || comp_table[4][3]) 
          && (~ready_states[5] || comp_table[5][3]) 
          && (~ready_states[6] || comp_table[6][3]) 
          && (~ready_states[7] || comp_table[7][3]) 
          && (~ready_states[8] || comp_table[8][3]) 
          && (~ready_states[9] || comp_table[9][3]) 
          && (~ready_states[10] || comp_table[10][3]) 
          && (~ready_states[11] || comp_table[11][3]) 
          && (~ready_states[12] || comp_table[12][3]) 
          && (~ready_states[13] || comp_table[13][3]) 
          && (~ready_states[14] || comp_table[14][3]) 
          && (~ready_states[15] || comp_table[15][3]) 
   ;
   assign issue_second_states[3] = ready_states[3] && ~issue_first_states[3] 
          && (~ready_states[0] || comp_table[0][3] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][3] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][3] || issue_first_states[2]) 
          && (~ready_states[4] || comp_table[4][3] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][3] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][3] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][3] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][3] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][3] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][3] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][3] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][3] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][3] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][3] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][3] || issue_first_states[15]) 
   ;
   assign comp_table[3][0]       = (ages[3]<ages[0]); 
   assign comp_table[3][1]       = (ages[3]<ages[1]); 
   assign comp_table[3][2]       = (ages[3]<ages[2]); 
   assign comp_table[3][3]       = (ages[3]<ages[3]); 
   assign comp_table[3][4]       = (ages[3]<ages[4]); 
   assign comp_table[3][5]       = (ages[3]<ages[5]); 
   assign comp_table[3][6]       = (ages[3]<ages[6]); 
   assign comp_table[3][7]       = (ages[3]<ages[7]); 
   assign comp_table[3][8]       = (ages[3]<ages[8]); 
   assign comp_table[3][9]       = (ages[3]<ages[9]); 
   assign comp_table[3][10]       = (ages[3]<ages[10]); 
   assign comp_table[3][11]       = (ages[3]<ages[11]); 
   assign comp_table[3][12]       = (ages[3]<ages[12]); 
   assign comp_table[3][13]       = (ages[3]<ages[13]); 
   assign comp_table[3][14]       = (ages[3]<ages[14]); 
   assign comp_table[3][15]       = (ages[3]<ages[15]); 
   assign ready_states[4]     = (statuses[4]==`RS_READY);
   assign issue_first_states[4]  = ready_states[4]
          && (~ready_states[0] || comp_table[0][4]) 
          && (~ready_states[1] || comp_table[1][4]) 
          && (~ready_states[2] || comp_table[2][4]) 
          && (~ready_states[3] || comp_table[3][4]) 
          && (~ready_states[5] || comp_table[5][4]) 
          && (~ready_states[6] || comp_table[6][4]) 
          && (~ready_states[7] || comp_table[7][4]) 
          && (~ready_states[8] || comp_table[8][4]) 
          && (~ready_states[9] || comp_table[9][4]) 
          && (~ready_states[10] || comp_table[10][4]) 
          && (~ready_states[11] || comp_table[11][4]) 
          && (~ready_states[12] || comp_table[12][4]) 
          && (~ready_states[13] || comp_table[13][4]) 
          && (~ready_states[14] || comp_table[14][4]) 
          && (~ready_states[15] || comp_table[15][4]) 
   ;
   assign issue_second_states[4] = ready_states[4] && ~issue_first_states[4] 
          && (~ready_states[0] || comp_table[0][4] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][4] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][4] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][4] || issue_first_states[3]) 
          && (~ready_states[5] || comp_table[5][4] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][4] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][4] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][4] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][4] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][4] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][4] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][4] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][4] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][4] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][4] || issue_first_states[15]) 
   ;
   assign comp_table[4][0]       = (ages[4]<ages[0]); 
   assign comp_table[4][1]       = (ages[4]<ages[1]); 
   assign comp_table[4][2]       = (ages[4]<ages[2]); 
   assign comp_table[4][3]       = (ages[4]<ages[3]); 
   assign comp_table[4][4]       = (ages[4]<ages[4]); 
   assign comp_table[4][5]       = (ages[4]<ages[5]); 
   assign comp_table[4][6]       = (ages[4]<ages[6]); 
   assign comp_table[4][7]       = (ages[4]<ages[7]); 
   assign comp_table[4][8]       = (ages[4]<ages[8]); 
   assign comp_table[4][9]       = (ages[4]<ages[9]); 
   assign comp_table[4][10]       = (ages[4]<ages[10]); 
   assign comp_table[4][11]       = (ages[4]<ages[11]); 
   assign comp_table[4][12]       = (ages[4]<ages[12]); 
   assign comp_table[4][13]       = (ages[4]<ages[13]); 
   assign comp_table[4][14]       = (ages[4]<ages[14]); 
   assign comp_table[4][15]       = (ages[4]<ages[15]); 
   assign ready_states[5]     = (statuses[5]==`RS_READY);
   assign issue_first_states[5]  = ready_states[5]
          && (~ready_states[0] || comp_table[0][5]) 
          && (~ready_states[1] || comp_table[1][5]) 
          && (~ready_states[2] || comp_table[2][5]) 
          && (~ready_states[3] || comp_table[3][5]) 
          && (~ready_states[4] || comp_table[4][5]) 
          && (~ready_states[6] || comp_table[6][5]) 
          && (~ready_states[7] || comp_table[7][5]) 
          && (~ready_states[8] || comp_table[8][5]) 
          && (~ready_states[9] || comp_table[9][5]) 
          && (~ready_states[10] || comp_table[10][5]) 
          && (~ready_states[11] || comp_table[11][5]) 
          && (~ready_states[12] || comp_table[12][5]) 
          && (~ready_states[13] || comp_table[13][5]) 
          && (~ready_states[14] || comp_table[14][5]) 
          && (~ready_states[15] || comp_table[15][5]) 
   ;
   assign issue_second_states[5] = ready_states[5] && ~issue_first_states[5] 
          && (~ready_states[0] || comp_table[0][5] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][5] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][5] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][5] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][5] || issue_first_states[4]) 
          && (~ready_states[6] || comp_table[6][5] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][5] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][5] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][5] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][5] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][5] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][5] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][5] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][5] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][5] || issue_first_states[15]) 
   ;
   assign comp_table[5][0]       = (ages[5]<ages[0]); 
   assign comp_table[5][1]       = (ages[5]<ages[1]); 
   assign comp_table[5][2]       = (ages[5]<ages[2]); 
   assign comp_table[5][3]       = (ages[5]<ages[3]); 
   assign comp_table[5][4]       = (ages[5]<ages[4]); 
   assign comp_table[5][5]       = (ages[5]<ages[5]); 
   assign comp_table[5][6]       = (ages[5]<ages[6]); 
   assign comp_table[5][7]       = (ages[5]<ages[7]); 
   assign comp_table[5][8]       = (ages[5]<ages[8]); 
   assign comp_table[5][9]       = (ages[5]<ages[9]); 
   assign comp_table[5][10]       = (ages[5]<ages[10]); 
   assign comp_table[5][11]       = (ages[5]<ages[11]); 
   assign comp_table[5][12]       = (ages[5]<ages[12]); 
   assign comp_table[5][13]       = (ages[5]<ages[13]); 
   assign comp_table[5][14]       = (ages[5]<ages[14]); 
   assign comp_table[5][15]       = (ages[5]<ages[15]); 
   assign ready_states[6]     = (statuses[6]==`RS_READY);
   assign issue_first_states[6]  = ready_states[6]
          && (~ready_states[0] || comp_table[0][6]) 
          && (~ready_states[1] || comp_table[1][6]) 
          && (~ready_states[2] || comp_table[2][6]) 
          && (~ready_states[3] || comp_table[3][6]) 
          && (~ready_states[4] || comp_table[4][6]) 
          && (~ready_states[5] || comp_table[5][6]) 
          && (~ready_states[7] || comp_table[7][6]) 
          && (~ready_states[8] || comp_table[8][6]) 
          && (~ready_states[9] || comp_table[9][6]) 
          && (~ready_states[10] || comp_table[10][6]) 
          && (~ready_states[11] || comp_table[11][6]) 
          && (~ready_states[12] || comp_table[12][6]) 
          && (~ready_states[13] || comp_table[13][6]) 
          && (~ready_states[14] || comp_table[14][6]) 
          && (~ready_states[15] || comp_table[15][6]) 
   ;
   assign issue_second_states[6] = ready_states[6] && ~issue_first_states[6] 
          && (~ready_states[0] || comp_table[0][6] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][6] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][6] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][6] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][6] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][6] || issue_first_states[5]) 
          && (~ready_states[7] || comp_table[7][6] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][6] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][6] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][6] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][6] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][6] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][6] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][6] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][6] || issue_first_states[15]) 
   ;
   assign comp_table[6][0]       = (ages[6]<ages[0]); 
   assign comp_table[6][1]       = (ages[6]<ages[1]); 
   assign comp_table[6][2]       = (ages[6]<ages[2]); 
   assign comp_table[6][3]       = (ages[6]<ages[3]); 
   assign comp_table[6][4]       = (ages[6]<ages[4]); 
   assign comp_table[6][5]       = (ages[6]<ages[5]); 
   assign comp_table[6][6]       = (ages[6]<ages[6]); 
   assign comp_table[6][7]       = (ages[6]<ages[7]); 
   assign comp_table[6][8]       = (ages[6]<ages[8]); 
   assign comp_table[6][9]       = (ages[6]<ages[9]); 
   assign comp_table[6][10]       = (ages[6]<ages[10]); 
   assign comp_table[6][11]       = (ages[6]<ages[11]); 
   assign comp_table[6][12]       = (ages[6]<ages[12]); 
   assign comp_table[6][13]       = (ages[6]<ages[13]); 
   assign comp_table[6][14]       = (ages[6]<ages[14]); 
   assign comp_table[6][15]       = (ages[6]<ages[15]); 
   assign ready_states[7]     = (statuses[7]==`RS_READY);
   assign issue_first_states[7]  = ready_states[7]
          && (~ready_states[0] || comp_table[0][7]) 
          && (~ready_states[1] || comp_table[1][7]) 
          && (~ready_states[2] || comp_table[2][7]) 
          && (~ready_states[3] || comp_table[3][7]) 
          && (~ready_states[4] || comp_table[4][7]) 
          && (~ready_states[5] || comp_table[5][7]) 
          && (~ready_states[6] || comp_table[6][7]) 
          && (~ready_states[8] || comp_table[8][7]) 
          && (~ready_states[9] || comp_table[9][7]) 
          && (~ready_states[10] || comp_table[10][7]) 
          && (~ready_states[11] || comp_table[11][7]) 
          && (~ready_states[12] || comp_table[12][7]) 
          && (~ready_states[13] || comp_table[13][7]) 
          && (~ready_states[14] || comp_table[14][7]) 
          && (~ready_states[15] || comp_table[15][7]) 
   ;
   assign issue_second_states[7] = ready_states[7] && ~issue_first_states[7] 
          && (~ready_states[0] || comp_table[0][7] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][7] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][7] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][7] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][7] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][7] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][7] || issue_first_states[6]) 
          && (~ready_states[8] || comp_table[8][7] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][7] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][7] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][7] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][7] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][7] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][7] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][7] || issue_first_states[15]) 
   ;
   assign comp_table[7][0]       = (ages[7]<ages[0]); 
   assign comp_table[7][1]       = (ages[7]<ages[1]); 
   assign comp_table[7][2]       = (ages[7]<ages[2]); 
   assign comp_table[7][3]       = (ages[7]<ages[3]); 
   assign comp_table[7][4]       = (ages[7]<ages[4]); 
   assign comp_table[7][5]       = (ages[7]<ages[5]); 
   assign comp_table[7][6]       = (ages[7]<ages[6]); 
   assign comp_table[7][7]       = (ages[7]<ages[7]); 
   assign comp_table[7][8]       = (ages[7]<ages[8]); 
   assign comp_table[7][9]       = (ages[7]<ages[9]); 
   assign comp_table[7][10]       = (ages[7]<ages[10]); 
   assign comp_table[7][11]       = (ages[7]<ages[11]); 
   assign comp_table[7][12]       = (ages[7]<ages[12]); 
   assign comp_table[7][13]       = (ages[7]<ages[13]); 
   assign comp_table[7][14]       = (ages[7]<ages[14]); 
   assign comp_table[7][15]       = (ages[7]<ages[15]); 
   assign ready_states[8]     = (statuses[8]==`RS_READY);
   assign issue_first_states[8]  = ready_states[8]
          && (~ready_states[0] || comp_table[0][8]) 
          && (~ready_states[1] || comp_table[1][8]) 
          && (~ready_states[2] || comp_table[2][8]) 
          && (~ready_states[3] || comp_table[3][8]) 
          && (~ready_states[4] || comp_table[4][8]) 
          && (~ready_states[5] || comp_table[5][8]) 
          && (~ready_states[6] || comp_table[6][8]) 
          && (~ready_states[7] || comp_table[7][8]) 
          && (~ready_states[9] || comp_table[9][8]) 
          && (~ready_states[10] || comp_table[10][8]) 
          && (~ready_states[11] || comp_table[11][8]) 
          && (~ready_states[12] || comp_table[12][8]) 
          && (~ready_states[13] || comp_table[13][8]) 
          && (~ready_states[14] || comp_table[14][8]) 
          && (~ready_states[15] || comp_table[15][8]) 
   ;
   assign issue_second_states[8] = ready_states[8] && ~issue_first_states[8] 
          && (~ready_states[0] || comp_table[0][8] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][8] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][8] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][8] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][8] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][8] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][8] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][8] || issue_first_states[7]) 
          && (~ready_states[9] || comp_table[9][8] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][8] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][8] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][8] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][8] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][8] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][8] || issue_first_states[15]) 
   ;
   assign comp_table[8][0]       = (ages[8]<ages[0]); 
   assign comp_table[8][1]       = (ages[8]<ages[1]); 
   assign comp_table[8][2]       = (ages[8]<ages[2]); 
   assign comp_table[8][3]       = (ages[8]<ages[3]); 
   assign comp_table[8][4]       = (ages[8]<ages[4]); 
   assign comp_table[8][5]       = (ages[8]<ages[5]); 
   assign comp_table[8][6]       = (ages[8]<ages[6]); 
   assign comp_table[8][7]       = (ages[8]<ages[7]); 
   assign comp_table[8][8]       = (ages[8]<ages[8]); 
   assign comp_table[8][9]       = (ages[8]<ages[9]); 
   assign comp_table[8][10]       = (ages[8]<ages[10]); 
   assign comp_table[8][11]       = (ages[8]<ages[11]); 
   assign comp_table[8][12]       = (ages[8]<ages[12]); 
   assign comp_table[8][13]       = (ages[8]<ages[13]); 
   assign comp_table[8][14]       = (ages[8]<ages[14]); 
   assign comp_table[8][15]       = (ages[8]<ages[15]); 
   assign ready_states[9]     = (statuses[9]==`RS_READY);
   assign issue_first_states[9]  = ready_states[9]
          && (~ready_states[0] || comp_table[0][9]) 
          && (~ready_states[1] || comp_table[1][9]) 
          && (~ready_states[2] || comp_table[2][9]) 
          && (~ready_states[3] || comp_table[3][9]) 
          && (~ready_states[4] || comp_table[4][9]) 
          && (~ready_states[5] || comp_table[5][9]) 
          && (~ready_states[6] || comp_table[6][9]) 
          && (~ready_states[7] || comp_table[7][9]) 
          && (~ready_states[8] || comp_table[8][9]) 
          && (~ready_states[10] || comp_table[10][9]) 
          && (~ready_states[11] || comp_table[11][9]) 
          && (~ready_states[12] || comp_table[12][9]) 
          && (~ready_states[13] || comp_table[13][9]) 
          && (~ready_states[14] || comp_table[14][9]) 
          && (~ready_states[15] || comp_table[15][9]) 
   ;
   assign issue_second_states[9] = ready_states[9] && ~issue_first_states[9] 
          && (~ready_states[0] || comp_table[0][9] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][9] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][9] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][9] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][9] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][9] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][9] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][9] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][9] || issue_first_states[8]) 
          && (~ready_states[10] || comp_table[10][9] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][9] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][9] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][9] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][9] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][9] || issue_first_states[15]) 
   ;
   assign comp_table[9][0]       = (ages[9]<ages[0]); 
   assign comp_table[9][1]       = (ages[9]<ages[1]); 
   assign comp_table[9][2]       = (ages[9]<ages[2]); 
   assign comp_table[9][3]       = (ages[9]<ages[3]); 
   assign comp_table[9][4]       = (ages[9]<ages[4]); 
   assign comp_table[9][5]       = (ages[9]<ages[5]); 
   assign comp_table[9][6]       = (ages[9]<ages[6]); 
   assign comp_table[9][7]       = (ages[9]<ages[7]); 
   assign comp_table[9][8]       = (ages[9]<ages[8]); 
   assign comp_table[9][9]       = (ages[9]<ages[9]); 
   assign comp_table[9][10]       = (ages[9]<ages[10]); 
   assign comp_table[9][11]       = (ages[9]<ages[11]); 
   assign comp_table[9][12]       = (ages[9]<ages[12]); 
   assign comp_table[9][13]       = (ages[9]<ages[13]); 
   assign comp_table[9][14]       = (ages[9]<ages[14]); 
   assign comp_table[9][15]       = (ages[9]<ages[15]); 
   assign ready_states[10]     = (statuses[10]==`RS_READY);
   assign issue_first_states[10]  = ready_states[10]
          && (~ready_states[0] || comp_table[0][10]) 
          && (~ready_states[1] || comp_table[1][10]) 
          && (~ready_states[2] || comp_table[2][10]) 
          && (~ready_states[3] || comp_table[3][10]) 
          && (~ready_states[4] || comp_table[4][10]) 
          && (~ready_states[5] || comp_table[5][10]) 
          && (~ready_states[6] || comp_table[6][10]) 
          && (~ready_states[7] || comp_table[7][10]) 
          && (~ready_states[8] || comp_table[8][10]) 
          && (~ready_states[9] || comp_table[9][10]) 
          && (~ready_states[11] || comp_table[11][10]) 
          && (~ready_states[12] || comp_table[12][10]) 
          && (~ready_states[13] || comp_table[13][10]) 
          && (~ready_states[14] || comp_table[14][10]) 
          && (~ready_states[15] || comp_table[15][10]) 
   ;
   assign issue_second_states[10] = ready_states[10] && ~issue_first_states[10] 
          && (~ready_states[0] || comp_table[0][10] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][10] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][10] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][10] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][10] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][10] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][10] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][10] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][10] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][10] || issue_first_states[9]) 
          && (~ready_states[11] || comp_table[11][10] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][10] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][10] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][10] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][10] || issue_first_states[15]) 
   ;
   assign comp_table[10][0]       = (ages[10]<ages[0]); 
   assign comp_table[10][1]       = (ages[10]<ages[1]); 
   assign comp_table[10][2]       = (ages[10]<ages[2]); 
   assign comp_table[10][3]       = (ages[10]<ages[3]); 
   assign comp_table[10][4]       = (ages[10]<ages[4]); 
   assign comp_table[10][5]       = (ages[10]<ages[5]); 
   assign comp_table[10][6]       = (ages[10]<ages[6]); 
   assign comp_table[10][7]       = (ages[10]<ages[7]); 
   assign comp_table[10][8]       = (ages[10]<ages[8]); 
   assign comp_table[10][9]       = (ages[10]<ages[9]); 
   assign comp_table[10][10]       = (ages[10]<ages[10]); 
   assign comp_table[10][11]       = (ages[10]<ages[11]); 
   assign comp_table[10][12]       = (ages[10]<ages[12]); 
   assign comp_table[10][13]       = (ages[10]<ages[13]); 
   assign comp_table[10][14]       = (ages[10]<ages[14]); 
   assign comp_table[10][15]       = (ages[10]<ages[15]); 
   assign ready_states[11]     = (statuses[11]==`RS_READY);
   assign issue_first_states[11]  = ready_states[11]
          && (~ready_states[0] || comp_table[0][11]) 
          && (~ready_states[1] || comp_table[1][11]) 
          && (~ready_states[2] || comp_table[2][11]) 
          && (~ready_states[3] || comp_table[3][11]) 
          && (~ready_states[4] || comp_table[4][11]) 
          && (~ready_states[5] || comp_table[5][11]) 
          && (~ready_states[6] || comp_table[6][11]) 
          && (~ready_states[7] || comp_table[7][11]) 
          && (~ready_states[8] || comp_table[8][11]) 
          && (~ready_states[9] || comp_table[9][11]) 
          && (~ready_states[10] || comp_table[10][11]) 
          && (~ready_states[12] || comp_table[12][11]) 
          && (~ready_states[13] || comp_table[13][11]) 
          && (~ready_states[14] || comp_table[14][11]) 
          && (~ready_states[15] || comp_table[15][11]) 
   ;
   assign issue_second_states[11] = ready_states[11] && ~issue_first_states[11] 
          && (~ready_states[0] || comp_table[0][11] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][11] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][11] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][11] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][11] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][11] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][11] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][11] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][11] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][11] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][11] || issue_first_states[10]) 
          && (~ready_states[12] || comp_table[12][11] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][11] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][11] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][11] || issue_first_states[15]) 
   ;
   assign comp_table[11][0]       = (ages[11]<ages[0]); 
   assign comp_table[11][1]       = (ages[11]<ages[1]); 
   assign comp_table[11][2]       = (ages[11]<ages[2]); 
   assign comp_table[11][3]       = (ages[11]<ages[3]); 
   assign comp_table[11][4]       = (ages[11]<ages[4]); 
   assign comp_table[11][5]       = (ages[11]<ages[5]); 
   assign comp_table[11][6]       = (ages[11]<ages[6]); 
   assign comp_table[11][7]       = (ages[11]<ages[7]); 
   assign comp_table[11][8]       = (ages[11]<ages[8]); 
   assign comp_table[11][9]       = (ages[11]<ages[9]); 
   assign comp_table[11][10]       = (ages[11]<ages[10]); 
   assign comp_table[11][11]       = (ages[11]<ages[11]); 
   assign comp_table[11][12]       = (ages[11]<ages[12]); 
   assign comp_table[11][13]       = (ages[11]<ages[13]); 
   assign comp_table[11][14]       = (ages[11]<ages[14]); 
   assign comp_table[11][15]       = (ages[11]<ages[15]); 
   assign ready_states[12]     = (statuses[12]==`RS_READY);
   assign issue_first_states[12]  = ready_states[12]
          && (~ready_states[0] || comp_table[0][12]) 
          && (~ready_states[1] || comp_table[1][12]) 
          && (~ready_states[2] || comp_table[2][12]) 
          && (~ready_states[3] || comp_table[3][12]) 
          && (~ready_states[4] || comp_table[4][12]) 
          && (~ready_states[5] || comp_table[5][12]) 
          && (~ready_states[6] || comp_table[6][12]) 
          && (~ready_states[7] || comp_table[7][12]) 
          && (~ready_states[8] || comp_table[8][12]) 
          && (~ready_states[9] || comp_table[9][12]) 
          && (~ready_states[10] || comp_table[10][12]) 
          && (~ready_states[11] || comp_table[11][12]) 
          && (~ready_states[13] || comp_table[13][12]) 
          && (~ready_states[14] || comp_table[14][12]) 
          && (~ready_states[15] || comp_table[15][12]) 
   ;
   assign issue_second_states[12] = ready_states[12] && ~issue_first_states[12] 
          && (~ready_states[0] || comp_table[0][12] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][12] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][12] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][12] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][12] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][12] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][12] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][12] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][12] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][12] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][12] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][12] || issue_first_states[11]) 
          && (~ready_states[13] || comp_table[13][12] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][12] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][12] || issue_first_states[15]) 
   ;
   assign comp_table[12][0]       = (ages[12]<ages[0]); 
   assign comp_table[12][1]       = (ages[12]<ages[1]); 
   assign comp_table[12][2]       = (ages[12]<ages[2]); 
   assign comp_table[12][3]       = (ages[12]<ages[3]); 
   assign comp_table[12][4]       = (ages[12]<ages[4]); 
   assign comp_table[12][5]       = (ages[12]<ages[5]); 
   assign comp_table[12][6]       = (ages[12]<ages[6]); 
   assign comp_table[12][7]       = (ages[12]<ages[7]); 
   assign comp_table[12][8]       = (ages[12]<ages[8]); 
   assign comp_table[12][9]       = (ages[12]<ages[9]); 
   assign comp_table[12][10]       = (ages[12]<ages[10]); 
   assign comp_table[12][11]       = (ages[12]<ages[11]); 
   assign comp_table[12][12]       = (ages[12]<ages[12]); 
   assign comp_table[12][13]       = (ages[12]<ages[13]); 
   assign comp_table[12][14]       = (ages[12]<ages[14]); 
   assign comp_table[12][15]       = (ages[12]<ages[15]); 
   assign ready_states[13]     = (statuses[13]==`RS_READY);
   assign issue_first_states[13]  = ready_states[13]
          && (~ready_states[0] || comp_table[0][13]) 
          && (~ready_states[1] || comp_table[1][13]) 
          && (~ready_states[2] || comp_table[2][13]) 
          && (~ready_states[3] || comp_table[3][13]) 
          && (~ready_states[4] || comp_table[4][13]) 
          && (~ready_states[5] || comp_table[5][13]) 
          && (~ready_states[6] || comp_table[6][13]) 
          && (~ready_states[7] || comp_table[7][13]) 
          && (~ready_states[8] || comp_table[8][13]) 
          && (~ready_states[9] || comp_table[9][13]) 
          && (~ready_states[10] || comp_table[10][13]) 
          && (~ready_states[11] || comp_table[11][13]) 
          && (~ready_states[12] || comp_table[12][13]) 
          && (~ready_states[14] || comp_table[14][13]) 
          && (~ready_states[15] || comp_table[15][13]) 
   ;
   assign issue_second_states[13] = ready_states[13] && ~issue_first_states[13] 
          && (~ready_states[0] || comp_table[0][13] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][13] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][13] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][13] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][13] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][13] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][13] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][13] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][13] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][13] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][13] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][13] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][13] || issue_first_states[12]) 
          && (~ready_states[14] || comp_table[14][13] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][13] || issue_first_states[15]) 
   ;
   assign comp_table[13][0]       = (ages[13]<ages[0]); 
   assign comp_table[13][1]       = (ages[13]<ages[1]); 
   assign comp_table[13][2]       = (ages[13]<ages[2]); 
   assign comp_table[13][3]       = (ages[13]<ages[3]); 
   assign comp_table[13][4]       = (ages[13]<ages[4]); 
   assign comp_table[13][5]       = (ages[13]<ages[5]); 
   assign comp_table[13][6]       = (ages[13]<ages[6]); 
   assign comp_table[13][7]       = (ages[13]<ages[7]); 
   assign comp_table[13][8]       = (ages[13]<ages[8]); 
   assign comp_table[13][9]       = (ages[13]<ages[9]); 
   assign comp_table[13][10]       = (ages[13]<ages[10]); 
   assign comp_table[13][11]       = (ages[13]<ages[11]); 
   assign comp_table[13][12]       = (ages[13]<ages[12]); 
   assign comp_table[13][13]       = (ages[13]<ages[13]); 
   assign comp_table[13][14]       = (ages[13]<ages[14]); 
   assign comp_table[13][15]       = (ages[13]<ages[15]); 
   assign ready_states[14]     = (statuses[14]==`RS_READY);
   assign issue_first_states[14]  = ready_states[14]
          && (~ready_states[0] || comp_table[0][14]) 
          && (~ready_states[1] || comp_table[1][14]) 
          && (~ready_states[2] || comp_table[2][14]) 
          && (~ready_states[3] || comp_table[3][14]) 
          && (~ready_states[4] || comp_table[4][14]) 
          && (~ready_states[5] || comp_table[5][14]) 
          && (~ready_states[6] || comp_table[6][14]) 
          && (~ready_states[7] || comp_table[7][14]) 
          && (~ready_states[8] || comp_table[8][14]) 
          && (~ready_states[9] || comp_table[9][14]) 
          && (~ready_states[10] || comp_table[10][14]) 
          && (~ready_states[11] || comp_table[11][14]) 
          && (~ready_states[12] || comp_table[12][14]) 
          && (~ready_states[13] || comp_table[13][14]) 
          && (~ready_states[15] || comp_table[15][14]) 
   ;
   assign issue_second_states[14] = ready_states[14] && ~issue_first_states[14] 
          && (~ready_states[0] || comp_table[0][14] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][14] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][14] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][14] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][14] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][14] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][14] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][14] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][14] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][14] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][14] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][14] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][14] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][14] || issue_first_states[13]) 
          && (~ready_states[15] || comp_table[15][14] || issue_first_states[15]) 
   ;
   assign comp_table[14][0]       = (ages[14]<ages[0]); 
   assign comp_table[14][1]       = (ages[14]<ages[1]); 
   assign comp_table[14][2]       = (ages[14]<ages[2]); 
   assign comp_table[14][3]       = (ages[14]<ages[3]); 
   assign comp_table[14][4]       = (ages[14]<ages[4]); 
   assign comp_table[14][5]       = (ages[14]<ages[5]); 
   assign comp_table[14][6]       = (ages[14]<ages[6]); 
   assign comp_table[14][7]       = (ages[14]<ages[7]); 
   assign comp_table[14][8]       = (ages[14]<ages[8]); 
   assign comp_table[14][9]       = (ages[14]<ages[9]); 
   assign comp_table[14][10]       = (ages[14]<ages[10]); 
   assign comp_table[14][11]       = (ages[14]<ages[11]); 
   assign comp_table[14][12]       = (ages[14]<ages[12]); 
   assign comp_table[14][13]       = (ages[14]<ages[13]); 
   assign comp_table[14][14]       = (ages[14]<ages[14]); 
   assign comp_table[14][15]       = (ages[14]<ages[15]); 
   assign ready_states[15]     = (statuses[15]==`RS_READY);
   assign issue_first_states[15]  = ready_states[15]
          && (~ready_states[0] || comp_table[0][15]) 
          && (~ready_states[1] || comp_table[1][15]) 
          && (~ready_states[2] || comp_table[2][15]) 
          && (~ready_states[3] || comp_table[3][15]) 
          && (~ready_states[4] || comp_table[4][15]) 
          && (~ready_states[5] || comp_table[5][15]) 
          && (~ready_states[6] || comp_table[6][15]) 
          && (~ready_states[7] || comp_table[7][15]) 
          && (~ready_states[8] || comp_table[8][15]) 
          && (~ready_states[9] || comp_table[9][15]) 
          && (~ready_states[10] || comp_table[10][15]) 
          && (~ready_states[11] || comp_table[11][15]) 
          && (~ready_states[12] || comp_table[12][15]) 
          && (~ready_states[13] || comp_table[13][15]) 
          && (~ready_states[14] || comp_table[14][15]) 
   ;
   assign issue_second_states[15] = ready_states[15] && ~issue_first_states[15] 
          && (~ready_states[0] || comp_table[0][15] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][15] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][15] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][15] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][15] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][15] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][15] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][15] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][15] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][15] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][15] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][15] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][15] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][15] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][15] || issue_first_states[14]) 
   ;
   assign comp_table[15][0]       = (ages[15]<ages[0]); 
   assign comp_table[15][1]       = (ages[15]<ages[1]); 
   assign comp_table[15][2]       = (ages[15]<ages[2]); 
   assign comp_table[15][3]       = (ages[15]<ages[3]); 
   assign comp_table[15][4]       = (ages[15]<ages[4]); 
   assign comp_table[15][5]       = (ages[15]<ages[5]); 
   assign comp_table[15][6]       = (ages[15]<ages[6]); 
   assign comp_table[15][7]       = (ages[15]<ages[7]); 
   assign comp_table[15][8]       = (ages[15]<ages[8]); 
   assign comp_table[15][9]       = (ages[15]<ages[9]); 
   assign comp_table[15][10]       = (ages[15]<ages[10]); 
   assign comp_table[15][11]       = (ages[15]<ages[11]); 
   assign comp_table[15][12]       = (ages[15]<ages[12]); 
   assign comp_table[15][13]       = (ages[15]<ages[13]); 
   assign comp_table[15][14]       = (ages[15]<ages[14]); 
   assign comp_table[15][15]       = (ages[15]<ages[15]); 

   
   ////////////////////////////////////////////////////
   // internal modules (reservation station entries) //
   ////////////////////////////////////////////////////
   generate
      for (i=0; i<`NUM_RSES; i=i+1)
	  begin : RSEMODULES

		   reservation_station_entry entries( .clock(clock), .reset(resets[i]), .fill(fills[i]),

								   .first_empty_filled_in(  (i==0) ? 1'b0 : first_empty_filleds[i-1]  ),
								   .second_empty_filled_in( (i==0) ? 1'b0 : second_empty_filleds[i-1] ),
								   .filling_first( filling1),
								   .filling_second(filling2),
				 
								   // input busses //
								   .dest_reg_in(dest_regs_in[i]),
								   .dest_tag_in(dest_tags_in[i]),
								   .rega_value_in(rega_values_in[i]),
								   .regb_value_in(regb_values_in[i]),
								   .waiting_taga_in(waiting_tagas_in[i]),
								   .waiting_tagb_in(waiting_tagbs_in[i]),                

								   // generic signals to just be passed on //
								   .opa_select_in(opa_selects_in[i]),
								   .opb_select_in(opb_selects_in[i]),
								   .alu_func_in(alu_funcs_in[i]),
								   .rd_mem_in(rd_mems_in[i]),
								   .wr_mem_in(wr_mems_in[i]),
								   .cond_branch_in(cond_branches_in[i]),
								   .uncond_branch_in(uncond_branches_in[i]),
                                                                   .NPC_in(NPCs_in[i]),
                                                                   .IR_in(IRs_in[i]),
                                                                   .PPC_in(PPCs_in[i]),
                                                                   .pht_index_in(pht_indices_in[i]),

								   // cdbs in //
								   .cdb1_tag_in(cdb1_tag_in), .cdb1_value_in(cdb1_value_in),                
								   .cdb2_tag_in(cdb2_tag_in), .cdb2_value_in(cdb2_value_in),

								   // outputs //
								   .status_out(statuses[i]),                                           // signals out
								   .age_out(ages[i]),
								   .first_empty(first_empties[i]),
								   .second_empty(second_empties[i]),
								   .first_empty_filled_out(  first_empty_filleds[i]  ),
								   .second_empty_filled_out( second_empty_filleds[i] ),
								   .dest_reg_out(dest_regs_out[i]),
								   .dest_tag_out(dest_tags_out[i]),
								   .rega_value_out(rega_values_out[i]),
								   .regb_value_out(regb_values_out[i]),

								   // outputs for signals to simply be passed through
								   .opa_select_out(opa_selects_out[i]),
								   .opb_select_out(opb_selects_out[i]),
								   .alu_func_out(alu_funcs_out[i]),
								   .rd_mem_out(rd_mems_out[i]),
								   .wr_mem_out(wr_mems_out[i]),
								   .cond_branch_out(cond_branches_out[i]),
								   .uncond_branch_out(uncond_branches_out[i]),
								   .NPC_out(NPCs_out[i]), 
                                                                   .IR_out(IRs_out[i]),
                                                                   .PPC_out(PPCs_out[i]),
                                                                   .pht_index_out(pht_indices_out[i])

									  );
									  
      end
   endgenerate
   
   
   // state debug output //
   generate
      for (i=0; i<`NUM_RSES*3; i=i+3)
      begin : STATESOUT
	     assign states_out[i+2:i] = statuses[i/3];
      end
   endgenerate
  
   generate
      for (i=0; i<`NUM_RSES; i=i+1)
      begin : ASDAS
          assign ages_out[(i+1)*8-1:(i*8)] = ages[i];
      end
   endgenerate
 
endmodule


