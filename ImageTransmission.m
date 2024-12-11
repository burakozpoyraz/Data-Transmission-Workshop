%% MAIN FUNCTION
function [num_symbols, BER, output_image] = ImageTransmission(input_image, M, mod_type, SNRdB, channel_type)
    % TRANSMITTER//////////////////////////////////////////////////////////
    % Convert Image to Binary Bit Array====================================
    image_bit_array = Im2Bit(input_image);
    num_bits = length(image_bit_array);
    % =====================================================================
    
    % Baseband Modulation==================================================
    if mod_type == "QAM"
        ss = qammod(0 : M-1, M, "Gray", "UnitAveragePower", true);
    elseif mod_type == "PSK"
        ss = pskmod(0 : M-1, M, 0, "Gray");
    end
    m = log2(M);
    bit_matrix = reshape(image_bit_array, [m, num_bits / m]).';
    x = ss(Bin2Dec(bit_matrix) + 1);
    num_symbols = length(x);
    % =====================================================================
    % /////////////////////////////////////////////////////////////////////
    
    
    % TRANSMISSION CHANNEL/////////////////////////////////////////////////
    % Wireless Channel=====================================================
    h = sqrt(1 / 2) * (randn(1, num_symbols) + 1i * randn(1, num_symbols));
    % =====================================================================
    
    % Additional White Gaussian Noise (AWGN)===============================
    N0 = 1 / 10^(SNRdB / 10);
    n = sqrt(N0 / 2) * (randn(1, num_symbols) + 1i * randn(1, num_symbols));
    % =====================================================================
    % /////////////////////////////////////////////////////////////////////
    
    
    % RECEIVER/////////////////////////////////////////////////////////////
    % Received Symbols=====================================================
    if channel_type == "AWGN"
        y = x + n;
    elseif channel_type == "Fading"
        y = h .* x + n;
    end
    % =====================================================================
    
    % Baseband Demodulation================================================
    if channel_type == "AWGN"
        [~, min_ind_vec] = min(y.' - ss, [], 2);
    elseif channel_type == "Fading"
        [~, min_ind_vec] = min(y.' - h.' .* ss, [], 2);
    end
    detected_bit_matrix = Dec2Bin(min_ind_vec - 1, m);
    detected_image_bit_array = reshape(detected_bit_matrix.', [1, num_bits]);
    num_bit_errors = sum(xor(image_bit_array, detected_image_bit_array));
    BER = num_bit_errors / num_bits;
    % =====================================================================
    
    % Convert Binary Bit Array to Image====================================
    detected_image_bit_matrix = reshape(detected_image_bit_array, [8, num_bits / 8]).';
    output_image_array = Bin2Dec(detected_image_bit_matrix).';
    output_image = uint8(reshape(output_image_array, size(input_image)));
    % =====================================================================
    % /////////////////////////////////////////////////////////////////////
end

%% INNER FUNCTIONS (TOTAL OF 2)
%==========================================================================
% 1. Conversion from binary to decimal

% ARGUMENT
% - bit_array: Bit array to be converted to decimal value

% OUTPUT
% - decimal_value: Corresponding decimal value of the bit array
%==========================================================================
function decimal_value = Bin2Dec(bit_array)
    size_bit_array = size(bit_array);
    num_bits = size_bit_array(2);
    decimal_value = bit_array * (2.^((num_bits - 1) : -1 : 0))';
end
%==========================================================================


%==========================================================================
% 2. Conversion from decimal to binary

% ARGUMENTS
% 1-) decimal: Decimal value to be converted to bit array
% 2-) n: Number of bits in the resulting bit array

% OUTPUT
% - bit_array: Corresponding bit array of the decimal value
%==========================================================================
function bit_array = Dec2Bin(decimal, n)
    decreasing_pow_array = (n - 1 : -1 : 0);
    bit_array = zeros(length(decimal), n);
    for bit_index = 1 : n
        pow_val = decreasing_pow_array(bit_index);
        comparison = (decimal / 2^pow_val) >= 1;
        bit_array(comparison == 0, bit_index) = 0;
        bit_array(comparison == 1, bit_index) = 1;
        decimal(comparison == 1) = decimal(comparison == 1) - 2^pow_val;
    end
end
%==========================================================================