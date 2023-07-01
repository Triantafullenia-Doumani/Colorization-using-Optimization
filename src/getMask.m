function mask = getMask(original, reference)
    % Compute the absolute difference between the two images
    diff = imabsdiff(rgb2gray(original), rgb2gray(reference));
    imtool(diff);
    % Apply a threshold to the difference image to create a binary mask
    %threshold = graythresh(diff);
    threshold = 0.01;
    mask = imbinarize(diff, threshold);
    disp("Threshold: " + threshold);
    if nnz(mask) == 0
        disp("The mask is full of zeros.");
    else
        disp("Cool! The mask contains nonzero elements.");
    end

end
