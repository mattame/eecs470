

// defines //
`define RSTAG_NULL      8'hFF     
`define ZERO_REG     5'd0
`define NUM_RSES 16

// reservation station testbench module //
module testbench;

	// internal wires/registers //
	wire correct;
	integer i = 0;

   // input regs for testing the module //
   reg clock;
   reg reset;

   reg [63:0] inst1_rega_value_in,inst1_regb_value_in;
   reg [7:0]  inst1_rega_tag_in,inst1_regb_tag_in;
   reg [4:0]  inst1_dest_reg_in;
   reg [7:0]  inst1_dest_tag_in;
   reg [1:0]  inst1_opa_select_in,inst1_opb_select_in;
   reg [4:0]  inst1_alu_func_in;
   reg        inst1_rd_mem_in,inst1_wr_mem_in;
   reg        inst1_cond_branch_in,inst1_uncond_branch_in;
   reg        inst1_valid;
   
   reg [63:0] inst2_rega_value_in,inst2_regb_value_in;
   reg [7:0]  inst2_rega_tag_in,inst2_regb_tag_in;
   reg [4:0]  inst2_dest_reg_in;
   reg [7:0]  inst2_dest_tag_in;
   reg [1:0]  inst2_opa_select_in,inst2_opb_select_in;
   reg [4:0]  inst2_alu_func_in;
   reg        inst2_rd_mem_in,inst2_wr_mem_in;
   reg        inst2_cond_branch_in,inst2_uncond_branch_in;
   reg        inst2_valid;

   reg [63:0] cdb1_value_in;
   reg [7:0]  cdb1_tag_in;
   reg [63:0] cdb2_value_in;
   reg [7:0]  cdb2_tag_in;
   
   // wires from the module //
   wire dispatch; 

   wire [63:0] inst1_rega_value_out,inst1_regb_value_out;
   wire [1:0]  inst1_opa_select_out,inst1_opb_select_out;
   wire [4:0]  inst1_alu_func_out;
   wire        inst1_rd_mem_out,inst1_wr_mem_out;
   wire        inst1_cond_branch_out,inst1_uncond_branch_out;
   wire        inst1_valid_out;
   wire [4:0]  inst1_dest_reg_out;
   wire [7:0]  inst1_dest_tag_out;

   wire [63:0] inst2_rega_value_out,inst2_regb_value_out;
   wire [1:0]  inst2_opa_select_out,inst2_opb_select_out;
   wire [4:0]  inst2_alu_func_out;
   wire        inst2_rd_mem_out,inst2_wr_mem_out;
   wire        inst2_cond_branch_out,inst2_uncond_branch_out;
   wire        inst2_valid_out;
   wire [4:0]  inst2_dest_reg_out;
   wire [7:0]  inst2_dest_tag_out;
   
   wire [(`NUM_RSES-1):0] first_empties;
   wire [(`NUM_RSES-1):0] second_empties;
   wire [(3*`NUM_RSES-1):0] states_out;   // for debugging 
   wire [(`NUM_RSES-1):0] fills;
   wire [(`NUM_RSES-1):0] issue_first_states;
   wire [(`NUM_RSES-1):0] issue_second_states;
   wire [(8*`NUM_RSES-1):0] ages_out;
   
        // module to be tested //	
        reservation_station rs( .clock(clock), .reset(reset),               // signals in

                           // signals and busses in for inst 1 (from id1) //
                           .inst1_rega_value_in(inst1_rega_value_in),
                           .inst1_regb_value_in(inst1_regb_value_in),
                           .inst1_rega_tag_in(inst1_rega_tag_in),
                           .inst1_regb_tag_in(inst1_regb_tag_in),
                           .inst1_dest_reg_in(inst1_dest_reg_in),
                           .inst1_dest_tag_in(inst1_dest_tag_in),
                           .inst1_opa_select_in(inst1_opa_select_in),
                           .inst1_opb_select_in(inst1_opb_select_in),
                           .inst1_alu_func_in(inst1_alu_func_in),
                           .inst1_rd_mem_in(inst1_rd_mem_in),
                           .inst1_wr_mem_in(inst1_wr_mem_in),
                           .inst1_cond_branch_in(inst1_cond_branch_in),
                           .inst1_uncond_branch_in(inst1_uncond_branch_in),
                           .inst1_valid(inst1_valid),

                           // signals and busses in for inst 2 (from id2) //
                           .inst2_rega_value_in(inst2_rega_value_in),
                           .inst2_regb_value_in(inst2_regb_value_in),
                           .inst2_rega_tag_in(inst2_rega_tag_in),
                           .inst2_regb_tag_in(inst2_regb_tag_in),
                           .inst2_dest_reg_in(inst2_dest_reg_in),
                           .inst2_dest_tag_in(inst2_dest_tag_in),
                           .inst2_opa_select_in(inst2_opa_select_in),
                           .inst2_opb_select_in(inst2_opb_select_in),
                           .inst2_alu_func_in(inst2_alu_func_in),
                           .inst2_rd_mem_in(inst2_rd_mem_in),
                           .inst2_wr_mem_in(inst2_wr_mem_in),
                           .inst2_cond_branch_in(inst2_cond_branch_in),
                           .inst2_uncond_branch_in(inst2_uncond_branch_in),
                           .inst2_valid(inst2_valid),

                           // cdb inputs //
                           .cdb1_tag_in(cdb1_tag_in),
                           .cdb2_tag_in(cdb2_tag_in),
                           .cdb1_value_in(cdb1_value_in),
                           .cdb2_value_in(cdb2_value_in),

                           // signals and busses out for inst1 to the ex stage
                           .inst1_rega_value_out(inst1_rega_value_out),.inst1_regb_value_out(inst1_regb_value_out),
                           .inst1_opa_select_out(inst1_opa_select_out),.inst1_opb_select_out(inst1_opb_select_out),
                           .inst1_alu_func_out(inst1_alu_func_out),
                           .inst1_rd_mem_out(inst1_rd_mem_out),.inst1_wr_mem_out(inst1_wr_mem_out),
                           .inst1_cond_branch_out(inst1_cond_branch_out),.inst1_uncond_branch_out(inst1_uncond_branch_out),
                           .inst1_valid_out(inst1_valid_out),
                           .inst1_dest_reg_out(inst1_dest_reg_out),
                           .inst1_dest_tag_out(inst1_dest_tag_out),

                           // signals and busses out for inst2 to the ex stage
                           .inst2_rega_value_out(inst2_rega_value_out),.inst2_regb_value_out(inst2_regb_value_out),
                           .inst2_opa_select_out(inst2_opa_select_out),.inst2_opb_select_out(inst2_opb_select_out),
                           .inst2_alu_func_out(inst2_alu_func_out),
                           .inst2_rd_mem_out(inst2_rd_mem_out),.inst2_wr_mem_out(inst2_wr_mem_out),
                           .inst2_cond_branch_out(inst2_cond_branch_out),.inst2_uncond_branch_out(inst2_uncond_branch_out),
                           .inst2_valid_out(inst2_valid_out),
                           .inst2_dest_reg_out(inst2_dest_reg_out),
                           .inst2_dest_tag_out(inst2_dest_tag_out),

                           // signal outputs //
                           .dispatch(dispatch),
                         
                           // outputs for debugging //
                           .first_empties(first_empties),.second_empties(second_empties),.states_out(states_out),.fills(fills),
                           .issue_first_states(issue_first_states),.issue_second_states(issue_second_states), .ages_out(ages_out) 
                      );


   // run the clock //
   always
   begin 
      #10; //clock "interval" ... AKA 1/2 the period
      clock=~clock; 
   end 

   // task to exit if there is an error //
   task exit_on_error;
   begin
      $display("@@@ Incorrect at time %4.0f", $time);
      $display("@@@ Time:%4.0f clock:%b reset:%h ", $time, clock, reset   );
      $display("ENDING TESTBENCH : ERROR !");
      $finish;
   end
   endtask


   // exit if not correct //
   always@(posedge clock)
   begin
      #2
      if(!correct)
         exit_on_error();
   end 

   // displays the current state of all wires //
   `define PRECLOCK  1'b1
   `define POSTCLOCK 1'b0
   task DISPLAY_STATE;
      input preclock;
   begin
      if (preclock==`PRECLOCK)
      begin
         $display("  preclock: reset=%b fe=%b se=%b states=%b fills=%b ifs=%b iss=%b ao=%h ", reset,first_empties,second_empties,states_out,fills,issue_first_states,issue_second_states,ages_out);
         $display("   i1_ravo=%h i1_rbvo=%h i2_ravo=%h i2_rbvo=%h", inst1_rega_value_out, inst1_regb_value_out, inst2_rega_value_out, inst2_regb_value_out);
      end
      else
      begin
         $display(" postclock: reset=%b fe=%b se=%b states=%b fills=%b ifs=%b iss=%b ao=%h ", reset,first_empties,second_empties,states_out,fills,issue_first_states,issue_second_states,ages_out);
         $display("   i1_ravo=%h i1_rbvo=%h i2_ravo=%h i2_rbvo=%h", inst1_rega_value_out, inst1_regb_value_out, inst2_rega_value_out, inst2_regb_value_out);
      end
   end
   endtask

   // runs the clock once and displays output before and after //
   task CLOCK_AND_DISPLAY;
   begin
      DISPLAY_STATE(`PRECLOCK);
      @(posedge clock);
      @(negedge clock);
      DISPLAY_STATE(`POSTCLOCK);
      $display("");
   end
   endtask
   
   // asserts truth of a value, exits on failure //
   task ASSERT;
   input state;
   begin
      if (~state)
	  begin
	     $display("@@@ Incorrect at time %4.0f", $time);
         $display("ENDING TESTBENCH : ERROR !");
         $finish;
      end
   end
   endtask


   // testing segment //
   initial
   begin 

	$display("STARTING TESTBENCH!\n");

	// initial state //
    clock = 0;
    reset = 1;

    inst1_rega_value_in = 64'd0;
    inst1_regb_value_in = 64'd0;
    inst1_rega_tag_in = `RSTAG_NULL;
    inst1_regb_tag_in = `RSTAG_NULL;
    inst1_dest_reg_in = `ZERO_REG;
    inst1_dest_tag_in = `RSTAG_NULL;
    inst1_opa_select_in = 2'd0;
    inst1_opb_select_in = 2'd0;
    inst1_alu_func_in = 5'd0;
    inst1_rd_mem_in = 1'b0;
    inst1_wr_mem_in = 1'b0;
    inst1_cond_branch_in = 1'b0;
    inst1_uncond_branch_in = 1'b0;
    inst1_valid = 1'b0;
   
    inst2_rega_value_in = 64'd0;
    inst2_regb_value_in = 64'd0;
    inst2_rega_tag_in = `RSTAG_NULL;
    inst2_regb_tag_in = `RSTAG_NULL;
    inst2_dest_reg_in = `ZERO_REG;
    inst2_dest_tag_in = `RSTAG_NULL;
    inst2_opa_select_in = 2'd0;
    inst2_opb_select_in = 2'd0;
    inst2_alu_func_in = 5'd0;
    inst2_rd_mem_in = 1'b0;
    inst2_wr_mem_in = 1'b0;
    inst2_cond_branch_in = 1'b0;
    inst2_uncond_branch_in = 1'b0;
    inst2_valid = 1'b0;

    cdb1_value_in = 64'd0;
    cdb1_tag_in = `RSTAG_NULL;
    cdb2_value_in = 64'd0;
    cdb2_tag_in = `RSTAG_NULL;


        //////////////////////
        // TRANSITION TESTS //
        //////////////////////

        // reet and check //
        $display("resetting\n");
        reset = 1;
        CLOCK_AND_DISPLAY();
	ASSERT(~inst1_valid_out && ~inst2_valid_out);
		
        // hold nothing and check //
        $display("holding\n");
        reset = 0;
	CLOCK_AND_DISPLAY();
        ASSERT(dispatch);
        ASSERT(~inst1_valid_out && ~inst2_valid_out);

        // dispatch two instructions and check //
        $display("dispatching1\n");
        inst1_valid = 1'b1;
        inst2_valid = 1'b1;
        inst1_rega_value_in = 64'd1;
        inst1_regb_tag_in = 8'd0;
        inst2_rega_value_in = 64'd2;
        inst2_regb_tag_in = 8'd0;
        
        CLOCK_AND_DISPLAY();
        ASSERT(dispatch);

        // dispatch again //
        $display("d2\n");
        CLOCK_AND_DISPLAY();
        ASSERT(dispatch);

        // and again //
        $display("d3\n");
        CLOCK_AND_DISPLAY();
        ASSERT(dispatch);

        // and yet again //
        $display("d4\n");
        CLOCK_AND_DISPLAY();
        ASSERT(dispatch);   // should not be full yet


        // fill all voids and issue first 2 ins'ns //
        $display("issue1\n"); 
        cdb1_tag_in = 8'd0;
        cdb1_value_in = 64'hDEADBEEFBAADBEEF;
        inst1_valid = 1'b0;
        inst2_valid = 1'b0;
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_valid_out && inst2_valid_out);   // first issue

        // watch RS empty as everything gets issued 
        $display("issue2\n");
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_valid_out && inst2_valid_out);
        $display("issue3\n");
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_valid_out && inst2_valid_out);
        $display("issue4\n");
        CLOCK_AND_DISPLAY();
        ASSERT(inst1_valid_out && inst2_valid_out);     // this should be the last issue
        $display("nothing\n");
        CLOCK_AND_DISPLAY();
        ASSERT(~inst1_valid_out && ~inst2_valid_out);   // RS should be empty at this point
        $display("nothing[again]\n");
        CLOCK_AND_DISPLAY();
        ASSERT(~inst1_valid_out && ~inst2_valid_out); 


        // reset and check //
        $display("resetting\n");
        reset = 1;	
	CLOCK_AND_DISPLAY();
        ASSERT(~inst1_valid_out && ~inst2_valid_out);
		

	// SUCCESSFULLY END TESTBENCH //
	$display("ENDING TESTBENCH : SUCCESS !\n");
	$finish;
	
   end

endmodule


