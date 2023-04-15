#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <ctype.h>
#include <string.h>
#include "snake.h"

#include <stdio.h>
#include <string.h>
#include <ctype.h>


//IMPORTANT
//
// Uncomment one of the two #defines below
// Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
// 0B000000 for running programs from dram
//
// In your labs, you will initially start by designing a system with SRam and later move to
// Dram, so these constants will need to be changed based on the version of the system you have
// building
//
// The working 68k system SOF file posted on canvas that you can use for your pre-lab
// is based around Dram so #define accordingly before building

//#define StartOfExceptionVectorTable 0x08030000
#define StartOfExceptionVectorTable 0x0B000000

/**********************************************************************************************
**	Parallel port addresses
**********************************************************************************************/

#define PortA   *(volatile unsigned char *)(0x00400000)
#define PortB   *(volatile unsigned char *)(0x00400002)
#define PortC   *(volatile unsigned char *)(0x00400004)
#define PortD   *(volatile unsigned char *)(0x00400006)
#define PortE   *(volatile unsigned char *)(0x00400008)

/*********************************************************************************************
**	Hex 7 seg displays port addresses
*********************************************************************************************/

#define HEX_A        *(volatile unsigned char *)(0x00400010)
#define HEX_B        *(volatile unsigned char *)(0x00400012)
#define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
#define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only

/**********************************************************************************************
**	LCD display port addresses
**********************************************************************************************/

#define LCDcommand   *(volatile unsigned char *)(0x00400020)
#define LCDdata      *(volatile unsigned char *)(0x00400022)

/********************************************************************************************
**	Timer Port addresses
*********************************************************************************************/

#define Timer1Data      *(volatile unsigned char *)(0x00400030)
#define Timer1Control   *(volatile unsigned char *)(0x00400032)
#define Timer1Status    *(volatile unsigned char *)(0x00400032)

#define Timer2Data      *(volatile unsigned char *)(0x00400034)
#define Timer2Control   *(volatile unsigned char *)(0x00400036)
#define Timer2Status    *(volatile unsigned char *)(0x00400036)

#define Timer3Data      *(volatile unsigned char *)(0x00400038)
#define Timer3Control   *(volatile unsigned char *)(0x0040003A)
#define Timer3Status    *(volatile unsigned char *)(0x0040003A)

#define Timer4Data      *(volatile unsigned char *)(0x0040003C)
#define Timer4Control   *(volatile unsigned char *)(0x0040003E)
#define Timer4Status    *(volatile unsigned char *)(0x0040003E)

/*********************************************************************************************
**	RS232 port addresses
*********************************************************************************************/

#define RS232_Control     *(volatile unsigned char *)(0x00400040)
#define RS232_Status      *(volatile unsigned char *)(0x00400040)
#define RS232_TxData      *(volatile unsigned char *)(0x00400042)
#define RS232_RxData      *(volatile unsigned char *)(0x00400042)
#define RS232_Baud        *(volatile unsigned char *)(0x00400044)

/*********************************************************************************************
**	PIA 1 and 2 port addresses
*********************************************************************************************/

#define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
#define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
#define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
#define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)

#define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
#define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
#define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
#define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)


/*************************************************************
** SPI Controller registers
**************************************************************/
// SPI Registers
//#define SPI_Control         (*(volatile unsigned char *)(0x00408020))
//#define SPI_Status          (*(volatile unsigned char *)(0x00408022))
//#define SPI_Data            (*(volatile unsigned char *)(0x00408024))
//#define SPI_Ext             (*(volatile unsigned char *)(0x00408026))
//#define SPI_CS              (*(volatile unsigned char *)(0x00408028))
//
//#define Enable_SPI_CS() SPI_CS = 0xFE
//#define Disable_SPI_CS() SPI_CS = 0xFF

/*************************************************************
** VGA Controller registers
**************************************************************/
// VGA Registers
#define VGA_Start           (*(volatile unsigned char *)(0x00500000))
//#define VGA_RAM_END         (*(volatile unsigned char *)(0x00500C7F)) 

