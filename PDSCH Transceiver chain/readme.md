Contains code in assignment 4 file.

The code contains
1. Transmit chain which will
 Generate a transport block (TB) of size 20496 and append TB-CRC
 Segment the TB and calculate and append the CB-CRC (implement the segmenta-
tion from the standard)
 LDPC encoding for all the segmented code blocks (Interleaving and interlacing are
not included)
 Perform rate matching for MCS 9 by considering an allocation of 100 PRBs over a
slot of 14 symbols. You can assume that six REs in a slot are reserved for pilots.
Assume that RV0 is being transmitted. Perform code block concatenation
 Perform interleaving, code block concatenation and scrambling according to the stan-
dard
 Perfom QPSK modulation according to the standard. You should remove the BPSK
modulator (mod output) provided with the LDPC encoder
2. Receive chain which will
 Perfom QPSK demodulation (create a new QPSK demodulator function by modify-
ing the BPSK demodulator provided with LDPC decoder)
 Perform de-scrambling, code block segmentation, and de-interleaving according to
the standard
 Perform code block segmentation
 Perform rate recovery for MCS 9 assuming RV0
 Perform LDPC decoding for each segmented code block
 Validate and remove the CB-CRC for each code block
 Concatenate the segemented decoder code blocks
 Show that the transmit and receive code block match
