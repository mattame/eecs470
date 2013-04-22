

///////////////////////////////////////////////////////////////////////////////
// This file will hold module definitions of the reservation station table.  //
// The main module utilizes multiple individual reservation station modules. //
///////////////////////////////////////////////////////////////////////////////

//`define SD #1

// defined paramters //
//`define NUM_RSES 16
//`define RS_EMPTY        3'b000
//`define RS_WAITING_A    3'b001
//`define RS_WAITING_B    3'b010
//`define RS_WAITING_BOTH 3'b011
//`define RS_READY        3'b100
//`define RS_TEST         3'b111
//`define RSTAG_NULL      8'hFF           
//`define ZERO_REG         5'd0
//`define NOOP_INST    32'h47ff041f

//`define HISTORY_BITS 8

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
   wire taga_cur_match_cdb1_in;
   wire taga_cur_match_cdb2_in;
   wire tagb_cur_match_cdb1_in;
   wire tagb_cur_match_cdb2_in;
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
                           first_empties,second_empties,states_out,fills,issue_first_states,issue_second_states,ages_out,resets);


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
   output wire  [(`NUM_RSES-1):0]      resets;
   //reg  [(`NUM_RSES-1):0] next_resets;

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

                 // assign current fill states for all entries //
                 assign fills[i] = ( dispatch && ((inst1_valid&&first_empties[i]) || (inst2_valid&&second_empties[i])) ); 
                 
                 // assign the dispatch availabilities //
                 assign dispatch_available1 = first_empties[i];   // note this is a wor, so it accumulates
                 assign dispatch_available2 = second_empties[i];   // note this is a wor, so it accumulates 

                 // assign resets for all rs entries //
                 assign resets[i] = (reset || (issue_first_states[i] && ~inst1_stall_in) || (issue_second_states[i] && ~inst2_stall_in));


		 always@*
		 begin
		 
			 // pull from the first instruction slot //
			 if ( dispatch && inst1_valid && (first_empties[i]) )
			 begin
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

	     end
		 
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

/*
   // START 16 //
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
  // END 16 //
*/

