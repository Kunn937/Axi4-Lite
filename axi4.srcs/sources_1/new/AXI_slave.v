//AXI_slave.v
//`include "AXI_interface.sv"
module AXI_slave  #(parameter WIDTH=32)
    (
			input   ACLK, ARESETn,
			// AXI_interface.slave AXI_S
    // ADDRESS WRITE CHANNEL
        output reg  AWREADY,
        input   AWVALID,
        input   [WIDTH-1:0]AWADDR,


    // DATA WRITE CHANNEL
        output reg  WREADY,
        input   WVALID,
        //input   [(WIDTH/8)-1:0] WSTRB,
        input   [WIDTH-1:0] WDATA,

    // WRITE RESPONSE CHANNEL
        output reg [1:0]    BRESP,
        output reg  BVALID,
        input   BREADY,

    // READ ADDRESS CHANNEL
        output reg  ARREADY,
        input   [WIDTH-1:0]ARADDR,
        input   ARVALID,

    // READ DATA CHANNEL
        output reg  [WIDTH-1:0]RDATA,
        //output reg  [1:0] RRESP,
        output reg  RVALID,
        input   RREADY,
    // ALU control signal 
        output we1,
        output we2,
        output [31:0] Op1,
        output [31:0] Op2,
        output read_result
);
reg [31:0] Op_1;
////////////////////// CREATING SLAVE MEMORY  
    reg  [31:0] slave_mem[0:65535];
    reg [31:0] AWADDR_reg;
    reg [31:0] ARADDR_reg;

//////////////////////////////// WRITE ADDRESS CHANNEL
	/////////////// VARIABLES FOR WRITE ADDRESS SLAVE ////////////////////

		parameter [1:0]         WA_IDLE_S = 2'b00,
                       			WA_START_S= 2'b01,
                        		WA_READY_S= 2'b10;

        reg [1:0]       WAState_S,WANext_state_S;
        integer i=0;

	//////////////////////////////  SEQUENTIAL BLOCK
						always@(posedge ACLK or negedge ARESETn)

								if(!ARESETn)			WAState_S <= WA_IDLE_S; 
																
													
								else					WAState_S <= WANext_state_S;
	/////////////////////////////  NEXT STATE DETEMINATION LOGIC

						always@*

								case (WAState_S)

									  WA_IDLE_S	 :  if(AWVALID)		WANext_state_S = WA_START_S;
									  				else			WANext_state_S = WA_IDLE_S;

									  WA_START_S :  				WANext_state_S = WA_READY_S;
									  
									  WA_READY_S :  				WANext_state_S = WA_IDLE_S;

    								  default    : 					WANext_state_S = WA_IDLE_S;
								endcase
	////////////////////////////  OUTPUT DTERMINATION LOGIC

						always@(posedge ACLK or negedge ARESETn)

								if(!ARESETn)				AWREADY <= 1'B0;
								else

									case (WANext_state_S)
									
										WA_IDLE_S : 			AWREADY <= 1'B0;
										WA_START_S:         begin 
																AWREADY <= 1'B1;
																AWADDR_reg <= AWADDR;
															end
										WA_READY_S:				AWREADY <= 1'B0;

										default : 				AWREADY <= 1'B0;
									endcase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////// WRITE DATA CHANNEL
	//////////////// VARIABLES FOR WRITE DATA SLAVE
            		parameter [1:0]         W_IDLE_S  = 2'b00,
		                                    W_START_S = 2'b01,
		                                    W_WAIT_S  = 2'b10,
		                                    W_TRAN_S  = 2'b11;

                    reg [1:0]       		WState_S,WNext_state_S;
			
 	//////////////////////////// SEQUENTIAL BLOCK

 								always@(posedge ACLK or negedge ARESETn)

 										if(!ARESETn)				WState_S <= W_IDLE_S;
 										else						WState_S <= WNext_state_S;				
	///////////////////////////// NEXT STATE DETERMINING BLOCK

								always@*

										case (WState_S)
											
											 W_IDLE_S  :  					WNext_state_S = W_START_S;

											 W_START_S :   if(AWREADY)		WNext_state_S = W_WAIT_S;
											 			   else				WNext_state_S = W_START_S;

											 W_WAIT_S  :   if(WVALID)		WNext_state_S = W_TRAN_S;
											 			   else				WNext_state_S = W_WAIT_S;

											 W_TRAN_S  :   					WNext_state_S = W_IDLE_S;

											 default   : 					WNext_state_S = W_IDLE_S;
										endcase
	///////////////////////////// OUTPUT DETERMINING BLOCK

						always@(posedge ACLK or negedge ARESETn)

								if(!ARESETn)					begin	WREADY <= 1'B0;
																		for(i=0 ; i<8;i=i+1)
															slave_mem[i] <= 8'b0;
												end	
								else
									case(WNext_state_S)

										 W_IDLE_S  :  				WREADY <= 1'B0;	

										 W_START_S :   				WREADY <= 1'B0;

										 W_WAIT_S  :   				WREADY <= 1'B0;

										 W_TRAN_S  :   		begin   WREADY <= 1'B1;
										 slave_mem[AWADDR_reg] <= WDATA;
										 //Op_1 <= WDATA;														 			
                               					end	 	

										 default   : 	WREADY <= 1'B0;

								endcase		 															
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////// WRITE RESPONSE CHANNEL
	//////////////////////// VARIABLES FOR WRITE RESPONSE SLAVE

   							parameter [1:0]         B_IDLE_S = 2'b00,
                                                    B_START_S= 2'b01,
                                                    B_READY_S= 2'b10;
                                                    
                                    reg [1:0]       BState_S,BNext_state_S;
	////////////////////////////////// SEQUENTIAL BLOCK

							always@(posedge ACLK or negedge ARESETn)

										if(!ARESETn)					BState_S <= B_IDLE_S;
										else							BState_S <= BNext_state_S;
	////////////////////////////////// NEXT STATE DETERMINING LOGIC

							always@*

										case(BState_S)

											B_IDLE_S   :  if(WREADY)	BNext_state_S = B_START_S;
														  else			BNext_state_S = B_IDLE_S;

											B_START_S  :  				BNext_state_S = B_READY_S;
											
											B_READY_S  :				BNext_state_S = B_IDLE_S;

											default    : 				BNext_state_S = B_IDLE_S;

										endcase // BState_S
	//////////////////////////////////// OUTPUT DETERMINING LOGIC

							always@(posedge ACLK or negedge ARESETn)

										if(!ARESETn)						begin BVALID <= 1'B0;
																			  BRESP  <= 2'B0; end
										else
											case(BNext_state_S)

												B_IDLE_S  :   			begin BVALID <= 1'B0;
																			  BRESP  <= 2'B00; end

												B_START_S :				begin BVALID <= 1'B1;
																			  BRESP  <= 2'B00; end

												B_READY_S :				begin BVALID <= 1'B0;
																			  BRESP  <= 2'B00; end

												default   :				begin BVALID <= 1'B0;
																			  BRESP  <= 2'B00; end

											endcase // BNext_state_S
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////																			  								  	 							  								  										  