// VGA address range is [31:16] = 16'b0000_0000_0101_0000 = 0050_0000
// using [13:0] in VGA_Controller
// [13:12] are CRX CRY CTL registers
// CRX = 0050...0001_0000_0000_0000 = 0050_1000
// CRY = 0050...0010_0000_0000_0000 = 0050_2000
// CTL = 0050...0011_0000_0000_0000 = 0050_3000
// if (Address[31:16] == 16'b0000_0000_0101_0000)	// address hex 0050_0000 -> 0050_1000
// [31:16],0050_ |0001_0000_0000_0000 

//#define VGA_CRX             (*(volatile unsigned char *)(0x00501000))
//#define VGA_CRY             (*(volatile unsigned char *)(0x00502000))
//#define VGA_CTL             (*(volatile unsigned char *)(0x00503000))

#define VGA_CRX             (*(volatile unsigned char *)(0x00511000))
#define VGA_CRY             (*(volatile unsigned char *)(0x00511001))
#define VGA_CTL             (*(volatile unsigned char *)(0x00511002))

//#define Enable_VGA_CS() SPI_CS = 0xFE
//#define Disable_VGA_CS() SPI_CS = 0xFF

/********************************************************************************************
**	RGB Colours
*********************************************************************************************/

#define RED     0x30
#define GREEN   0xC0
#define BLUE    0x20
#define WHITE   0xFF
#define BLACK   0

/********************************************************************************************
**	VideoRam addresses
*********************************************************************************************/

#define DramStart               0x08000000
#define DramEnd                 0x0BFFFFFF  // 64MB on DE1-soc
#define ProgramStart            0x08000000
#define FlashStart				0x01000000  // 256Kbytes
#define ProgramEnd              0x0803FFFF  // 256Kbytes
#define Num_FlashSectors        ((ProgramEnd - ProgramStart)/65536)
#define FlashSize               (ProgramEnd - ProgramStart)
#define XRES			        640
#define YRES			        480
#define MemNumRows		        512
#define MemNumCols		        1024
#define XPIXELS			        7		// number of horizontal pixels in a column including space
#define YPIXELS			        9		// number of vertical pixels in a row including space
#define BorderHeight            4
#define BorderWidth		        4


/*********************************************************************************************************************************
(( DO NOT initialise global variables here, do it main even if you want 0
(( it's a limitation of the compiler
(( YOU HAVE BEEN WARNED
*********************************************************************************************************************************/

unsigned int i, x, y, z, PortA_Count;
unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count;


/**********************************************************************************
** Timer Initialisation Routine
**********************************************************************************/
void Timer_Init(void)
{   

    // program time delay into timers 1-4
    Timer1Data = 0x03;		// 10 ms
    Timer2Data = 0x4c;      // 200 ms
    Timer3Data = 0xb7;      // 500 ms
    Timer4Data = 0x24;      // 100 ms

    /*
    ** timer driven off 25Mhz clock so program value so that it counts down in 0.01 secs
    ** the example 0x03 above is loaded into top 8 bits of a 24 bit timer so reads as
    ** 0x03FFFF a value of 0x03 would be 262,143/25,000,000, so is close to 1/100th sec
    **
    **
    ** Now write binary 00000011 to timer control register:
    **	Bit0 = 1 (enable interrupt from that timer)
    **	Bit 1 = 1 enable counting
    */

    Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
    Timer2Control = 3;
    Timer3Control = 3;
    Timer4Control = 3;
}
/*****************************************************************************************
**	Interrupt service routine for Timers
**
**  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
**  out which timer is producing the interrupt
**
*****************************************************************************************/

void Timer_ISR()
{
    if (Timer4Status == 1) {         // Did Timer 1 produce the Interrupt?
        Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_B = Timer4Count++;     // increment an LED count on PortA with each tick of Timer 1
    }

    if (Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
        Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        PortC = Timer2Count++;     // increment an LED count on PortC with each tick of Timer 2

    }

    if (Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
        Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_A = Timer3Count++;     // increment a HEX count on Port HEX_A with each tick of Timer 3
    }

    if (Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
        Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        PortA = Timer1Count++;              // increment an LED count on PortA with each tick of Timer 1
        PortA_Count += 10;
        //printf("\r\nPortA_Count = %d", PortA_Count);
    }
}

