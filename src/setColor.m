function image = setColor(channel, YUV_combined_image, sparse_weights_matrix,pixels, colored_pixel_indices, n , m )
    % extract the current color channel from the combined YUV image
    U_or_V_channel = YUV_combined_image(:,:,channel);

    % set the values of the colored pixels in the solution vector
    new_sparseValues = zeros(pixels, 1);
    new_sparseValues(colored_pixel_indices) = U_or_V_channel(colored_pixel_indices);

    % solve the linear system of equations using the preconditioned conjugate gradient method
    tolerance = 1e-6; % set the tolerance
    maxIterations = 5000; % set the maximum number of iterations
    [new_sparseValues, ~, ~, ~] = pcg(sparse_weights_matrix, new_sparseValues, tolerance, maxIterations);

    % reshape the resulting sparse values to form the color channel image
    YUV_combined_image (:,:,channel) = reshape(new_sparseValues, n, m, 1);

    image = YUV_combined_image;
end
