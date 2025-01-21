`timescale 1ns / 1ps


module fifo_tb;

    reg clk,resetn,soft_reset,write_enb,read_enb,lfd_state;
    reg [7:0]datain;
    wire full,empty;
    wire [7:0]dataout;
    
    parameter cycle=10;
    
    integer i;
    
    router_fifo DUT (clk,resetn,soft_reset,write_enb,read_enb,lfd_state,datain,full,empty,dataout);
    
    initial
    begin
        clk=0;
        forever #(cycle/2) clk=~clk;
    end
    
    
    task inputs(input [7:0]a);//task for noramal inputs
        begin
            @(negedge clk)
            datain=a;
            
            
        end
    endtask
    
    task reset;//resets the fifo
        begin
            @(negedge clk)
            resetn=0;
            @(negedge clk)
            resetn=1; 
        end
    endtask
    
    task inputs_first(input [7:0]a);//task for header inpute
        begin
            @(negedge clk)
            write_enb=1'b1;
            lfd_state=1'b1;
            datain=a;
            #7;//lfd_state will be sampled
            lfd_state=1'b0;

        end
    endtask
    
    initial
        begin
            reset;
            for(i=0;i<30;i=i+1)
                begin
                    if(!i)inputs_first(8'b01010000);//20 is the payload lenght and 1 parity bit
                    else inputs(i);
                end
            write_enb=1'b0;
            
            
            
            
        end
        
    initial
        begin
            #50
            read_enb=1'b1;//after counter completes output will be high impedence
            #400 $finish;
            
        end
    
endmodule
