`timescale 1ns / 1ps


module combine_fsm_reg_tb;

     
    reg clk,resetn,packet_valid;//common
    reg [7:0]datain;
    reg [2:0]read_enb;//fifo
    
    wire fifo_full,busy;
    wire [2:0]soft_reset;//from sync
    wire [2:0]fifo_empty;//from fifo
    wire [2:0]full; //form fifo
    wire [2:0]vld_out;
    wire [2:0]write_enb;
    wire [7:0]dataout;
    wire parity_done,low_packet_valid,err;//from reg
    wire [7:0]dout;
    wire detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state; //from fsm
    wire [2:0]current_state;
    
    integer i;
    
    parameter cycle=10;
    
    combine_fsm_reg DUT(clk,resetn,packet_valid,datain,parity_done,low_packet_valid,err,dout,fifo_full,busy,soft_reset,read_enb,
                       fifo_empty,full,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,vld_out,write_enb,dataout,
                       current_state);
    
    initial
        begin
            clk=0;
            forever #(cycle/2) clk=~clk;
        end
        
    task reset;
        begin
            @(negedge clk) resetn=1'b0;
            @(negedge clk) resetn=1'b1;
        end
    endtask
    
//    task case1;
        
////        reg [7:0]header, payload_data, parity;
////		reg [8:0]payloadlen;
			
			
//        begin
            
//            {fifo_full,fifo_empty}=4'b0111;
//             reset;
////            parity_done=1'b0;
//           reset;
//            fifo_empty[0]=1'b1;
//            fifo_full=1'b0;
         
//            @(negedge clk)
//            packet_valid=1'b1;
//            datain=8'h0c;
//            while(busy);
//            @(negedge clk)
//            fifo_empty=0;
//            @(negedge clk)
//            datain=8'h11;
             
//            @(negedge clk)
//            datain=8'h00;
             
//            @(negedge clk)
//            datain=8'h11;
             
//            @(negedge clk)
//            packet_valid=1'b0;
//            datain=8'h0c;
            
            
////			parity=0;
////			wait(!busy)
////				begin
////                    @(negedge clk);
////                    payloadlen=8;
////                    packet_valid=1'b1;
////                    header={payloadlen,2'b00};
////                    datain=header;
////                    parity=parity^datain;
////				end
////			@(negedge clk);			
////			for(i=0;i<payloadlen;i=i+1)
////				begin
////					wait(!busy)				
////					@(negedge clk);
////					payload_data={$random}%256;
////					datain=payload_data;
////					parity=parity^datain;				
////				end					
								
////			wait(!busy)				
////			@(negedge clk);
////			packet_valid=0;				
////			datain=parity;
////			repeat(30)
////			@(negedge clk);
//////			read_enb_1=1'b1;
			
//        end
//    endtask
    
    task case2;
        reg[7:0] packet [4:0];
        begin
            packet[4]=8'h0c;
            packet[3]=8'hff;
            packet[2]=8'h00;
            packet[1]=8'hff;
            packet[0]=8'h0c;
            
            reset;
            @(negedge clk)
            packet_valid=1;
            datain=packet[4];
            
            @(negedge clk)
            
            
            @(negedge clk)
            datain=packet[3];
            @(negedge clk)
            datain=packet[2];
            @(negedge clk)
            datain=packet[1];
            @(negedge clk)
            datain=packet[0];
            
            @(negedge clk)
            packet_valid=0;
            
            @(negedge clk)
            read_enb[0]=1;
            
            
            
        end
    endtask
    
    
    initial
        begin
            case2;
            #100 $finish;
        end

endmodule
