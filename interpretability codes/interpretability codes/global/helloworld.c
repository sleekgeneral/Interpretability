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
#include <stdint.h>
#include <string.h>

#define NUM_OUTPUTS 3
#define GPIO_TRI_OFFSET  0x4
#define GPIO_DATA_OFFSET 0x0
#define NUM_INPUTS 2

int main() {
    xil_printf("=== BUILD CHECK: %s %s ===\r\n", __DATE__, __TIME__);
    printf("\n");
    printf("// ------------------ Xilinx ZCU102 FPGA Development Board--------------- // \n");
    printf("// ------------------------------ READY --------------------------------- // \n");
    printf("//////////////////////////////////////////////////////////////////////////// \n");
    printf("\n");

    unsigned int output_bases[NUM_OUTPUTS] = {
        XPAR_XGPIO_0_BASEADDR,   /* kselect = [start,mnist] */
        XPAR_XGPIO_1_BASEADDR,    /* address */
        XPAR_XGPIO_2_BASEADDR,    /* class_no */
        
    };
    unsigned int input_bases[NUM_INPUTS] = {
        XPAR_XGPIO_3_BASEADDR,    /* value */
        XPAR_XGPIO_4_BASEADDR     //done   
    };

    /* Configure directions: outputs -> drive, inputs -> read */
    for (int i = 0; i < NUM_OUTPUTS; i++) {
        Xil_Out32(output_bases[i] + GPIO_TRI_OFFSET, 0x0); /* outputs */
    }
    for (int i = 0; i < NUM_INPUTS; i++) {
        Xil_Out32(input_bases[i] + GPIO_TRI_OFFSET, 0xFFFFFFFF); /* inputs */
    }
    while (1) {        
        Xil_Out32(XPAR_XGPIO_0_BASEADDR + GPIO_DATA_OFFSET, 0x0); // assert stop
        Xil_Out32(XPAR_XGPIO_0_BASEADDR + GPIO_DATA_OFFSET, 0x2); // start,emnist
        int i,j,k,wait = 0;
        u32 gpio_read2;
        int16_t lower_16, upper_16;
        for(j = 0;j<10;j++){
            Xil_Out32(XPAR_XGPIO_2_BASEADDR + GPIO_DATA_OFFSET, j); // assert class_no
            while ((Xil_In32(XPAR_XGPIO_4_BASEADDR + GPIO_DATA_OFFSET) & 0x1) == 0);
            for(i = 0;i < 784; i = i + 2){
                Xil_Out32(XPAR_XGPIO_1_BASEADDR + GPIO_DATA_OFFSET, i);
                gpio_read2 = Xil_In32(XPAR_XGPIO_3_BASEADDR + GPIO_DATA_OFFSET);
                for(k=0;k<1000;k++)wait = wait + 1;
                lower_16 = (int16_t)(gpio_read2 & 0xFFFF);          // lower 16 bits
                upper_16 = (int16_t)((gpio_read2 >> 16) & 0xFFFF); // upper 16 bits
                xil_printf("matrix[%d][%d] = %d \n\r", j,i,lower_16);
                xil_printf("matrix[%d][%d] = %d \n\r", j,i+1,upper_16);
            }
        }
    break;
    }
 cleanup_platform();
    return 0;
}