/*
   // START 32 //
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
          && (~ready_states[16] || comp_table[16][0]) 
          && (~ready_states[17] || comp_table[17][0]) 
          && (~ready_states[18] || comp_table[18][0]) 
          && (~ready_states[19] || comp_table[19][0]) 
          && (~ready_states[20] || comp_table[20][0]) 
          && (~ready_states[21] || comp_table[21][0]) 
          && (~ready_states[22] || comp_table[22][0]) 
          && (~ready_states[23] || comp_table[23][0]) 
          && (~ready_states[24] || comp_table[24][0]) 
          && (~ready_states[25] || comp_table[25][0]) 
          && (~ready_states[26] || comp_table[26][0]) 
          && (~ready_states[27] || comp_table[27][0]) 
          && (~ready_states[28] || comp_table[28][0]) 
          && (~ready_states[29] || comp_table[29][0]) 
          && (~ready_states[30] || comp_table[30][0]) 
          && (~ready_states[31] || comp_table[31][0]) 
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
          && (~ready_states[16] || comp_table[16][0] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][0] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][0] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][0] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][0] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][0] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][0] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][0] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][0] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][0] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][0] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][0] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][0] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][0] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][0] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][0] || issue_first_states[31]) 
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
   assign comp_table[0][16]       = (ages[0]<ages[16]); 
   assign comp_table[0][17]       = (ages[0]<ages[17]); 
   assign comp_table[0][18]       = (ages[0]<ages[18]); 
   assign comp_table[0][19]       = (ages[0]<ages[19]); 
   assign comp_table[0][20]       = (ages[0]<ages[20]); 
   assign comp_table[0][21]       = (ages[0]<ages[21]); 
   assign comp_table[0][22]       = (ages[0]<ages[22]); 
   assign comp_table[0][23]       = (ages[0]<ages[23]); 
   assign comp_table[0][24]       = (ages[0]<ages[24]); 
   assign comp_table[0][25]       = (ages[0]<ages[25]); 
   assign comp_table[0][26]       = (ages[0]<ages[26]); 
   assign comp_table[0][27]       = (ages[0]<ages[27]); 
   assign comp_table[0][28]       = (ages[0]<ages[28]); 
   assign comp_table[0][29]       = (ages[0]<ages[29]); 
   assign comp_table[0][30]       = (ages[0]<ages[30]); 
   assign comp_table[0][31]       = (ages[0]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][1]) 
          && (~ready_states[17] || comp_table[17][1]) 
          && (~ready_states[18] || comp_table[18][1]) 
          && (~ready_states[19] || comp_table[19][1]) 
          && (~ready_states[20] || comp_table[20][1]) 
          && (~ready_states[21] || comp_table[21][1]) 
          && (~ready_states[22] || comp_table[22][1]) 
          && (~ready_states[23] || comp_table[23][1]) 
          && (~ready_states[24] || comp_table[24][1]) 
          && (~ready_states[25] || comp_table[25][1]) 
          && (~ready_states[26] || comp_table[26][1]) 
          && (~ready_states[27] || comp_table[27][1]) 
          && (~ready_states[28] || comp_table[28][1]) 
          && (~ready_states[29] || comp_table[29][1]) 
          && (~ready_states[30] || comp_table[30][1]) 
          && (~ready_states[31] || comp_table[31][1]) 
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
          && (~ready_states[16] || comp_table[16][1] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][1] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][1] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][1] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][1] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][1] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][1] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][1] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][1] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][1] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][1] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][1] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][1] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][1] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][1] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][1] || issue_first_states[31]) 
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
   assign comp_table[1][16]       = (ages[1]<ages[16]); 
   assign comp_table[1][17]       = (ages[1]<ages[17]); 
   assign comp_table[1][18]       = (ages[1]<ages[18]); 
   assign comp_table[1][19]       = (ages[1]<ages[19]); 
   assign comp_table[1][20]       = (ages[1]<ages[20]); 
   assign comp_table[1][21]       = (ages[1]<ages[21]); 
   assign comp_table[1][22]       = (ages[1]<ages[22]); 
   assign comp_table[1][23]       = (ages[1]<ages[23]); 
   assign comp_table[1][24]       = (ages[1]<ages[24]); 
   assign comp_table[1][25]       = (ages[1]<ages[25]); 
   assign comp_table[1][26]       = (ages[1]<ages[26]); 
   assign comp_table[1][27]       = (ages[1]<ages[27]); 
   assign comp_table[1][28]       = (ages[1]<ages[28]); 
   assign comp_table[1][29]       = (ages[1]<ages[29]); 
   assign comp_table[1][30]       = (ages[1]<ages[30]); 
   assign comp_table[1][31]       = (ages[1]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][2]) 
          && (~ready_states[17] || comp_table[17][2]) 
          && (~ready_states[18] || comp_table[18][2]) 
          && (~ready_states[19] || comp_table[19][2]) 
          && (~ready_states[20] || comp_table[20][2]) 
          && (~ready_states[21] || comp_table[21][2]) 
          && (~ready_states[22] || comp_table[22][2]) 
          && (~ready_states[23] || comp_table[23][2]) 
          && (~ready_states[24] || comp_table[24][2]) 
          && (~ready_states[25] || comp_table[25][2]) 
          && (~ready_states[26] || comp_table[26][2]) 
          && (~ready_states[27] || comp_table[27][2]) 
          && (~ready_states[28] || comp_table[28][2]) 
          && (~ready_states[29] || comp_table[29][2]) 
          && (~ready_states[30] || comp_table[30][2]) 
          && (~ready_states[31] || comp_table[31][2]) 
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
          && (~ready_states[16] || comp_table[16][2] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][2] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][2] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][2] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][2] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][2] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][2] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][2] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][2] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][2] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][2] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][2] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][2] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][2] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][2] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][2] || issue_first_states[31]) 
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
   assign comp_table[2][16]       = (ages[2]<ages[16]); 
   assign comp_table[2][17]       = (ages[2]<ages[17]); 
   assign comp_table[2][18]       = (ages[2]<ages[18]); 
   assign comp_table[2][19]       = (ages[2]<ages[19]); 
   assign comp_table[2][20]       = (ages[2]<ages[20]); 
   assign comp_table[2][21]       = (ages[2]<ages[21]); 
   assign comp_table[2][22]       = (ages[2]<ages[22]); 
   assign comp_table[2][23]       = (ages[2]<ages[23]); 
   assign comp_table[2][24]       = (ages[2]<ages[24]); 
   assign comp_table[2][25]       = (ages[2]<ages[25]); 
   assign comp_table[2][26]       = (ages[2]<ages[26]); 
   assign comp_table[2][27]       = (ages[2]<ages[27]); 
   assign comp_table[2][28]       = (ages[2]<ages[28]); 
   assign comp_table[2][29]       = (ages[2]<ages[29]); 
   assign comp_table[2][30]       = (ages[2]<ages[30]); 
   assign comp_table[2][31]       = (ages[2]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][3]) 
          && (~ready_states[17] || comp_table[17][3]) 
          && (~ready_states[18] || comp_table[18][3]) 
          && (~ready_states[19] || comp_table[19][3]) 
          && (~ready_states[20] || comp_table[20][3]) 
          && (~ready_states[21] || comp_table[21][3]) 
          && (~ready_states[22] || comp_table[22][3]) 
          && (~ready_states[23] || comp_table[23][3]) 
          && (~ready_states[24] || comp_table[24][3]) 
          && (~ready_states[25] || comp_table[25][3]) 
          && (~ready_states[26] || comp_table[26][3]) 
          && (~ready_states[27] || comp_table[27][3]) 
          && (~ready_states[28] || comp_table[28][3]) 
          && (~ready_states[29] || comp_table[29][3]) 
          && (~ready_states[30] || comp_table[30][3]) 
          && (~ready_states[31] || comp_table[31][3]) 
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
          && (~ready_states[16] || comp_table[16][3] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][3] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][3] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][3] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][3] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][3] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][3] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][3] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][3] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][3] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][3] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][3] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][3] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][3] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][3] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][3] || issue_first_states[31]) 
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
   assign comp_table[3][16]       = (ages[3]<ages[16]); 
   assign comp_table[3][17]       = (ages[3]<ages[17]); 
   assign comp_table[3][18]       = (ages[3]<ages[18]); 
   assign comp_table[3][19]       = (ages[3]<ages[19]); 
   assign comp_table[3][20]       = (ages[3]<ages[20]); 
   assign comp_table[3][21]       = (ages[3]<ages[21]); 
   assign comp_table[3][22]       = (ages[3]<ages[22]); 
   assign comp_table[3][23]       = (ages[3]<ages[23]); 
   assign comp_table[3][24]       = (ages[3]<ages[24]); 
   assign comp_table[3][25]       = (ages[3]<ages[25]); 
   assign comp_table[3][26]       = (ages[3]<ages[26]); 
   assign comp_table[3][27]       = (ages[3]<ages[27]); 
   assign comp_table[3][28]       = (ages[3]<ages[28]); 
   assign comp_table[3][29]       = (ages[3]<ages[29]); 
   assign comp_table[3][30]       = (ages[3]<ages[30]); 
   assign comp_table[3][31]       = (ages[3]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][4]) 
          && (~ready_states[17] || comp_table[17][4]) 
          && (~ready_states[18] || comp_table[18][4]) 
          && (~ready_states[19] || comp_table[19][4]) 
          && (~ready_states[20] || comp_table[20][4]) 
          && (~ready_states[21] || comp_table[21][4]) 
          && (~ready_states[22] || comp_table[22][4]) 
          && (~ready_states[23] || comp_table[23][4]) 
          && (~ready_states[24] || comp_table[24][4]) 
          && (~ready_states[25] || comp_table[25][4]) 
          && (~ready_states[26] || comp_table[26][4]) 
          && (~ready_states[27] || comp_table[27][4]) 
          && (~ready_states[28] || comp_table[28][4]) 
          && (~ready_states[29] || comp_table[29][4]) 
          && (~ready_states[30] || comp_table[30][4]) 
          && (~ready_states[31] || comp_table[31][4]) 
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
          && (~ready_states[16] || comp_table[16][4] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][4] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][4] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][4] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][4] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][4] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][4] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][4] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][4] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][4] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][4] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][4] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][4] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][4] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][4] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][4] || issue_first_states[31]) 
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
   assign comp_table[4][16]       = (ages[4]<ages[16]); 
   assign comp_table[4][17]       = (ages[4]<ages[17]); 
   assign comp_table[4][18]       = (ages[4]<ages[18]); 
   assign comp_table[4][19]       = (ages[4]<ages[19]); 
   assign comp_table[4][20]       = (ages[4]<ages[20]); 
   assign comp_table[4][21]       = (ages[4]<ages[21]); 
   assign comp_table[4][22]       = (ages[4]<ages[22]); 
   assign comp_table[4][23]       = (ages[4]<ages[23]); 
   assign comp_table[4][24]       = (ages[4]<ages[24]); 
   assign comp_table[4][25]       = (ages[4]<ages[25]); 
   assign comp_table[4][26]       = (ages[4]<ages[26]); 
   assign comp_table[4][27]       = (ages[4]<ages[27]); 
   assign comp_table[4][28]       = (ages[4]<ages[28]); 
   assign comp_table[4][29]       = (ages[4]<ages[29]); 
   assign comp_table[4][30]       = (ages[4]<ages[30]); 
   assign comp_table[4][31]       = (ages[4]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][5]) 
          && (~ready_states[17] || comp_table[17][5]) 
          && (~ready_states[18] || comp_table[18][5]) 
          && (~ready_states[19] || comp_table[19][5]) 
          && (~ready_states[20] || comp_table[20][5]) 
          && (~ready_states[21] || comp_table[21][5]) 
          && (~ready_states[22] || comp_table[22][5]) 
          && (~ready_states[23] || comp_table[23][5]) 
          && (~ready_states[24] || comp_table[24][5]) 
          && (~ready_states[25] || comp_table[25][5]) 
          && (~ready_states[26] || comp_table[26][5]) 
          && (~ready_states[27] || comp_table[27][5]) 
          && (~ready_states[28] || comp_table[28][5]) 
          && (~ready_states[29] || comp_table[29][5]) 
          && (~ready_states[30] || comp_table[30][5]) 
          && (~ready_states[31] || comp_table[31][5]) 
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
          && (~ready_states[16] || comp_table[16][5] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][5] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][5] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][5] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][5] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][5] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][5] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][5] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][5] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][5] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][5] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][5] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][5] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][5] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][5] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][5] || issue_first_states[31]) 
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
   assign comp_table[5][16]       = (ages[5]<ages[16]); 
   assign comp_table[5][17]       = (ages[5]<ages[17]); 
   assign comp_table[5][18]       = (ages[5]<ages[18]); 
   assign comp_table[5][19]       = (ages[5]<ages[19]); 
   assign comp_table[5][20]       = (ages[5]<ages[20]); 
   assign comp_table[5][21]       = (ages[5]<ages[21]); 
   assign comp_table[5][22]       = (ages[5]<ages[22]); 
   assign comp_table[5][23]       = (ages[5]<ages[23]); 
   assign comp_table[5][24]       = (ages[5]<ages[24]); 
   assign comp_table[5][25]       = (ages[5]<ages[25]); 
   assign comp_table[5][26]       = (ages[5]<ages[26]); 
   assign comp_table[5][27]       = (ages[5]<ages[27]); 
   assign comp_table[5][28]       = (ages[5]<ages[28]); 
   assign comp_table[5][29]       = (ages[5]<ages[29]); 
   assign comp_table[5][30]       = (ages[5]<ages[30]); 
   assign comp_table[5][31]       = (ages[5]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][6]) 
          && (~ready_states[17] || comp_table[17][6]) 
          && (~ready_states[18] || comp_table[18][6]) 
          && (~ready_states[19] || comp_table[19][6]) 
          && (~ready_states[20] || comp_table[20][6]) 
          && (~ready_states[21] || comp_table[21][6]) 
          && (~ready_states[22] || comp_table[22][6]) 
          && (~ready_states[23] || comp_table[23][6]) 
          && (~ready_states[24] || comp_table[24][6]) 
          && (~ready_states[25] || comp_table[25][6]) 
          && (~ready_states[26] || comp_table[26][6]) 
          && (~ready_states[27] || comp_table[27][6]) 
          && (~ready_states[28] || comp_table[28][6]) 
          && (~ready_states[29] || comp_table[29][6]) 
          && (~ready_states[30] || comp_table[30][6]) 
          && (~ready_states[31] || comp_table[31][6]) 
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
          && (~ready_states[16] || comp_table[16][6] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][6] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][6] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][6] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][6] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][6] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][6] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][6] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][6] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][6] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][6] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][6] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][6] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][6] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][6] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][6] || issue_first_states[31]) 
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
   assign comp_table[6][16]       = (ages[6]<ages[16]); 
   assign comp_table[6][17]       = (ages[6]<ages[17]); 
   assign comp_table[6][18]       = (ages[6]<ages[18]); 
   assign comp_table[6][19]       = (ages[6]<ages[19]); 
   assign comp_table[6][20]       = (ages[6]<ages[20]); 
   assign comp_table[6][21]       = (ages[6]<ages[21]); 
   assign comp_table[6][22]       = (ages[6]<ages[22]); 
   assign comp_table[6][23]       = (ages[6]<ages[23]); 
   assign comp_table[6][24]       = (ages[6]<ages[24]); 
   assign comp_table[6][25]       = (ages[6]<ages[25]); 
   assign comp_table[6][26]       = (ages[6]<ages[26]); 
   assign comp_table[6][27]       = (ages[6]<ages[27]); 
   assign comp_table[6][28]       = (ages[6]<ages[28]); 
   assign comp_table[6][29]       = (ages[6]<ages[29]); 
   assign comp_table[6][30]       = (ages[6]<ages[30]); 
   assign comp_table[6][31]       = (ages[6]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][7]) 
          && (~ready_states[17] || comp_table[17][7]) 
          && (~ready_states[18] || comp_table[18][7]) 
          && (~ready_states[19] || comp_table[19][7]) 
          && (~ready_states[20] || comp_table[20][7]) 
          && (~ready_states[21] || comp_table[21][7]) 
          && (~ready_states[22] || comp_table[22][7]) 
          && (~ready_states[23] || comp_table[23][7]) 
          && (~ready_states[24] || comp_table[24][7]) 
          && (~ready_states[25] || comp_table[25][7]) 
          && (~ready_states[26] || comp_table[26][7]) 
          && (~ready_states[27] || comp_table[27][7]) 
          && (~ready_states[28] || comp_table[28][7]) 
          && (~ready_states[29] || comp_table[29][7]) 
          && (~ready_states[30] || comp_table[30][7]) 
          && (~ready_states[31] || comp_table[31][7]) 
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
          && (~ready_states[16] || comp_table[16][7] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][7] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][7] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][7] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][7] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][7] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][7] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][7] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][7] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][7] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][7] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][7] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][7] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][7] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][7] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][7] || issue_first_states[31]) 
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
   assign comp_table[7][16]       = (ages[7]<ages[16]); 
   assign comp_table[7][17]       = (ages[7]<ages[17]); 
   assign comp_table[7][18]       = (ages[7]<ages[18]); 
   assign comp_table[7][19]       = (ages[7]<ages[19]); 
   assign comp_table[7][20]       = (ages[7]<ages[20]); 
   assign comp_table[7][21]       = (ages[7]<ages[21]); 
   assign comp_table[7][22]       = (ages[7]<ages[22]); 
   assign comp_table[7][23]       = (ages[7]<ages[23]); 
   assign comp_table[7][24]       = (ages[7]<ages[24]); 
   assign comp_table[7][25]       = (ages[7]<ages[25]); 
   assign comp_table[7][26]       = (ages[7]<ages[26]); 
   assign comp_table[7][27]       = (ages[7]<ages[27]); 
   assign comp_table[7][28]       = (ages[7]<ages[28]); 
   assign comp_table[7][29]       = (ages[7]<ages[29]); 
   assign comp_table[7][30]       = (ages[7]<ages[30]); 
   assign comp_table[7][31]       = (ages[7]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][8]) 
          && (~ready_states[17] || comp_table[17][8]) 
          && (~ready_states[18] || comp_table[18][8]) 
          && (~ready_states[19] || comp_table[19][8]) 
          && (~ready_states[20] || comp_table[20][8]) 
          && (~ready_states[21] || comp_table[21][8]) 
          && (~ready_states[22] || comp_table[22][8]) 
          && (~ready_states[23] || comp_table[23][8]) 
          && (~ready_states[24] || comp_table[24][8]) 
          && (~ready_states[25] || comp_table[25][8]) 
          && (~ready_states[26] || comp_table[26][8]) 
          && (~ready_states[27] || comp_table[27][8]) 
          && (~ready_states[28] || comp_table[28][8]) 
          && (~ready_states[29] || comp_table[29][8]) 
          && (~ready_states[30] || comp_table[30][8]) 
          && (~ready_states[31] || comp_table[31][8]) 
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
          && (~ready_states[16] || comp_table[16][8] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][8] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][8] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][8] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][8] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][8] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][8] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][8] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][8] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][8] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][8] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][8] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][8] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][8] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][8] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][8] || issue_first_states[31]) 
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
   assign comp_table[8][16]       = (ages[8]<ages[16]); 
   assign comp_table[8][17]       = (ages[8]<ages[17]); 
   assign comp_table[8][18]       = (ages[8]<ages[18]); 
   assign comp_table[8][19]       = (ages[8]<ages[19]); 
   assign comp_table[8][20]       = (ages[8]<ages[20]); 
   assign comp_table[8][21]       = (ages[8]<ages[21]); 
   assign comp_table[8][22]       = (ages[8]<ages[22]); 
   assign comp_table[8][23]       = (ages[8]<ages[23]); 
   assign comp_table[8][24]       = (ages[8]<ages[24]); 
   assign comp_table[8][25]       = (ages[8]<ages[25]); 
   assign comp_table[8][26]       = (ages[8]<ages[26]); 
   assign comp_table[8][27]       = (ages[8]<ages[27]); 
   assign comp_table[8][28]       = (ages[8]<ages[28]); 
   assign comp_table[8][29]       = (ages[8]<ages[29]); 
   assign comp_table[8][30]       = (ages[8]<ages[30]); 
   assign comp_table[8][31]       = (ages[8]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][9]) 
          && (~ready_states[17] || comp_table[17][9]) 
          && (~ready_states[18] || comp_table[18][9]) 
          && (~ready_states[19] || comp_table[19][9]) 
          && (~ready_states[20] || comp_table[20][9]) 
          && (~ready_states[21] || comp_table[21][9]) 
          && (~ready_states[22] || comp_table[22][9]) 
          && (~ready_states[23] || comp_table[23][9]) 
          && (~ready_states[24] || comp_table[24][9]) 
          && (~ready_states[25] || comp_table[25][9]) 
          && (~ready_states[26] || comp_table[26][9]) 
          && (~ready_states[27] || comp_table[27][9]) 
          && (~ready_states[28] || comp_table[28][9]) 
          && (~ready_states[29] || comp_table[29][9]) 
          && (~ready_states[30] || comp_table[30][9]) 
          && (~ready_states[31] || comp_table[31][9]) 
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
          && (~ready_states[16] || comp_table[16][9] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][9] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][9] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][9] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][9] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][9] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][9] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][9] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][9] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][9] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][9] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][9] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][9] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][9] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][9] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][9] || issue_first_states[31]) 
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
   assign comp_table[9][16]       = (ages[9]<ages[16]); 
   assign comp_table[9][17]       = (ages[9]<ages[17]); 
   assign comp_table[9][18]       = (ages[9]<ages[18]); 
   assign comp_table[9][19]       = (ages[9]<ages[19]); 
   assign comp_table[9][20]       = (ages[9]<ages[20]); 
   assign comp_table[9][21]       = (ages[9]<ages[21]); 
   assign comp_table[9][22]       = (ages[9]<ages[22]); 
   assign comp_table[9][23]       = (ages[9]<ages[23]); 
   assign comp_table[9][24]       = (ages[9]<ages[24]); 
   assign comp_table[9][25]       = (ages[9]<ages[25]); 
   assign comp_table[9][26]       = (ages[9]<ages[26]); 
   assign comp_table[9][27]       = (ages[9]<ages[27]); 
   assign comp_table[9][28]       = (ages[9]<ages[28]); 
   assign comp_table[9][29]       = (ages[9]<ages[29]); 
   assign comp_table[9][30]       = (ages[9]<ages[30]); 
   assign comp_table[9][31]       = (ages[9]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][10]) 
          && (~ready_states[17] || comp_table[17][10]) 
          && (~ready_states[18] || comp_table[18][10]) 
          && (~ready_states[19] || comp_table[19][10]) 
          && (~ready_states[20] || comp_table[20][10]) 
          && (~ready_states[21] || comp_table[21][10]) 
          && (~ready_states[22] || comp_table[22][10]) 
          && (~ready_states[23] || comp_table[23][10]) 
          && (~ready_states[24] || comp_table[24][10]) 
          && (~ready_states[25] || comp_table[25][10]) 
          && (~ready_states[26] || comp_table[26][10]) 
          && (~ready_states[27] || comp_table[27][10]) 
          && (~ready_states[28] || comp_table[28][10]) 
          && (~ready_states[29] || comp_table[29][10]) 
          && (~ready_states[30] || comp_table[30][10]) 
          && (~ready_states[31] || comp_table[31][10]) 
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
          && (~ready_states[16] || comp_table[16][10] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][10] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][10] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][10] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][10] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][10] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][10] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][10] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][10] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][10] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][10] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][10] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][10] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][10] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][10] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][10] || issue_first_states[31]) 
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
   assign comp_table[10][16]       = (ages[10]<ages[16]); 
   assign comp_table[10][17]       = (ages[10]<ages[17]); 
   assign comp_table[10][18]       = (ages[10]<ages[18]); 
   assign comp_table[10][19]       = (ages[10]<ages[19]); 
   assign comp_table[10][20]       = (ages[10]<ages[20]); 
   assign comp_table[10][21]       = (ages[10]<ages[21]); 
   assign comp_table[10][22]       = (ages[10]<ages[22]); 
   assign comp_table[10][23]       = (ages[10]<ages[23]); 
   assign comp_table[10][24]       = (ages[10]<ages[24]); 
   assign comp_table[10][25]       = (ages[10]<ages[25]); 
   assign comp_table[10][26]       = (ages[10]<ages[26]); 
   assign comp_table[10][27]       = (ages[10]<ages[27]); 
   assign comp_table[10][28]       = (ages[10]<ages[28]); 
   assign comp_table[10][29]       = (ages[10]<ages[29]); 
   assign comp_table[10][30]       = (ages[10]<ages[30]); 
   assign comp_table[10][31]       = (ages[10]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][11]) 
          && (~ready_states[17] || comp_table[17][11]) 
          && (~ready_states[18] || comp_table[18][11]) 
          && (~ready_states[19] || comp_table[19][11]) 
          && (~ready_states[20] || comp_table[20][11]) 
          && (~ready_states[21] || comp_table[21][11]) 
          && (~ready_states[22] || comp_table[22][11]) 
          && (~ready_states[23] || comp_table[23][11]) 
          && (~ready_states[24] || comp_table[24][11]) 
          && (~ready_states[25] || comp_table[25][11]) 
          && (~ready_states[26] || comp_table[26][11]) 
          && (~ready_states[27] || comp_table[27][11]) 
          && (~ready_states[28] || comp_table[28][11]) 
          && (~ready_states[29] || comp_table[29][11]) 
          && (~ready_states[30] || comp_table[30][11]) 
          && (~ready_states[31] || comp_table[31][11]) 
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
          && (~ready_states[16] || comp_table[16][11] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][11] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][11] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][11] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][11] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][11] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][11] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][11] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][11] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][11] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][11] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][11] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][11] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][11] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][11] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][11] || issue_first_states[31]) 
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
   assign comp_table[11][16]       = (ages[11]<ages[16]); 
   assign comp_table[11][17]       = (ages[11]<ages[17]); 
   assign comp_table[11][18]       = (ages[11]<ages[18]); 
   assign comp_table[11][19]       = (ages[11]<ages[19]); 
   assign comp_table[11][20]       = (ages[11]<ages[20]); 
   assign comp_table[11][21]       = (ages[11]<ages[21]); 
   assign comp_table[11][22]       = (ages[11]<ages[22]); 
   assign comp_table[11][23]       = (ages[11]<ages[23]); 
   assign comp_table[11][24]       = (ages[11]<ages[24]); 
   assign comp_table[11][25]       = (ages[11]<ages[25]); 
   assign comp_table[11][26]       = (ages[11]<ages[26]); 
   assign comp_table[11][27]       = (ages[11]<ages[27]); 
   assign comp_table[11][28]       = (ages[11]<ages[28]); 
   assign comp_table[11][29]       = (ages[11]<ages[29]); 
   assign comp_table[11][30]       = (ages[11]<ages[30]); 
   assign comp_table[11][31]       = (ages[11]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][12]) 
          && (~ready_states[17] || comp_table[17][12]) 
          && (~ready_states[18] || comp_table[18][12]) 
          && (~ready_states[19] || comp_table[19][12]) 
          && (~ready_states[20] || comp_table[20][12]) 
          && (~ready_states[21] || comp_table[21][12]) 
          && (~ready_states[22] || comp_table[22][12]) 
          && (~ready_states[23] || comp_table[23][12]) 
          && (~ready_states[24] || comp_table[24][12]) 
          && (~ready_states[25] || comp_table[25][12]) 
          && (~ready_states[26] || comp_table[26][12]) 
          && (~ready_states[27] || comp_table[27][12]) 
          && (~ready_states[28] || comp_table[28][12]) 
          && (~ready_states[29] || comp_table[29][12]) 
          && (~ready_states[30] || comp_table[30][12]) 
          && (~ready_states[31] || comp_table[31][12]) 
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
          && (~ready_states[16] || comp_table[16][12] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][12] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][12] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][12] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][12] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][12] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][12] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][12] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][12] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][12] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][12] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][12] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][12] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][12] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][12] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][12] || issue_first_states[31]) 
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
   assign comp_table[12][16]       = (ages[12]<ages[16]); 
   assign comp_table[12][17]       = (ages[12]<ages[17]); 
   assign comp_table[12][18]       = (ages[12]<ages[18]); 
   assign comp_table[12][19]       = (ages[12]<ages[19]); 
   assign comp_table[12][20]       = (ages[12]<ages[20]); 
   assign comp_table[12][21]       = (ages[12]<ages[21]); 
   assign comp_table[12][22]       = (ages[12]<ages[22]); 
   assign comp_table[12][23]       = (ages[12]<ages[23]); 
   assign comp_table[12][24]       = (ages[12]<ages[24]); 
   assign comp_table[12][25]       = (ages[12]<ages[25]); 
   assign comp_table[12][26]       = (ages[12]<ages[26]); 
   assign comp_table[12][27]       = (ages[12]<ages[27]); 
   assign comp_table[12][28]       = (ages[12]<ages[28]); 
   assign comp_table[12][29]       = (ages[12]<ages[29]); 
   assign comp_table[12][30]       = (ages[12]<ages[30]); 
   assign comp_table[12][31]       = (ages[12]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][13]) 
          && (~ready_states[17] || comp_table[17][13]) 
          && (~ready_states[18] || comp_table[18][13]) 
          && (~ready_states[19] || comp_table[19][13]) 
          && (~ready_states[20] || comp_table[20][13]) 
          && (~ready_states[21] || comp_table[21][13]) 
          && (~ready_states[22] || comp_table[22][13]) 
          && (~ready_states[23] || comp_table[23][13]) 
          && (~ready_states[24] || comp_table[24][13]) 
          && (~ready_states[25] || comp_table[25][13]) 
          && (~ready_states[26] || comp_table[26][13]) 
          && (~ready_states[27] || comp_table[27][13]) 
          && (~ready_states[28] || comp_table[28][13]) 
          && (~ready_states[29] || comp_table[29][13]) 
          && (~ready_states[30] || comp_table[30][13]) 
          && (~ready_states[31] || comp_table[31][13]) 
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
          && (~ready_states[16] || comp_table[16][13] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][13] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][13] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][13] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][13] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][13] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][13] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][13] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][13] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][13] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][13] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][13] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][13] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][13] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][13] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][13] || issue_first_states[31]) 
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
   assign comp_table[13][16]       = (ages[13]<ages[16]); 
   assign comp_table[13][17]       = (ages[13]<ages[17]); 
   assign comp_table[13][18]       = (ages[13]<ages[18]); 
   assign comp_table[13][19]       = (ages[13]<ages[19]); 
   assign comp_table[13][20]       = (ages[13]<ages[20]); 
   assign comp_table[13][21]       = (ages[13]<ages[21]); 
   assign comp_table[13][22]       = (ages[13]<ages[22]); 
   assign comp_table[13][23]       = (ages[13]<ages[23]); 
   assign comp_table[13][24]       = (ages[13]<ages[24]); 
   assign comp_table[13][25]       = (ages[13]<ages[25]); 
   assign comp_table[13][26]       = (ages[13]<ages[26]); 
   assign comp_table[13][27]       = (ages[13]<ages[27]); 
   assign comp_table[13][28]       = (ages[13]<ages[28]); 
   assign comp_table[13][29]       = (ages[13]<ages[29]); 
   assign comp_table[13][30]       = (ages[13]<ages[30]); 
   assign comp_table[13][31]       = (ages[13]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][14]) 
          && (~ready_states[17] || comp_table[17][14]) 
          && (~ready_states[18] || comp_table[18][14]) 
          && (~ready_states[19] || comp_table[19][14]) 
          && (~ready_states[20] || comp_table[20][14]) 
          && (~ready_states[21] || comp_table[21][14]) 
          && (~ready_states[22] || comp_table[22][14]) 
          && (~ready_states[23] || comp_table[23][14]) 
          && (~ready_states[24] || comp_table[24][14]) 
          && (~ready_states[25] || comp_table[25][14]) 
          && (~ready_states[26] || comp_table[26][14]) 
          && (~ready_states[27] || comp_table[27][14]) 
          && (~ready_states[28] || comp_table[28][14]) 
          && (~ready_states[29] || comp_table[29][14]) 
          && (~ready_states[30] || comp_table[30][14]) 
          && (~ready_states[31] || comp_table[31][14]) 
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
          && (~ready_states[16] || comp_table[16][14] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][14] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][14] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][14] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][14] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][14] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][14] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][14] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][14] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][14] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][14] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][14] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][14] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][14] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][14] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][14] || issue_first_states[31]) 
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
   assign comp_table[14][16]       = (ages[14]<ages[16]); 
   assign comp_table[14][17]       = (ages[14]<ages[17]); 
   assign comp_table[14][18]       = (ages[14]<ages[18]); 
   assign comp_table[14][19]       = (ages[14]<ages[19]); 
   assign comp_table[14][20]       = (ages[14]<ages[20]); 
   assign comp_table[14][21]       = (ages[14]<ages[21]); 
   assign comp_table[14][22]       = (ages[14]<ages[22]); 
   assign comp_table[14][23]       = (ages[14]<ages[23]); 
   assign comp_table[14][24]       = (ages[14]<ages[24]); 
   assign comp_table[14][25]       = (ages[14]<ages[25]); 
   assign comp_table[14][26]       = (ages[14]<ages[26]); 
   assign comp_table[14][27]       = (ages[14]<ages[27]); 
   assign comp_table[14][28]       = (ages[14]<ages[28]); 
   assign comp_table[14][29]       = (ages[14]<ages[29]); 
   assign comp_table[14][30]       = (ages[14]<ages[30]); 
   assign comp_table[14][31]       = (ages[14]<ages[31]); 
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
          && (~ready_states[16] || comp_table[16][15]) 
          && (~ready_states[17] || comp_table[17][15]) 
          && (~ready_states[18] || comp_table[18][15]) 
          && (~ready_states[19] || comp_table[19][15]) 
          && (~ready_states[20] || comp_table[20][15]) 
          && (~ready_states[21] || comp_table[21][15]) 
          && (~ready_states[22] || comp_table[22][15]) 
          && (~ready_states[23] || comp_table[23][15]) 
          && (~ready_states[24] || comp_table[24][15]) 
          && (~ready_states[25] || comp_table[25][15]) 
          && (~ready_states[26] || comp_table[26][15]) 
          && (~ready_states[27] || comp_table[27][15]) 
          && (~ready_states[28] || comp_table[28][15]) 
          && (~ready_states[29] || comp_table[29][15]) 
          && (~ready_states[30] || comp_table[30][15]) 
          && (~ready_states[31] || comp_table[31][15]) 
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
          && (~ready_states[16] || comp_table[16][15] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][15] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][15] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][15] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][15] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][15] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][15] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][15] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][15] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][15] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][15] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][15] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][15] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][15] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][15] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][15] || issue_first_states[31]) 
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
   assign comp_table[15][16]       = (ages[15]<ages[16]); 
   assign comp_table[15][17]       = (ages[15]<ages[17]); 
   assign comp_table[15][18]       = (ages[15]<ages[18]); 
   assign comp_table[15][19]       = (ages[15]<ages[19]); 
   assign comp_table[15][20]       = (ages[15]<ages[20]); 
   assign comp_table[15][21]       = (ages[15]<ages[21]); 
   assign comp_table[15][22]       = (ages[15]<ages[22]); 
   assign comp_table[15][23]       = (ages[15]<ages[23]); 
   assign comp_table[15][24]       = (ages[15]<ages[24]); 
   assign comp_table[15][25]       = (ages[15]<ages[25]); 
   assign comp_table[15][26]       = (ages[15]<ages[26]); 
   assign comp_table[15][27]       = (ages[15]<ages[27]); 
   assign comp_table[15][28]       = (ages[15]<ages[28]); 
   assign comp_table[15][29]       = (ages[15]<ages[29]); 
   assign comp_table[15][30]       = (ages[15]<ages[30]); 
   assign comp_table[15][31]       = (ages[15]<ages[31]); 
   assign ready_states[16]     = (statuses[16]==`RS_READY);
   assign issue_first_states[16]  = ready_states[16]
          && (~ready_states[0] || comp_table[0][16]) 
          && (~ready_states[1] || comp_table[1][16]) 
          && (~ready_states[2] || comp_table[2][16]) 
          && (~ready_states[3] || comp_table[3][16]) 
          && (~ready_states[4] || comp_table[4][16]) 
          && (~ready_states[5] || comp_table[5][16]) 
          && (~ready_states[6] || comp_table[6][16]) 
          && (~ready_states[7] || comp_table[7][16]) 
          && (~ready_states[8] || comp_table[8][16]) 
          && (~ready_states[9] || comp_table[9][16]) 
          && (~ready_states[10] || comp_table[10][16]) 
          && (~ready_states[11] || comp_table[11][16]) 
          && (~ready_states[12] || comp_table[12][16]) 
          && (~ready_states[13] || comp_table[13][16]) 
          && (~ready_states[14] || comp_table[14][16]) 
          && (~ready_states[15] || comp_table[15][16]) 
          && (~ready_states[17] || comp_table[17][16]) 
          && (~ready_states[18] || comp_table[18][16]) 
          && (~ready_states[19] || comp_table[19][16]) 
          && (~ready_states[20] || comp_table[20][16]) 
          && (~ready_states[21] || comp_table[21][16]) 
          && (~ready_states[22] || comp_table[22][16]) 
          && (~ready_states[23] || comp_table[23][16]) 
          && (~ready_states[24] || comp_table[24][16]) 
          && (~ready_states[25] || comp_table[25][16]) 
          && (~ready_states[26] || comp_table[26][16]) 
          && (~ready_states[27] || comp_table[27][16]) 
          && (~ready_states[28] || comp_table[28][16]) 
          && (~ready_states[29] || comp_table[29][16]) 
          && (~ready_states[30] || comp_table[30][16]) 
          && (~ready_states[31] || comp_table[31][16]) 
   ;
   assign issue_second_states[16] = ready_states[16] && ~issue_first_states[16] 
          && (~ready_states[0] || comp_table[0][16] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][16] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][16] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][16] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][16] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][16] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][16] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][16] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][16] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][16] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][16] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][16] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][16] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][16] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][16] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][16] || issue_first_states[15]) 
          && (~ready_states[17] || comp_table[17][16] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][16] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][16] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][16] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][16] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][16] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][16] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][16] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][16] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][16] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][16] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][16] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][16] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][16] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][16] || issue_first_states[31]) 
   ;
   assign comp_table[16][0]       = (ages[16]<ages[0]); 
   assign comp_table[16][1]       = (ages[16]<ages[1]); 
   assign comp_table[16][2]       = (ages[16]<ages[2]); 
   assign comp_table[16][3]       = (ages[16]<ages[3]); 
   assign comp_table[16][4]       = (ages[16]<ages[4]); 
   assign comp_table[16][5]       = (ages[16]<ages[5]); 
   assign comp_table[16][6]       = (ages[16]<ages[6]); 
   assign comp_table[16][7]       = (ages[16]<ages[7]); 
   assign comp_table[16][8]       = (ages[16]<ages[8]); 
   assign comp_table[16][9]       = (ages[16]<ages[9]); 
   assign comp_table[16][10]       = (ages[16]<ages[10]); 
   assign comp_table[16][11]       = (ages[16]<ages[11]); 
   assign comp_table[16][12]       = (ages[16]<ages[12]); 
   assign comp_table[16][13]       = (ages[16]<ages[13]); 
   assign comp_table[16][14]       = (ages[16]<ages[14]); 
   assign comp_table[16][15]       = (ages[16]<ages[15]); 
   assign comp_table[16][16]       = (ages[16]<ages[16]); 
   assign comp_table[16][17]       = (ages[16]<ages[17]); 
   assign comp_table[16][18]       = (ages[16]<ages[18]); 
   assign comp_table[16][19]       = (ages[16]<ages[19]); 
   assign comp_table[16][20]       = (ages[16]<ages[20]); 
   assign comp_table[16][21]       = (ages[16]<ages[21]); 
   assign comp_table[16][22]       = (ages[16]<ages[22]); 
   assign comp_table[16][23]       = (ages[16]<ages[23]); 
   assign comp_table[16][24]       = (ages[16]<ages[24]); 
   assign comp_table[16][25]       = (ages[16]<ages[25]); 
   assign comp_table[16][26]       = (ages[16]<ages[26]); 
   assign comp_table[16][27]       = (ages[16]<ages[27]); 
   assign comp_table[16][28]       = (ages[16]<ages[28]); 
   assign comp_table[16][29]       = (ages[16]<ages[29]); 
   assign comp_table[16][30]       = (ages[16]<ages[30]); 
   assign comp_table[16][31]       = (ages[16]<ages[31]); 
   assign ready_states[17]     = (statuses[17]==`RS_READY);
   assign issue_first_states[17]  = ready_states[17]
          && (~ready_states[0] || comp_table[0][17]) 
          && (~ready_states[1] || comp_table[1][17]) 
          && (~ready_states[2] || comp_table[2][17]) 
          && (~ready_states[3] || comp_table[3][17]) 
          && (~ready_states[4] || comp_table[4][17]) 
          && (~ready_states[5] || comp_table[5][17]) 
          && (~ready_states[6] || comp_table[6][17]) 
          && (~ready_states[7] || comp_table[7][17]) 
          && (~ready_states[8] || comp_table[8][17]) 
          && (~ready_states[9] || comp_table[9][17]) 
          && (~ready_states[10] || comp_table[10][17]) 
          && (~ready_states[11] || comp_table[11][17]) 
          && (~ready_states[12] || comp_table[12][17]) 
          && (~ready_states[13] || comp_table[13][17]) 
          && (~ready_states[14] || comp_table[14][17]) 
          && (~ready_states[15] || comp_table[15][17]) 
          && (~ready_states[16] || comp_table[16][17]) 
          && (~ready_states[18] || comp_table[18][17]) 
          && (~ready_states[19] || comp_table[19][17]) 
          && (~ready_states[20] || comp_table[20][17]) 
          && (~ready_states[21] || comp_table[21][17]) 
          && (~ready_states[22] || comp_table[22][17]) 
          && (~ready_states[23] || comp_table[23][17]) 
          && (~ready_states[24] || comp_table[24][17]) 
          && (~ready_states[25] || comp_table[25][17]) 
          && (~ready_states[26] || comp_table[26][17]) 
          && (~ready_states[27] || comp_table[27][17]) 
          && (~ready_states[28] || comp_table[28][17]) 
          && (~ready_states[29] || comp_table[29][17]) 
          && (~ready_states[30] || comp_table[30][17]) 
          && (~ready_states[31] || comp_table[31][17]) 
   ;
   assign issue_second_states[17] = ready_states[17] && ~issue_first_states[17] 
          && (~ready_states[0] || comp_table[0][17] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][17] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][17] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][17] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][17] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][17] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][17] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][17] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][17] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][17] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][17] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][17] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][17] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][17] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][17] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][17] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][17] || issue_first_states[16]) 
          && (~ready_states[18] || comp_table[18][17] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][17] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][17] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][17] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][17] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][17] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][17] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][17] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][17] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][17] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][17] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][17] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][17] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][17] || issue_first_states[31]) 
   ;
   assign comp_table[17][0]       = (ages[17]<ages[0]); 
   assign comp_table[17][1]       = (ages[17]<ages[1]); 
   assign comp_table[17][2]       = (ages[17]<ages[2]); 
   assign comp_table[17][3]       = (ages[17]<ages[3]); 
   assign comp_table[17][4]       = (ages[17]<ages[4]); 
   assign comp_table[17][5]       = (ages[17]<ages[5]); 
   assign comp_table[17][6]       = (ages[17]<ages[6]); 
   assign comp_table[17][7]       = (ages[17]<ages[7]); 
   assign comp_table[17][8]       = (ages[17]<ages[8]); 
   assign comp_table[17][9]       = (ages[17]<ages[9]); 
   assign comp_table[17][10]       = (ages[17]<ages[10]); 
   assign comp_table[17][11]       = (ages[17]<ages[11]); 
   assign comp_table[17][12]       = (ages[17]<ages[12]); 
   assign comp_table[17][13]       = (ages[17]<ages[13]); 
   assign comp_table[17][14]       = (ages[17]<ages[14]); 
   assign comp_table[17][15]       = (ages[17]<ages[15]); 
   assign comp_table[17][16]       = (ages[17]<ages[16]); 
   assign comp_table[17][17]       = (ages[17]<ages[17]); 
   assign comp_table[17][18]       = (ages[17]<ages[18]); 
   assign comp_table[17][19]       = (ages[17]<ages[19]); 
   assign comp_table[17][20]       = (ages[17]<ages[20]); 
   assign comp_table[17][21]       = (ages[17]<ages[21]); 
   assign comp_table[17][22]       = (ages[17]<ages[22]); 
   assign comp_table[17][23]       = (ages[17]<ages[23]); 
   assign comp_table[17][24]       = (ages[17]<ages[24]); 
   assign comp_table[17][25]       = (ages[17]<ages[25]); 
   assign comp_table[17][26]       = (ages[17]<ages[26]); 
   assign comp_table[17][27]       = (ages[17]<ages[27]); 
   assign comp_table[17][28]       = (ages[17]<ages[28]); 
   assign comp_table[17][29]       = (ages[17]<ages[29]); 
   assign comp_table[17][30]       = (ages[17]<ages[30]); 
   assign comp_table[17][31]       = (ages[17]<ages[31]); 
   assign ready_states[18]     = (statuses[18]==`RS_READY);
   assign issue_first_states[18]  = ready_states[18]
          && (~ready_states[0] || comp_table[0][18]) 
          && (~ready_states[1] || comp_table[1][18]) 
          && (~ready_states[2] || comp_table[2][18]) 
          && (~ready_states[3] || comp_table[3][18]) 
          && (~ready_states[4] || comp_table[4][18]) 
          && (~ready_states[5] || comp_table[5][18]) 
          && (~ready_states[6] || comp_table[6][18]) 
          && (~ready_states[7] || comp_table[7][18]) 
          && (~ready_states[8] || comp_table[8][18]) 
          && (~ready_states[9] || comp_table[9][18]) 
          && (~ready_states[10] || comp_table[10][18]) 
          && (~ready_states[11] || comp_table[11][18]) 
          && (~ready_states[12] || comp_table[12][18]) 
          && (~ready_states[13] || comp_table[13][18]) 
          && (~ready_states[14] || comp_table[14][18]) 
          && (~ready_states[15] || comp_table[15][18]) 
          && (~ready_states[16] || comp_table[16][18]) 
          && (~ready_states[17] || comp_table[17][18]) 
          && (~ready_states[19] || comp_table[19][18]) 
          && (~ready_states[20] || comp_table[20][18]) 
          && (~ready_states[21] || comp_table[21][18]) 
          && (~ready_states[22] || comp_table[22][18]) 
          && (~ready_states[23] || comp_table[23][18]) 
          && (~ready_states[24] || comp_table[24][18]) 
          && (~ready_states[25] || comp_table[25][18]) 
          && (~ready_states[26] || comp_table[26][18]) 
          && (~ready_states[27] || comp_table[27][18]) 
          && (~ready_states[28] || comp_table[28][18]) 
          && (~ready_states[29] || comp_table[29][18]) 
          && (~ready_states[30] || comp_table[30][18]) 
          && (~ready_states[31] || comp_table[31][18]) 
   ;
   assign issue_second_states[18] = ready_states[18] && ~issue_first_states[18] 
          && (~ready_states[0] || comp_table[0][18] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][18] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][18] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][18] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][18] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][18] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][18] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][18] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][18] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][18] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][18] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][18] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][18] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][18] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][18] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][18] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][18] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][18] || issue_first_states[17]) 
          && (~ready_states[19] || comp_table[19][18] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][18] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][18] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][18] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][18] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][18] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][18] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][18] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][18] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][18] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][18] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][18] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][18] || issue_first_states[31]) 
   ;
   assign comp_table[18][0]       = (ages[18]<ages[0]); 
   assign comp_table[18][1]       = (ages[18]<ages[1]); 
   assign comp_table[18][2]       = (ages[18]<ages[2]); 
   assign comp_table[18][3]       = (ages[18]<ages[3]); 
   assign comp_table[18][4]       = (ages[18]<ages[4]); 
   assign comp_table[18][5]       = (ages[18]<ages[5]); 
   assign comp_table[18][6]       = (ages[18]<ages[6]); 
   assign comp_table[18][7]       = (ages[18]<ages[7]); 
   assign comp_table[18][8]       = (ages[18]<ages[8]); 
   assign comp_table[18][9]       = (ages[18]<ages[9]); 
   assign comp_table[18][10]       = (ages[18]<ages[10]); 
   assign comp_table[18][11]       = (ages[18]<ages[11]); 
   assign comp_table[18][12]       = (ages[18]<ages[12]); 
   assign comp_table[18][13]       = (ages[18]<ages[13]); 
   assign comp_table[18][14]       = (ages[18]<ages[14]); 
   assign comp_table[18][15]       = (ages[18]<ages[15]); 
   assign comp_table[18][16]       = (ages[18]<ages[16]); 
   assign comp_table[18][17]       = (ages[18]<ages[17]); 
   assign comp_table[18][18]       = (ages[18]<ages[18]); 
   assign comp_table[18][19]       = (ages[18]<ages[19]); 
   assign comp_table[18][20]       = (ages[18]<ages[20]); 
   assign comp_table[18][21]       = (ages[18]<ages[21]); 
   assign comp_table[18][22]       = (ages[18]<ages[22]); 
   assign comp_table[18][23]       = (ages[18]<ages[23]); 
   assign comp_table[18][24]       = (ages[18]<ages[24]); 
   assign comp_table[18][25]       = (ages[18]<ages[25]); 
   assign comp_table[18][26]       = (ages[18]<ages[26]); 
   assign comp_table[18][27]       = (ages[18]<ages[27]); 
   assign comp_table[18][28]       = (ages[18]<ages[28]); 
   assign comp_table[18][29]       = (ages[18]<ages[29]); 
   assign comp_table[18][30]       = (ages[18]<ages[30]); 
   assign comp_table[18][31]       = (ages[18]<ages[31]); 
   assign ready_states[19]     = (statuses[19]==`RS_READY);
   assign issue_first_states[19]  = ready_states[19]
          && (~ready_states[0] || comp_table[0][19]) 
          && (~ready_states[1] || comp_table[1][19]) 
          && (~ready_states[2] || comp_table[2][19]) 
          && (~ready_states[3] || comp_table[3][19]) 
          && (~ready_states[4] || comp_table[4][19]) 
          && (~ready_states[5] || comp_table[5][19]) 
          && (~ready_states[6] || comp_table[6][19]) 
          && (~ready_states[7] || comp_table[7][19]) 
          && (~ready_states[8] || comp_table[8][19]) 
          && (~ready_states[9] || comp_table[9][19]) 
          && (~ready_states[10] || comp_table[10][19]) 
          && (~ready_states[11] || comp_table[11][19]) 
          && (~ready_states[12] || comp_table[12][19]) 
          && (~ready_states[13] || comp_table[13][19]) 
          && (~ready_states[14] || comp_table[14][19]) 
          && (~ready_states[15] || comp_table[15][19]) 
          && (~ready_states[16] || comp_table[16][19]) 
          && (~ready_states[17] || comp_table[17][19]) 
          && (~ready_states[18] || comp_table[18][19]) 
          && (~ready_states[20] || comp_table[20][19]) 
          && (~ready_states[21] || comp_table[21][19]) 
          && (~ready_states[22] || comp_table[22][19]) 
          && (~ready_states[23] || comp_table[23][19]) 
          && (~ready_states[24] || comp_table[24][19]) 
          && (~ready_states[25] || comp_table[25][19]) 
          && (~ready_states[26] || comp_table[26][19]) 
          && (~ready_states[27] || comp_table[27][19]) 
          && (~ready_states[28] || comp_table[28][19]) 
          && (~ready_states[29] || comp_table[29][19]) 
          && (~ready_states[30] || comp_table[30][19]) 
          && (~ready_states[31] || comp_table[31][19]) 
   ;
   assign issue_second_states[19] = ready_states[19] && ~issue_first_states[19] 
          && (~ready_states[0] || comp_table[0][19] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][19] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][19] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][19] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][19] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][19] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][19] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][19] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][19] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][19] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][19] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][19] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][19] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][19] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][19] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][19] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][19] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][19] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][19] || issue_first_states[18]) 
          && (~ready_states[20] || comp_table[20][19] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][19] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][19] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][19] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][19] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][19] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][19] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][19] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][19] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][19] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][19] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][19] || issue_first_states[31]) 
   ;
   assign comp_table[19][0]       = (ages[19]<ages[0]); 
   assign comp_table[19][1]       = (ages[19]<ages[1]); 
   assign comp_table[19][2]       = (ages[19]<ages[2]); 
   assign comp_table[19][3]       = (ages[19]<ages[3]); 
   assign comp_table[19][4]       = (ages[19]<ages[4]); 
   assign comp_table[19][5]       = (ages[19]<ages[5]); 
   assign comp_table[19][6]       = (ages[19]<ages[6]); 
   assign comp_table[19][7]       = (ages[19]<ages[7]); 
   assign comp_table[19][8]       = (ages[19]<ages[8]); 
   assign comp_table[19][9]       = (ages[19]<ages[9]); 
   assign comp_table[19][10]       = (ages[19]<ages[10]); 
   assign comp_table[19][11]       = (ages[19]<ages[11]); 
   assign comp_table[19][12]       = (ages[19]<ages[12]); 
   assign comp_table[19][13]       = (ages[19]<ages[13]); 
   assign comp_table[19][14]       = (ages[19]<ages[14]); 
   assign comp_table[19][15]       = (ages[19]<ages[15]); 
   assign comp_table[19][16]       = (ages[19]<ages[16]); 
   assign comp_table[19][17]       = (ages[19]<ages[17]); 
   assign comp_table[19][18]       = (ages[19]<ages[18]); 
   assign comp_table[19][19]       = (ages[19]<ages[19]); 
   assign comp_table[19][20]       = (ages[19]<ages[20]); 
   assign comp_table[19][21]       = (ages[19]<ages[21]); 
   assign comp_table[19][22]       = (ages[19]<ages[22]); 
   assign comp_table[19][23]       = (ages[19]<ages[23]); 
   assign comp_table[19][24]       = (ages[19]<ages[24]); 
   assign comp_table[19][25]       = (ages[19]<ages[25]); 
   assign comp_table[19][26]       = (ages[19]<ages[26]); 
   assign comp_table[19][27]       = (ages[19]<ages[27]); 
   assign comp_table[19][28]       = (ages[19]<ages[28]); 
   assign comp_table[19][29]       = (ages[19]<ages[29]); 
   assign comp_table[19][30]       = (ages[19]<ages[30]); 
   assign comp_table[19][31]       = (ages[19]<ages[31]); 
   assign ready_states[20]     = (statuses[20]==`RS_READY);
   assign issue_first_states[20]  = ready_states[20]
          && (~ready_states[0] || comp_table[0][20]) 
          && (~ready_states[1] || comp_table[1][20]) 
          && (~ready_states[2] || comp_table[2][20]) 
          && (~ready_states[3] || comp_table[3][20]) 
          && (~ready_states[4] || comp_table[4][20]) 
          && (~ready_states[5] || comp_table[5][20]) 
          && (~ready_states[6] || comp_table[6][20]) 
          && (~ready_states[7] || comp_table[7][20]) 
          && (~ready_states[8] || comp_table[8][20]) 
          && (~ready_states[9] || comp_table[9][20]) 
          && (~ready_states[10] || comp_table[10][20]) 
          && (~ready_states[11] || comp_table[11][20]) 
          && (~ready_states[12] || comp_table[12][20]) 
          && (~ready_states[13] || comp_table[13][20]) 
          && (~ready_states[14] || comp_table[14][20]) 
          && (~ready_states[15] || comp_table[15][20]) 
          && (~ready_states[16] || comp_table[16][20]) 
          && (~ready_states[17] || comp_table[17][20]) 
          && (~ready_states[18] || comp_table[18][20]) 
          && (~ready_states[19] || comp_table[19][20]) 
          && (~ready_states[21] || comp_table[21][20]) 
          && (~ready_states[22] || comp_table[22][20]) 
          && (~ready_states[23] || comp_table[23][20]) 
          && (~ready_states[24] || comp_table[24][20]) 
          && (~ready_states[25] || comp_table[25][20]) 
          && (~ready_states[26] || comp_table[26][20]) 
          && (~ready_states[27] || comp_table[27][20]) 
          && (~ready_states[28] || comp_table[28][20]) 
          && (~ready_states[29] || comp_table[29][20]) 
          && (~ready_states[30] || comp_table[30][20]) 
          && (~ready_states[31] || comp_table[31][20]) 
   ;
   assign issue_second_states[20] = ready_states[20] && ~issue_first_states[20] 
          && (~ready_states[0] || comp_table[0][20] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][20] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][20] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][20] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][20] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][20] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][20] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][20] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][20] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][20] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][20] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][20] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][20] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][20] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][20] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][20] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][20] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][20] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][20] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][20] || issue_first_states[19]) 
          && (~ready_states[21] || comp_table[21][20] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][20] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][20] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][20] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][20] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][20] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][20] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][20] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][20] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][20] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][20] || issue_first_states[31]) 
   ;
   assign comp_table[20][0]       = (ages[20]<ages[0]); 
   assign comp_table[20][1]       = (ages[20]<ages[1]); 
   assign comp_table[20][2]       = (ages[20]<ages[2]); 
   assign comp_table[20][3]       = (ages[20]<ages[3]); 
   assign comp_table[20][4]       = (ages[20]<ages[4]); 
   assign comp_table[20][5]       = (ages[20]<ages[5]); 
   assign comp_table[20][6]       = (ages[20]<ages[6]); 
   assign comp_table[20][7]       = (ages[20]<ages[7]); 
   assign comp_table[20][8]       = (ages[20]<ages[8]); 
   assign comp_table[20][9]       = (ages[20]<ages[9]); 
   assign comp_table[20][10]       = (ages[20]<ages[10]); 
   assign comp_table[20][11]       = (ages[20]<ages[11]); 
   assign comp_table[20][12]       = (ages[20]<ages[12]); 
   assign comp_table[20][13]       = (ages[20]<ages[13]); 
   assign comp_table[20][14]       = (ages[20]<ages[14]); 
   assign comp_table[20][15]       = (ages[20]<ages[15]); 
   assign comp_table[20][16]       = (ages[20]<ages[16]); 
   assign comp_table[20][17]       = (ages[20]<ages[17]); 
   assign comp_table[20][18]       = (ages[20]<ages[18]); 
   assign comp_table[20][19]       = (ages[20]<ages[19]); 
   assign comp_table[20][20]       = (ages[20]<ages[20]); 
   assign comp_table[20][21]       = (ages[20]<ages[21]); 
   assign comp_table[20][22]       = (ages[20]<ages[22]); 
   assign comp_table[20][23]       = (ages[20]<ages[23]); 
   assign comp_table[20][24]       = (ages[20]<ages[24]); 
   assign comp_table[20][25]       = (ages[20]<ages[25]); 
   assign comp_table[20][26]       = (ages[20]<ages[26]); 
   assign comp_table[20][27]       = (ages[20]<ages[27]); 
   assign comp_table[20][28]       = (ages[20]<ages[28]); 
   assign comp_table[20][29]       = (ages[20]<ages[29]); 
   assign comp_table[20][30]       = (ages[20]<ages[30]); 
   assign comp_table[20][31]       = (ages[20]<ages[31]); 
   assign ready_states[21]     = (statuses[21]==`RS_READY);
   assign issue_first_states[21]  = ready_states[21]
          && (~ready_states[0] || comp_table[0][21]) 
          && (~ready_states[1] || comp_table[1][21]) 
          && (~ready_states[2] || comp_table[2][21]) 
          && (~ready_states[3] || comp_table[3][21]) 
          && (~ready_states[4] || comp_table[4][21]) 
          && (~ready_states[5] || comp_table[5][21]) 
          && (~ready_states[6] || comp_table[6][21]) 
          && (~ready_states[7] || comp_table[7][21]) 
          && (~ready_states[8] || comp_table[8][21]) 
          && (~ready_states[9] || comp_table[9][21]) 
          && (~ready_states[10] || comp_table[10][21]) 
          && (~ready_states[11] || comp_table[11][21]) 
          && (~ready_states[12] || comp_table[12][21]) 
          && (~ready_states[13] || comp_table[13][21]) 
          && (~ready_states[14] || comp_table[14][21]) 
          && (~ready_states[15] || comp_table[15][21]) 
          && (~ready_states[16] || comp_table[16][21]) 
          && (~ready_states[17] || comp_table[17][21]) 
          && (~ready_states[18] || comp_table[18][21]) 
          && (~ready_states[19] || comp_table[19][21]) 
          && (~ready_states[20] || comp_table[20][21]) 
          && (~ready_states[22] || comp_table[22][21]) 
          && (~ready_states[23] || comp_table[23][21]) 
          && (~ready_states[24] || comp_table[24][21]) 
          && (~ready_states[25] || comp_table[25][21]) 
          && (~ready_states[26] || comp_table[26][21]) 
          && (~ready_states[27] || comp_table[27][21]) 
          && (~ready_states[28] || comp_table[28][21]) 
          && (~ready_states[29] || comp_table[29][21]) 
          && (~ready_states[30] || comp_table[30][21]) 
          && (~ready_states[31] || comp_table[31][21]) 
   ;
   assign issue_second_states[21] = ready_states[21] && ~issue_first_states[21] 
          && (~ready_states[0] || comp_table[0][21] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][21] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][21] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][21] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][21] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][21] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][21] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][21] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][21] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][21] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][21] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][21] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][21] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][21] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][21] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][21] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][21] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][21] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][21] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][21] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][21] || issue_first_states[20]) 
          && (~ready_states[22] || comp_table[22][21] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][21] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][21] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][21] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][21] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][21] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][21] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][21] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][21] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][21] || issue_first_states[31]) 
   ;
   assign comp_table[21][0]       = (ages[21]<ages[0]); 
   assign comp_table[21][1]       = (ages[21]<ages[1]); 
   assign comp_table[21][2]       = (ages[21]<ages[2]); 
   assign comp_table[21][3]       = (ages[21]<ages[3]); 
   assign comp_table[21][4]       = (ages[21]<ages[4]); 
   assign comp_table[21][5]       = (ages[21]<ages[5]); 
   assign comp_table[21][6]       = (ages[21]<ages[6]); 
   assign comp_table[21][7]       = (ages[21]<ages[7]); 
   assign comp_table[21][8]       = (ages[21]<ages[8]); 
   assign comp_table[21][9]       = (ages[21]<ages[9]); 
   assign comp_table[21][10]       = (ages[21]<ages[10]); 
   assign comp_table[21][11]       = (ages[21]<ages[11]); 
   assign comp_table[21][12]       = (ages[21]<ages[12]); 
   assign comp_table[21][13]       = (ages[21]<ages[13]); 
   assign comp_table[21][14]       = (ages[21]<ages[14]); 
   assign comp_table[21][15]       = (ages[21]<ages[15]); 
   assign comp_table[21][16]       = (ages[21]<ages[16]); 
   assign comp_table[21][17]       = (ages[21]<ages[17]); 
   assign comp_table[21][18]       = (ages[21]<ages[18]); 
   assign comp_table[21][19]       = (ages[21]<ages[19]); 
   assign comp_table[21][20]       = (ages[21]<ages[20]); 
   assign comp_table[21][21]       = (ages[21]<ages[21]); 
   assign comp_table[21][22]       = (ages[21]<ages[22]); 
   assign comp_table[21][23]       = (ages[21]<ages[23]); 
   assign comp_table[21][24]       = (ages[21]<ages[24]); 
   assign comp_table[21][25]       = (ages[21]<ages[25]); 
   assign comp_table[21][26]       = (ages[21]<ages[26]); 
   assign comp_table[21][27]       = (ages[21]<ages[27]); 
   assign comp_table[21][28]       = (ages[21]<ages[28]); 
   assign comp_table[21][29]       = (ages[21]<ages[29]); 
   assign comp_table[21][30]       = (ages[21]<ages[30]); 
   assign comp_table[21][31]       = (ages[21]<ages[31]); 
   assign ready_states[22]     = (statuses[22]==`RS_READY);
   assign issue_first_states[22]  = ready_states[22]
          && (~ready_states[0] || comp_table[0][22]) 
          && (~ready_states[1] || comp_table[1][22]) 
          && (~ready_states[2] || comp_table[2][22]) 
          && (~ready_states[3] || comp_table[3][22]) 
          && (~ready_states[4] || comp_table[4][22]) 
          && (~ready_states[5] || comp_table[5][22]) 
          && (~ready_states[6] || comp_table[6][22]) 
          && (~ready_states[7] || comp_table[7][22]) 
          && (~ready_states[8] || comp_table[8][22]) 
          && (~ready_states[9] || comp_table[9][22]) 
          && (~ready_states[10] || comp_table[10][22]) 
          && (~ready_states[11] || comp_table[11][22]) 
          && (~ready_states[12] || comp_table[12][22]) 
          && (~ready_states[13] || comp_table[13][22]) 
          && (~ready_states[14] || comp_table[14][22]) 
          && (~ready_states[15] || comp_table[15][22]) 
          && (~ready_states[16] || comp_table[16][22]) 
          && (~ready_states[17] || comp_table[17][22]) 
          && (~ready_states[18] || comp_table[18][22]) 
          && (~ready_states[19] || comp_table[19][22]) 
          && (~ready_states[20] || comp_table[20][22]) 
          && (~ready_states[21] || comp_table[21][22]) 
          && (~ready_states[23] || comp_table[23][22]) 
          && (~ready_states[24] || comp_table[24][22]) 
          && (~ready_states[25] || comp_table[25][22]) 
          && (~ready_states[26] || comp_table[26][22]) 
          && (~ready_states[27] || comp_table[27][22]) 
          && (~ready_states[28] || comp_table[28][22]) 
          && (~ready_states[29] || comp_table[29][22]) 
          && (~ready_states[30] || comp_table[30][22]) 
          && (~ready_states[31] || comp_table[31][22]) 
   ;
   assign issue_second_states[22] = ready_states[22] && ~issue_first_states[22] 
          && (~ready_states[0] || comp_table[0][22] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][22] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][22] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][22] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][22] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][22] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][22] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][22] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][22] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][22] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][22] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][22] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][22] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][22] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][22] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][22] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][22] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][22] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][22] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][22] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][22] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][22] || issue_first_states[21]) 
          && (~ready_states[23] || comp_table[23][22] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][22] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][22] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][22] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][22] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][22] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][22] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][22] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][22] || issue_first_states[31]) 
   ;
   assign comp_table[22][0]       = (ages[22]<ages[0]); 
   assign comp_table[22][1]       = (ages[22]<ages[1]); 
   assign comp_table[22][2]       = (ages[22]<ages[2]); 
   assign comp_table[22][3]       = (ages[22]<ages[3]); 
   assign comp_table[22][4]       = (ages[22]<ages[4]); 
   assign comp_table[22][5]       = (ages[22]<ages[5]); 
   assign comp_table[22][6]       = (ages[22]<ages[6]); 
   assign comp_table[22][7]       = (ages[22]<ages[7]); 
   assign comp_table[22][8]       = (ages[22]<ages[8]); 
   assign comp_table[22][9]       = (ages[22]<ages[9]); 
   assign comp_table[22][10]       = (ages[22]<ages[10]); 
   assign comp_table[22][11]       = (ages[22]<ages[11]); 
   assign comp_table[22][12]       = (ages[22]<ages[12]); 
   assign comp_table[22][13]       = (ages[22]<ages[13]); 
   assign comp_table[22][14]       = (ages[22]<ages[14]); 
   assign comp_table[22][15]       = (ages[22]<ages[15]); 
   assign comp_table[22][16]       = (ages[22]<ages[16]); 
   assign comp_table[22][17]       = (ages[22]<ages[17]); 
   assign comp_table[22][18]       = (ages[22]<ages[18]); 
   assign comp_table[22][19]       = (ages[22]<ages[19]); 
   assign comp_table[22][20]       = (ages[22]<ages[20]); 
   assign comp_table[22][21]       = (ages[22]<ages[21]); 
   assign comp_table[22][22]       = (ages[22]<ages[22]); 
   assign comp_table[22][23]       = (ages[22]<ages[23]); 
   assign comp_table[22][24]       = (ages[22]<ages[24]); 
   assign comp_table[22][25]       = (ages[22]<ages[25]); 
   assign comp_table[22][26]       = (ages[22]<ages[26]); 
   assign comp_table[22][27]       = (ages[22]<ages[27]); 
   assign comp_table[22][28]       = (ages[22]<ages[28]); 
   assign comp_table[22][29]       = (ages[22]<ages[29]); 
   assign comp_table[22][30]       = (ages[22]<ages[30]); 
   assign comp_table[22][31]       = (ages[22]<ages[31]); 
   assign ready_states[23]     = (statuses[23]==`RS_READY);
   assign issue_first_states[23]  = ready_states[23]
          && (~ready_states[0] || comp_table[0][23]) 
          && (~ready_states[1] || comp_table[1][23]) 
          && (~ready_states[2] || comp_table[2][23]) 
          && (~ready_states[3] || comp_table[3][23]) 
          && (~ready_states[4] || comp_table[4][23]) 
          && (~ready_states[5] || comp_table[5][23]) 
          && (~ready_states[6] || comp_table[6][23]) 
          && (~ready_states[7] || comp_table[7][23]) 
          && (~ready_states[8] || comp_table[8][23]) 
          && (~ready_states[9] || comp_table[9][23]) 
          && (~ready_states[10] || comp_table[10][23]) 
          && (~ready_states[11] || comp_table[11][23]) 
          && (~ready_states[12] || comp_table[12][23]) 
          && (~ready_states[13] || comp_table[13][23]) 
          && (~ready_states[14] || comp_table[14][23]) 
          && (~ready_states[15] || comp_table[15][23]) 
          && (~ready_states[16] || comp_table[16][23]) 
          && (~ready_states[17] || comp_table[17][23]) 
          && (~ready_states[18] || comp_table[18][23]) 
          && (~ready_states[19] || comp_table[19][23]) 
          && (~ready_states[20] || comp_table[20][23]) 
          && (~ready_states[21] || comp_table[21][23]) 
          && (~ready_states[22] || comp_table[22][23]) 
          && (~ready_states[24] || comp_table[24][23]) 
          && (~ready_states[25] || comp_table[25][23]) 
          && (~ready_states[26] || comp_table[26][23]) 
          && (~ready_states[27] || comp_table[27][23]) 
          && (~ready_states[28] || comp_table[28][23]) 
          && (~ready_states[29] || comp_table[29][23]) 
          && (~ready_states[30] || comp_table[30][23]) 
          && (~ready_states[31] || comp_table[31][23]) 
   ;
   assign issue_second_states[23] = ready_states[23] && ~issue_first_states[23] 
          && (~ready_states[0] || comp_table[0][23] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][23] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][23] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][23] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][23] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][23] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][23] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][23] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][23] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][23] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][23] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][23] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][23] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][23] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][23] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][23] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][23] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][23] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][23] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][23] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][23] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][23] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][23] || issue_first_states[22]) 
          && (~ready_states[24] || comp_table[24][23] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][23] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][23] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][23] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][23] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][23] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][23] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][23] || issue_first_states[31]) 
   ;
   assign comp_table[23][0]       = (ages[23]<ages[0]); 
   assign comp_table[23][1]       = (ages[23]<ages[1]); 
   assign comp_table[23][2]       = (ages[23]<ages[2]); 
   assign comp_table[23][3]       = (ages[23]<ages[3]); 
   assign comp_table[23][4]       = (ages[23]<ages[4]); 
   assign comp_table[23][5]       = (ages[23]<ages[5]); 
   assign comp_table[23][6]       = (ages[23]<ages[6]); 
   assign comp_table[23][7]       = (ages[23]<ages[7]); 
   assign comp_table[23][8]       = (ages[23]<ages[8]); 
   assign comp_table[23][9]       = (ages[23]<ages[9]); 
   assign comp_table[23][10]       = (ages[23]<ages[10]); 
   assign comp_table[23][11]       = (ages[23]<ages[11]); 
   assign comp_table[23][12]       = (ages[23]<ages[12]); 
   assign comp_table[23][13]       = (ages[23]<ages[13]); 
   assign comp_table[23][14]       = (ages[23]<ages[14]); 
   assign comp_table[23][15]       = (ages[23]<ages[15]); 
   assign comp_table[23][16]       = (ages[23]<ages[16]); 
   assign comp_table[23][17]       = (ages[23]<ages[17]); 
   assign comp_table[23][18]       = (ages[23]<ages[18]); 
   assign comp_table[23][19]       = (ages[23]<ages[19]); 
   assign comp_table[23][20]       = (ages[23]<ages[20]); 
   assign comp_table[23][21]       = (ages[23]<ages[21]); 
   assign comp_table[23][22]       = (ages[23]<ages[22]); 
   assign comp_table[23][23]       = (ages[23]<ages[23]); 
   assign comp_table[23][24]       = (ages[23]<ages[24]); 
   assign comp_table[23][25]       = (ages[23]<ages[25]); 
   assign comp_table[23][26]       = (ages[23]<ages[26]); 
   assign comp_table[23][27]       = (ages[23]<ages[27]); 
   assign comp_table[23][28]       = (ages[23]<ages[28]); 
   assign comp_table[23][29]       = (ages[23]<ages[29]); 
   assign comp_table[23][30]       = (ages[23]<ages[30]); 
   assign comp_table[23][31]       = (ages[23]<ages[31]); 
   assign ready_states[24]     = (statuses[24]==`RS_READY);
   assign issue_first_states[24]  = ready_states[24]
          && (~ready_states[0] || comp_table[0][24]) 
          && (~ready_states[1] || comp_table[1][24]) 
          && (~ready_states[2] || comp_table[2][24]) 
          && (~ready_states[3] || comp_table[3][24]) 
          && (~ready_states[4] || comp_table[4][24]) 
          && (~ready_states[5] || comp_table[5][24]) 
          && (~ready_states[6] || comp_table[6][24]) 
          && (~ready_states[7] || comp_table[7][24]) 
          && (~ready_states[8] || comp_table[8][24]) 
          && (~ready_states[9] || comp_table[9][24]) 
          && (~ready_states[10] || comp_table[10][24]) 
          && (~ready_states[11] || comp_table[11][24]) 
          && (~ready_states[12] || comp_table[12][24]) 
          && (~ready_states[13] || comp_table[13][24]) 
          && (~ready_states[14] || comp_table[14][24]) 
          && (~ready_states[15] || comp_table[15][24]) 
          && (~ready_states[16] || comp_table[16][24]) 
          && (~ready_states[17] || comp_table[17][24]) 
          && (~ready_states[18] || comp_table[18][24]) 
          && (~ready_states[19] || comp_table[19][24]) 
          && (~ready_states[20] || comp_table[20][24]) 
          && (~ready_states[21] || comp_table[21][24]) 
          && (~ready_states[22] || comp_table[22][24]) 
          && (~ready_states[23] || comp_table[23][24]) 
          && (~ready_states[25] || comp_table[25][24]) 
          && (~ready_states[26] || comp_table[26][24]) 
          && (~ready_states[27] || comp_table[27][24]) 
          && (~ready_states[28] || comp_table[28][24]) 
          && (~ready_states[29] || comp_table[29][24]) 
          && (~ready_states[30] || comp_table[30][24]) 
          && (~ready_states[31] || comp_table[31][24]) 
   ;
   assign issue_second_states[24] = ready_states[24] && ~issue_first_states[24] 
          && (~ready_states[0] || comp_table[0][24] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][24] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][24] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][24] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][24] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][24] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][24] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][24] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][24] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][24] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][24] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][24] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][24] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][24] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][24] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][24] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][24] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][24] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][24] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][24] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][24] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][24] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][24] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][24] || issue_first_states[23]) 
          && (~ready_states[25] || comp_table[25][24] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][24] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][24] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][24] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][24] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][24] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][24] || issue_first_states[31]) 
   ;
   assign comp_table[24][0]       = (ages[24]<ages[0]); 
   assign comp_table[24][1]       = (ages[24]<ages[1]); 
   assign comp_table[24][2]       = (ages[24]<ages[2]); 
   assign comp_table[24][3]       = (ages[24]<ages[3]); 
   assign comp_table[24][4]       = (ages[24]<ages[4]); 
   assign comp_table[24][5]       = (ages[24]<ages[5]); 
   assign comp_table[24][6]       = (ages[24]<ages[6]); 
   assign comp_table[24][7]       = (ages[24]<ages[7]); 
   assign comp_table[24][8]       = (ages[24]<ages[8]); 
   assign comp_table[24][9]       = (ages[24]<ages[9]); 
   assign comp_table[24][10]       = (ages[24]<ages[10]); 
   assign comp_table[24][11]       = (ages[24]<ages[11]); 
   assign comp_table[24][12]       = (ages[24]<ages[12]); 
   assign comp_table[24][13]       = (ages[24]<ages[13]); 
   assign comp_table[24][14]       = (ages[24]<ages[14]); 
   assign comp_table[24][15]       = (ages[24]<ages[15]); 
   assign comp_table[24][16]       = (ages[24]<ages[16]); 
   assign comp_table[24][17]       = (ages[24]<ages[17]); 
   assign comp_table[24][18]       = (ages[24]<ages[18]); 
   assign comp_table[24][19]       = (ages[24]<ages[19]); 
   assign comp_table[24][20]       = (ages[24]<ages[20]); 
   assign comp_table[24][21]       = (ages[24]<ages[21]); 
   assign comp_table[24][22]       = (ages[24]<ages[22]); 
   assign comp_table[24][23]       = (ages[24]<ages[23]); 
   assign comp_table[24][24]       = (ages[24]<ages[24]); 
   assign comp_table[24][25]       = (ages[24]<ages[25]); 
   assign comp_table[24][26]       = (ages[24]<ages[26]); 
   assign comp_table[24][27]       = (ages[24]<ages[27]); 
   assign comp_table[24][28]       = (ages[24]<ages[28]); 
   assign comp_table[24][29]       = (ages[24]<ages[29]); 
   assign comp_table[24][30]       = (ages[24]<ages[30]); 
   assign comp_table[24][31]       = (ages[24]<ages[31]); 
   assign ready_states[25]     = (statuses[25]==`RS_READY);
   assign issue_first_states[25]  = ready_states[25]
          && (~ready_states[0] || comp_table[0][25]) 
          && (~ready_states[1] || comp_table[1][25]) 
          && (~ready_states[2] || comp_table[2][25]) 
          && (~ready_states[3] || comp_table[3][25]) 
          && (~ready_states[4] || comp_table[4][25]) 
          && (~ready_states[5] || comp_table[5][25]) 
          && (~ready_states[6] || comp_table[6][25]) 
          && (~ready_states[7] || comp_table[7][25]) 
          && (~ready_states[8] || comp_table[8][25]) 
          && (~ready_states[9] || comp_table[9][25]) 
          && (~ready_states[10] || comp_table[10][25]) 
          && (~ready_states[11] || comp_table[11][25]) 
          && (~ready_states[12] || comp_table[12][25]) 
          && (~ready_states[13] || comp_table[13][25]) 
          && (~ready_states[14] || comp_table[14][25]) 
          && (~ready_states[15] || comp_table[15][25]) 
          && (~ready_states[16] || comp_table[16][25]) 
          && (~ready_states[17] || comp_table[17][25]) 
          && (~ready_states[18] || comp_table[18][25]) 
          && (~ready_states[19] || comp_table[19][25]) 
          && (~ready_states[20] || comp_table[20][25]) 
          && (~ready_states[21] || comp_table[21][25]) 
          && (~ready_states[22] || comp_table[22][25]) 
          && (~ready_states[23] || comp_table[23][25]) 
          && (~ready_states[24] || comp_table[24][25]) 
          && (~ready_states[26] || comp_table[26][25]) 
          && (~ready_states[27] || comp_table[27][25]) 
          && (~ready_states[28] || comp_table[28][25]) 
          && (~ready_states[29] || comp_table[29][25]) 
          && (~ready_states[30] || comp_table[30][25]) 
          && (~ready_states[31] || comp_table[31][25]) 
   ;
   assign issue_second_states[25] = ready_states[25] && ~issue_first_states[25] 
          && (~ready_states[0] || comp_table[0][25] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][25] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][25] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][25] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][25] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][25] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][25] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][25] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][25] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][25] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][25] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][25] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][25] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][25] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][25] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][25] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][25] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][25] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][25] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][25] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][25] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][25] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][25] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][25] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][25] || issue_first_states[24]) 
          && (~ready_states[26] || comp_table[26][25] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][25] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][25] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][25] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][25] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][25] || issue_first_states[31]) 
   ;
   assign comp_table[25][0]       = (ages[25]<ages[0]); 
   assign comp_table[25][1]       = (ages[25]<ages[1]); 
   assign comp_table[25][2]       = (ages[25]<ages[2]); 
   assign comp_table[25][3]       = (ages[25]<ages[3]); 
   assign comp_table[25][4]       = (ages[25]<ages[4]); 
   assign comp_table[25][5]       = (ages[25]<ages[5]); 
   assign comp_table[25][6]       = (ages[25]<ages[6]); 
   assign comp_table[25][7]       = (ages[25]<ages[7]); 
   assign comp_table[25][8]       = (ages[25]<ages[8]); 
   assign comp_table[25][9]       = (ages[25]<ages[9]); 
   assign comp_table[25][10]       = (ages[25]<ages[10]); 
   assign comp_table[25][11]       = (ages[25]<ages[11]); 
   assign comp_table[25][12]       = (ages[25]<ages[12]); 
   assign comp_table[25][13]       = (ages[25]<ages[13]); 
   assign comp_table[25][14]       = (ages[25]<ages[14]); 
   assign comp_table[25][15]       = (ages[25]<ages[15]); 
   assign comp_table[25][16]       = (ages[25]<ages[16]); 
   assign comp_table[25][17]       = (ages[25]<ages[17]); 
   assign comp_table[25][18]       = (ages[25]<ages[18]); 
   assign comp_table[25][19]       = (ages[25]<ages[19]); 
   assign comp_table[25][20]       = (ages[25]<ages[20]); 
   assign comp_table[25][21]       = (ages[25]<ages[21]); 
   assign comp_table[25][22]       = (ages[25]<ages[22]); 
   assign comp_table[25][23]       = (ages[25]<ages[23]); 
   assign comp_table[25][24]       = (ages[25]<ages[24]); 
   assign comp_table[25][25]       = (ages[25]<ages[25]); 
   assign comp_table[25][26]       = (ages[25]<ages[26]); 
   assign comp_table[25][27]       = (ages[25]<ages[27]); 
   assign comp_table[25][28]       = (ages[25]<ages[28]); 
   assign comp_table[25][29]       = (ages[25]<ages[29]); 
   assign comp_table[25][30]       = (ages[25]<ages[30]); 
   assign comp_table[25][31]       = (ages[25]<ages[31]); 
   assign ready_states[26]     = (statuses[26]==`RS_READY);
   assign issue_first_states[26]  = ready_states[26]
          && (~ready_states[0] || comp_table[0][26]) 
          && (~ready_states[1] || comp_table[1][26]) 
          && (~ready_states[2] || comp_table[2][26]) 
          && (~ready_states[3] || comp_table[3][26]) 
          && (~ready_states[4] || comp_table[4][26]) 
          && (~ready_states[5] || comp_table[5][26]) 
          && (~ready_states[6] || comp_table[6][26]) 
          && (~ready_states[7] || comp_table[7][26]) 
          && (~ready_states[8] || comp_table[8][26]) 
          && (~ready_states[9] || comp_table[9][26]) 
          && (~ready_states[10] || comp_table[10][26]) 
          && (~ready_states[11] || comp_table[11][26]) 
          && (~ready_states[12] || comp_table[12][26]) 
          && (~ready_states[13] || comp_table[13][26]) 
          && (~ready_states[14] || comp_table[14][26]) 
          && (~ready_states[15] || comp_table[15][26]) 
          && (~ready_states[16] || comp_table[16][26]) 
          && (~ready_states[17] || comp_table[17][26]) 
          && (~ready_states[18] || comp_table[18][26]) 
          && (~ready_states[19] || comp_table[19][26]) 
          && (~ready_states[20] || comp_table[20][26]) 
          && (~ready_states[21] || comp_table[21][26]) 
          && (~ready_states[22] || comp_table[22][26]) 
          && (~ready_states[23] || comp_table[23][26]) 
          && (~ready_states[24] || comp_table[24][26]) 
          && (~ready_states[25] || comp_table[25][26]) 
          && (~ready_states[27] || comp_table[27][26]) 
          && (~ready_states[28] || comp_table[28][26]) 
          && (~ready_states[29] || comp_table[29][26]) 
          && (~ready_states[30] || comp_table[30][26]) 
          && (~ready_states[31] || comp_table[31][26]) 
   ;
   assign issue_second_states[26] = ready_states[26] && ~issue_first_states[26] 
          && (~ready_states[0] || comp_table[0][26] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][26] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][26] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][26] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][26] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][26] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][26] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][26] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][26] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][26] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][26] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][26] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][26] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][26] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][26] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][26] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][26] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][26] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][26] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][26] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][26] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][26] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][26] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][26] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][26] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][26] || issue_first_states[25]) 
          && (~ready_states[27] || comp_table[27][26] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][26] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][26] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][26] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][26] || issue_first_states[31]) 
   ;
   assign comp_table[26][0]       = (ages[26]<ages[0]); 
   assign comp_table[26][1]       = (ages[26]<ages[1]); 
   assign comp_table[26][2]       = (ages[26]<ages[2]); 
   assign comp_table[26][3]       = (ages[26]<ages[3]); 
   assign comp_table[26][4]       = (ages[26]<ages[4]); 
   assign comp_table[26][5]       = (ages[26]<ages[5]); 
   assign comp_table[26][6]       = (ages[26]<ages[6]); 
   assign comp_table[26][7]       = (ages[26]<ages[7]); 
   assign comp_table[26][8]       = (ages[26]<ages[8]); 
   assign comp_table[26][9]       = (ages[26]<ages[9]); 
   assign comp_table[26][10]       = (ages[26]<ages[10]); 
   assign comp_table[26][11]       = (ages[26]<ages[11]); 
   assign comp_table[26][12]       = (ages[26]<ages[12]); 
   assign comp_table[26][13]       = (ages[26]<ages[13]); 
   assign comp_table[26][14]       = (ages[26]<ages[14]); 
   assign comp_table[26][15]       = (ages[26]<ages[15]); 
   assign comp_table[26][16]       = (ages[26]<ages[16]); 
   assign comp_table[26][17]       = (ages[26]<ages[17]); 
   assign comp_table[26][18]       = (ages[26]<ages[18]); 
   assign comp_table[26][19]       = (ages[26]<ages[19]); 
   assign comp_table[26][20]       = (ages[26]<ages[20]); 
   assign comp_table[26][21]       = (ages[26]<ages[21]); 
   assign comp_table[26][22]       = (ages[26]<ages[22]); 
   assign comp_table[26][23]       = (ages[26]<ages[23]); 
   assign comp_table[26][24]       = (ages[26]<ages[24]); 
   assign comp_table[26][25]       = (ages[26]<ages[25]); 
   assign comp_table[26][26]       = (ages[26]<ages[26]); 
   assign comp_table[26][27]       = (ages[26]<ages[27]); 
   assign comp_table[26][28]       = (ages[26]<ages[28]); 
   assign comp_table[26][29]       = (ages[26]<ages[29]); 
   assign comp_table[26][30]       = (ages[26]<ages[30]); 
   assign comp_table[26][31]       = (ages[26]<ages[31]); 
   assign ready_states[27]     = (statuses[27]==`RS_READY);
   assign issue_first_states[27]  = ready_states[27]
          && (~ready_states[0] || comp_table[0][27]) 
          && (~ready_states[1] || comp_table[1][27]) 
          && (~ready_states[2] || comp_table[2][27]) 
          && (~ready_states[3] || comp_table[3][27]) 
          && (~ready_states[4] || comp_table[4][27]) 
          && (~ready_states[5] || comp_table[5][27]) 
          && (~ready_states[6] || comp_table[6][27]) 
          && (~ready_states[7] || comp_table[7][27]) 
          && (~ready_states[8] || comp_table[8][27]) 
          && (~ready_states[9] || comp_table[9][27]) 
          && (~ready_states[10] || comp_table[10][27]) 
          && (~ready_states[11] || comp_table[11][27]) 
          && (~ready_states[12] || comp_table[12][27]) 
          && (~ready_states[13] || comp_table[13][27]) 
          && (~ready_states[14] || comp_table[14][27]) 
          && (~ready_states[15] || comp_table[15][27]) 
          && (~ready_states[16] || comp_table[16][27]) 
          && (~ready_states[17] || comp_table[17][27]) 
          && (~ready_states[18] || comp_table[18][27]) 
          && (~ready_states[19] || comp_table[19][27]) 
          && (~ready_states[20] || comp_table[20][27]) 
          && (~ready_states[21] || comp_table[21][27]) 
          && (~ready_states[22] || comp_table[22][27]) 
          && (~ready_states[23] || comp_table[23][27]) 
          && (~ready_states[24] || comp_table[24][27]) 
          && (~ready_states[25] || comp_table[25][27]) 
          && (~ready_states[26] || comp_table[26][27]) 
          && (~ready_states[28] || comp_table[28][27]) 
          && (~ready_states[29] || comp_table[29][27]) 
          && (~ready_states[30] || comp_table[30][27]) 
          && (~ready_states[31] || comp_table[31][27]) 
   ;
   assign issue_second_states[27] = ready_states[27] && ~issue_first_states[27] 
          && (~ready_states[0] || comp_table[0][27] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][27] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][27] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][27] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][27] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][27] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][27] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][27] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][27] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][27] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][27] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][27] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][27] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][27] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][27] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][27] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][27] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][27] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][27] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][27] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][27] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][27] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][27] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][27] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][27] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][27] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][27] || issue_first_states[26]) 
          && (~ready_states[28] || comp_table[28][27] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][27] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][27] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][27] || issue_first_states[31]) 
   ;
   assign comp_table[27][0]       = (ages[27]<ages[0]); 
   assign comp_table[27][1]       = (ages[27]<ages[1]); 
   assign comp_table[27][2]       = (ages[27]<ages[2]); 
   assign comp_table[27][3]       = (ages[27]<ages[3]); 
   assign comp_table[27][4]       = (ages[27]<ages[4]); 
   assign comp_table[27][5]       = (ages[27]<ages[5]); 
   assign comp_table[27][6]       = (ages[27]<ages[6]); 
   assign comp_table[27][7]       = (ages[27]<ages[7]); 
   assign comp_table[27][8]       = (ages[27]<ages[8]); 
   assign comp_table[27][9]       = (ages[27]<ages[9]); 
   assign comp_table[27][10]       = (ages[27]<ages[10]); 
   assign comp_table[27][11]       = (ages[27]<ages[11]); 
   assign comp_table[27][12]       = (ages[27]<ages[12]); 
   assign comp_table[27][13]       = (ages[27]<ages[13]); 
   assign comp_table[27][14]       = (ages[27]<ages[14]); 
   assign comp_table[27][15]       = (ages[27]<ages[15]); 
   assign comp_table[27][16]       = (ages[27]<ages[16]); 
   assign comp_table[27][17]       = (ages[27]<ages[17]); 
   assign comp_table[27][18]       = (ages[27]<ages[18]); 
   assign comp_table[27][19]       = (ages[27]<ages[19]); 
   assign comp_table[27][20]       = (ages[27]<ages[20]); 
   assign comp_table[27][21]       = (ages[27]<ages[21]); 
   assign comp_table[27][22]       = (ages[27]<ages[22]); 
   assign comp_table[27][23]       = (ages[27]<ages[23]); 
   assign comp_table[27][24]       = (ages[27]<ages[24]); 
   assign comp_table[27][25]       = (ages[27]<ages[25]); 
   assign comp_table[27][26]       = (ages[27]<ages[26]); 
   assign comp_table[27][27]       = (ages[27]<ages[27]); 
   assign comp_table[27][28]       = (ages[27]<ages[28]); 
   assign comp_table[27][29]       = (ages[27]<ages[29]); 
   assign comp_table[27][30]       = (ages[27]<ages[30]); 
   assign comp_table[27][31]       = (ages[27]<ages[31]); 
   assign ready_states[28]     = (statuses[28]==`RS_READY);
   assign issue_first_states[28]  = ready_states[28]
          && (~ready_states[0] || comp_table[0][28]) 
          && (~ready_states[1] || comp_table[1][28]) 
          && (~ready_states[2] || comp_table[2][28]) 
          && (~ready_states[3] || comp_table[3][28]) 
          && (~ready_states[4] || comp_table[4][28]) 
          && (~ready_states[5] || comp_table[5][28]) 
          && (~ready_states[6] || comp_table[6][28]) 
          && (~ready_states[7] || comp_table[7][28]) 
          && (~ready_states[8] || comp_table[8][28]) 
          && (~ready_states[9] || comp_table[9][28]) 
          && (~ready_states[10] || comp_table[10][28]) 
          && (~ready_states[11] || comp_table[11][28]) 
          && (~ready_states[12] || comp_table[12][28]) 
          && (~ready_states[13] || comp_table[13][28]) 
          && (~ready_states[14] || comp_table[14][28]) 
          && (~ready_states[15] || comp_table[15][28]) 
          && (~ready_states[16] || comp_table[16][28]) 
          && (~ready_states[17] || comp_table[17][28]) 
          && (~ready_states[18] || comp_table[18][28]) 
          && (~ready_states[19] || comp_table[19][28]) 
          && (~ready_states[20] || comp_table[20][28]) 
          && (~ready_states[21] || comp_table[21][28]) 
          && (~ready_states[22] || comp_table[22][28]) 
          && (~ready_states[23] || comp_table[23][28]) 
          && (~ready_states[24] || comp_table[24][28]) 
          && (~ready_states[25] || comp_table[25][28]) 
          && (~ready_states[26] || comp_table[26][28]) 
          && (~ready_states[27] || comp_table[27][28]) 
          && (~ready_states[29] || comp_table[29][28]) 
          && (~ready_states[30] || comp_table[30][28]) 
          && (~ready_states[31] || comp_table[31][28]) 
   ;
   assign issue_second_states[28] = ready_states[28] && ~issue_first_states[28] 
          && (~ready_states[0] || comp_table[0][28] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][28] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][28] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][28] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][28] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][28] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][28] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][28] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][28] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][28] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][28] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][28] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][28] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][28] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][28] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][28] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][28] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][28] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][28] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][28] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][28] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][28] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][28] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][28] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][28] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][28] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][28] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][28] || issue_first_states[27]) 
          && (~ready_states[29] || comp_table[29][28] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][28] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][28] || issue_first_states[31]) 
   ;
   assign comp_table[28][0]       = (ages[28]<ages[0]); 
   assign comp_table[28][1]       = (ages[28]<ages[1]); 
   assign comp_table[28][2]       = (ages[28]<ages[2]); 
   assign comp_table[28][3]       = (ages[28]<ages[3]); 
   assign comp_table[28][4]       = (ages[28]<ages[4]); 
   assign comp_table[28][5]       = (ages[28]<ages[5]); 
   assign comp_table[28][6]       = (ages[28]<ages[6]); 
   assign comp_table[28][7]       = (ages[28]<ages[7]); 
   assign comp_table[28][8]       = (ages[28]<ages[8]); 
   assign comp_table[28][9]       = (ages[28]<ages[9]); 
   assign comp_table[28][10]       = (ages[28]<ages[10]); 
   assign comp_table[28][11]       = (ages[28]<ages[11]); 
   assign comp_table[28][12]       = (ages[28]<ages[12]); 
   assign comp_table[28][13]       = (ages[28]<ages[13]); 
   assign comp_table[28][14]       = (ages[28]<ages[14]); 
   assign comp_table[28][15]       = (ages[28]<ages[15]); 
   assign comp_table[28][16]       = (ages[28]<ages[16]); 
   assign comp_table[28][17]       = (ages[28]<ages[17]); 
   assign comp_table[28][18]       = (ages[28]<ages[18]); 
   assign comp_table[28][19]       = (ages[28]<ages[19]); 
   assign comp_table[28][20]       = (ages[28]<ages[20]); 
   assign comp_table[28][21]       = (ages[28]<ages[21]); 
   assign comp_table[28][22]       = (ages[28]<ages[22]); 
   assign comp_table[28][23]       = (ages[28]<ages[23]); 
   assign comp_table[28][24]       = (ages[28]<ages[24]); 
   assign comp_table[28][25]       = (ages[28]<ages[25]); 
   assign comp_table[28][26]       = (ages[28]<ages[26]); 
   assign comp_table[28][27]       = (ages[28]<ages[27]); 
   assign comp_table[28][28]       = (ages[28]<ages[28]); 
   assign comp_table[28][29]       = (ages[28]<ages[29]); 
   assign comp_table[28][30]       = (ages[28]<ages[30]); 
   assign comp_table[28][31]       = (ages[28]<ages[31]); 
   assign ready_states[29]     = (statuses[29]==`RS_READY);
   assign issue_first_states[29]  = ready_states[29]
          && (~ready_states[0] || comp_table[0][29]) 
          && (~ready_states[1] || comp_table[1][29]) 
          && (~ready_states[2] || comp_table[2][29]) 
          && (~ready_states[3] || comp_table[3][29]) 
          && (~ready_states[4] || comp_table[4][29]) 
          && (~ready_states[5] || comp_table[5][29]) 
          && (~ready_states[6] || comp_table[6][29]) 
          && (~ready_states[7] || comp_table[7][29]) 
          && (~ready_states[8] || comp_table[8][29]) 
          && (~ready_states[9] || comp_table[9][29]) 
          && (~ready_states[10] || comp_table[10][29]) 
          && (~ready_states[11] || comp_table[11][29]) 
          && (~ready_states[12] || comp_table[12][29]) 
          && (~ready_states[13] || comp_table[13][29]) 
          && (~ready_states[14] || comp_table[14][29]) 
          && (~ready_states[15] || comp_table[15][29]) 
          && (~ready_states[16] || comp_table[16][29]) 
          && (~ready_states[17] || comp_table[17][29]) 
          && (~ready_states[18] || comp_table[18][29]) 
          && (~ready_states[19] || comp_table[19][29]) 
          && (~ready_states[20] || comp_table[20][29]) 
          && (~ready_states[21] || comp_table[21][29]) 
          && (~ready_states[22] || comp_table[22][29]) 
          && (~ready_states[23] || comp_table[23][29]) 
          && (~ready_states[24] || comp_table[24][29]) 
          && (~ready_states[25] || comp_table[25][29]) 
          && (~ready_states[26] || comp_table[26][29]) 
          && (~ready_states[27] || comp_table[27][29]) 
          && (~ready_states[28] || comp_table[28][29]) 
          && (~ready_states[30] || comp_table[30][29]) 
          && (~ready_states[31] || comp_table[31][29]) 
   ;
   assign issue_second_states[29] = ready_states[29] && ~issue_first_states[29] 
          && (~ready_states[0] || comp_table[0][29] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][29] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][29] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][29] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][29] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][29] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][29] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][29] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][29] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][29] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][29] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][29] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][29] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][29] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][29] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][29] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][29] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][29] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][29] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][29] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][29] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][29] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][29] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][29] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][29] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][29] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][29] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][29] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][29] || issue_first_states[28]) 
          && (~ready_states[30] || comp_table[30][29] || issue_first_states[30]) 
          && (~ready_states[31] || comp_table[31][29] || issue_first_states[31]) 
   ;
   assign comp_table[29][0]       = (ages[29]<ages[0]); 
   assign comp_table[29][1]       = (ages[29]<ages[1]); 
   assign comp_table[29][2]       = (ages[29]<ages[2]); 
   assign comp_table[29][3]       = (ages[29]<ages[3]); 
   assign comp_table[29][4]       = (ages[29]<ages[4]); 
   assign comp_table[29][5]       = (ages[29]<ages[5]); 
   assign comp_table[29][6]       = (ages[29]<ages[6]); 
   assign comp_table[29][7]       = (ages[29]<ages[7]); 
   assign comp_table[29][8]       = (ages[29]<ages[8]); 
   assign comp_table[29][9]       = (ages[29]<ages[9]); 
   assign comp_table[29][10]       = (ages[29]<ages[10]); 
   assign comp_table[29][11]       = (ages[29]<ages[11]); 
   assign comp_table[29][12]       = (ages[29]<ages[12]); 
   assign comp_table[29][13]       = (ages[29]<ages[13]); 
   assign comp_table[29][14]       = (ages[29]<ages[14]); 
   assign comp_table[29][15]       = (ages[29]<ages[15]); 
   assign comp_table[29][16]       = (ages[29]<ages[16]); 
   assign comp_table[29][17]       = (ages[29]<ages[17]); 
   assign comp_table[29][18]       = (ages[29]<ages[18]); 
   assign comp_table[29][19]       = (ages[29]<ages[19]); 
   assign comp_table[29][20]       = (ages[29]<ages[20]); 
   assign comp_table[29][21]       = (ages[29]<ages[21]); 
   assign comp_table[29][22]       = (ages[29]<ages[22]); 
   assign comp_table[29][23]       = (ages[29]<ages[23]); 
   assign comp_table[29][24]       = (ages[29]<ages[24]); 
   assign comp_table[29][25]       = (ages[29]<ages[25]); 
   assign comp_table[29][26]       = (ages[29]<ages[26]); 
   assign comp_table[29][27]       = (ages[29]<ages[27]); 
   assign comp_table[29][28]       = (ages[29]<ages[28]); 
   assign comp_table[29][29]       = (ages[29]<ages[29]); 
   assign comp_table[29][30]       = (ages[29]<ages[30]); 
   assign comp_table[29][31]       = (ages[29]<ages[31]); 
   assign ready_states[30]     = (statuses[30]==`RS_READY);
   assign issue_first_states[30]  = ready_states[30]
          && (~ready_states[0] || comp_table[0][30]) 
          && (~ready_states[1] || comp_table[1][30]) 
          && (~ready_states[2] || comp_table[2][30]) 
          && (~ready_states[3] || comp_table[3][30]) 
          && (~ready_states[4] || comp_table[4][30]) 
          && (~ready_states[5] || comp_table[5][30]) 
          && (~ready_states[6] || comp_table[6][30]) 
          && (~ready_states[7] || comp_table[7][30]) 
          && (~ready_states[8] || comp_table[8][30]) 
          && (~ready_states[9] || comp_table[9][30]) 
          && (~ready_states[10] || comp_table[10][30]) 
          && (~ready_states[11] || comp_table[11][30]) 
          && (~ready_states[12] || comp_table[12][30]) 
          && (~ready_states[13] || comp_table[13][30]) 
          && (~ready_states[14] || comp_table[14][30]) 
          && (~ready_states[15] || comp_table[15][30]) 
          && (~ready_states[16] || comp_table[16][30]) 
          && (~ready_states[17] || comp_table[17][30]) 
          && (~ready_states[18] || comp_table[18][30]) 
          && (~ready_states[19] || comp_table[19][30]) 
          && (~ready_states[20] || comp_table[20][30]) 
          && (~ready_states[21] || comp_table[21][30]) 
          && (~ready_states[22] || comp_table[22][30]) 
          && (~ready_states[23] || comp_table[23][30]) 
          && (~ready_states[24] || comp_table[24][30]) 
          && (~ready_states[25] || comp_table[25][30]) 
          && (~ready_states[26] || comp_table[26][30]) 
          && (~ready_states[27] || comp_table[27][30]) 
          && (~ready_states[28] || comp_table[28][30]) 
          && (~ready_states[29] || comp_table[29][30]) 
          && (~ready_states[31] || comp_table[31][30]) 
   ;
   assign issue_second_states[30] = ready_states[30] && ~issue_first_states[30] 
          && (~ready_states[0] || comp_table[0][30] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][30] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][30] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][30] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][30] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][30] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][30] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][30] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][30] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][30] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][30] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][30] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][30] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][30] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][30] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][30] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][30] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][30] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][30] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][30] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][30] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][30] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][30] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][30] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][30] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][30] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][30] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][30] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][30] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][30] || issue_first_states[29]) 
          && (~ready_states[31] || comp_table[31][30] || issue_first_states[31]) 
   ;
   assign comp_table[30][0]       = (ages[30]<ages[0]); 
   assign comp_table[30][1]       = (ages[30]<ages[1]); 
   assign comp_table[30][2]       = (ages[30]<ages[2]); 
   assign comp_table[30][3]       = (ages[30]<ages[3]); 
   assign comp_table[30][4]       = (ages[30]<ages[4]); 
   assign comp_table[30][5]       = (ages[30]<ages[5]); 
   assign comp_table[30][6]       = (ages[30]<ages[6]); 
   assign comp_table[30][7]       = (ages[30]<ages[7]); 
   assign comp_table[30][8]       = (ages[30]<ages[8]); 
   assign comp_table[30][9]       = (ages[30]<ages[9]); 
   assign comp_table[30][10]       = (ages[30]<ages[10]); 
   assign comp_table[30][11]       = (ages[30]<ages[11]); 
   assign comp_table[30][12]       = (ages[30]<ages[12]); 
   assign comp_table[30][13]       = (ages[30]<ages[13]); 
   assign comp_table[30][14]       = (ages[30]<ages[14]); 
   assign comp_table[30][15]       = (ages[30]<ages[15]); 
   assign comp_table[30][16]       = (ages[30]<ages[16]); 
   assign comp_table[30][17]       = (ages[30]<ages[17]); 
   assign comp_table[30][18]       = (ages[30]<ages[18]); 
   assign comp_table[30][19]       = (ages[30]<ages[19]); 
   assign comp_table[30][20]       = (ages[30]<ages[20]); 
   assign comp_table[30][21]       = (ages[30]<ages[21]); 
   assign comp_table[30][22]       = (ages[30]<ages[22]); 
   assign comp_table[30][23]       = (ages[30]<ages[23]); 
   assign comp_table[30][24]       = (ages[30]<ages[24]); 
   assign comp_table[30][25]       = (ages[30]<ages[25]); 
   assign comp_table[30][26]       = (ages[30]<ages[26]); 
   assign comp_table[30][27]       = (ages[30]<ages[27]); 
   assign comp_table[30][28]       = (ages[30]<ages[28]); 
   assign comp_table[30][29]       = (ages[30]<ages[29]); 
   assign comp_table[30][30]       = (ages[30]<ages[30]); 
   assign comp_table[30][31]       = (ages[30]<ages[31]); 
   assign ready_states[31]     = (statuses[31]==`RS_READY);
   assign issue_first_states[31]  = ready_states[31]
          && (~ready_states[0] || comp_table[0][31]) 
          && (~ready_states[1] || comp_table[1][31]) 
          && (~ready_states[2] || comp_table[2][31]) 
          && (~ready_states[3] || comp_table[3][31]) 
          && (~ready_states[4] || comp_table[4][31]) 
          && (~ready_states[5] || comp_table[5][31]) 
          && (~ready_states[6] || comp_table[6][31]) 
          && (~ready_states[7] || comp_table[7][31]) 
          && (~ready_states[8] || comp_table[8][31]) 
          && (~ready_states[9] || comp_table[9][31]) 
          && (~ready_states[10] || comp_table[10][31]) 
          && (~ready_states[11] || comp_table[11][31]) 
          && (~ready_states[12] || comp_table[12][31]) 
          && (~ready_states[13] || comp_table[13][31]) 
          && (~ready_states[14] || comp_table[14][31]) 
          && (~ready_states[15] || comp_table[15][31]) 
          && (~ready_states[16] || comp_table[16][31]) 
          && (~ready_states[17] || comp_table[17][31]) 
          && (~ready_states[18] || comp_table[18][31]) 
          && (~ready_states[19] || comp_table[19][31]) 
          && (~ready_states[20] || comp_table[20][31]) 
          && (~ready_states[21] || comp_table[21][31]) 
          && (~ready_states[22] || comp_table[22][31]) 
          && (~ready_states[23] || comp_table[23][31]) 
          && (~ready_states[24] || comp_table[24][31]) 
          && (~ready_states[25] || comp_table[25][31]) 
          && (~ready_states[26] || comp_table[26][31]) 
          && (~ready_states[27] || comp_table[27][31]) 
          && (~ready_states[28] || comp_table[28][31]) 
          && (~ready_states[29] || comp_table[29][31]) 
          && (~ready_states[30] || comp_table[30][31]) 
   ;
   assign issue_second_states[31] = ready_states[31] && ~issue_first_states[31] 
          && (~ready_states[0] || comp_table[0][31] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][31] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][31] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][31] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][31] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][31] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][31] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][31] || issue_first_states[7]) 
          && (~ready_states[8] || comp_table[8][31] || issue_first_states[8]) 
          && (~ready_states[9] || comp_table[9][31] || issue_first_states[9]) 
          && (~ready_states[10] || comp_table[10][31] || issue_first_states[10]) 
          && (~ready_states[11] || comp_table[11][31] || issue_first_states[11]) 
          && (~ready_states[12] || comp_table[12][31] || issue_first_states[12]) 
          && (~ready_states[13] || comp_table[13][31] || issue_first_states[13]) 
          && (~ready_states[14] || comp_table[14][31] || issue_first_states[14]) 
          && (~ready_states[15] || comp_table[15][31] || issue_first_states[15]) 
          && (~ready_states[16] || comp_table[16][31] || issue_first_states[16]) 
          && (~ready_states[17] || comp_table[17][31] || issue_first_states[17]) 
          && (~ready_states[18] || comp_table[18][31] || issue_first_states[18]) 
          && (~ready_states[19] || comp_table[19][31] || issue_first_states[19]) 
          && (~ready_states[20] || comp_table[20][31] || issue_first_states[20]) 
          && (~ready_states[21] || comp_table[21][31] || issue_first_states[21]) 
          && (~ready_states[22] || comp_table[22][31] || issue_first_states[22]) 
          && (~ready_states[23] || comp_table[23][31] || issue_first_states[23]) 
          && (~ready_states[24] || comp_table[24][31] || issue_first_states[24]) 
          && (~ready_states[25] || comp_table[25][31] || issue_first_states[25]) 
          && (~ready_states[26] || comp_table[26][31] || issue_first_states[26]) 
          && (~ready_states[27] || comp_table[27][31] || issue_first_states[27]) 
          && (~ready_states[28] || comp_table[28][31] || issue_first_states[28]) 
          && (~ready_states[29] || comp_table[29][31] || issue_first_states[29]) 
          && (~ready_states[30] || comp_table[30][31] || issue_first_states[30]) 
   ;
   assign comp_table[31][0]       = (ages[31]<ages[0]); 
   assign comp_table[31][1]       = (ages[31]<ages[1]); 
   assign comp_table[31][2]       = (ages[31]<ages[2]); 
   assign comp_table[31][3]       = (ages[31]<ages[3]); 
   assign comp_table[31][4]       = (ages[31]<ages[4]); 
   assign comp_table[31][5]       = (ages[31]<ages[5]); 
   assign comp_table[31][6]       = (ages[31]<ages[6]); 
   assign comp_table[31][7]       = (ages[31]<ages[7]); 
   assign comp_table[31][8]       = (ages[31]<ages[8]); 
   assign comp_table[31][9]       = (ages[31]<ages[9]); 
   assign comp_table[31][10]       = (ages[31]<ages[10]); 
   assign comp_table[31][11]       = (ages[31]<ages[11]); 
   assign comp_table[31][12]       = (ages[31]<ages[12]); 
   assign comp_table[31][13]       = (ages[31]<ages[13]); 
   assign comp_table[31][14]       = (ages[31]<ages[14]); 
   assign comp_table[31][15]       = (ages[31]<ages[15]); 
   assign comp_table[31][16]       = (ages[31]<ages[16]); 
   assign comp_table[31][17]       = (ages[31]<ages[17]); 
   assign comp_table[31][18]       = (ages[31]<ages[18]); 
   assign comp_table[31][19]       = (ages[31]<ages[19]); 
   assign comp_table[31][20]       = (ages[31]<ages[20]); 
   assign comp_table[31][21]       = (ages[31]<ages[21]); 
   assign comp_table[31][22]       = (ages[31]<ages[22]); 
   assign comp_table[31][23]       = (ages[31]<ages[23]); 
   assign comp_table[31][24]       = (ages[31]<ages[24]); 
   assign comp_table[31][25]       = (ages[31]<ages[25]); 
   assign comp_table[31][26]       = (ages[31]<ages[26]); 
   assign comp_table[31][27]       = (ages[31]<ages[27]); 
   assign comp_table[31][28]       = (ages[31]<ages[28]); 
   assign comp_table[31][29]       = (ages[31]<ages[29]); 
   assign comp_table[31][30]       = (ages[31]<ages[30]); 
   assign comp_table[31][31]       = (ages[31]<ages[31]); 
   // END 32 //
*/

