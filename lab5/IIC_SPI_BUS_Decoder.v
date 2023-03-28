module IIC_SPI_BUS_Decoder(
    input unsigned [31:0] Address,
    input IOSelect_H,
    input AS_L,
    output reg IIC0_Enable
);

    always@(*) begin
        IIC0_Enable <= 0;

        if(IOSelect_H && ~AS_L) begin
		    if(Address[15:4] == 12'h800) begin
                IIC0_Enable <= 1;
            end
        end
    end
    
endmodule

