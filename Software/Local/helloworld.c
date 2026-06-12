/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include <stdint.h>
#include <string.h>
#include "img_data.h"
#include "memory_data.h"
#include "weights_memory_data.h"

#define IMG_SIZE 28
#define TOTAL_BITS 784   // 28x28

#define NUM_OUTPUTS 2
#define NUM_INPUTS 2
#define GPIO_DATA_OFFSET 0x0
#define ROWS 28
#define COLS 28
#define LINES_PER_IMAGE 8
#define LINE_LENGTH 128
#define GPIO_TRI_OFFSET  0x4
#define WORDS_PER_ENTRY  8
#define THRESHOLD_CLAUSES        140
#define THRESHOLD_WEIGHTS        10
#define BRAM_BASE        XPAR_AXI_BRAM_0_BASEADDRESS
#define BRAM_BASE1      XPAR_AXI_BRAM_1_BASEADDRESS

int classes, clause,clauses, stride,patch_size,dataset,customized,classe;
int num_imgs = 20;
int d[1280];

#define TOTAL_CHUNKS 8
#define CHUNK_BITS 128
void transfer_img();
void print_binary();
void print_image();
void reconstruct_and_print();
int load_file_to_bram_mnist_7_weights(int BRAM_WIDTH_BITS) {
     u32 address_offsetcl = 0;

    // Each BRAM line = BRAM_WIDTH_BITS / 32 words
    int WORDS_PER_BRAM_LINE = BRAM_WIDTH_BITS / 32;
    int BYTES_PER_BRAM_LINE = BRAM_WIDTH_BITS / 8;

    xil_printf("Loading data into clauses BRAM (Width = %d bits)...\n\r", BRAM_WIDTH_BITS);

    // Loop through BRAM lines
    for (int line = 0; line < weights_memory_data_size / WORDS_PER_BRAM_LINE; line++) {
        xil_printf("Writing BRAM line %d at address 0x%08X\n\r",
                   line, BRAM_BASE1 + address_offsetcl);

        // Write each 32-bit word in the line
        for (int j = 0; j < WORDS_PER_BRAM_LINE; j++) {
            int idx = line * WORDS_PER_BRAM_LINE + j;
            Xil_Out32(BRAM_BASE + address_offsetcl + (j * 4), weights_memory_data[idx]);
        }

        // Move to next BRAM line
        address_offsetcl += BYTES_PER_BRAM_LINE;
    }
    xil_printf("Data loaded into weights BRAM 0 from internal array.\n\r");
    return 0;
}
int load_file_to_bram_mnistclauses_7(int BRAM_WIDTH_BITS) {
    u32 address_offsetcl = 0;

    // Each BRAM line = BRAM_WIDTH_BITS / 32 words
    int WORDS_PER_BRAM_LINE = BRAM_WIDTH_BITS / 32;
    int BYTES_PER_BRAM_LINE = BRAM_WIDTH_BITS / 8;

    xil_printf("Loading data into clauses BRAM (Width = %d bits)...\n\r", BRAM_WIDTH_BITS);

    // Loop through BRAM lines
    for (int line = 0; line < memory_data_size / WORDS_PER_BRAM_LINE; line++) {
        xil_printf("Writing BRAM line %d at address 0x%08X\n\r",
                   line, BRAM_BASE + address_offsetcl);

        // Write each 32-bit word in the line
        for (int j = 0; j < WORDS_PER_BRAM_LINE; j++) {
            int idx = line * WORDS_PER_BRAM_LINE + j;
            Xil_Out32(BRAM_BASE + address_offsetcl + (j * 4), memory_data[idx]);
        }

        // Move to next BRAM line
        address_offsetcl += BYTES_PER_BRAM_LINE;
    }

    xil_printf("Data loaded into clauses BRAM successfully.\n\r");
    return 0;
}
int main() {
xil_printf("=== BUILD CHECK: %s %s ===\r\n", __DATE__, __TIME__);
    printf("\n");
    printf("// ------------------ Xilinx ZCU102 FPGA Development Board--------------- // \n");
    printf("// ------------------------------ READY --------------------------------- // \n");
    printf("//////////////////////////////////////////////////////////////////////////// \n");
    printf("\n");

    unsigned int output_bases[NUM_OUTPUTS] = {
        XPAR_XGPIO_3_BASEADDR,   /* model params = {classes,clauses,stride,patch_size} */
        XPAR_XGPIO_1_BASEADDR    /* resets = {rst} */
    };
    unsigned int input_bases[NUM_INPUTS] = {
        XPAR_XGPIO_0_BASEADDR,    /* {class_op} */
        XPAR_XGPIO_2_BASEADDR        
    };

    /* Configure directions: outputs -> drive, inputs -> read */
    for (int i = 0; i < NUM_OUTPUTS; i++) {
        Xil_Out32(output_bases[i] + GPIO_TRI_OFFSET, 0x0); /* outputs */
    }
    for (int i = 0; i < NUM_INPUTS; i++) {
        Xil_Out32(input_bases[i] + GPIO_TRI_OFFSET, 0xFFFFFFFF); /* inputs */
    }

    while (1) {
        u32 val = 0,success = 0;
    Xil_Out32(XPAR_XGPIO_1_BASEADDR + GPIO_TRI_OFFSET, 0x0); // output
    Xil_Out32(XPAR_XGPIO_1_BASEADDR + GPIO_DATA_OFFSET, 0x1); // assert reset/stop
            xil_printf("Enter model parameters:\n\r");  
            xil_printf("Stride (0-7): ");
            //scanf("%d", &stride);
            stride = 1;
            xil_printf("%d\n\r",stride);

            xil_printf("Patch size (3 or  5 or 7): ");
            //scanf("%d", &patch_size);
            patch_size = 7;
            xil_printf("%d\n\r",patch_size);

            xil_printf("Dataset (1-4): \n\r 1.MNIST \n\r 2.FMNIST \n\r 3.KMNIST \n\r 4.Custom\n\r");            
            //scanf("%d", &dataset);
            dataset = 1;
            if(dataset == 1)xil_printf("MNIST Dataset selected\n\r");
            else if(dataset == 2)xil_printf("FMNIST Dataset selected\n\r");
            else if(dataset == 3)xil_printf("KMNIST Dataset selected\n\r");
            else if(dataset == 4)xil_printf("Custom Dataset selected, please change the clauses accordingly to the trained values\n\r");                                
            xil_printf("Classes (0-15): ");
            classe = 10;
            xil_printf("%d\n\r",classe%100);
            xil_printf("Clauses (0-140): ");
            clause = 140;
            xil_printf("%d\n\r",clause%1000);
            clauses = clause % 1000;
            classes = classe % 100;
            val = ((classes & 0xF) << 14) |
              ((clauses & 0xFF) << 6) |
              ((stride & 0x7) << 3) |
              ((patch_size & 0x7));
            xil_printf("GPIO i/p : %d\n\r",val);
            Xil_Out32(XPAR_XGPIO_3_BASEADDR + GPIO_DATA_OFFSET, val);
            int gpio_read2,temp = 0;
            if(patch_size == 7 && dataset == 1){
            xil_printf("Loading weights' BRAM...\n\r");
            load_file_to_bram_mnist_7_weights(256);
            xil_printf("Loading clauses' BRAM...\n\r");
            load_file_to_bram_mnistclauses_7(256);
       }
        xil_printf("Toggling overall reset & starting the image loading process...\n\r");
        Xil_Out32(XPAR_XGPIO_1_BASEADDR + GPIO_TRI_OFFSET, 0x0); // output
        Xil_Out32(XPAR_XGPIO_1_BASEADDR + GPIO_DATA_OFFSET, 0x1); // assert start
        Xil_Out32(XPAR_AXI_GPIO_0_BASEADDR + GPIO_TRI_OFFSET, 0xF);
        Xil_Out32(XPAR_AXI_GPIO_2_BASEADDR + GPIO_TRI_OFFSET, 0xFF);
        for(int j = 0;j < num_imgs;j++){
            transfer_img(j);   
            const char *img_dat[8] = {
            img_data[(8*j)],
            img_data[(8*j)+1],
            img_data[(8*j)+2],
            img_data[(8*j)+3],
            img_data[(8*j)+4],
            img_data[(8*j)+5],
            img_data[(8*j)+6],
            img_data[(8*j)+7]
            }; 
            reconstruct_and_print(img_dat);  
            for(int i=0;i<1000;i++){
               temp = temp + 1;            
            }
            gpio_read2 = Xil_In32(XPAR_XGPIO_0_BASEADDR + GPIO_DATA_OFFSET);
            xil_printf("Predicted class: %d, label : %d \n\r", gpio_read2,j/100);
            if(gpio_read2 == j/100)success++;
        }
        float percentage = ((float)success / num_imgs)* 100.0;
        int int_part = (int)percentage;
        int frac_part = (int)((percentage - int_part) * 100); // 2 decimal places
        xil_printf("accuracy = %d.%02d%%\n\r", int_part, frac_part);
    xil_printf("Multi-image inference complete.\n\r"); 
    break;
    }
 cleanup_platform();
    return 0;
}

