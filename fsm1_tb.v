`timescale 1ns / 1ps

module fsm_tb;

	reg clk,resetn,packet_valid;
	reg [1:0] datain;
	reg fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid;
	wire write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
	wire [2:0]current_state;
				
    parameter cycle=10;

    
    fsm DUT (clk,resetn,packet_valid,datain,fifo_full,fifo_empty_0,fifo_empty_1,
             fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid, 
		     write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy,
		     current_state
		     );
    
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
    
    task inputs(input [1:0]a);
        begin
            @(negedge clk)
            datain=a;
        end
    endtask

    task normal_case;
        begin
            reset;
            inputs(2'b00);
            fifo_full=1'b0;
            {packet_valid,fifo_empty_0}=2'b11;
            #50 packet_valid=1'b0;
            #10 parity_done=1'b1; 
            #15 parity_done=1'b0;
 
           
        end
    endtask 
       
    task full_case;
        begin
            reset;
            inputs(2'b00);
            fifo_full=1'b0;
            {packet_valid,fifo_empty_0}=2'b10;
            #12 fifo_empty_0=1'b1;
            fifo_full=1'b1;
            #10 fifo_full=1'b0;
            #50 packet_valid=1'b0;
            #10 parity_done=1'b1; 
            #15 parity_done=1'b0;
            
           
        end
    endtask   
     
    task just_full_case;
        begin
            reset;
            inputs(2'b00);
            fifo_full=1'b1;
            {packet_valid,fifo_empty_0}=2'b11;
            #50 packet_valid=1'b0;
            #5 fifo_full=1'b0;
            low_packet_valid=1'b1;
            #20 low_packet_valid= 1'b0;
            #10 parity_done=1'b1; 
            #15 parity_done=1'b0;
           
            
//            @(negedge clk)
//            read_enb_0=1'b1;
            #70 $finish;
        end
    endtask
    
    initial 
        begin
//            normal_case;
//            #30
//            full_case;
//            #30
//            just_full_case;
            
            
//            #20$finish;
            
            reset;
            fifo_empty_0=1'b1;
            fifo_full=1'b0;
            parity_done=1'b0;
            @(negedge clk)
            packet_valid=1'b1;
            datain=2'b00;
            while(busy);
            @(negedge clk)
            fifo_empty_0=1'b0;
            datain=2'b11;
             
            @(negedge clk)
            datain=2'b00;
             
            @(negedge clk)
            datain=2'b11;
             
            @(negedge clk)
            packet_valid=1'b0;
            datain=2'b00;
            
            #10 parity_done=1'b1;
                 
//            @(negedge clk)
//            read_enb_0=1'b1;
            #70 $finish;
        end


    			  
endmodule
