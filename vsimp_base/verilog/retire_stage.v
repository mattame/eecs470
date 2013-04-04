module retire_stage(
                clock, reset, 
                //inputs
                rob_register_in1, rob_register_in2, rob_value_in1, rob_value_in2, instruction_in1, instruction_in2,
                complete_head1, complete_head2,

                //outputs
                register_out1, register_out2, value_out1, value_out2
              );

  input wire clock;
  input wire reset;

  input  [4:0] rob_register_in1;
  input  [4:0] rob_register_in2;
  input [63:0] rob_value_in1;
  input [63:0] rob_value_in2;
  input [31:0] instruction_in1;
  input [31:0] instruction_in2;

  input complete_head1;
  input complete_head2;


  output  [4:0] register_out1;
  output  [4:0] register_out2;
  output [63:0] value_out1;
  output [63:0] value_out2;


  /*** internals ***/
  reg next_state0; //next state bits
  reg next_state1;
  
  wire current_state0; //current state bits
  wire current_state1;
