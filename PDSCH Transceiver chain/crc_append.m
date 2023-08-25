%This function generates CRC 
function p = crc_append(a_vec,g,L)  
dividend = [a_vec zeros(1,L)]; % padding L zeros to the end of transport block and treating it as dividend.
COND     = 1;
%% modulo 2 division
while (COND)
    divisor   = [g zeros(1,length(dividend)-(L+1))]; % adding zeros to ensure that the TB data from L+1 to end is unaffected
    % if the data is less than L+1 treat it as remainder and exit.
    if (length(dividend) < length(g))
        COND = 0;
        p    = dividend; % p is the CRC remainder which is appended at the end of TB.
        break;
    else
        remainder = bitxor(dividend,divisor);
        index     = find(remainder,1);% this line finds the first non-zero index in the remainder
        dividend  = remainder(index:end); % ignoring the zeros and treating remaining bits as dividend.
    end
end

if length(p)<L
    p = [zeros(1,L-length(p)) p]; % length of remainder has to be L if it is less than L adding zeros in the front.
end
end