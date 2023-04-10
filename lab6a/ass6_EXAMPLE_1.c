/*
 * EXAMPLE_1.C
 *
 * This is a minimal program to verify multitasking.
 *
 */

#include <stdio.h>
#include <Bios.h>
#include <ucos_ii.h>

#define STACKSIZE  256

 /*
 ** Stacks for each task are allocated here in the application in this case = 256 bytes
 ** but you can change size if required
 */

OS_STK Task1Stk[STACKSIZE];
OS_STK Task2Stk[STACKSIZE];
OS_STK Task3Stk[STACKSIZE];
OS_STK Task4Stk[STACKSIZE];


/* Prototypes for our tasks/threads*/
void Task1(void*);	/* (void *) means the child task expects no data from parent*/
void Task2(void*);
void Task3(void*);
void Task4(void*);


/*
* From Bios.h:
* LED PORT ADDR:
* PortA = LED 0-7
* PortB = LED 8-9
* HEX 7 SEG PORT ADDR:
* HEX_A, HEX_B, HEX_C
*/

// LED and 7 Segment constants
INT8U LED70;
INT8U LED98;
INT8U HEX01;
INT8U HEX23;
INT8U HEX45;


/*
** Our main application which has to
** 1) Initialise any peripherals on the board, e.g. RS232 for hyperterminal + LCD
** 2) Call OSInit() to initialise the OS
** 3) Create our application task/threads
** 4) Call OSStart()
*/

void main(void)
{
    // initialise board hardware by calling our routines from the BIOS.C source file

    Init_RS232();
    Init_LCD();

    /* display welcome message on LCD display */

    Oline0("Altera DE1/68K");
    Oline1("Micrium uC/OS-II RTOS");

    OSInit();		// call to initialise the OS

    /*
    ** Now create the 4 child tasks and pass them no data.
    ** the smaller the numerical priority value, the higher the task priority
    */

    OSTaskCreate(Task1, OS_NULL, &Task1Stk[STACKSIZE], 12);
    OSTaskCreate(Task2, OS_NULL, &Task2Stk[STACKSIZE], 11);     // highest priority task
    OSTaskCreate(Task3, OS_NULL, &Task3Stk[STACKSIZE], 13);
    OSTaskCreate(Task4, OS_NULL, &Task4Stk[STACKSIZE], 14);	    // lowest priority task

    OSStart();  // call to start the OS scheduler, (never returns from this function)
}

/*
** IMPORTANT : Timer 1 interrupts must be started by the highest priority task
** that runs first which is Task2
*/

// 2nd priority
void Task1(void* pdata)
{

    for (;;) {
        printf("This is Task #1: LED Control\n");
        PortA = LED70;
        PortB = LED98;

        // LED 70 count to FF, then inc LED98
        if (LED70 == 0xFF) {
            LED70 = 0x00;
            // if LED70 at max val, check if at max val, then reset
            if (LED98 == 0xFF) {
                LED98 = 0x00;
            }
            else {
                LED98++;
            }
        }
        else {
            LED70++;
        }

        OSTimeDly(30);
    }
}

/*
** Task 2 below was created with the highest priority so it must start timer1
** so that it produces interrupts for the 100hz context switches
*/

// first priority
void Task2(void* pdata)
{
    // must start timer ticker here 

    Timer1_Init();      // this function is in BIOS.C and written by us to start timer      

    for (;;) {
        printf("....This is Task #2: 7 Seg HEX_A Control\n");
        HEX_A = HEX01;

        if (HEX01 == 0xFF) {
            HEX01 = 0x00;
        }
        else {
            HEX01++;
        }

        OSTimeDly(10);
    }
}

// 3rd prioriyt
void Task3(void* pdata)
{
    for (;;) {
        printf("........This is Task #3: 7 Seg HEX_B Control\n");
        HEX_B = HEX23;

        if (HEX23 == 0xFF) {
            HEX23 = 0x00;
        }
        else {
            HEX23++;
        }
        OSTimeDly(40);
    }
}

// 4th priority
void Task4(void* pdata)
{

    for (;;) {
        printf("............This is Task #4: 7 Seg HEX_C Control\n");
        HEX_C = HEX45;

        if (HEX45 == 0xFF) {
            HEX45 = 0x00;
        }
        else {
            HEX45++;
        }
        OSTimeDly(50);
    }
}
