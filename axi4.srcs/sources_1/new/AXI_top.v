//AXI_top.sv

//AXI_topsv

module AXI_top #(parameter WIDTH=32) 
				   (input ACLK, ARESETn,input   [WIDTH-1:0]  awaddr,
					//input	[(WIDTH/8)-1:0]   wstrb,
					input	[WIDTH-1:0]	wdata,
					input	[WIDTH-1:0]	araddr,
					output	 [31:0] data_out,
					input   start,
					input   [1:0] alu_op,
					output  [31:0] alu_result);

						// ADDRESS WRITE CHANNEL
					wire		AWREADY;
					wire		AWVALID;
					wire	[WIDTH-1:0]	AWADDR;


					// DATA WRITE CHANNEL
					wire		WREADY;
					wire		WVALID;
					//wire	[(WIDTH/8)-1:0]	WSTRB;
					wire	[WIDTH-1:0]	WDATA;


					// WRITE RESPONSE CHANNEL
					wire	[1:0]			BRESP;
					wire		BVALID;
					wire		BREADY;

					// READ ADDRESS CHANNEL
					wire		ARREADY;
					wire		ARVALID;
					wire	[WIDTH-1:0]	ARADDR;


					// READ DATA CHANNEL
					wire	[WIDTH-1:0]	RDATA;
					wire	[1:0]	RRESP;
					wire		RVALID;
					wire		RREADY;

					// ALU control signal 
					wire we1;
					wire we2;
					wire [31:0] Op1;
					wire [31:0] Op2;
					wire [31:0] read_result;
					wire [31:0] alu_result;
//////////////// AXI MASTER
    AXI_master mstr (
        .awaddr(awaddr),
        .wdata(wdata),
        .araddr(araddr),
        .data_out(data_out),
        .ACLK(ACLK),
        .ARESETn(ARESETn),
    // ADDRESS WRITE CHANNEL	
        .AWREADY(AWREADY),
        .AWVALID(AWVALID),
        .AWADDR(AWADDR),							
    // DATA WRITE CHANNEL
        .WREADY(WREADY),
        .WVALID(WVALID),
        //.WSTRB(WSTRB),
        .WDATA(WDATA),						
    // WRITE RESPONSE CHANNEL
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
    // READ ADDRESS CHANNEL
        .ARREADY(ARREADY),
        .ARVALID(ARVALID),
        .ARADDR(ARADDR),
    // READ DATA CHANNEL
        .RDATA(RDATA),
        //.RRESP(RRESP),
        .RVALID(RVALID),
        .RREADY(RREADY)
        );
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////// SLAVE
		AXI_slave slv (
            .ACLK(ACLK),
        .ARESETn(ARESETn),
    // ADDRESS WRITE CHANNEL	
            .AWREADY(AWREADY),
            .AWVALID(AWVALID),
            .AWADDR(AWADDR),		
    // DATA WRITE CHANNEL
            .WREADY(WREADY),
            .WVALID(WVALID),
            //.WSTRB(WSTRB),
            .WDATA(WDATA),				
    // WRITE RESPONSE CHANNEL
            .BRESP(BRESP),
            .BVALID(BVALID),
            .BREADY(BREADY),
    // READ ADDRESS CHANNEL
            .ARREADY(ARREADY),
            .ARVALID(ARVALID),
            .ARADDR(ARADDR),
    // READ DATA CHANNEL
            .RDATA(RDATA),
            .RVALID(RVALID),
            .RREADY(RREADY),
    // ALU CONTROL SIGNAL                                           
            .Op1(Op1),
            .Op2(Op2),
            .we1(we1), 
            .we2(we2),  
            .read_result(read_result)
            );
								
 //////////////// AXI_ALU 
        ALU ALU_inst( 
            .clk(ACLK), 
            .rst(ARESETn), 
            .start(start),
            .Op1(Op1),
            .Op2(Op2),
            .we1(we1), 
            .we2(we2),  
            .alu_op(alu_op),
            .read_result(read_result),
            .alu_result(alu_result));
	endmodule 
		//////////////////////////////////////////////////////////////////////////////