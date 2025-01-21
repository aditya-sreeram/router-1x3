
module router_fifo(clk,resetn,soft_reset,write_enb,read_enb,lfd_state,datain,full,empty,dataout);

    input clk,resetn,soft_reset,write_enb,read_enb,lfd_state;
    input [7:0]datain;
    output full,empty;
    output reg [7:0]dataout;
    
    integer i,j,
            ptr_count,//keeps track memory allocations
            pkt_counter;//keepts track of valid packets
    reg[8:0]mem[15:0];
    
    reg [7:0] temp;
    reg temp_flag;
    
    always@(*)
        begin
            temp<=datain;
            if(lfd_state) temp_flag=1'b1;
        end
 
    
    always@(posedge clk)
        begin
            if(!resetn || soft_reset) 
                begin
                    {dataout,ptr_count}=0;//reset state
                    for(i=0;i<16;i=i+1) mem[i]<=0;//clearing memory 
                    {i,j}<=0;
                    pkt_counter<=-1;//invalid state
                end
            else
                begin
                    if(write_enb && !full)//condition for writing
                        begin
                            mem[i][8:1]<=temp;
                            mem[i][0]=(temp_flag)? 1:0;//header bit addition
                            temp_flag=1'b0;
                            i=(i+1)%16;
                            ptr_count=ptr_count+1;//memory allocation pointer
//                            dataout<=8'h55;
                        end
                    if(read_enb && !empty)//condition for reading
                        begin
                            if(!pkt_counter) dataout=8'bz;//on completion of reading
                            else if(mem[j][0] && (pkt_counter==-1))//header read
                                begin
                                    pkt_counter=(mem[j][8:3])+1;//packet counter allocation
                                    dataout=mem[j][8:1];
                                    j=(j+1)%16;
                                    ptr_count=ptr_count-1;//memory allocation pointer
                                end
  
                            else if(pkt_counter>0)
                                begin
                                    dataout=mem[j][8:1];
                                    j=(j+1)%16;
                                    ptr_count=ptr_count-1;//memory allocation pointer
                                    pkt_counter=pkt_counter -1;//packet counter decrement 
                                end
                            else dataout=8'hff;//error condition case
                        end
                end
        end
        
        assign full=(ptr_count && (i==j))? 1:0;
        assign empty=(!ptr_count && (i==j))?1:0;
        
endmodule
