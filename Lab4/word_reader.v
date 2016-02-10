// dffe: D-type flip-flop with enable
//
// q      (output) - Current value of flip flop
// d      (input)  - Next value of flip flop
// clk    (input)  - Clock (positive edge-sensitive)
// enable (input)  - Load new value? (yes = 1, no = 0)
// reset  (input)  - Asynchronous reset   (reset =  1)
//
module dffe(q, d, clk, enable, reset);
   output q;
   reg    q;
   input  d;
   input  clk, enable, reset;

   always@(reset)
     if (reset == 1'b1)
       q <= 0;

   always@(posedge clk)
     if ((reset == 1'b0) && (enable == 1'b1))
       q <= d;
endmodule // dffe


module word_reader(I, L, U, V, bits, clk, reset);
   output 	I, L, U, V;
   input [1:0] 	bits;
   input 	reset, clk;

   wire         sBlank, sBlank_next;
   
   dffe fsBlank(sBlank, sBlank_next, clk, 1'b1, 1'b0);
   
   assign sBlank_next = reset;  // | other condition ... 

   assign in00 = bits[1:0] == 3'b00;

   assign in11 = bits[1:0] == 3'b11;
   
   //copied from i_reader
   assign sGarbage_next = restart | ((sBlank | sI_end) & ~(in00 | in11)) | ((sGarbage | sI) & ~in00);
   assign sBlank_next = ((sBlank | sGarbage | sI_end) & in00) & ~restart;
   assign sI_next = ((sBlank | sI_end) & in11) & ~restart;
   assign sI_end_next = (sI & in00) & ~restart;

   dffe fsGarbage(sGarbage, sGarbage_next, clk, 1'b1, 1'b0);
   dffe fsBlank(sBlank, sBlank_next, clk, 1'b1, 1'b0);
   dffe fsI(sI, sI_next, clk, 1'b1, 1'b0);
   dffe fsI_end(sI_end, sI_end_next, clk, 1'b1, 1'b0);

   assign I = sI_end;
   



   
endmodule // word_reader
