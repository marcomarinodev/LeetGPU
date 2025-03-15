#include "solve.h"
#include <cuda_runtime.h>
#include <iostream>

__global__ void invert_kernel(unsigned char* image, int width, int height) {
    const int firstBlockIndex = blockDim.x * blockIdx.x;

    // here it's like accessing a portion of the array, this element 
    // is a pixel, and for each pixel we would like to access 
    // to its RGBA values (reason why we do * 4)
    const int pixelIndex = (threadIdx.x + firstBlockIndex) * 4;

    // number of threads per block can be more then the number of pixels (plus the RGBA values)
    // so we need to check to not to go out of bounds
    if (pixelIndex < width * height * 4) {
        // computing the inverse for only RGB values
        for (int i = 0; i < 3; i++) {
            image[pixelIndex + i] = 255 - image[pixelIndex + i];
        }
    }
}
// image_input, image_output are device pointers (i.e. pointers to memory on the GPU)
void solve(unsigned char* image, int width, int height) {
    int threadsPerBlock = 256;
    int blocksPerGrid = (width * height + threadsPerBlock - 1) / threadsPerBlock;
    
    invert_kernel<<<blocksPerGrid, threadsPerBlock>>>(image, width, height);
    cudaDeviceSynchronize();
}