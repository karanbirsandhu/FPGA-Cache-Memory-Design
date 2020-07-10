`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2020 10:59:46 AM
// Design Name: 
// Module Name: cache__tb
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

module cache_tb;

    reg clk;
    reg rst;

    reg PRead_request;
    reg PWrite_request;
    wire PRead_ready;
    wire PWrite_done;
    reg [7:0] PWrite_data;
    wire [7:0] PRead_data;
    reg [7:0] PAddress;
    //memory side
    wire MRead_request;
    wire MWrite_request;
    reg MRead_ready;
    reg MWrite_done;
    wire [7:0] MWrite_data;
    reg [31:0] MRead_data;
    wire [7:0] MAddress;
    //
    

    cache dut(
        .clk(clk),
        .rst(rst),
        //processor side
        .PRead_request(PRead_request),
        .PRead_ready(PRead_ready),
        .PRead_data(PRead_data),
        .PAddress(PAddress),
        .PWrite_request(PWrite_request),
        .PWrite_data(PWrite_data),
        .PWrite_done(PWrite_done),
        //memory side
        .MRead_request(MRead_request),
        .MRead_ready(MRead_ready),
        .MRead_data(MRead_data),
        .MAddress(MAddress),
        .MWrite_request(MWrite_request),
        .MWrite_done(MWrite_done),
        .MWrite_data(MWrite_data)              
        );

initial
begin
    clk = 0;
    rst = 1;
    
    PRead_request = 0;
    PAddress = 0;
    MRead_ready=0;
    MRead_data=32'b10111111100111111111001111111111;
    
    
    #10;
    @(posedge clk);
    rst = 0;
    #10;

//Writing Test
    //test logic for cache miss
    @(posedge clk);
    PWrite_data=1;
    PAddress = 2;
    PWrite_request=1;
    #10;
    @(posedge clk);
    MWrite_done=0;
    @(posedge clk);
    MWrite_done=1;
    wait(PWrite_done);
    @(posedge clk)
    MWrite_done=0;
    PWrite_request=0;
    #10;
    
    //test logic for cache hit
    @(posedge clk);
    PWrite_data=2;   
    PAddress = 2;
    PWrite_request=1;
    @(posedge clk)
    MWrite_done=0;
    @(posedge clk)
    MWrite_done=1;    
    wait(PWrite_done);
    @(posedge clk)
    PWrite_request=0;
    MWrite_done=0;
    #10;
    
    
    
    
 //Reading Test  
    //test logic for cache miss
    @(posedge clk);
    PAddress = 3;
    PRead_request = 1;
    #10;
    @(posedge clk);
    MRead_ready = 1;
    @(posedge clk);
    MRead_ready = 0;
    wait(PRead_ready);
    @(posedge clk);
    PRead_request = 0;
    #10;
    
    //test logic for cache hit
    @(posedge clk);
    PAddress = 2;
    PRead_request = 1;
    wait(PRead_ready);
    @(posedge clk);
    PRead_request = 0;
    #10;

    

end

always clk = #1 ~clk;

endmodule