void print_binary(uint32_t val)
{
    for (int i = 31; i >= 0; i--) {
        xil_printf("%d", (val >> i) & 1);
    }
    xil_printf("\n");
}
uint32_t bin_to_uint32(const char *bin)
{
    uint32_t val = 0;
    for (int i = 0; i < 32; i++) {
        val = (val << 1) | (bin[i] - '0');
    }
    return val;
}

void transfer_img(int num_img)
{
    // Configure GPIOs once
    Xil_Out32(XPAR_XGPIO_4_BASEADDR + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(XPAR_XGPIO_5_BASEADDR + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(XPAR_XGPIO_6_BASEADDR + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(XPAR_XGPIO_7_BASEADDR + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(XPAR_XGPIO_8_BASEADDR + GPIO_TRI_OFFSET, 0x0);

    for (int i = 0; i <= TOTAL_CHUNKS; i++)
    {
        const char *line;
        uint32_t d3, d2, d1, d0;
        if(i< TOTAL_CHUNKS)
        line = img_data[i + (8 * num_img)];
        else line = NULL;
        // Split 128-bit → 4×32-bit
        if(line != NULL){
        d3 = bin_to_uint32(&line[0]);    // [127:96]
        d2 = bin_to_uint32(&line[32]);   // [95:64]
        d1 = bin_to_uint32(&line[64]);   // [63:32]
        d0 = bin_to_uint32(&line[96]);   // [31:0]
        }

        else{
        d3 = 0;     // [127:96]
        d2 = 0;     // [95:64]
        d1 = 0;     // [63:32]
        d0 = 0;
        }    
        for (int b = 0; b < 32; b++) {
        d[i*128 + b]      = (d0 >> (31 - b)) & 1;
        d[i*128 + b + 32] = (d1 >> (31 - b)) & 1;
        d[i*128 + b + 64] = (d2 >> (31 - b)) & 1;
        d[i*128 + b + 96] = (d3 >> (31 - b)) & 1;
        }

        // Send to GPIO
        Xil_Out32(XPAR_XGPIO_8_BASEADDR + GPIO_DATA_OFFSET, i+1);
        Xil_Out32(XPAR_XGPIO_4_BASEADDR + GPIO_DATA_OFFSET, d0);
        Xil_Out32(XPAR_XGPIO_5_BASEADDR + GPIO_DATA_OFFSET, d1);
        Xil_Out32(XPAR_XGPIO_6_BASEADDR + GPIO_DATA_OFFSET, d2);
        Xil_Out32(XPAR_XGPIO_7_BASEADDR + GPIO_DATA_OFFSET, d3);

        for (volatile int d = 0; d < 1000; d++);
    }
}

// -------- FUNCTION --------
void reconstruct_and_print(const char *img_data[]) {
    
    int a[1024];           // temporary buffer (8 × 128)
    int b[ROWS][COLS];     // final 28×28 image

    int k = 0;

    // -------- READ FIRST 8 LINES ONLY --------
    for (int l = 0; l < LINES_PER_IMAGE; l++) {
        const char *line = img_data[l];

        // Reverse each line (MSB → LSB)
        for (int j = LINE_LENGTH - 1; j >= 0; j--) {
            a[k++] = line[j] - '0';
        }
    }

    // -------- RECONSTRUCT IMAGE (USE FIRST 784 BITS) --------
    k = 0;
    for (int i = ROWS - 1; i >= 0; i--) {
        for (int j = COLS - 1; j >= 0; j--) {
            b[i][j] = a[k++];
        }
    }

    // -------- PRINT IMAGE (* and .) --------
    printf("\nReconstructed Image:\n\n");

    for (int i = ROWS; i > 0; i--) {
        for (int j = COLS; j > 0; j--) {
            printf(b[i][j] ? "**" : "  ");
        }
        printf("\n");
    }
}

