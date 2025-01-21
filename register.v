module register(clk,resetn,packet_valid,datain,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);

    input clk,resetn,packet_valid;
	input [7:0] datain;
	input fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
	output reg err,parity_done,low_packet_valid;
	output reg [7:0] dout;
			
    //4 registers
	reg[7:0] hold_header_byte;
	reg[7:0] fifo_full_state_byte;
	reg[7:0]internal_parity;
	reg[7:0] packet_parity_byte;
	
 
    //parity_done    
    always@(posedge clk)
        begin
            if(!resetn) parity_done=1'b0;
            
            else  
//            parity_done= (!detect_add &&(((ld_state && !(fifo_full || packet_valid))||(laf_state && low_packet_valid && !parity_done))))? 1:0;  
                begin
                    if(ld_state && !(fifo_full || packet_valid)) parity_done<=1'b1;
                    else if(laf_state && low_packet_valid && !parity_done) parity_done<=1'b1;
                    else if(detect_add) parity_done<=1'b0;
                end
            
        end
            
    //low_packet_valid
    always@(posedge clk)
        begin
            if(!resetn) low_packet_valid<=1'b0;
            else  
//            low_packet_valid=(!rst_int_reg && ld_state && !packet_valid)? 1:0;
                begin
                    if(rst_int_reg) low_packet_valid<=1'b0;
                    if(ld_state && !packet_valid) low_packet_valid<=1'b1;
                end
        end
        
//    //updation    
//    always@(posedge clk)
//        begin
//            if(!resetn) {err,dout,int_parity,packet_parity,header,fifo_full_reg}=0;
//            else
//                begin
//                    if(packet_valid)
//                        begin
//                            if(detect_add) header=datain; //latched to internal register
//                            if(lfd_state) 
//                                begin
//                                    dout=header; //latched to output
//                                    int_parity=int_parity ^ header;
//                                end
                                     
//                             if(ld_state && !fifo_full) 
//                                begin
//                                    dout=datain; //latched to output
//                                    int_parity= int_parity ^ datain;
//                                end
                                     
//                             if(ld_state && fifo_full) fifo_full_reg=datain; //latched to register
//                        end
                                 
//                     //incase of error, try else if:)
//                     if(laf_state) 
//                        begin
//                            dout=fifo_full_reg;//this is internal signal, so dout won't be overwritten
//                            int_parity = int_parity ^ fifo_full_reg;
//                        end
                                 
//                     if(!packet_valid && !packet_parity)
//                        begin
//                            if(!fifo_full && ld_state) 
//                                begin
//                                    err=(int_parity == datain)? 1:0;
//                                    packet_parity=1'b1;
//                                end
//                            else if(!low_packet_valid)//check this later
//                                begin
//                                    err=(fifo_full_reg == int_parity)? 1:0;
//                                    packet_parity=1'b1;
//                                end
//                        end
//                end
        
        
//        end


    
    //----------------------------------------------------------------------------------------------------------
    //dout
    always@(posedge clk)
    
        begin
            if(!resetn)
                dout<=8'b0;
            else
            begin
                if(detect_add && packet_valid)
                    hold_header_byte<=datain;
                else if(lfd_state)
                    dout<=hold_header_byte;
                else if(ld_state && !fifo_full)
                    dout<=datain;
                else if(ld_state && fifo_full)
                    fifo_full_state_byte<=datain;
                else 
                    begin
                        if(laf_state)
                            dout<=fifo_full_state_byte;
                    end
            end
        end
    //-----------------------------------------------------------------------------------------------------
    

    // internal parity
    always@(posedge clk)
        begin
            if(!resetn)
                internal_parity<=8'b0;
            else if(lfd_state)
                internal_parity<=internal_parity ^ hold_header_byte;
            else if(ld_state && packet_valid && !full_state)
                internal_parity<=internal_parity ^ datain;
            else 
                begin	
                    if (detect_add)
                        internal_parity<=8'b0;
                end
        end
    //--------------------------------------------------------------------------------------------------------	
    //error and packet_
    always@(posedge clk)
        begin
            if(!resetn)
                packet_parity_byte<=8'b0;
            else 
                begin
                    if(!packet_valid && ld_state)
                        packet_parity_byte<=datain;
                end
        end
    //-------------------------------------------------------------------------------------------------------------------------------------
    //error
    always@(posedge clk)
        begin
            if(!resetn)
                err<=1'b0;
            else 
                begin
                    if(parity_done)
                    begin
                        if(internal_parity!=packet_parity_byte)
                            err<=1'b1;
                        else
                            err<=1'b0;
                    end
                end
        end
    


			 	  
				  
endmodule
