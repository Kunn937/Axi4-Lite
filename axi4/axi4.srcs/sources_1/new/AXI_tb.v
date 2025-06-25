`timescale 1ns / 1ps

module AXI_tb();
reg ACLK;
reg ARESETn;
reg [31:0] awaddr;
reg [31:0] araddr;
reg [31:0] wdata;
//reg [3:0] wstrb;
wire [31:0] data_out;
wire [31:0] alu_result;
reg [1:0] alu_op;
reg start;
AXI_top #(32) axxi  (.ACLK(ACLK), .ARESETn(ARESETn),
                    .awaddr(awaddr),
					.wdata(wdata),
					.araddr(araddr),
					.data_out(data_out),
					.start(start),
					.alu_op(alu_op),
					.alu_result(alu_result));

// Reset initialization
    initial begin
    ACLK = 0;
    start = 0;
    ARESETn = 0;
    #2 ARESETn = 1;
    start = 1;
    end
    always begin
        #1 ACLK = ~ ACLK;
    end
integer i;

initial begin
    for (i = 0; i <= 10; i = i + 1) begin
            awaddr = 16'h300;
            wdata = $urandom_range(16);
            #10  
            wdata = $urandom_range(16);
            awaddr = 16'h310;
            #10
            araddr = 16'h320;
            #8 alu_op = 2'b00;
            #8 alu_op = 2'b01;
            #6 alu_op = 2'b10;
            #8 alu_op = 2'b11;
            
    end
end
endmodule
