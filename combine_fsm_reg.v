
module combine_fsm_reg(clk,resetn,packet_valid,datain,parity_done,low_packet_valid,err,dout,fifo_full,busy,soft_reset,read_enb,
                       fifo_empty,full,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,vld_out,write_enb,dataout,
                       current_state);
    
    input clk,resetn,packet_valid;//common
    input [7:0]datain;
//    input [2:0]fifo_empty,soft_reset;//fsm
    
    input [2:0]read_enb;//fifo
    
    output busy;
    output fifo_full;
    output [2:0]soft_reset;//from sync
    output [2:0]fifo_empty;//from fifo
    output [2:0]full; //form fifo
    
    output [2:0]vld_out;
    
    output [2:0]write_enb;
    
    output [7:0]dataout;
    
    output parity_done,low_packet_valid,err;//from reg
    output [7:0]dout;
    output detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state; //from fsm
    output [2:0]current_state;
    
    wire detect_add_wire,ld_state_wire,laf_state_wire,full_state_wire,rst_int_reg_wire,lfd_state_wire,write_enb_reg_wire;//fsm
    wire parity_done_wire,low_packet_valid_wire;//reg
    wire[2:0] fifo_empty_wire,soft_reset_wire,full_wire;
    wire[2:0] write_enb_wire;
    wire[7:0]dout_wire;
    wire fifo_full_wire;
    
    
    fsm DUT1(clk,resetn,packet_valid,datain[1:0],
             fifo_full_wire,fifo_empty_wire[0],fifo_empty_wire[1],fifo_empty_wire[2],
             soft_reset_wire[0],soft_reset_wire[1],soft_reset_wire[2],parity_done_wire, 
             low_packet_valid_wire, write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,
             rst_int_reg,busy,current_state);
           
    register DUT2(clk,resetn,packet_valid,datain,fifo_full_wire,detect_add_wire,ld_state_wire,laf_state_wire,full_state_wire,
                  lfd_state_wire,rst_int_reg_wire,err,parity_done,low_packet_valid,dout);

                  
    router_sync DUT3(clk,resetn,detect_add_wire,write_enb_reg_wire,read_enb[0],read_enb[1],read_enb[2],
                      fifo_empty_wire[0],fifo_empty_wire[1],fifo_empty_wire[2],full_wire[0],full_wire[1],full_wire[2],datain[1:0],
				      vld_out[0],vld_out[1],vld_out[2],write_enb,fifo_full, soft_reset_wire[0],soft_reset_wire[1],soft_reset_wire[2]);
				      
				      
	router_fifo DUT4(clk,resetn,soft_reset_wire[0],write_enb_wire[0],read_enb[0],lfd_state_wire,dout_wire,full[0],fifo_empty[0],dataout);
					
    
    assign detect_add_wire=detect_add;
    assign ld_state_wire=ld_state;
    assign laf_state_wire=laf_state;
    assign full_state_wire=full_state;
    assign rst_int_reg_wire=rst_int_reg;
    assign lfd_state_wire=lfd_state;
    
    assign parity_done_wire=parity_done;
    assign low_packet_valid_wire=low_packet_valid;
    
    assign fifo_empty_wire[0]=fifo_empty[0];
    assign fifo_empty_wire[1]=fifo_empty[1];
    assign fifo_empty_wire[2]=fifo_empty[2];
    
    assign soft_reset_wire[0]=soft_reset[0];
    assign soft_reset_wire[1]=soft_reset[1];
    assign soft_reset_wire[2]=soft_reset[2];
    
    assign write_enb_reg_wire=write_enb_reg;
     
    assign write_enb_wire[0]=write_enb;
    assign write_enb_wire[1]=write_enb;
    assign write_enb_wire[2]=write_enb;
    
    assign dout_wire=dout;
    
    assign full_wire=full;
    
    assign fifo_full_wire=fifo_full;
    
    	
    
    
endmodule
