function [neighbors, neighbor_coords] = getNeighbors(x, y, windowSize, YUV_combined_image)
    [n, m, ~] = size(YUV_combined_image);
    
    % Generate arrays of indices for all pixels in the local patch
    [x_neighbor, y_neighbor] = meshgrid(max(1,x-windowSize):min(x+windowSize,n), max(1,y-windowSize):min(y+windowSize,m));
    
    % Remove the indices corresponding to the current pixel
    not_current_pixel = (x_neighbor ~= x) | (y_neighbor ~= y);
    x_neighbor = x_neighbor(not_current_pixel);
    y_neighbor = y_neighbor(not_current_pixel);
    
    % Convert the subscripts to linear indices and store in the neighbors list
    num_neighbors = numel(x_neighbor);
    
    % Convert subscripts to linear indices
    linear_indices = sub2ind(size(YUV_combined_image), x_neighbor(:), y_neighbor(:), ones(num_neighbors, 1));
    
    % Get the Y channel values of the neighbors
    neighbors = YUV_combined_image(linear_indices);
    
    % Return the coordinates of the neighbors
    neighbor_coords = [x_neighbor(:), y_neighbor(:)];
end
