% Read the original and reference images and normalize them,  so that their pixel values are in the range [0,1]
% Imread function reads the image as an RGB image by default. 

original = double(imread('resources/example.bmp'))/255;
reference   = double(imread('resources/example_marked.bmp'))/255;

if size(original, 3) == 1 % Check if the original image is grayscale
    original = repmat(original, [1, 1, 3]); % Convert to RGB
end

disp("Original image size");
disp(size(original));
disp("Reference image size");
disp(size(reference));

% As the algorithm works in YUV color mode where Y is the grayscale value
% and U, V define color, rgb2ntsc is used (converts to YUV basically)
YUV_Original=rgb2ntsc(original);
YUV_Reference=rgb2ntsc(reference);

% Get the brightness or luma component of the image in combination with the colored channels from the reference image.
YUV_combined_image = cat(3, YUV_Original(:,:,1), YUV_Reference(:,:,2:3));

% Get the size of the image
[N,M,~] = size(YUV_combined_image);
pixels = N * M;

% Set the size of the window. We need an odd number
windowSize = 7;
disp("Window size: " + windowSize);


% Create a matrix of size N by M containing consecutive integers from 1 to pixels
% to keep the indices for each pixel in the input image
inputPixelIndices = reshape(1:pixels, N, M);

% This variable keeps track of the number of non-zero elements in the sparse matrix.
countNonZeroElements = 0;

% Store the values(weights), row and column indices of the non-zero elements in the sparse matrix
weights             = zeros(pixels * (2*windowSize + 1), 1);
nonzeroPixelRows    = zeros(pixels * (2*windowSize + 1), 1);
nonzeroPixelColumns = zeros(pixels * (2*windowSize + 1), 1);

neighbors = zeros(1, windowSize);

mask = getMask(original, reference); 
% Find the indices of the uncolored and colored pixels in the binary mask
[uncolored_rows, uncolored_cols] = find(mask == 0);
colored_pixel_indices = find(mask == 1);

% Loop through each uncolored pixel
for idx = 1:length(uncolored_rows)
    % Get the (row, column) indices of the current uncolored pixel
    i = uncolored_rows(idx);
    j = uncolored_cols(idx);
    
    % calculate the linear index of the current uncolored pixel using the row and column indices, and the number of columns in the image
    pixelNum = sub2ind([N, M], i, j); % (j-1)*N + i

    % Get the neighbors based on a specific window
    [neighbors, neighbor_coords] = getNeighbors(i, j, windowSize, YUV_combined_image);
    neighborsNum = size(neighbors, 1);

    % Loop through the neighbors
    for neighbor = 1:neighborsNum
         neighborPixelNum =  sub2ind([N, M],neighbor_coords(neighbor, 1), neighbor_coords(neighbor, 2));

        countNonZeroElements = countNonZeroElements + 1;

        nonzeroPixelRows(countNonZeroElements) = pixelNum;
        nonzeroPixelColumns(countNonZeroElements) = neighborPixelNum;
    end

    % Add the current pixel value to the list of neighbors
    currentPixelValue = YUV_combined_image(i, j, 1);
    neighbors(neighborsNum + 1) = currentPixelValue;

    % Compute the variance of the local neighbors and set sigma accordingly
    sigma = var(neighbors(1:neighborsNum + 1));
    
    % Compute the mean value of the local neighbors 
    mean_value=mean(neighbors(1:neighborsNum+1));

    % calculate the correlation-based window using the neighbors, current pixel value, and sigma
    neighbors(1:neighborsNum) = 1 + (1/sigma)*(neighbors(1:neighborsNum) - mean_value)*(currentPixelValue - mean_value);


    % Calculate the Gaussian kernel using the neighbors, current pixel value, and sigma
    %neighbors(1:neighborsNum) = exp(-(neighbors(1:neighborsNum) - currentPixelValue).^2 / sigma);
    neighbors(1:neighborsNum) = neighbors(1:neighborsNum) / sum(neighbors(1:neighborsNum));

    % Create weights for the linear system of equations
    weights(countNonZeroElements - neighborsNum + 1:countNonZeroElements) = - neighbors(1:neighborsNum);
end

% Initialize diagonal elements vector
diagonal_elements = ones(pixels, 1);

% Build sparse matrix without diagonal elements
sparse_weights_matrix = sparse(nonzeroPixelRows(1:countNonZeroElements), nonzeroPixelColumns(1:countNonZeroElements), weights(1:countNonZeroElements), pixels, pixels);

% Add diagonal elements to the sparse matrix
sparse_weights_matrix = sparse_weights_matrix + spdiags(diagonal_elements, 0, pixels, pixels);

% Set U color (channel 2)
YUV_combined_image = setColor(2,YUV_combined_image,sparse_weights_matrix, pixels, colored_pixel_indices,N,M);
% Set V color (channel 3)
YUV_combined_image = setColor(3,YUV_combined_image, sparse_weights_matrix, pixels, colored_pixel_indices,N,M);

% Convert to rgb
YUV_combined_image  = ntsc2rgb(YUV_combined_image  );

figure, image(YUV_combined_image  )

write the image to file
imwrite(luma_channel,"output.bmp")


