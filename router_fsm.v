module router_fsm(clk,resetn,packet_valid,datain,
           fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,
           soft_reset_0,soft_reset_1,soft_reset_2,parity_done, 
           low_packet_valid, write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy
//           ,current_state 
           );
		   
	input clk,resetn,packet_valid;
	input [1:0] datain;
	input fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid;
	output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
//	output reg [2:0]current_state;

//correspondingly uncommment current_state in both rtl and tb, to view current state
				  
    parameter DECODE_ADDRESS=3'b000,
	WAIT_TILL_EMPTY=3'b001,
	LOAD_FIRST_DATA=3'b010,
	LOAD_DATA=3'b011,
	LOAD_PARITY=3'b100,
	FIFO_FULL_STATE=3'b101,
	LOAD_AFTER_FULL=3'b110,
	CHECK_PARITY_ERROR=3'b111;
				            			            
	reg[2:0] state,next_state;
				  
	always@(posedge clk)
		begin
		    
			if(!resetn) state=DECODE_ADDRESS;
			else state=next_state;
//			current_state=state;
	   end
				          
				  
	always@(*)
       begin
           case(state)
                    DECODE_ADDRESS:begin
                       if((packet_valid && (datain[1:0]==0) && fifo_empty_0)||
                          (packet_valid && (datain[1:0]==1) && fifo_empty_1)||
                          (packet_valid && (datain[1:0]==2) && fifo_empty_2))
                           next_state=LOAD_FIRST_DATA;
                                                    
                       else if
                         ((packet_valid && (datain[1:0]==0) && !fifo_empty_0)||
                          (packet_valid && (datain[1:0]==1) && !fifo_empty_1)||
                          (packet_valid && (datain[1:0]==2) && !fifo_empty_2))
                           next_state=WAIT_TILL_EMPTY;
                                                    
                       else next_state=DECODE_ADDRESS;
                    end
                                           
	                WAIT_TILL_EMPTY:begin
		              if((fifo_empty_0 && (datain==2'b0))||(fifo_empty_1 && (datain==2'b01))||(fifo_empty_2 && (datain==2'b11)))
				          next_state=LOAD_FIRST_DATA;
				      else next_state=WAIT_TILL_EMPTY;
				    end
				                            
				    LOAD_FIRST_DATA:next_state=LOAD_DATA;
				            
				    LOAD_DATA:begin
				      if(!fifo_full && !packet_valid) next_state=LOAD_PARITY;
				      else if(fifo_full) next_state=FIFO_FULL_STATE;
				      else next_state=LOAD_DATA;
				    end
				                      
				    LOAD_PARITY:next_state=CHECK_PARITY_ERROR;
				            
				    FIFO_FULL_STATE:begin
				      if(!fifo_full) next_state=LOAD_AFTER_FULL;
				      else next_state=FIFO_FULL_STATE;
				                                
				    end
				    
				    LOAD_AFTER_FULL:begin
				      if(!parity_done && low_packet_valid) next_state=LOAD_PARITY;
				      else if(!parity_done && !low_packet_valid) next_state=LOAD_DATA;
				      else if(parity_done) next_state=DECODE_ADDRESS;
				      else next_state=LOAD_AFTER_FULL;
				    end
				    
				    CHECK_PARITY_ERROR:begin
				      if(!fifo_full) next_state=DECODE_ADDRESS;
				      else next_state=FIFO_FULL_STATE;
				    end
				    
				    default: next_state=DECODE_ADDRESS;
        endcase
    end
    
    //write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy    
    assign busy=((state==LOAD_FIRST_DATA)||(state==LOAD_PARITY)||
                 (state==FIFO_FULL_STATE)||(state==LOAD_AFTER_FULL)||
                 (state==WAIT_TILL_EMPTY)||(state==CHECK_PARITY_ERROR))?1:0;
    assign detect_add=((state==DECODE_ADDRESS))?1:0;
    assign lfd_state=((state==LOAD_FIRST_DATA))?1:0;
    assign ld_state=((state==LOAD_DATA))?1:0;
    assign write_enb_reg=((state==LOAD_DATA)||(state==LOAD_AFTER_FULL)||(state==LOAD_PARITY))?1:0;
    assign full_state=((state==FIFO_FULL_STATE))?1:0;
    assign laf_state=((state==LOAD_AFTER_FULL))?1:0;
    assign rst_int_reg=((state==CHECK_PARITY_ERROR))?1:0;
    
endmodule