/*
   // START 8 //
   assign ready_states[0]     = (statuses[0]==`RS_READY);
   assign issue_first_states[0]  = ready_states[0]
          && (~ready_states[1] || comp_table[1][0]) 
          && (~ready_states[2] || comp_table[2][0]) 
          && (~ready_states[3] || comp_table[3][0]) 
          && (~ready_states[4] || comp_table[4][0]) 
          && (~ready_states[5] || comp_table[5][0]) 
          && (~ready_states[6] || comp_table[6][0]) 
          && (~ready_states[7] || comp_table[7][0]) 
   ;
   assign issue_second_states[0] = ready_states[0] && ~issue_first_states[0] 
          && (~ready_states[1] || comp_table[1][0] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][0] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][0] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][0] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][0] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][0] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][0] || issue_first_states[7]) 
   ;
   assign comp_table[0][0]       = (ages[0]<ages[0]); 
   assign comp_table[0][1]       = (ages[0]<ages[1]); 
   assign comp_table[0][2]       = (ages[0]<ages[2]); 
   assign comp_table[0][3]       = (ages[0]<ages[3]); 
   assign comp_table[0][4]       = (ages[0]<ages[4]); 
   assign comp_table[0][5]       = (ages[0]<ages[5]); 
   assign comp_table[0][6]       = (ages[0]<ages[6]); 
   assign comp_table[0][7]       = (ages[0]<ages[7]); 
   assign ready_states[1]     = (statuses[1]==`RS_READY);
   assign issue_first_states[1]  = ready_states[1]
          && (~ready_states[0] || comp_table[0][1]) 
          && (~ready_states[2] || comp_table[2][1]) 
          && (~ready_states[3] || comp_table[3][1]) 
          && (~ready_states[4] || comp_table[4][1]) 
          && (~ready_states[5] || comp_table[5][1]) 
          && (~ready_states[6] || comp_table[6][1]) 
          && (~ready_states[7] || comp_table[7][1]) 
   ;
   assign issue_second_states[1] = ready_states[1] && ~issue_first_states[1] 
          && (~ready_states[0] || comp_table[0][1] || issue_first_states[0]) 
          && (~ready_states[2] || comp_table[2][1] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][1] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][1] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][1] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][1] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][1] || issue_first_states[7]) 
   ;
   assign comp_table[1][0]       = (ages[1]<ages[0]); 
   assign comp_table[1][1]       = (ages[1]<ages[1]); 
   assign comp_table[1][2]       = (ages[1]<ages[2]); 
   assign comp_table[1][3]       = (ages[1]<ages[3]); 
   assign comp_table[1][4]       = (ages[1]<ages[4]); 
   assign comp_table[1][5]       = (ages[1]<ages[5]); 
   assign comp_table[1][6]       = (ages[1]<ages[6]); 
   assign comp_table[1][7]       = (ages[1]<ages[7]); 
   assign ready_states[2]     = (statuses[2]==`RS_READY);
   assign issue_first_states[2]  = ready_states[2]
          && (~ready_states[0] || comp_table[0][2]) 
          && (~ready_states[1] || comp_table[1][2]) 
          && (~ready_states[3] || comp_table[3][2]) 
          && (~ready_states[4] || comp_table[4][2]) 
          && (~ready_states[5] || comp_table[5][2]) 
          && (~ready_states[6] || comp_table[6][2]) 
          && (~ready_states[7] || comp_table[7][2]) 
   ;
   assign issue_second_states[2] = ready_states[2] && ~issue_first_states[2] 
          && (~ready_states[0] || comp_table[0][2] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][2] || issue_first_states[1]) 
          && (~ready_states[3] || comp_table[3][2] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][2] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][2] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][2] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][2] || issue_first_states[7]) 
   ;
   assign comp_table[2][0]       = (ages[2]<ages[0]); 
   assign comp_table[2][1]       = (ages[2]<ages[1]); 
   assign comp_table[2][2]       = (ages[2]<ages[2]); 
   assign comp_table[2][3]       = (ages[2]<ages[3]); 
   assign comp_table[2][4]       = (ages[2]<ages[4]); 
   assign comp_table[2][5]       = (ages[2]<ages[5]); 
   assign comp_table[2][6]       = (ages[2]<ages[6]); 
   assign comp_table[2][7]       = (ages[2]<ages[7]); 
   assign ready_states[3]     = (statuses[3]==`RS_READY);
   assign issue_first_states[3]  = ready_states[3]
          && (~ready_states[0] || comp_table[0][3]) 
          && (~ready_states[1] || comp_table[1][3]) 
          && (~ready_states[2] || comp_table[2][3]) 
          && (~ready_states[4] || comp_table[4][3]) 
          && (~ready_states[5] || comp_table[5][3]) 
          && (~ready_states[6] || comp_table[6][3]) 
          && (~ready_states[7] || comp_table[7][3]) 
   ;
   assign issue_second_states[3] = ready_states[3] && ~issue_first_states[3] 
          && (~ready_states[0] || comp_table[0][3] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][3] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][3] || issue_first_states[2]) 
          && (~ready_states[4] || comp_table[4][3] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][3] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][3] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][3] || issue_first_states[7]) 
   ;
   assign comp_table[3][0]       = (ages[3]<ages[0]); 
   assign comp_table[3][1]       = (ages[3]<ages[1]); 
   assign comp_table[3][2]       = (ages[3]<ages[2]); 
   assign comp_table[3][3]       = (ages[3]<ages[3]); 
   assign comp_table[3][4]       = (ages[3]<ages[4]); 
   assign comp_table[3][5]       = (ages[3]<ages[5]); 
   assign comp_table[3][6]       = (ages[3]<ages[6]); 
   assign comp_table[3][7]       = (ages[3]<ages[7]); 
   assign ready_states[4]     = (statuses[4]==`RS_READY);
   assign issue_first_states[4]  = ready_states[4]
          && (~ready_states[0] || comp_table[0][4]) 
          && (~ready_states[1] || comp_table[1][4]) 
          && (~ready_states[2] || comp_table[2][4]) 
          && (~ready_states[3] || comp_table[3][4]) 
          && (~ready_states[5] || comp_table[5][4]) 
          && (~ready_states[6] || comp_table[6][4]) 
          && (~ready_states[7] || comp_table[7][4]) 
   ;
   assign issue_second_states[4] = ready_states[4] && ~issue_first_states[4] 
          && (~ready_states[0] || comp_table[0][4] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][4] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][4] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][4] || issue_first_states[3]) 
          && (~ready_states[5] || comp_table[5][4] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][4] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][4] || issue_first_states[7]) 
   ;
   assign comp_table[4][0]       = (ages[4]<ages[0]); 
   assign comp_table[4][1]       = (ages[4]<ages[1]); 
   assign comp_table[4][2]       = (ages[4]<ages[2]); 
   assign comp_table[4][3]       = (ages[4]<ages[3]); 
   assign comp_table[4][4]       = (ages[4]<ages[4]); 
   assign comp_table[4][5]       = (ages[4]<ages[5]); 
   assign comp_table[4][6]       = (ages[4]<ages[6]); 
   assign comp_table[4][7]       = (ages[4]<ages[7]); 
   assign ready_states[5]     = (statuses[5]==`RS_READY);
   assign issue_first_states[5]  = ready_states[5]
          && (~ready_states[0] || comp_table[0][5]) 
          && (~ready_states[1] || comp_table[1][5]) 
          && (~ready_states[2] || comp_table[2][5]) 
          && (~ready_states[3] || comp_table[3][5]) 
          && (~ready_states[4] || comp_table[4][5]) 
          && (~ready_states[6] || comp_table[6][5]) 
          && (~ready_states[7] || comp_table[7][5]) 
   ;
   assign issue_second_states[5] = ready_states[5] && ~issue_first_states[5] 
          && (~ready_states[0] || comp_table[0][5] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][5] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][5] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][5] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][5] || issue_first_states[4]) 
          && (~ready_states[6] || comp_table[6][5] || issue_first_states[6]) 
          && (~ready_states[7] || comp_table[7][5] || issue_first_states[7]) 
   ;
   assign comp_table[5][0]       = (ages[5]<ages[0]); 
   assign comp_table[5][1]       = (ages[5]<ages[1]); 
   assign comp_table[5][2]       = (ages[5]<ages[2]); 
   assign comp_table[5][3]       = (ages[5]<ages[3]); 
   assign comp_table[5][4]       = (ages[5]<ages[4]); 
   assign comp_table[5][5]       = (ages[5]<ages[5]); 
   assign comp_table[5][6]       = (ages[5]<ages[6]); 
   assign comp_table[5][7]       = (ages[5]<ages[7]); 
   assign ready_states[6]     = (statuses[6]==`RS_READY);
   assign issue_first_states[6]  = ready_states[6]
          && (~ready_states[0] || comp_table[0][6]) 
          && (~ready_states[1] || comp_table[1][6]) 
          && (~ready_states[2] || comp_table[2][6]) 
          && (~ready_states[3] || comp_table[3][6]) 
          && (~ready_states[4] || comp_table[4][6]) 
          && (~ready_states[5] || comp_table[5][6]) 
          && (~ready_states[7] || comp_table[7][6]) 
   ;
   assign issue_second_states[6] = ready_states[6] && ~issue_first_states[6] 
          && (~ready_states[0] || comp_table[0][6] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][6] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][6] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][6] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][6] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][6] || issue_first_states[5]) 
          && (~ready_states[7] || comp_table[7][6] || issue_first_states[7]) 
   ;
   assign comp_table[6][0]       = (ages[6]<ages[0]); 
   assign comp_table[6][1]       = (ages[6]<ages[1]); 
   assign comp_table[6][2]       = (ages[6]<ages[2]); 
   assign comp_table[6][3]       = (ages[6]<ages[3]); 
   assign comp_table[6][4]       = (ages[6]<ages[4]); 
   assign comp_table[6][5]       = (ages[6]<ages[5]); 
   assign comp_table[6][6]       = (ages[6]<ages[6]); 
   assign comp_table[6][7]       = (ages[6]<ages[7]); 
   assign ready_states[7]     = (statuses[7]==`RS_READY);
   assign issue_first_states[7]  = ready_states[7]
          && (~ready_states[0] || comp_table[0][7]) 
          && (~ready_states[1] || comp_table[1][7]) 
          && (~ready_states[2] || comp_table[2][7]) 
          && (~ready_states[3] || comp_table[3][7]) 
          && (~ready_states[4] || comp_table[4][7]) 
          && (~ready_states[5] || comp_table[5][7]) 
          && (~ready_states[6] || comp_table[6][7]) 
   ;
   assign issue_second_states[7] = ready_states[7] && ~issue_first_states[7] 
          && (~ready_states[0] || comp_table[0][7] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][7] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][7] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][7] || issue_first_states[3]) 
          && (~ready_states[4] || comp_table[4][7] || issue_first_states[4]) 
          && (~ready_states[5] || comp_table[5][7] || issue_first_states[5]) 
          && (~ready_states[6] || comp_table[6][7] || issue_first_states[6]) 
   ;
   assign comp_table[7][0]       = (ages[7]<ages[0]); 
   assign comp_table[7][1]       = (ages[7]<ages[1]); 
   assign comp_table[7][2]       = (ages[7]<ages[2]); 
   assign comp_table[7][3]       = (ages[7]<ages[3]); 
   assign comp_table[7][4]       = (ages[7]<ages[4]); 
   assign comp_table[7][5]       = (ages[7]<ages[5]); 
   assign comp_table[7][6]       = (ages[7]<ages[6]); 
   assign comp_table[7][7]       = (ages[7]<ages[7]); 
   // STOP 8 //
*/

   // START 4 //
      assign ready_states[0]     = (statuses[0]==`RS_READY);
   assign issue_first_states[0]  = ready_states[0]
          && (~ready_states[1] || comp_table[1][0]) 
          && (~ready_states[2] || comp_table[2][0]) 
          && (~ready_states[3] || comp_table[3][0]) 
   ;
   assign issue_second_states[0] = ready_states[0] && ~issue_first_states[0] 
          && (~ready_states[1] || comp_table[1][0] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][0] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][0] || issue_first_states[3]) 
   ;
   assign comp_table[0][0]       = (ages[0]<ages[0]); 
   assign comp_table[0][1]       = (ages[0]<ages[1]); 
   assign comp_table[0][2]       = (ages[0]<ages[2]); 
   assign comp_table[0][3]       = (ages[0]<ages[3]); 
   assign ready_states[1]     = (statuses[1]==`RS_READY);
   assign issue_first_states[1]  = ready_states[1]
          && (~ready_states[0] || comp_table[0][1]) 
          && (~ready_states[2] || comp_table[2][1]) 
          && (~ready_states[3] || comp_table[3][1]) 
   ;
   assign issue_second_states[1] = ready_states[1] && ~issue_first_states[1] 
          && (~ready_states[0] || comp_table[0][1] || issue_first_states[0]) 
          && (~ready_states[2] || comp_table[2][1] || issue_first_states[2]) 
          && (~ready_states[3] || comp_table[3][1] || issue_first_states[3]) 
   ;
   assign comp_table[1][0]       = (ages[1]<ages[0]); 
   assign comp_table[1][1]       = (ages[1]<ages[1]); 
   assign comp_table[1][2]       = (ages[1]<ages[2]); 
   assign comp_table[1][3]       = (ages[1]<ages[3]); 
   assign ready_states[2]     = (statuses[2]==`RS_READY);
   assign issue_first_states[2]  = ready_states[2]
          && (~ready_states[0] || comp_table[0][2]) 
          && (~ready_states[1] || comp_table[1][2]) 
          && (~ready_states[3] || comp_table[3][2]) 
   ;
   assign issue_second_states[2] = ready_states[2] && ~issue_first_states[2] 
          && (~ready_states[0] || comp_table[0][2] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][2] || issue_first_states[1]) 
          && (~ready_states[3] || comp_table[3][2] || issue_first_states[3]) 
   ;
   assign comp_table[2][0]       = (ages[2]<ages[0]); 
   assign comp_table[2][1]       = (ages[2]<ages[1]); 
   assign comp_table[2][2]       = (ages[2]<ages[2]); 
   assign comp_table[2][3]       = (ages[2]<ages[3]); 
   assign ready_states[3]     = (statuses[3]==`RS_READY);
   assign issue_first_states[3]  = ready_states[3]
          && (~ready_states[0] || comp_table[0][3]) 
          && (~ready_states[1] || comp_table[1][3]) 
          && (~ready_states[2] || comp_table[2][3]) 
   ;
   assign issue_second_states[3] = ready_states[3] && ~issue_first_states[3] 
          && (~ready_states[0] || comp_table[0][3] || issue_first_states[0]) 
          && (~ready_states[1] || comp_table[1][3] || issue_first_states[1]) 
          && (~ready_states[2] || comp_table[2][3] || issue_first_states[2]) 
   ;
   assign comp_table[3][0]       = (ages[3]<ages[0]); 
   assign comp_table[3][1]       = (ages[3]<ages[1]); 
   assign comp_table[3][2]       = (ages[3]<ages[2]); 
   assign comp_table[3][3]       = (ages[3]<ages[3]);
   // STOP 4 //

   
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

/*   
   // state for resets on next clock cycle //
   generate
      for (i=0; i<`NUM_RSES; i=i+1)
      begin : SETNEXTRESETS
         always@(posedge clock)
         begin
            if (reset)
               resets[i]    <=   `SD 1'b1;
            else
               resets[i]    <=   `SD next_resets[i];
         end
      end
   endgenerate
  */ 
   
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


