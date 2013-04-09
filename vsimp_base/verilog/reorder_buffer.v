///////////////////////////////////////////////////////////////
// This file houses modules for the inner workings of the ROB //
//
// This ROB will have 32 entries. We can decide to add or     //
// subtract entries as we see fit.
// ROB consists of 32 ROB Entries                             //
////////////////////////////////////////////////////////////////

/***
*     TODO:  Combinaional logic
***/

// parameters //
`define ROB_ENTRIES 32
`define ROB_ENTRY_AVAILABLE 1
`define NO_ROB_ENTRY 0
`define SD = 1;


// rob main module //
module rob(
			
			        //inputs
			        clock,reset
              valid1_in, value1_in, valid2_in, value2_in
              complete1, complete2
              
              //outputs
              value1_out, reg1_out, value2_out, reg2_out



			        );


  /***  inputs  ***/
  input wire clock;
  input wire reset;
  
  input wire        valid1_in, valid2_in;
  input wire [63:0] instruction1_in, instruction2_in;
  input wire [31:0] register1_in, register2_in;

  /***  internals ***/

  //n_tail will eventually take on the value of n_tail1 or n_tail2  
  reg  [4:0]  tail, n_tail, n_tail1, n_tail2;


  reg  [4:0]  head, n_head, n_head1, n_head2;
    
 


  /***  outputs ***/
  //what outputs do we need
  output reg  [63:0] value1_out, value2_out;
  output reg  [4:0] register1_out, register2_out;


  /***  internal nexts  ***/
  reg [63:0] n_value1, n_value2;
  reg  [4:0] n_register1, n_register2;


  /*** WORK HERE ***/
 /*
  *   Need to bring in:
  *     clock
  *     instructions
  *     decode register
  *     
  */
  //initialize rob entries
  rob_entry rob_entries[(`ROB_ENTRIES - 1):0] (.clock
  
                                                  
   

  //we need to set each rob entries' write_enable
  always@ *
  begin
    
	  //First we will determine the next tail pointer
	  if(valid1 == 1)
    begin
      
      if(tail == 31)
        n_tail1 = 0;
      else
        n_tail1 = tail + 1;
           
      if(valid2 == 1)
      begin
        if(n_tail1 == 31) 
          n_tail2 = 0;
        else
          n_tail2 = tail + 1;
      end
      else
          n_tail2 = tail;      

    end
    else
    begin
    
      //if valid1 isn't set then we have no new instructions to add
      n_tail1 = tail;
      n_tail2 = tail;
    end

    //if we are adding one or two instructions we need to 
    //adjust the tail accordingly
    if(valid1 == 1 && valid2 == 1)
      n_tail = n_tail2;
    else if (valid1 == 1 && valid2 == 0)
      n_tail = n_tail1;
    else
      n_tail = tail; 

    //now we need to set the write enable bits of the appropriate rob_entry-es
    rob_entries[n_tail1].write_enable1 = valid1;
    rob_entries[n_tail2].write_enable2 = valid2; 
    
    
    //now we should check which ROB entries to retire
    if (rob_entries[head].complete_out == 1)
    begin
    
      n_value1 = rob_entries[head].value;
        
      if(head == 31)
        n_head1 = 0;
      else
        n_head1 = head + 1;
      
      if (rob_entries[n_head1].complete_out == 1)
      begin
      
        n_value2 = rob_entries[n_head1].value;
      
        if(n_head1 == 31)
          n_head2 = 0;
        else
          n_head2 = head + 1;            
      end
      else 
          n_head2 = head;
    end
    else
    begin
        n_head1 = head;
        n_head2 = head;
    end 
    
    if(rob_entries[head].complete_out == 1 & rob_entries[head + 1].complete_out == 1)
      n_head = n_head2;
    else if (rob_entries[head.complete_out == 1 & rob_entries[head + 1].complete_out == 0)
      n_head = n_head1;
    else
      n_head = head;
       
      
  end

   

always @(posedge clock)
begin
   if(reset)
   begin
    head <= `SD 5'b0;
    tail <= `SD 5'b0;


   end
   else
   begin
      
    head <= `SD n_head;
    tail <= `SD n_tail;
    
    register1_out <= `SD n_register1;
    register2_out <= `SD n_register2;
    value1_out <= `SD n_value2;
    value2_out <= `SD n_value2;      
           
   end
   

endmodule 


/***
*   Each ROB Entry needs:
*       Instruction     
*       Valid bit       (Whether or not the entry is valid)
*       Value           (To know when to retire)
*       Register        (Output Register)
*       Complete bit    (To know if it is ready to retire) 
***/
module rob_entry(
                  //inputs
                  clock, reset,
                  instruction_in1, valid_in1, value_in1, complete_in1, register_in1, 
                  instruction_in2, valid_in2, value_in2, complete_in2, register_in2,

                  //outputs
                  instruction_out, valid_out, head_out, tail_out, value_out, register_out, complete_out,
                 );


  /***  inputs  ***/
  input wire        reset;
  input wire        clock;

  //for dispatch stage
  input wire        valid_1in, valid2_in;
  input wire [31:0] instruction1_in, instruction2_in;
  input wire  [5:0] register1_in, register2_in;
  
  
  //for complete
  //input wire        complete_in;
  input wire [31:0] value1_in, value2_in;

  /***  internals  ***/
  reg [31:0]  n_instruction;
  reg         n_valid;
  reg [63:0]  n_value;
  reg         n_complete;
  reg  [4:0]  n_register;

  reg complete_enable1, complete_enable2;
  reg write_enable1, write_enable2;
  reg n_write_enable1, n_write_enable2;

  /***  outputs  ***/
  output reg [31:0] instruction_out;
  output reg        valid_out;
  output reg [63:0] value_out;
  output reg        complete_out;
  output reg  [4:0] register_out;


  // combinational assignments //  
  always @*
  begin
    if (write_enable_1)
    begin
      n_instruction = instruction_in1;
      n_valid = valid_in1;
      n_value = 64'b0;
      n_register = register_in1;
      n_complete = 1'b0;
    end
    else if (write_enable_2)
      begin
      n_instruction = instruction_in2;
      n_valid = valid_in2;
      n_value = 64'b0;
      n_register = register_in2;
      n_complete = 1'b0;
    end
    else
    begin 
      n_instruction = instruction_out;
      n_valid = valid_out;
      n_value = value_out;
      n_register = register_out;
      n_complete = complete_out;
    end


    //determine whether to latch complete
    if(complete_enable1)
    begin
      n_value = value1_in;
    else if (complete_enable2)
      n_value = value2_in;
    else
      n_value = value_out;
    end   


  end


  // clock synchronous events //
  always@(posedge clock)
  begin
     if (reset)
     begin
        instruction_out <= `SD 32'd0;
        valid_out <= `SD 1'b0;
        value_out <= `SD 64'h0;
        register_out <= `SD 5'b0;
        complete_out <= `SD 1'b0;
     end
     else
     begin
        instruction_out <= `SD n_instruction;
        valid_out <= `SD n_valid;
        value_out <= `SD n_value;
        register_out <= `SD n_exception;
        complete_out <= `SD n_complete;
     end


endmodule