/*****************************************************************************************
**	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void ACIA_ISR()
{}

/***************************************************************************************
**	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void PIA_ISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 2 on DE1 board. Add your own response here
************************************************************************************/
void Key2PressISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 1 on DE1 board. Add your own response here
************************************************************************************/
void Key1PressISR()
{}

/************************************************************************************
**   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
************************************************************************************/
void Wait1ms(void)
{
    int  i;
    for (i = 0; i < 1000; i++)
        ;
}

/************************************************************************************
**  Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i;
    for (i = 0; i < 3; i++)
        Wait1ms();
}

/*********************************************************************************************
**  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
**  Sets it for parallel port and 2 line display mode (if I recall correctly)
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = 0x0c;
    Wait3ms();
    LCDcommand = 0x38;
    Wait3ms();
}

/*********************************************************************************************
**  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = 0x15; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
    RS232_Baud = 0x1;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

/*********************************************************************************************************
**  Subroutine to provide a low level output function to 6850 ACIA
**  This routine provides the basic functionality to output a single character to the serial Port
**  to allow the board to communicate with HyperTerminal Program
**
**  NOTE you do not call this function directly, instead you call the normal putchar() function
**  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
**  call _putch() also
*********************************************************************************************************/

int _putch(int c)
{
    while ((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal getchar() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
**  call _getch() also
*********************************************************************************************************/
int _getch(void)
{
    char c;
    while ((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
}

int kbhit(void)
{
    if (((char)(RS232_Status) & (char)(0x01)) == (char)(0x01))    // wait for Rx bit in status register to be '1'
        return 1;
    else
        return 0;
}


/******************************************************************************
**  Subroutine to output a single character to the 2 row LCD display
**  It is assumed the character is an ASCII code and it will be displayed at the
**  current cursor position
*******************************************************************************/
void LCDOutchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms();
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void LCDOutMessage(char* theMessage)
{
    char c;
    while ((c = *theMessage++) != 0)     // output characters from the string until NULL
        LCDOutchar(c);
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void LCDClearln(void)
{
    int i;
    for (i = 0; i < 24; i++)
        LCDOutchar(' ');       // write a space char to the LCD display
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 1 and clear that line
*******************************************************************************/
void LCDLine1Message(char* theMessage)
{
    LCDcommand = 0x80;
    Wait3ms();
    LCDClearln();
    LCDcommand = 0x80;
    Wait3ms();
    LCDOutMessage(theMessage);
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 2 and clear that line
*******************************************************************************/
void LCDLine2Message(char* theMessage)
{
    LCDcommand = 0xC0;
    Wait3ms();
    LCDClearln();
    LCDcommand = 0xC0;
    Wait3ms();
    LCDOutMessage(theMessage);
}

/*********************************************************************************************************************************
**  IMPORTANT FUNCTION
**  This function install an exception handler so you can capture and deal with any 68000 exception in your program
**  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
**  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
**  Calling this function allows you to deal with Interrupts for example
***********************************************************************************************************************************/

void InstallExceptionHandler(void (*function_ptr)(), int level)
{
    volatile long int* RamVectorAddress = (volatile long int*)(StartOfExceptionVectorTable);   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int*)(function_ptr);                       // install the address of our function into the exception table
}

// converts hex char to 4 bit binary equiv in range 0000-1111 (0-F)
// char assumed to be a valid hex char 0-9, a-f, A-F

char xtod(int c)
{
    if ((char)(c) <= (char)('9'))
        return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
    else if ((char)(c) > (char)('F'))    // assume lower case
        return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
    else
        return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
}

int Get2HexDigits(char* CheckSumPtr)
{
    register int i = (xtod(_getch()) << 4) | (xtod(_getch()));

    if (CheckSumPtr)
        *CheckSumPtr += i;

    return i;
}

int Get4HexDigits(char* CheckSumPtr)
{
    return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get6HexDigits(char* CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get8HexDigits(char* CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//                        user program
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////



int score;
int timer;

struct
{
    coord_t xy[SNAKE_LENGTH_LIMIT];
    int length;
    dir_t direction;
    int speed;
    int speed_increase;
    coord_t food;
} Snake;

const coord_t screensize = { NUM_VGA_COLUMNS,NUM_VGA_ROWS };

int waiting_for_direction_to_be_implemented;


/////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//                        functions to implement
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////


void putcharxy(int x, int y, char ch) {
	//display on the VGA char ch at column x, line y
    unsigned char* RamPtr;
    RamPtr = &VGA_Start + (y * NUM_VGA_COLUMNS + x);
    *RamPtr = ch;
}

void print_at_xy(int x, int y, const char* str) {
	 //print a string on the VGA, starting at column x, line y. 
	 //Wrap around to the next line if we reach the edge of the screen

    char* strPtr;
    int i = x;
    int j = y;
    for (strPtr = str; *strPtr != '\0'; strPtr++) {
        putcharxy(i, j, *strPtr);
        i++;
        if (i > NUM_VGA_COLUMNS-1) {
            j++;
            i = x;
        }
    }

}

void cls()
{
    int i;
    int j;
    for (i = 0; i < NUM_VGA_COLUMNS; i++) {
        for (j = 0; j < NUM_VGA_ROWS; j++) {
            putcharxy(i, j, SPACE);
        }
    }
};

void gotoxy(int x, int y)
{
	//move the cursor to location column = x, row = y
    VGA_CRX = x;
    VGA_CRY = y;
};

void set_vga_control_reg(char x) {
	//Set the VGA control (OCTL) value
    /*Control of the peripheral.Bit 7 (MSB)is VGA enable signal.Bit 6 is HW
    cursor enable bit.Bit 5 is Blink HW cursor enable bit.Bit 4 is HW cursor
    mode(0 = big; 1 = small).Bits(2:0) is the output color.*/
    VGA_CTL = x;
}


char get_vga_control_reg() {
	//return the VGA control (OCTL) value
    char ctl_status;
    ctl_status = VGA_CTL;

    return ctl_status;
}

int clock() {
	//return the current value of a milliseconds counter, with a resolution of 10ms or better
    return PortA_Count;
}

void delay_ms(int num_ms) {
	//delay a certain number of milliseconds
    int start_time = PortA_Count;
    int end_time = PortA_Count + num_ms;

    while (PortA_Count < end_time) {}
}

void disable_cursor() {
    // 100x_xxxx = 80
    // 111x_xxxx = E0
    // default: 1111_0010
    set_vga_control_reg(0x82);
}

void gameOver()
{
    //show game over screen and animation
    /*Bit 7 (MSB)is VGA enable signal.
    Bit 6 is HW cursor enable bit.
    Bit 5 is Blink HW cursor enable bit.
    Bit 4 is HW cursor mode(0 = big; 1 = small).
    Bits(2:0) is the output color.*/

    int x = 35;
    int y = 21;
    int i;
    unsigned char color = 0xF0;
    unsigned char ctl_status;

    char gameover_text[] = "Game over!";
    char score_display[] = "Score: ";
    char score_text[];

    int len = strlen(gameover_text);

    // clear screen
    cls();
    set_vga_control_reg(0xF4);
    

    // gameover
    for (i = 0; i < len; i++) {
        gotoxy(x, y);
        putcharxy(x, y, gameover_text[i]);
        delay_ms(100);
        x++;

       /* ctl_status = get_vga_control_reg();
        printf("\r\nCTL STATUS: %x", ctl_status);*/
    }

    // score
    x = 35;
    y += 2;
    sprintf(score_text, "%d", score);
    strcat(score_display, score_text);
    len = strlen(score_display);

    for (i = 0; i < len; i++) {
        gotoxy(x, y);
        putcharxy(x, y, score_display[i]);
        delay_ms(100);
        x++;
    }
    x++;
    gotoxy(x, y);

    while (!kbhit()) {
        // change colors
        color++;
        if (color == 0xF7) {
            set_vga_control_reg((char)color);
            color = 0xF0;
        }
        else {
            set_vga_control_reg((char)color);
        }
        delay_ms(300);
    }
    printf("\r\nGAMEOVER!\r\nPress any key to continue...");
}

void updateScore()
{
	//print the score at the bottom of the screen
    char* score_text = "Score: ";
    char score_display[10];
   
    sprintf(score_display, "%d", score);
    print_at_xy(1, NUM_VGA_ROWS - 1, score_text);
    print_at_xy(8, NUM_VGA_ROWS - 1, (char*)score_display);
}
void drawRect(int x, int y, int x2, int y2, char ch)
{
    //draws a rectangle. Left top corner: (x1,y1) length of sides = x2,y2
    int i;
    // top line
    for (i = x; i < (x + x2); i++) {
        putcharxy(i, y, BORDER);
    }
    // left line
    for (i = y; i < (y + y2); i++) {
        putcharxy(x, i, BORDER);
    }
    // right line
    for (i = y; i < (y + y2); i++) {
        putcharxy(x2, i, BORDER);
    }
    // bottom line
    for (i = x; i < (x + x2); i++) {
        putcharxy(i, y2, BORDER);
    }
}

/////////////////////////////////////////////////////////////////////////////
//
//  End functions you need to implement
//
/////////////////////////////////////////////////////////////////////////////

void initSnake()
{
    Snake.speed          = INITIAL_SNAKE_SPEED ;         
    Snake.speed_increase = SNAKE_SPEED_INCREASE;
}

void drawSnake()
{
    int i;
    for(i = 0; i < Snake.length; i++)
    {
       	putcharxy(Snake.xy[i].x, Snake.xy[i].y,SNAKE);
    }

}

void drawFood()
{
    putcharxy(Snake.food.x, Snake.food.y,FOOD);
}

void moveSnake()//remove tail, move array, add new head based on direction
{
    int i;
    int x;
    int y;
    x = Snake.xy[0].x;
    y = Snake.xy[0].y;
    //saves initial head for direction determination

    putcharxy(Snake.xy[Snake.length-1].x, Snake.xy[Snake.length-1].y,' ');

    for(i = Snake.length; i > 1; i--)
    {
        Snake.xy[i-1] = Snake.xy[i-2];
    }
    //moves the snake array to the right

    switch (Snake.direction)
    {
        case north:
            if (y > 0)  { y--; }
            break;
        case south:
            if (y < (NUM_VGA_ROWS-1)) { y++; }
            break;
        case west:
            if (x > 0) { x--; }
            break;
        case east:
            if (x < (NUM_VGA_COLUMNS-1))  { x++; }
            break;
        default:
            break;
    }
    //adds new snake head
    Snake.xy[0].x = x;
    Snake.xy[0].y = y;

    waiting_for_direction_to_be_implemented = 0;
    putcharxy(Snake.xy[0].x,Snake.xy[0].y,SNAKE);
}


/* Compute x mod y using binary long division. */
int mod_bld(int x, int y)
{
    int modulus = x, divisor = y;

    while (divisor <= modulus && divisor <= 16384)
        divisor <<= 1;

    while (modulus >= y) {
        while (divisor > modulus)
            divisor >>= 1;
        modulus -= divisor;
    }

    return modulus;
}

void generateFood()
{
    int bol;
    int i;
	static int firsttime = 1;

	//removes last food
    if (!firsttime) {
         putcharxy(Snake.food.x,Snake.food.y,' ');
	} else {
	     firsttime = 0;
	}

    do
    {
        bol = 0;
		
		//pseudo-randomly set food location
		//use clock instead of random function that is
		//not implemented in ide68k
		
        Snake.food.x = 3+ mod_bld(((clock()& 0xFFF0) >> 4),screensize.x-6); 
        Snake.food.y = 3+ mod_bld(clock()& 0xFFFF,screensize.y-6); 
        for(i = 0; i < Snake.length; i++)
        {
            if (Snake.food.x == Snake.xy[i].x && Snake.food.y == Snake.xy[i].y) {
                bol = 1; //resets loop if collision detected
            }

        }

    } while (bol);//while colliding with snake
    drawFood();

}

int getKeypress()
{
    if (kbhit()) {
        switch (_getch())
        {
            case 'w':
                if (!waiting_for_direction_to_be_implemented && (Snake.direction != south)){
				Snake.direction = north;
				waiting_for_direction_to_be_implemented = 1;
				}
                break;
            case 's':
                if (!waiting_for_direction_to_be_implemented && (Snake.direction != north)){
				Snake.direction = south;
				waiting_for_direction_to_be_implemented = 1;
				}
                break;
            case 'a':
                if (!waiting_for_direction_to_be_implemented && (Snake.direction != east)){
				Snake.direction = west;
				waiting_for_direction_to_be_implemented = 1;
                }
                break;
            case 'd':
                if (!waiting_for_direction_to_be_implemented && (Snake.direction != west)){
				 Snake.direction = east;
				 waiting_for_direction_to_be_implemented = 1;
                }
                break;
            case 'p':
                _getch();
                break;
            case 'q':
                gameOver();
                return 0;
            default:
                //do nothing
                break;
        }
    }
    return 1;
}

int detectCollision()//with self -> game over, food -> delete food add score (only head checks)
                     // returns 0 for no collision, 1 for game over
{
    int i;
	int retval;
	retval = 0;
    if (Snake.xy[0].x == Snake.food.x && Snake.xy[0].y == Snake.food.y) {
	    //detect collision with food
        Snake.length++;
		Snake.xy[Snake.length-1].x = Snake.xy[Snake.length-2].x;
		Snake.xy[Snake.length-1].y = Snake.xy[Snake.length-2].y;
        Snake.speed = Snake.speed + Snake.speed_increase;
        generateFood();
        score++;
        updateScore();
    }

    for(i = 2; i < Snake.length; i++)
    {
	    //detects collision of the head
        if (Snake.xy[i].x == Snake.xy[0].x && Snake.xy[i].y == Snake.xy[0].y) {
            gameOver();
			retval = 1;
        }

    }

    if (Snake.xy[0].x == 1 || Snake.xy[0].x == (screensize.x-1) || Snake.xy[0].y == 1 || Snake.xy[0].y == (screensize.y-2)) {
	    //collision with wall
        gameOver();
		retval = 1;
    }
	return retval;
}



void mainloop()
{
	int current_time;
	int got_game_over;

    while(1){
        if (!getKeypress()) {
          return;
        }
		current_time = clock();
        if (current_time >= ((MILLISECONDS_PER_SEC/Snake.speed) + timer)) {
            moveSnake(); //draws new snake position
            got_game_over = detectCollision();
            printf("\r\nSNEK %d", got_game_over);
			if (got_game_over) {
			   break;
			}

            timer = current_time;
        }

    }
    printf("\r\nEND OF MAIN LOOP");
}

void main()
{
    while (1) {
        char x;
        char y;

        Timer4Count = Timer2Count = Timer3Count = 0;
        Timer1Count = 0;
        PortA_Count = 0;

        // program time delay into timer
        InstallExceptionHandler(Timer_ISR, 27);
        Timer_Init();

        score = 0;
        waiting_for_direction_to_be_implemented = 0;
        Snake.xy[0].x = 4;
        Snake.xy[0].y = 3;
        Snake.xy[1].x = 3;
        Snake.xy[1].y = 3;
        Snake.xy[2].x = 2;
        Snake.xy[2].y = 3;
        Snake.length = INITIAL_SNAKE_LENGTH;
        Snake.direction = east;

        initSnake();
        disable_cursor();
        cls();
        drawRect(1, 1, screensize.x - 1, screensize.y - 2, BORDER);
        drawSnake();
        generateFood();
        drawFood();
        timer = clock();
        updateScore();
        mainloop();
        printf("\r\nPLAY AGAIN");
    }
}