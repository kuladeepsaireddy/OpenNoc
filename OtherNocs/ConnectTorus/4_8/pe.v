`timescale 1ns/1ps

module pe #(address = 0,PktLmit=20,Pattern="RANDOM",AddressWidth=5,numPE=32)(
input clk,
input rst,
input [39:0] i_data,
input i_data_valid,
output o_data_ready,
output [39:0] o_data,
output wire o_data_valid,
input i_data_ready,
input done
);

integer receivedPkts = 0;
assign o_data_ready = 1'b1;
reg [AddressWidth-1:0] peaddress = 3;
integer seed;
reg [31:0] data;
integer i=0;
integer               receive_log_file;
reg   [100*8:0]       receive_log_file_name = "receive_log.csv";
integer j;
reg start=0;
integer counter=0;
integer latency;

always @(posedge clk)
    counter <= counter + 1;
    
initial
begin
    seed = address;
    @(posedge rst);
    #100;
    @(posedge clk);
    start = 1;
    receive_log_file = $fopen(receive_log_file_name,"a");
    repeat(PktLmit)
    begin
        data = counter;
        i = i+1;
        if(Pattern == "RANDOM")
        begin
           peaddress = $urandom(seed)%numPE;
        end
	    else if(Pattern == "COMPLEMENT")
        begin
           for(j=0;j<AddressWidth;j=j+1)
               peaddress[j] = !address[j];
        end
        else if(Pattern == "REVERSE")
        begin
           for(j=0;j<AddressWidth;j=j+1)
               peaddress[j] = address[AddressWidth-1-j]; 
        end
        else if(Pattern == "Rotation")
        begin
           for(j=0;j<AddressWidth;j=j+1)
               peaddress[j] = address[(j+1)%AddressWidth]; 
        end
        else if(Pattern == "Transpose")
        begin
           for(j=0;j<AddressWidth;j=j+1)
               peaddress[j] = address[(j+(AddressWidth/2))%AddressWidth]; 
        end
        else if(Pattern == "Tornado")
        begin
               peaddress = (address + (numPE+1)/2)%numPE; 
        end
        else if(Pattern == "Neighbour")
        begin
               peaddress = (address + 1)%numPE; 
        end    
        seed = seed + 1;
        sendData();
    end
    start = 0;
end

always @(posedge clk)
begin
    if(i_data_valid)
    begin
       latency = counter - i_data[31:0];
       $fwrite(receive_log_file,"%0d,%0d,%d,%d\n",address,i_data[35:33],i_data[31:0],latency);
       $fflush(receive_log_file);
       receivedPkts = receivedPkts + 1;
    end
end

reg data_valid=0;
assign o_data_valid = i_data_ready&start;
assign o_data = {1'b1,1'b1,peaddress,1'b0,data};

task sendData;
    begin
        #1;
        wait(i_data_ready);
        @(posedge clk);
    end
endtask

initial
begin
    @(posedge done);
    $display("PE No: %d\tReceived Packets: %d",address,receivedPkts);
end

endmodule
