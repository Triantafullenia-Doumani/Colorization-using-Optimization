# Colorization-using-Optimization

### General Idea 

The "Colorization using Optimization" algorithm is used to add color to grayscale images by leveraging the fact that neighboring pixels of the same intensity should have similar colors. Specifically, it employs a cost function J(r) to quantify the difference between a pixel r and its neighboring pixels in the color space, aiming to find the optimal value for that pixel to minimize this difference. The cost function is solved using a system of equations to determine the best values for all the pixels in the image.

The implementation of this algorithm is written in Matlab in this project and only works for still images.

### Algorithm


1) Input:
   
Original & reference image.

2) Iteration for non-colored pixels:

For each non-colored pixel, the code calculates the weights for the linear system of equations that will be solved later to estimate the U and V channels.

3) Neighborhood:

   
For each non-colored pixel, the algorithm identifies its neighbors within a specified window size.

4) Weights:


Calculate the weight based on the Gaussian Kernel using the neighbors, the current pixel value, and the variance.

5) U(s) = ai Y (s) + bi:
   
Construct the 'sparse_weights_matrix' using the computed weights. The matrix represents the relationship between neighboring pixels, capturing the local linear relationship between color and brightness.

6) Linear system:
    
The algorithm solves a system of linear equations using the preconditioned conjugate gradient (pcg) method. The solution includes the coefficients ai and bi as part of the equation system.

7) Update U and V channels:
    
The estimated U and V channels are updated in the YUV image using the solutions obtained from the linear system of equations.

8) Output:
The colored image is in RGB format.

### How to use the code

All you need to do is simply run the colorization.m file in Matlab. This will automatically use the examples from the recourses folder and give you the output(colored) image. 

### Authors

The "Colorization using Optimization" method was introduced by Anat Levin, Dani Lischinski, and Yair Weiss in their 2004 research paper titled "Colorization using Optimization" published in the ACM Transactions on Graphics (TOG) journal. 
