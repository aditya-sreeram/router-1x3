module router_reg(clk,resetn,packet_valid,datain,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);

    input clk,resetn,packet_valid;
	input [7:0] datain;
	input fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
	output reg err,parity_done,low_packet_valid;
	output reg [7:0] dout;
			
    //4 registers
	reg[7:0] header;
	reg[7:0] fifo_full_reg;
	reg[7:0]int_parity;
	reg packet_parity;
			
	always@(posedge clk)
		begin
		  if(!resetn) {int_parity,packet_parity,header,fifo_full_reg,dout,err,parity_done,low_packet_valid}=0;
			
		  else
		      begin
			      //parity_done
                  parity_done= (!detect_add &&
                               (((ld_state && !(fifo_full || packet_valid))||
                               (laf_state && low_packet_valid && !parity_done))))
                               ? 1:0;
                         
                  //low_pkt_done
                  low_packet_valid=(!rst_int_reg && ld_state && !packet_valid)? 1:0;
                  
                  
                  
                         
                  //datain
                  if(packet_valid)
                     begin
                         if(detect_add) header=datain; //latched to internal register
                         if(lfd_state) 
                             begin
                                dout=header; //latched to output
                                int_parity=int_parity ^ header;
                             end
                             
                         if(ld_state && !fifo_full) 
                             begin
                                dout=datain; //latched to output
                                int_parity= int_parity ^ datain;
                             end
                             
                         if(ld_state && fifo_full) fifo_full_reg=datain; //latched to register
                     end
                         
                  //incase of error, try else if:)
                  if(laf_state) 
                     begin
                         dout=fifo_full_reg;//this is internal signal, so dout won't be overwritten
                         int_parity = int_parity ^ fifo_full_reg;
                     end
                         
                  if(!packet_valid && !packet_parity)
                     begin
                         if(!fifo_full && ld_state) 
                            begin
                                err=(int_parity == datain)? 1:0;
                                packet_parity=1'b1;
                            end
                         else if(!low_packet_valid)//check this later
                            begin
                                err=(fifo_full_reg == int_parity)? 1:0;
                                packet_parity=1'b1;
                            end
                     end
                         
                         
              end
        end
        
        
			 	  
				  
endmodule
