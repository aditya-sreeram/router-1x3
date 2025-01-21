`timescale 1ns / 1ps
module top_tb;
    			  
    reg clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2;
	reg [7:0]datain; 
	wire vldout_0, vldout_1, vldout_2, err, busy;
	wire [7:0]data_out_0, data_out_1, data_out_2;
	
	parameter cycle=10; 
	
	integer i;
	
	router_top DUT(clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2,datain,vldout_0, vldout_1, vldout_2, err, busy,data_out_0, data_out_1, data_out_2);
		
	
	initial
	   begin
	       clk=0;
	       forever #(cycle/2) clk=~clk;
	   end
	   
    task reset;
        begin
            @(negedge clk)
            resetn=1'b0;
            @(negedge clk)
            resetn=1'b1;
        end
    endtask
    
    initial
        begin
            reset;
            @(negedge clk)
            packet_valid=1'b1;
            datain=8'h0c;
            while(busy);
            @(negedge clk)
            datain=8'hff;
             
            @(negedge clk)
            datain=8'h00;
             
            @(negedge clk)
            datain=8'hff;
             
            @(negedge clk)
            packet_valid=1'b0;
            datain=8'h0c;
             
            #10
            @(negedge clk)
            read_enb_0=1'b1;
            #70 $finish;
        end

endmodule
