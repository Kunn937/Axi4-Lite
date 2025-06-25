module ALU(
input clk, rst,
input start,
input [31:0] Op1,
input [31:0] Op2,
input we1, we2,    // chi cho thanh 2 thanh ghi Op1, Op2 ghi voi dung dia chi 
input [1:0] alu_op,
input read_result,
output [31:0] alu_result
    );
wire [31:0] reg1, reg2;
reg [31:0] reg3;    
register Op1_(.clk(clk), .rst(rst), .writeEn(we1), .regIn(Op1), .regOut(reg1));
register Op2_(.clk(clk), .rst(rst), .writeEn(we2), .regIn(Op2), .regOut(reg2));
register alu_result_(.clk(clk), .rst(rst), .writeEn(read_result), .regIn(reg3), .regOut(alu_result));
always @(posedge clk) begin
    if (start) begin
    case (alu_op)
        2'b00: assign reg3 = reg1 + reg2;
        2'b01: assign reg3 = reg1 - reg2;
        2'b10: assign reg3 = reg1 & reg2;
        2'b11: assign reg3 = reg1 | reg2;
        default: assign reg3 = 0;
     endcase
     end
end
endmodule