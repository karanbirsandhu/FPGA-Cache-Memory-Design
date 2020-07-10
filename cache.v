`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/21/2020 06:48:15 PM
// Design Name: 
// Module Name: cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache( PRead_request,PWrite_request,PWrite_data,PAddress,clk,rst,MRead_data,MRead_ready,MWrite_done,
MRead_request,MWrite_request,MWrite_data,MAddress,PRead_ready,PWrite_done,PRead_data);
//Processor Interface
input PRead_request;
input PWrite_request;
input [7:0] PWrite_data;
input [7:0] PAddress;
output PRead_ready;
output PWrite_done;
output [7:0] PRead_data;
//Memory Interface
output MRead_request;
output MWrite_request;
output [7:0] MWrite_data;
output [7:0] MAddress;
input MRead_ready;
input MWrite_done;
input [31:0] MRead_data;

//other ports
input clk;
input rst;
//
`define IDLE 8'd0
`define READING 8'd1
`define WRITING 8'd2
`define RESPONSE 8'd3

//8 blocks and each 32 bits
reg [31:0] blocks[7:0];
reg [2:0]cache_tags[7:0];
reg [7:0] invalid;
reg [1:0]state;
//
wire cache_hit;
reg data_out;
///
//

wire[2:0]p_tag=PAddress[7:5];
wire[2:0]p_block_select=PAddress[4:2];
wire[1:0]p_byte_in_block=PAddress[1:0];


always@(posedge clk)
begin
    if(rst)
    begin
        state <= `IDLE;
        invalid<=8'hFF;
    end
    else
    begin
        case(state)
        `IDLE:
        begin
            if(PRead_request & ~cache_hit)
                begin
                    state<=`READING;
                 end
            else if(PRead_request & cache_hit)
                begin
                    state<=`RESPONSE;
                end  
            else if(PWrite_request & ~cache_hit)
                begin
                    state<=`WRITING;
                end
            else if(PWrite_request & cache_hit)
                begin
                    state<=`RESPONSE;
                end                           
        end   
        `READING:
        begin
        //wait for memory to signal success
            if (MRead_ready)
            begin
            blocks[p_block_select] <= MRead_data;
            cache_tags[p_block_select] <= p_tag;
            invalid[p_block_select]<=1'b0;
            state<=`RESPONSE;
            end
        end
        `RESPONSE:
        begin
            if(~PRead_request && ~PWrite_request)
            begin
            state<=`IDLE;
            end
           else if(PRead_request)
            begin
                if( cache_tags[p_block_select]== p_tag)                           
                state<=`IDLE;
            end
           else if (PWrite_request)
            begin
                if (cache_tags[p_block_select] == p_tag)
                    begin
                        if(p_byte_in_block==2'd0)
                        begin
                            blocks[p_block_select][7:0]<=PWrite_data;                           
                        end 
                        else if(p_byte_in_block==2'd1) 
                        begin
                            blocks [p_block_select][15:8]<=PWrite_data;                           
                        end
                        else if(p_byte_in_block==2'd2)
                        begin
                            blocks [p_block_select][23:16]<=PWrite_data;                           
                        end
                        else
                        begin
                            blocks [p_block_select][31:24]<=PWrite_data;                           
                        end     
                    
                  
                        invalid[p_block_select]=1'b0;
                        state<=`WRITING;
                     end      
            end
        end
        `WRITING:
            begin
            if(MWrite_done)
                begin
                state<=`IDLE;
                end        
            end
        
       
        endcase
    end
end
        //cache hit assignment
        assign cache_hit=((cache_tags[p_block_select] == p_tag) & ~invalid[p_block_select]) ? 1:0;
        //
        assign PRead_ready=(PRead_request & (state==`RESPONSE));
        
        assign MRead_request =(state == `READING);
        
        assign MWrite_request=(state==`WRITING);
        //
        assign PWrite_done=MWrite_done;;
        
        //
        assign MWrite_data= ((state==`WRITING) & ~MWrite_done)? PWrite_data:0;
        //////(state==`WRITING)? PWrite_data: (p_byte_in_block==2'd0 ? blocks[p_block_select][7:0]:    
            ////                 p_byte_in_block==2'd1 ? blocks [p_block_select][15:8]:  
              ////               p_byte_in_block==2'd2 ? blocks [p_block_select][23:16]: 
                //                                     blocks [p_block_select][31:24]); 
        
        assign MAddress =(state == `READING)? {PAddress[7:2],2'b00}:PAddress;
        //data to be sent to processor after being read.
        assign PRead_data =     (p_byte_in_block==2'd0 )? blocks[p_block_select][7:0]:
                                (p_byte_in_block==2'd1 )? blocks [p_block_select][15:8]: 
                                (p_byte_in_block==2'd2 )? blocks [p_block_select][23:16]:
                                                          blocks [p_block_select][31:24];
        
endmodule
