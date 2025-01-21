`timescale 1ns/1ps

module sync_tb;
        reg clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
		reg [1:0]datain;
		wire vld_out_0,vld_out_1,vld_out_2;
		wire [2:0]write_enb;
		wire fifo_full, soft_reset_0,soft_reset_1,soft_reset_2;
		
		parameter cycle=10;
		
		router_sync DUT(clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,datain,
					vld_out_0,vld_out_1,vld_out_2,write_enb,fifo_full, soft_reset_0,soft_reset_1,soft_reset_2);
		
		//clock
		initial
		  begin
		      clk=0;
		      forever #(cycle/2) clk=~clk; 
		  end
		//reset  
		task reset;
		  begin
		      @(negedge clk)
              resetn=1'b0;
              @(negedge clk)
              resetn=1'b1;
		  end
		endtask
		//input datain  
		task inputs(input [1:0]a);
		  begin
		      @(negedge clk)
		      datain=a;
		  end
		endtask
		//An hypothetical state to test soft_reset
		task state1;
		  begin
		      {empty_0,empty_1,empty_2}=3'b001;
		      write_enb_reg=1'b1;
		      {read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2}=0;
		      detect_add=1'b1;
		  end
		endtask
		
		
		initial
		  begin
		      reset;
		      inputs(2'b00);//verifying write_enb
		      state1;
		      #10
		      inputs(2'b01);
		      #10
		      inputs(2'b10);
		      
		      #200 read_enb_1=1'b1;
		      #200 $finish; //delay should trigger soft_reset for fifo_0
		      
		  end
endmodule 