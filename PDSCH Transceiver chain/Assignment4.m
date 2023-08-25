%Name : Prajeeth Babu Kodru
%Roll no : 22104071
%Assignment 4

clc;
TB = round(rand(20496,1));  %generates 20496 random values of 0 and 1
TBt = TB';                  %Transpose of TB 1x20496
B = length(TB)+24;          %TB+CRC CRC length=24
C = ceil(B/(8448-24));      %Number of codeblocks
B_ = B+C*24;                %Effective payload
Z = [power(2,(1:8)) 3.*power(2,(0:7)) 5.*power(2,(0:6)) 7.*power(2,(0:5)) 9.*power(2,(0:5)) 11.*power(2,(0:5)) 13.*power(2,(0:4)) 15.*power(2,(0:4))];
Z = sort(Z);
Zc = Z(find(Z>(B_/(C*22)),1,'first'));  %Lifting size >(B_/C*22) or >312 = 320 
K = 22*Zc;                  %Code block size
Fb = K-(B_/C);              %Number of filler bits per code block segment

nbg = 1;                    %Base graph 1
CRC_polynomial = [24,23,18,17,14,11,10,7,6,5,4,3,1,0]; %Coefficients of [D^24 + D^23 + D^18 + D^17 + D^14 + D^11 + D^10 + D^7 + D^6 + D^5 + D^4 + D^3 + D^1 + 1] from 3GPP TS 38.212 
GPoly = zeros(1,25);
for i=1:length(CRC_polynomial)
    GPoly(CRC_polynomial(i)+1) = 1;  %Generating Polynomial 
end

TBCRC = crc_append(TBt,GPoly,24); %Generate TB CRC
TB_B = [TBt TBCRC];               %TB+TBCRC append TB CRC
disp('Transport Block CRC generated');

%----------------------------------Segmentation----------------------- -------------------------
code_block=zeros(K,C);
for i=1:C
    if i<C
        code_block(:,i)=[TB_B((i-1)*(K-24-Fb)+1:i*(K-24-Fb)) crc_append(TB_B((i-1)*(K-24-Fb)+1:i*(K-24-Fb)),GPoly,24) -1*ones(1,176)]';
    else
        code_block(:,i)=[TB_B((i-1)*(K-24-Fb)+1:end) crc_append(TB_B((i-1)*(K-24-Fb)+1:end),GPoly,24) -1*ones(1,176)]';
    end
end
disp('Transport Block segmentation complete');

%LDPC Encoding
nldpcdecits = 25; % Decode with maximum no of iteration
  
%----------------------------------LDPC encoding----------------------- ------------------------
  
ldpc_coded_bits = double(LDPCEncode(code_block,nbg)); 
disp('LDPC encoding complete');

%----------------------------------Rate Matching----------------------- ------------------------

G = 100*162*2;  %Total number of bits allowed to transmit = PRB*RE*QAM
                %Rate matching for MCS 9 by considering an allocation of 100 PRBs over a
                % slot of 14 symbols. Assuming that six REs in a slot are reserved for pilots.
E = G/C;        %Number of bits allowed to be sent for each segmented code block

ldpc_coded_bits = ldpc_coded_bits(1:E,:);   %Remove bits after E
disp('Rate matching complete');

%----------------------------------Interleaving----------------------- -------------------------

Qm = 2;         %Modulation order
E = length(ldpc_coded_bits(:,1));
F = zeros(E,C);

for j=1:(E/Qm)
    for i=1:Qm
        F(i+Qm*(j-1),:) = ldpc_coded_bits(j+(E/Qm)*(i-1),:);
    end
end
disp('Interleaving complete');
        
%----------------------------------Code-Block Concatenation-----------------------------------------------

