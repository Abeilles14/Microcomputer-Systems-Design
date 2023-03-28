module SPI_BUS_Decoder (
input unsigned [31:0] Address,
input SPI_Select_H,
input AS_L,
output reg SPI_Enable_H
);
    always@(*) begin
        SPI_Enable_H <= 0 ;
        if(SPI_Select_H && ~AS_L) begin
            if(Address[15:4]==12'h802) begin
                SPI_Enable_H <= 1;
            end
        end
    end
endmodule