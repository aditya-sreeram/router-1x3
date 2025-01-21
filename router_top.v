module router_top(clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2,datain,vldout_0, vldout_1, vldout_2, err, busy,data_out_0, data_out_1, data_out_2);
				  
    input clk, resetn, packet_valid, read_enb_0, read_enb_1, read_enb_2;
	input [7:0]datain; 
	output vldout_0, vldout_1, vldout_2, err, busy;
	output [7:0]data_out_0, data_out_1, data_out_2;
				  
				  
	wire fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid,
	     write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg;
	     
	wire [7:0] dout;
	
	wire [2:0] write_enb;

    
    router_fsm FSM(clk,resetn,packet_valid,datain[1:0],fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid,
                    write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
				  
				  
    register REG(clk,resetn,packet_valid,datain,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);
    
    
				  
    router_fifo FIFO0(clk,resetn,soft_reset,write_enb[0],read_enb,lfd_state,dout,full,empty,data_out_0);
    router_fifo FIFO1(clk,resetn,soft_reset,write_enb[1],read_enb,lfd_state,dout,full,empty,data_out_1);
    router_fifo FIFO2(clk,resetn,soft_reset,write_enb[2],read_enb,lfd_state,dout,full,empty,data_out_2);
    
    router_sync SYNC(clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2, datain[1:0],
					vldout_0,vldout_1,vldout_2,write_enb,fifo_full, soft_reset_0,soft_reset_1,soft_reset_2);
    
endmodule 