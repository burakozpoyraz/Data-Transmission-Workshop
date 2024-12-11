%% MAIN FUNCTION
function [num_symbols, BER, output_stereo_array] = AudioTransmission(input_audio_array, M, mod_type, SNRdB, channel_type)
    % TRANSMITTER//////////////////////////////////////////////////////////
    % Map Audio Data to (0-255) Range======================================
    min_input = min(input_audio_array);
    max_input = max(input_audio_array);
    mapped_input_audio_array = fix(MapRange(input_audio_array, 0, 255));
    % =====================================================================
    
    % Convert Audio to Binary Bit Array====================================
    audio_bit_matrix = Dec2Bin(mapped_input_audio_array, 8);
    audio_bit_array = reshape(audio_bit_matrix.', [1, numel(audio_bit_matrix)]);
    num_bits = length(audio_bit_array);
    % =====================================================================
    
    % Baseband Modulation==================================================
    if mod_type == "QAM"
        ss = qammod(0 : M-1, M, "Gray", "UnitAveragePower", true);
    elseif mod_type == "PSK"
        ss = pskmod(0 : M-1, M, 0, "Gray");
    end
    m = log2(M);
    bit_matrix = reshape(audio_bit_array, [m, num_bits / m]).';
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
    detected_audio_bit_array = reshape(detected_bit_matrix.', [1, num_bits]);
    num_bit_errors = sum(xor(audio_bit_array, detected_audio_bit_array));
    BER = num_bit_errors / num_bits;
    % =====================================================================
    
    % Convert Binary Bit Array to Audio====================================
    detected_audio_bit_matrix = reshape(detected_audio_bit_array, [8, num_bits / 8]).';
    output_audio_array = Bin2Dec(detected_audio_bit_matrix).';
    % =====================================================================
    
    % Demap Output Array to Audio Data=====================================
    output_audio_array = MapRange(output_audio_array, min_input, max_input);
    mono_size = size(input_audio_array);
    output_stereo_array = reshape(output_audio_array, [mono_size(2) / 2, 2]);
    % =====================================================================
    % /////////////////////////////////////////////////////////////////////
end

%% INNER FUNCTIONS (TOTAL OF 3)
%==========================================================================
% 1. Conversion from decimal to binary

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


%==========================================================================
% 2. Mapping an array to another range

% ARGUMENTS
% 1-) input_array: Input array to be mapped to another range
% 2-) min_input: Minimum value of the new range
% 3-) max_input: Maximum value of the new range

% OUTPUT
% - output_array: Output array when the input array is mapped into the
% desired range
%==========================================================================
function output_array = MapRange(input_array, min_output, max_output)
    min_input = min(input_array, [], "all");
    max_input = max(input_array, [], "all");
    output_array = min_output +...
        (input_array - min_input) * (max_output - min_output) / (max_input - min_input);
end
%==========================================================================


%==========================================================================
% 3. Conversion from binary to decimal

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