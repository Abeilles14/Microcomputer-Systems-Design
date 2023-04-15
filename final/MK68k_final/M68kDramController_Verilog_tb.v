`timescale 1ns / 1ps

module M68kDramController_Verilog_tb ();
	reg clk;
	reg Reset_L;
	wire [31:0] Address;
	wire [15:0] DataIn;
	wire UDS_L;
	wire LDS_L;
	wire DramSelect_L;
	wire WE_L;
	wire AS_L;

	wire [15:0] DataOut;
	wire SDram_CKE_H;
	wire SDram_CS_L;
	wire SDram_RAS_L;
	wire SDram_CAS_L;
	wire SDram_WE_L;
	wire [12:0] SDram_Addr;
	wire [1:0] SDram_BA;
	wire [15:0] SDram_DQ;
	wire Dtack_L;
	wire ResetOut_L;
	wire [4:0] DramState;

	M68kDramController_Verilog DUT (
		.Clock(clk),
		.Reset_L(Reset_L),
		.Address(Address),
		.DataIn(DataIn),
		.UDS_L(UDS_L),
		.LDS_L(LDS_L),
		.DramSelect_L(DramSelect_L),
		.WE_L(WE_L),
		.AS_L(AS_L),

		.DataOut(DataOut),
		.SDram_CKE_H(SDram_CKE_H),
		.SDram_CS_L(SDram_CS_L),
		.SDram_RAS_L(SDram_RAS_L),
		.SDram_CAS_L(SDram_CAS_L),
		.SDram_WE_L(SDram_WE_L),
		.SDram_Addr(SDram_Addr),
		.SDram_BA(SDram_BA),
		.SDram_DQ(SDram_DQ),
		.Dtack_L(Dtack_L),
		.ResetOut_L(ResetOut_L),
		.DramState(DramState)
	); 	

	// 1 period cycle = 10 ns
	initial	begin		//initial block
    	clk = 0;		//simulates clk every 5ps
    	#5;
    	forever begin
      		clk = 1 ;	//simulate clk
      		#5;
      		clk = 0 ;
      		#5;
    	end
  	end

	initial begin
		#10
		Reset_L = 1'b0;
		#10
		Reset_L = 1'b1;

		#1000;

	 	$stop;
	end
endmodule

