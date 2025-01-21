
module router_sync(clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,datain,
				   vld_out_0,vld_out_1,vld_out_2,write_enb,fifo_full, soft_reset_0,soft_reset_1,soft_reset_2);
					
		input clk,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
		input [1:0]datain;
		output wire vld_out_0,vld_out_1,vld_out_2;
		output reg [2:0]write_enb;
		output reg fifo_full, soft_reset_0,soft_reset_1,soft_reset_2;
					
		integer counter_0,counter_1,counter_2;//counter to track 30cycles if not read
		
		reg [2:0] temp;

		
		always@(posedge clk)
		  begin
		      if(!resetn)
		          begin
		              counter_0<=30;//initializing 
		              counter_1<=30;
		              counter_2<=30;

		              {write_enb,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2}=0;
		              
		          end
		      else if(detect_add)
		          begin
		              temp<=datain;
		              case(datain)
		                  2'b00: fifo_full<=full_0;//fifo full connected to fifo_0
		                            
		                  2'b01: fifo_full<=full_1;
		                           
		                  2'b10: fifo_full<=full_2;
		                            
		                  default: fifo_full<=1'bz;
		                          
		              endcase
		          end
		  end
		  
		  always@(posedge clk)
		  begin
		  if(resetn)
		      begin
		          if(vld_out_0)//executes only when fifo_0 isn't empty
		              begin
                          if(!counter_0 && !read_enb_0 ) //condition for soft_reset
                              begin
                                  soft_reset_0<=1;
                                  counter_0<=30;
                              end
                                  
                          else if(!read_enb_0) counter_0<=counter_0-1;//counter updation
		              end
		          
		          else counter_0<=30;
		      end
		  end
		  
		  always@(posedge clk)
		  begin
		  if(resetn)
		      begin
		          if(vld_out_1)
		              begin
                          if(!counter_1 && !read_enb_1 ) 
                              begin
                                  soft_reset_1<=1;
                                  counter_1<=30;
                              end
                                  
                          else if(!read_enb_1) counter_1<=counter_1-1;
		              end
		          
		          else counter_1<=30;
		      end
		  end
		  
		  always@(posedge clk)
		  begin
		  if(resetn)
		      begin
		          if(vld_out_2)
		              begin
                          if(!counter_2 && !read_enb_2 ) 
                              begin
                                  soft_reset_2<=1;
                                  counter_2<=30;
                              end
                                  
                          else if(!read_enb_2) counter_2=counter_2-1;
		              end
		          
		          else counter_2<=30;
		      end
		  end
		  
		  always@(posedge clk)
		      begin
		          if(write_enb_reg)
		              begin
		              case(temp)
		                  2'b00: write_enb<=write_enb_reg ? 3'b001:3'b0 ;//write enable switched based on register
		                  
		                  2'b01: write_enb<=write_enb_reg ? 3'b010: 3'b0;
		                        
		                  2'b10: write_enb<=write_enb_reg ? 3'b100: 3'b0;

		                  default:write_enb<=1'bz;
		              endcase
		              end
		      end
		      
		  assign vld_out_0=~empty_0;
		  assign vld_out_1=~empty_1;
		  assign vld_out_2=~empty_2;
endmodule