TB_tx = []; %TB Transmitted
for i=1:C
    TB_tx=[TB_tx (F(:,i))'];
end
disp('Code Block concatenation complete');

%----------------------------------Scrambling-----------------------------------------------------
Nc = 1600;
x1 = -1*ones(1,G+Nc);
c = zeros(1,G);
scrambled_output = -1*ones(1,G);

%Initialization of first sequence x1
x1(1)=1;    
for i=2:31
    x1(i)=0;
end

%Initialization of second sequence x2
x2init = randi([100,300],1,1);  %Take any random number for x2 initialization
x2initb = dec2bin(x2init)-'0';  %Covert decimal to binary
x2 = [x2initb zeros(1,G+Nc-length(x2initb))];   %Append zeros

for i=1:G+Nc-31
    x1(i+31)=xor(x1(i+3),x1(i));    %Generation of first sequence x1
    x2(i+31)=xor(xor(xor(x2(i),x2(i+1)),x2(i+2)),x2(i+3));  %Generation of second sequence x2
end
for i=1:G
    c(i)=xor(x1(i+Nc),x2(i+Nc));    %Generation of pseudo random sequence
end

for i=1:G
    scrambled_output(i) = xor(c(i),TB_tx(i));  %Scrambling
end
TB_tx = scrambled_output;
disp('Scrambling complete');

%----------------------------------QPSK Modulation----------------------- ------------------------  

NRZ = 2*(TB_tx-0.5);   %Convert to +1 and -1 

odd = zeros(1,length(TB_tx)/2);
even = odd;
cto = 1; cte = 1;
for i=1:length(TB_tx)
    if(mod(i,2)==1)
        odd(cto)=NRZ(i);
        cto=cto+1;
    else
        even(cte)=NRZ(i);
        cte=cte+1;
    end
end

disp('QPSK modulation complete');

% Add noise
noise_power = (10^-5);
noise = sqrt(noise_power)*randn(1,length(odd),'single');
tx_sigi = odd + noise; % to add noise in inphase component
tx_sigq = even + noise; % to add noise in quadrature component

tx_signal = tx_sigi + 1i*tx_sigq;   % Transmitted signal

disp('Signal Transmitted');

%----------------------------------QPSK Demodulation----------------------- ------------------------ 

disp('Signal Received');
rx_sigi = real(tx_signal);
rx_sigq = imag(tx_signal);
llr0 =  abs(-1 + rx_sigi);   % inphase demod
llr1 =  abs(1 + rx_sigi);    % inphase demod
llrj0=  abs(-1 + rx_sigq);    % quadrature demod   
llrj1=  abs(1 + rx_sigq);   % quadrature demod

llr_inphase = log(llr0./llr1);      % ldpc decoder requires log(p(r/0)/p(r/1))
llr_quadrature = log(llrj0./llrj1);      % ldpc decoder requires log(p(r/0)/p(r/1))
llrc = zeros(1,length(TB_tx));

ct=1;
for i=1:length(TB_tx)/2   %Combining inphase and quadrature
    llrc(ct)=llr_inphase(i);
    ct=ct+1;
    llrc(ct)=llr_quadrature(i);
    ct=ct+1;
end

demod_output = llrc;
disp('QPSK demodulation complete');

%-----------------------------------Descrambling-------------------------------------------------

descrambling_op = demod_output.*(-2*c+1);   %For xor with 0, multiply by 1
                                            %For xor with 1, multiply by -1
                                            %This is done because
                                            %demod_output is not in form
                                            %of 0 and 1.
disp('Descrambling complete');

%--------------------------------Code Block segmentation-----------------------------------------

code_block_rx = zeros(E,C); %Code block received
for i=1:C
    code_block_rx(:,i) = descrambling_op((i-1)*E+1:i*E);
end
disp('Code Block segmentation complete');

%----------------------------------Deinterleaver----------------------- -------------------------

deinterleaved_bits = zeros(E,C);
for j=1:(E/Qm)
    for i=1:Qm
        deinterleaved_bits(j+(E/Qm)*(i-1),:) = code_block_rx(i+Qm*(j-1),:);
    end
end
disp('DeInterleaving complete');

%----------------------------------Rate recovery----------------------- -------------------------
Decode_in = zeros(66*Zc,C);
for i=1:C
    Decode_in(:,i) = [deinterleaved_bits(:,i)' -1*ones(1,(66*Zc-E))]';
end
disp('Rate recovery complete');

%----------------------------------LDPC decoding----------------------- -------------------------

outputbits = double(LDPCDecode(Decode_in,nbg,nldpcdecits));  %Output of Demodulator

%errors = find(outputbits - code_block)
disp('LDPC decoding complete');

%----------------------------------CRC Validation----------------------- -------------------------

Validation_check = zeros(C,24);
Decoder_output = outputbits(1:K-Fb,:);    %Removing the filler bits
for i=1:C
    Validation_check(i,:) = crc_append((Decoder_output(:,i))',GPoly,24);
end
if sum(Validation_check)==0
    disp('Code Block CRC Validation successful- No errors');
else
    disp('Code Block CRC Validation failed- Errors present');
end

%----------------------------------Concatenation----------------------- -------------------------

code_block_received = Decoder_output(1:K-Fb-24,:);    %Remove Filler bits and CB-CRC
TB_received = []; %Concatenate the blocks 
for i=1:C
    TB_received = [TB_received (code_block_received(:,i))'];
end
disp('Code Block concatenation complete');

%----------------------------------Transport-Block Validation----------------------- -------------------------

TB_validate = crc_append(TB_received,GPoly,24);
if sum(TB_validate)==0
    disp('Transport Block CRC Validation successful- No errors');
else
    disp('Transport Block CRC Validation failed- Errors present');
end