//////////////////////////////// READ ADDRESS CHANNEL
	//////////////////////// VARIABLES FOR READ ADDRESS CHANNEL

							parameter [1:0]	AR_IDLE_S  = 2'B00,
											AR_READY_S = 2'B01;
							reg [1:0] ARState_S, ARNext_State_S;
	/////////////////////////// SEQUENTIAL BLOCK
							always@(posedge ACLK or negedge ARESETn)
									if(!ARESETn)					ARState_S <= AR_IDLE_S;
									else							ARState_S <= ARNext_State_S;
	/////////////////////////// NEXT STATE DETERMINING LOGIC
							always@*
									case(ARState_S)
										AR_IDLE_S :  if(ARVALID)  	ARNext_State_S = AR_READY_S;
													 else			ARNext_State_S = AR_IDLE_S;
										AR_READY_S:	 				ARNext_State_S = AR_IDLE_S;									
										default   :					ARNext_State_S = AR_IDLE_S;
									endcase 
	///////////////////////////// OUTPUT DETERMINING LOGIC
							always@(posedge ACLK or negedge ARESETn)
									if(!ARESETn)						ARREADY <= 1'B0;
									else
										case(ARNext_State_S)
											AR_IDLE_S  : 			ARREADY <= 1'B0;
											AR_READY_S :	begin	ARREADY <= 1'B1;
																	ARADDR_reg <= ARADDR; end
											default    :			ARREADY <= 1'B0;									
										endcase 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////																												 				

//////////////////////////////// READ DATA CHANNEL
	//////////////////////////// VARIABLES FOR READ DATA CHANNEL
parameter [1:0]	R_IDLE_S  = 2'B00,
            R_START_S = 2'B01,
            R_VALID_S = 2'B10;
reg       [1:0] RState_S, RNext_state_S;
//////////////////////////////// SEQUENTIAL BLOCK
always@(posedge ACLK or negedge ARESETn)
    if(!ARESETn)					RState_S 	  <=    R_IDLE_S;
    else							RState_S	  <= 	RNext_state_S;
//////////////////////////////// NEXT STATE DETERMINATION 								
always@*
    case(RState_S)
        R_IDLE_S  :  if(ARREADY)	RNext_state_S <=   R_START_S;
                     else			RNext_state_S <=   R_IDLE_S;
        R_START_S :  				RNext_state_S <=   R_VALID_S;									
        R_VALID_S : if(RREADY)		RNext_state_S <=   R_IDLE_S;
                    else			RNext_state_S <=   R_VALID_S;
        default   : 				RNext_state_S <=   R_IDLE_S;									
    endcase 
//////////////////////////////// OUTPUT DETERMINING LOGIC
always@(posedge ACLK or negedge ARESETn)
    if(!ARESETn)					RVALID   <=  1'B0;
    else
        case(RNext_state_S)
            R_IDLE_S  : 		RVALID   <= 1'B0;
            R_START_S : 		RVALID   <= 1'B0;
            R_VALID_S :	begin	RVALID   <= 1'B1;
            RDATA <= slave_mem[ARADDR_reg];     
                       end  	
            default   :					RVALID   <= 1'B0;
        endcase 
	//////////////////////////////// AXI slave												 
//////////////////////////////// ALU control signal
wire we1;
wire we2;
wire [31:0] Op1;
wire [31:0] Op2;
wire read_result;
assign we1 = (AWADDR == 16'h300 && AWREADY && AWVALID) ? 1 : 0;
assign we2 = (AWADDR == 16'h310 && AWREADY && AWVALID) ? 1 : 0;
assign Op1 = (we1) ? WDATA : Op1;
assign Op2 = (we2) ? WDATA : Op2;
assign read_result = (ARADDR == 16'h320 && RREADY && RVALID) ? 1 : 0;

endmodule // AXI_slave