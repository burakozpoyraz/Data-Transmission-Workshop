function image_bit_array = Im2Bit(input_image)
    input_image_array = double(reshape(input_image, [1, numel(input_image)]));
    image_bit_matrix = Dec2Bin(input_image_array, 8);
    image_bit_array = reshape(image_bit_matrix.', [1, numel(image_bit_matrix)]);
end

%==========================================================================
% Conversion from decimal to binary

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