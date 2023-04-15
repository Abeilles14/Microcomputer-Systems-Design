; C:\IDE68K\FINAL\SNAKE.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include <stdlib.h>
; #include <limits.h>
; #include <ctype.h>
; #include <string.h>
; #include "snake.h"
; #include <stdio.h>
; #include <string.h>
; #include <ctype.h>
; //IMPORTANT
; //
; // Uncomment one of the two #defines below
; // Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
; // 0B000000 for running programs from dram
; //
; // In your labs, you will initially start by designing a system with SRam and later move to
; // Dram, so these constants will need to be changed based on the version of the system you have
; // building
; //
; // The working 68k system SOF file posted on canvas that you can use for your pre-lab
; // is based around Dram so #define accordingly before building
; //#define StartOfExceptionVectorTable 0x08030000
; #define StartOfExceptionVectorTable 0x0B000000
; /**********************************************************************************************
; **	Parallel port addresses
; **********************************************************************************************/
; #define PortA   *(volatile unsigned char *)(0x00400000)
; #define PortB   *(volatile unsigned char *)(0x00400002)
; #define PortC   *(volatile unsigned char *)(0x00400004)
; #define PortD   *(volatile unsigned char *)(0x00400006)
; #define PortE   *(volatile unsigned char *)(0x00400008)
; /*********************************************************************************************
; **	Hex 7 seg displays port addresses
; *********************************************************************************************/
; #define HEX_A        *(volatile unsigned char *)(0x00400010)
; #define HEX_B        *(volatile unsigned char *)(0x00400012)
; #define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
; #define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only
; /**********************************************************************************************
; **	LCD display port addresses
; **********************************************************************************************/
; #define LCDcommand   *(volatile unsigned char *)(0x00400020)
; #define LCDdata      *(volatile unsigned char *)(0x00400022)
; /********************************************************************************************
; **	Timer Port addresses
; *********************************************************************************************/
; #define Timer1Data      *(volatile unsigned char *)(0x00400030)
; #define Timer1Control   *(volatile unsigned char *)(0x00400032)
; #define Timer1Status    *(volatile unsigned char *)(0x00400032)
; #define Timer2Data      *(volatile unsigned char *)(0x00400034)
; #define Timer2Control   *(volatile unsigned char *)(0x00400036)
; #define Timer2Status    *(volatile unsigned char *)(0x00400036)
; #define Timer3Data      *(volatile unsigned char *)(0x00400038)
; #define Timer3Control   *(volatile unsigned char *)(0x0040003A)
; #define Timer3Status    *(volatile unsigned char *)(0x0040003A)
; #define Timer4Data      *(volatile unsigned char *)(0x0040003C)
; #define Timer4Control   *(volatile unsigned char *)(0x0040003E)
; #define Timer4Status    *(volatile unsigned char *)(0x0040003E)
; /*********************************************************************************************
; **	RS232 port addresses
; *********************************************************************************************/
; #define RS232_Control     *(volatile unsigned char *)(0x00400040)
; #define RS232_Status      *(volatile unsigned char *)(0x00400040)
; #define RS232_TxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_RxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_Baud        *(volatile unsigned char *)(0x00400044)
; /*********************************************************************************************
; **	PIA 1 and 2 port addresses
; *********************************************************************************************/
; #define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
; #define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
; #define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
; #define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)
; #define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
; #define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
; #define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
; #define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)
; /*************************************************************
; ** SPI Controller registers
; **************************************************************/
; // SPI Registers
; //#define SPI_Control         (*(volatile unsigned char *)(0x00408020))
; //#define SPI_Status          (*(volatile unsigned char *)(0x00408022))
; //#define SPI_Data            (*(volatile unsigned char *)(0x00408024))
; //#define SPI_Ext             (*(volatile unsigned char *)(0x00408026))
; //#define SPI_CS              (*(volatile unsigned char *)(0x00408028))
; //
; //#define Enable_SPI_CS() SPI_CS = 0xFE
; //#define Disable_SPI_CS() SPI_CS = 0xFF
; /*************************************************************
; ** VGA Controller registers
; **************************************************************/
; // VGA Registers
; #define VGA_Start           (*(volatile unsigned char *)(0x00500000))
; //#define VGA_RAM_END         (*(volatile unsigned char *)(0x00500C7F)) 
; // VGA address range is [31:16] = 16'b0000_0000_0101_0000 = 0050_0000
; // using [13:0] in VGA_Controller
; // [13:12] are CRX CRY CTL registers
; // CRX = 0050...0001_0000_0000_0000 = 0050_1000
; // CRY = 0050...0010_0000_0000_0000 = 0050_2000
; // CTL = 0050...0011_0000_0000_0000 = 0050_3000
; // if (Address[31:16] == 16'b0000_0000_0101_0000)	// address hex 0050_0000 -> 0050_1000
; // [31:16],0050_ |0001_0000_0000_0000 
; //#define VGA_CRX             (*(volatile unsigned char *)(0x00501000))
; //#define VGA_CRY             (*(volatile unsigned char *)(0x00502000))
; //#define VGA_CTL             (*(volatile unsigned char *)(0x00503000))
; #define VGA_CRX             (*(volatile unsigned char *)(0x00511000))
; #define VGA_CRY             (*(volatile unsigned char *)(0x00511001))
; #define VGA_CTL             (*(volatile unsigned char *)(0x00511002))
; //#define Enable_VGA_CS() SPI_CS = 0xFE
; //#define Disable_VGA_CS() SPI_CS = 0xFF
; /********************************************************************************************
; **	RGB Colours
; *********************************************************************************************/
; #define RED     0x30
; #define GREEN   0xC0
; #define BLUE    0x20
; #define WHITE   0xFF
; #define BLACK   0
; /********************************************************************************************
; **	VideoRam addresses
; *********************************************************************************************/
; #define DramStart               0x08000000
; #define DramEnd                 0x0BFFFFFF  // 64MB on DE1-soc
; #define ProgramStart            0x08000000
; #define FlashStart				0x01000000  // 256Kbytes
; #define ProgramEnd              0x0803FFFF  // 256Kbytes
; #define Num_FlashSectors        ((ProgramEnd - ProgramStart)/65536)
; #define FlashSize               (ProgramEnd - ProgramStart)
; #define XRES			        640
; #define YRES			        480
; #define MemNumRows		        512
; #define MemNumCols		        1024
; #define XPIXELS			        7		// number of horizontal pixels in a column including space
; #define YPIXELS			        9		// number of vertical pixels in a row including space
; #define BorderHeight            4
; #define BorderWidth		        4
; /*********************************************************************************************************************************
; (( DO NOT initialise global variables here, do it main even if you want 0
; (( it's a limitation of the compiler
; (( YOU HAVE BEEN WARNED
; *********************************************************************************************************************************/
; unsigned int i, x, y, z, PortA_Count;
; unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count;
; /**********************************************************************************
; ** Timer Initialisation Routine
; **********************************************************************************/
; void Timer_Init(void)
; {   
       section   code
       xdef      _Timer_Init
_Timer_Init:
; // program time delay into timers 1-4
; Timer1Data = 0x03;		// 10 ms
       move.b    #3,4194352
; Timer2Data = 0x4c;      // 200 ms
       move.b    #76,4194356
; Timer3Data = 0xb7;      // 500 ms
       move.b    #183,4194360
; Timer4Data = 0x24;      // 100 ms
       move.b    #36,4194364
; /*
; ** timer driven off 25Mhz clock so program value so that it counts down in 0.01 secs
; ** the example 0x03 above is loaded into top 8 bits of a 24 bit timer so reads as
; ** 0x03FFFF a value of 0x03 would be 262,143/25,000,000, so is close to 1/100th sec
; **
; **
; ** Now write binary 00000011 to timer control register:
; **	Bit0 = 1 (enable interrupt from that timer)
; **	Bit 1 = 1 enable counting
; */
; Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
       move.b    #3,4194354
; Timer2Control = 3;
       move.b    #3,4194358
; Timer3Control = 3;
       move.b    #3,4194362
; Timer4Control = 3;
       move.b    #3,4194366
       rts
; }
; /*****************************************************************************************
; **	Interrupt service routine for Timers
; **
; **  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
; **  out which timer is producing the interrupt
; **
; *****************************************************************************************/
; void Timer_ISR()
; {
       xdef      _Timer_ISR
_Timer_ISR:
; if (Timer4Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_1
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
; HEX_B = Timer4Count++;     // increment an LED count on PortA with each tick of Timer 1
       move.b    _Timer4Count.L,D0
       addq.b    #1,_Timer4Count.L
       move.b    D0,4194322
Timer_ISR_1:
; }
; if (Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_3
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
; PortC = Timer2Count++;     // increment an LED count on PortC with each tick of Timer 2
       move.b    _Timer2Count.L,D0
       addq.b    #1,_Timer2Count.L
       move.b    D0,4194308
Timer_ISR_3:
; }
; if (Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_5
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
; HEX_A = Timer3Count++;     // increment a HEX count on Port HEX_A with each tick of Timer 3
       move.b    _Timer3Count.L,D0
       addq.b    #1,_Timer3Count.L
       move.b    D0,4194320
Timer_ISR_5:
; }
; if (Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_7
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
; PortA = Timer1Count++;              // increment an LED count on PortA with each tick of Timer 1
       move.b    _Timer1Count.L,D0
       addq.b    #1,_Timer1Count.L
       move.b    D0,4194304
; PortA_Count += 10;
       add.l     #10,_PortA_Count.L
Timer_ISR_7:
       rts
; //printf("\r\nPortA_Count = %d", PortA_Count);
; }
; }
; /*****************************************************************************************
; **	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void ACIA_ISR()
; {}
       xdef      _ACIA_ISR
_ACIA_ISR:
       rts
; /***************************************************************************************
; **	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void PIA_ISR()
; {}
       xdef      _PIA_ISR
_PIA_ISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 2 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key2PressISR()
; {}
       xdef      _Key2PressISR
_Key2PressISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 1 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key1PressISR()
; {}
       xdef      _Key1PressISR
_Key1PressISR:
       rts
; /************************************************************************************
; **   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
; ************************************************************************************/
; void Wait1ms(void)
; {
       xdef      _Wait1ms
_Wait1ms:
       move.l    D2,-(A7)
; int  i;
; for (i = 0; i < 1000; i++)
       clr.l     D2
Wait1ms_1:
       cmp.l     #1000,D2
       bge.s     Wait1ms_3
       addq.l    #1,D2
       bra       Wait1ms_1
Wait1ms_3:
       move.l    (A7)+,D2
       rts
; ;
; }
; /************************************************************************************
; **  Subroutine to give the 68000 something useless to do to waste 3 mSec
; **************************************************************************************/
; void Wait3ms(void)
; {
       xdef      _Wait3ms
_Wait3ms:
       move.l    D2,-(A7)
; int i;
; for (i = 0; i < 3; i++)
       clr.l     D2
Wait3ms_1:
       cmp.l     #3,D2
       bge.s     Wait3ms_3
; Wait1ms();
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       Wait3ms_1
Wait3ms_3:
       move.l    (A7)+,D2
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
; **  Sets it for parallel port and 2 line display mode (if I recall correctly)
; *********************************************************************************************/
; void Init_LCD(void)
; {
       xdef      _Init_LCD
_Init_LCD:
; LCDcommand = 0x0c;
       move.b    #12,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDcommand = 0x38;
       move.b    #56,4194336
; Wait3ms();
       jsr       _Wait3ms
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
; *********************************************************************************************/
; void Init_RS232(void)
; {
       xdef      _Init_RS232
_Init_RS232:
; RS232_Control = 0x15; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = 0x1;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
       move.b    #1,4194372
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level output function to 6850 ACIA
; **  This routine provides the basic functionality to output a single character to the serial Port
; **  to allow the board to communicate with HyperTerminal Program
; **
; **  NOTE you do not call this function directly, instead you call the normal putchar() function
; **  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
; **  call _putch() also
; *********************************************************************************************************/
; int _putch(int c)
; {
       xdef      __putch
__putch:
       link      A6,#0
; while ((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
_putch_1:
       move.b    4194368,D0
       and.b     #2,D0
       cmp.b     #2,D0
       beq.s     _putch_3
       bra       _putch_1
_putch_3:
; ;
; RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
       move.l    8(A6),D0
       and.l     #127,D0
       move.b    D0,4194370
; return c;                                              // putchar() expects the character to be returned
       move.l    8(A6),D0
       unlk      A6
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level input function to 6850 ACIA
; **  This routine provides the basic functionality to input a single character from the serial Port
; **  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
; **
; **  NOTE you do not call this function directly, instead you call the normal getchar() function
; **  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
; **  call _getch() also
; *********************************************************************************************************/
; int _getch(void)
; {
       xdef      __getch
__getch:
       link      A6,#-4
; char c;
; while ((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
_getch_1:
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     _getch_3
       bra       _getch_1
_getch_3:
; ;
; return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
       move.b    4194370,D0
       and.l     #255,D0
       and.l     #127,D0
       unlk      A6
       rts
; }
; int kbhit(void)
; {
       xdef      _kbhit
_kbhit:
; if (((char)(RS232_Status) & (char)(0x01)) == (char)(0x01))    // wait for Rx bit in status register to be '1'
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       bne.s     kbhit_1
; return 1;
       moveq     #1,D0
       bra.s     kbhit_3
kbhit_1:
; else
; return 0;
       clr.l     D0
kbhit_3:
       rts
; }
; /******************************************************************************
; **  Subroutine to output a single character to the 2 row LCD display
; **  It is assumed the character is an ASCII code and it will be displayed at the
; **  current cursor position
; *******************************************************************************/
; void LCDOutchar(int c)
; {
       xdef      _LCDOutchar
_LCDOutchar:
       link      A6,#0
; LCDdata = (char)(c);
       move.l    8(A6),D0
       move.b    D0,4194338
; Wait1ms();
       jsr       _Wait1ms
       unlk      A6
       rts
; }
; /**********************************************************************************
; *subroutine to output a message at the current cursor position of the LCD display
; ************************************************************************************/
; void LCDOutMessage(char* theMessage)
; {
       xdef      _LCDOutMessage
_LCDOutMessage:
       link      A6,#-4
; char c;
; while ((c = *theMessage++) != 0)     // output characters from the string until NULL
LCDOutMessage_1:
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-1(A6)
       move.b    (A0),D0
       beq.s     LCDOutMessage_3
; LCDOutchar(c);
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _LCDOutchar
       addq.w    #4,A7
       bra       LCDOutMessage_1
LCDOutMessage_3:
       unlk      A6
       rts
; }
; /******************************************************************************
; *subroutine to clear the line by issuing 24 space characters
; *******************************************************************************/
; void LCDClearln(void)
; {
       xdef      _LCDClearln
_LCDClearln:
       move.l    D2,-(A7)
; int i;
; for (i = 0; i < 24; i++)
       clr.l     D2
LCDClearln_1:
       cmp.l     #24,D2
       bge.s     LCDClearln_3
; LCDOutchar(' ');       // write a space char to the LCD display
       pea       32
       jsr       _LCDOutchar
       addq.w    #4,A7
       addq.l    #1,D2
       bra       LCDClearln_1
LCDClearln_3:
       move.l    (A7)+,D2
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 1 and clear that line
; *******************************************************************************/
; void LCDLine1Message(char* theMessage)
; {
       xdef      _LCDLine1Message
_LCDLine1Message:
       link      A6,#0
; LCDcommand = 0x80;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln();
       jsr       _LCDClearln
; LCDcommand = 0x80;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDOutMessage(theMessage);
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 2 and clear that line
; *******************************************************************************/
; void LCDLine2Message(char* theMessage)
; {
       xdef      _LCDLine2Message
_LCDLine2Message:
       link      A6,#0
; LCDcommand = 0xC0;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln();
       jsr       _LCDClearln
; LCDcommand = 0xC0;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDOutMessage(theMessage);
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /*********************************************************************************************************************************
; **  IMPORTANT FUNCTION
; **  This function install an exception handler so you can capture and deal with any 68000 exception in your program
; **  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
; **  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
; **  Calling this function allows you to deal with Interrupts for example
; ***********************************************************************************************************************************/
; void InstallExceptionHandler(void (*function_ptr)(), int level)
; {
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int* RamVectorAddress = (volatile long int*)(StartOfExceptionVectorTable);   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #184549376,-4(A6)
; RamVectorAddress[level] = (long int*)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; // converts hex char to 4 bit binary equiv in range 0000-1111 (0-F)
; // char assumed to be a valid hex char 0-9, a-f, A-F
; char xtod(int c)
; {
       xdef      _xtod
_xtod:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; if ((char)(c) <= (char)('9'))
       cmp.b     #57,D2
       bgt.s     xtod_1
; return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
       move.b    D2,D0
       sub.b     #48,D0
       bra.s     xtod_3
xtod_1:
; else if ((char)(c) > (char)('F'))    // assume lower case
       cmp.b     #70,D2
       ble.s     xtod_4
; return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
       move.b    D2,D0
       sub.b     #87,D0
       bra.s     xtod_3
xtod_4:
; else
; return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
       move.b    D2,D0
       sub.b     #55,D0
xtod_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get2HexDigits(char* CheckSumPtr)
; {
       xdef      _Get2HexDigits
_Get2HexDigits:
       link      A6,#0
       move.l    D2,-(A7)
; register int i = (xtod(_getch()) << 4) | (xtod(_getch()));
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       and.l     #255,D0
       asl.l     #4,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       __getch
       move.l    (A7)+,D1
       move.l    D0,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D2
; if (CheckSumPtr)
       tst.l     8(A6)
       beq.s     Get2HexDigits_1
; *CheckSumPtr += i;
       move.l    8(A6),A0
       add.b     D2,(A0)
Get2HexDigits_1:
; return i;
       move.l    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get4HexDigits(char* CheckSumPtr)
; {
       xdef      _Get4HexDigits
_Get4HexDigits:
       link      A6,#0
; return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get6HexDigits(char* CheckSumPtr)
; {
       xdef      _Get6HexDigits
_Get6HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get8HexDigits(char* CheckSumPtr)
; {
       xdef      _Get8HexDigits
_Get8HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; //
; //
; //                        user program
; //
; //
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; int score;
; int timer;
; struct
; {
; coord_t xy[SNAKE_LENGTH_LIMIT];
; int length;
; dir_t direction;
; int speed;
; int speed_increase;
; coord_t food;
; } Snake;
; const coord_t screensize = { NUM_VGA_COLUMNS,NUM_VGA_ROWS };
; int waiting_for_direction_to_be_implemented;
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; //
; //
; //                        functions to implement
; //
; //
; /////////////////////////////////////////////////////////////////////////////////////////////////////
; void putcharxy(int x, int y, char ch) {
       xdef      _putcharxy
_putcharxy:
       link      A6,#-4
; //display on the VGA char ch at column x, line y
; unsigned char* RamPtr;
; RamPtr = &VGA_Start + (y * NUM_VGA_COLUMNS + x);
       move.l    #5242880,D0
       move.l    12(A6),-(A7)
       pea       80
       jsr       LMUL
       move.l    (A7),D1
       addq.w    #8,A7
       add.l     8(A6),D1
       add.l     D1,D0
       move.l    D0,-4(A6)
; *RamPtr = ch;
       move.l    -4(A6),A0
       move.b    19(A6),(A0)
       unlk      A6
       rts
; }
; void print_at_xy(int x, int y, const char* str) {
       xdef      _print_at_xy
_print_at_xy:
       link      A6,#0
       movem.l   D2/D3/D4,-(A7)
; //print a string on the VGA, starting at column x, line y. 
; //Wrap around to the next line if we reach the edge of the screen
; char* strPtr;
; int i = x;
       move.l    8(A6),D2
; int j = y;
       move.l    12(A6),D4
; for (strPtr = str; *strPtr != '\0'; strPtr++) {
       move.l    16(A6),D3
print_at_xy_1:
       move.l    D3,A0
       move.b    (A0),D0
       beq       print_at_xy_3
; putcharxy(i, j, *strPtr);
       move.l    D3,A0
       move.b    (A0),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       move.l    D2,-(A7)
       jsr       _putcharxy
       add.w     #12,A7
; i++;
       addq.l    #1,D2
; if (i > NUM_VGA_COLUMNS-1) {
       cmp.l     #79,D2
       ble.s     print_at_xy_4
; j++;
       addq.l    #1,D4
; i = x;
       move.l    8(A6),D2
print_at_xy_4:
       addq.l    #1,D3
       bra       print_at_xy_1
print_at_xy_3:
       movem.l   (A7)+,D2/D3/D4
       unlk      A6
       rts
; }
; }
; }
; void cls()
; {
       xdef      _cls
_cls:
       movem.l   D2/D3,-(A7)
; int i;
; int j;
; for (i = 0; i < NUM_VGA_COLUMNS; i++) {
       clr.l     D3
cls_1:
       cmp.l     #80,D3
       bge.s     cls_3
; for (j = 0; j < NUM_VGA_ROWS; j++) {
       clr.l     D2
cls_4:
       cmp.l     #40,D2
       bge.s     cls_6
; putcharxy(i, j, SPACE);
       pea       32
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       jsr       _putcharxy
       add.w     #12,A7
       addq.l    #1,D2
       bra       cls_4
cls_6:
       addq.l    #1,D3
       bra       cls_1
cls_3:
       movem.l   (A7)+,D2/D3
       rts
; }
; }
; };
; void gotoxy(int x, int y)
; {
       xdef      _gotoxy
_gotoxy:
       link      A6,#0
; //move the cursor to location column = x, row = y
; VGA_CRX = x;
       move.l    8(A6),D0
       move.b    D0,5312512
; VGA_CRY = y;
       move.l    12(A6),D0
       move.b    D0,5312513
       unlk      A6
       rts
; };
; void set_vga_control_reg(char x) {
       xdef      _set_vga_control_reg
_set_vga_control_reg:
       link      A6,#0
; //Set the VGA control (OCTL) value
; /*Control of the peripheral.Bit 7 (MSB)is VGA enable signal.Bit 6 is HW
; cursor enable bit.Bit 5 is Blink HW cursor enable bit.Bit 4 is HW cursor
; mode(0 = big; 1 = small).Bits(2:0) is the output color.*/
; VGA_CTL = x;
       move.b    11(A6),5312514
       unlk      A6
       rts
; }
; char get_vga_control_reg() {
       xdef      _get_vga_control_reg
_get_vga_control_reg:
       link      A6,#-4
; //return the VGA control (OCTL) value
; char ctl_status;
; ctl_status = VGA_CTL;
       move.b    5312514,-1(A6)
; return ctl_status;
       move.b    -1(A6),D0
       unlk      A6
       rts
; }
; int clock() {
       xdef      _clock
_clock:
; //return the current value of a milliseconds counter, with a resolution of 10ms or better
; return PortA_Count;
       move.l    _PortA_Count.L,D0
       rts
; }
; void delay_ms(int num_ms) {
       xdef      _delay_ms
_delay_ms:
       link      A6,#-8
       move.l    A2,-(A7)
       lea       _PortA_Count.L,A2
; //delay a certain number of milliseconds
; int start_time = PortA_Count;
       move.l    (A2),-8(A6)
; int end_time = PortA_Count + num_ms;
       move.l    (A2),D0
       add.l     8(A6),D0
       move.l    D0,-4(A6)
; while (PortA_Count < end_time) {}
delay_ms_1:
       move.l    (A2),D0
       cmp.l     -4(A6),D0
       bhs.s     delay_ms_3
       bra       delay_ms_1
delay_ms_3:
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; void disable_cursor() {
       xdef      _disable_cursor
_disable_cursor:
; // 100x_xxxx = 80
; // 111x_xxxx = E0
; // default: 1111_0010
; set_vga_control_reg(0x82);
       pea       130
       jsr       _set_vga_control_reg
       addq.w    #4,A7
       rts
; }
; void gameOver()
; {
       xdef      _gameOver
_gameOver:
       link      A6,#-24
       movem.l   D2/D3/D4/D5/D6/A2/A3/A4/A5,-(A7)
       lea       -8(A6),A2
       lea       _delay_ms.L,A3
       lea       _gotoxy.L,A4
       lea       _set_vga_control_reg.L,A5
; //show game over screen and animation
; /*Bit 7 (MSB)is VGA enable signal.
; Bit 6 is HW cursor enable bit.
; Bit 5 is Blink HW cursor enable bit.
; Bit 4 is HW cursor mode(0 = big; 1 = small).
; Bits(2:0) is the output color.*/
; int x = 35;
       moveq     #35,D2
; int y = 21;
       moveq     #21,D4
; int i;
; unsigned char color = 0xF0;
       move.b    #240,D5
; unsigned char ctl_status;
; char gameover_text[] = "Game over!";
       lea       -20(A6),A0
       lea       gameOver_gameover_text.L,A1
       move.l    (A1)+,(A0)+
       move.l    (A1)+,(A0)+
       move.w    (A1)+,(A0)+
       move.b    (A1)+,(A0)+
; char score_display[] = "Score: ";
       move.l    A2,A0
       lea       gameOver_score_display.L,A1
       move.l    (A1)+,(A0)+
       move.l    (A1)+,(A0)+
; char score_text[];
; int len = strlen(gameover_text);
       pea       -20(A6)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D6
; // clear screen
; cls();
       jsr       _cls
; set_vga_control_reg(0xF4);
       pea       244
       jsr       (A5)
       addq.w    #4,A7
; // gameover
; for (i = 0; i < len; i++) {
       clr.l     D3
gameOver_1:
       cmp.l     D6,D3
       bge       gameOver_3
; gotoxy(x, y);
       move.l    D4,-(A7)
       move.l    D2,-(A7)
       jsr       (A4)
       addq.w    #8,A7
; putcharxy(x, y, gameover_text[i]);
       move.b    -20(A6,D3.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       move.l    D2,-(A7)
       jsr       _putcharxy
       add.w     #12,A7
; delay_ms(100);
       pea       100
       jsr       (A3)
       addq.w    #4,A7
; x++;
       addq.l    #1,D2
       addq.l    #1,D3
       bra       gameOver_1
gameOver_3:
; /* ctl_status = get_vga_control_reg();
; printf("\r\nCTL STATUS: %x", ctl_status);*/
; }
; // score
; x = 35;
       moveq     #35,D2
; y += 2;
       addq.l    #2,D4
; sprintf(score_text, "%d", score);
       move.l    _score.L,-(A7)
       pea       @snake_1.L
       pea       (A6)
       jsr       _sprintf
       add.w     #12,A7
; strcat(score_display, score_text);
       pea       (A6)
       move.l    A2,-(A7)
       jsr       _strcat
       addq.w    #8,A7
; len = strlen(score_display);
       move.l    A2,-(A7)
       jsr       _strlen
       addq.w    #4,A7
       move.l    D0,D6
; for (i = 0; i < len; i++) {
       clr.l     D3
gameOver_4:
       cmp.l     D6,D3
       bge       gameOver_6
; gotoxy(x, y);
       move.l    D4,-(A7)
       move.l    D2,-(A7)
       jsr       (A4)
       addq.w    #8,A7
; putcharxy(x, y, score_display[i]);
       move.b    0(A2,D3.L),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       move.l    D2,-(A7)
       jsr       _putcharxy
       add.w     #12,A7
; delay_ms(100);
       pea       100
       jsr       (A3)
       addq.w    #4,A7
; x++;
       addq.l    #1,D2
       addq.l    #1,D3
       bra       gameOver_4
gameOver_6:
; }
; x++;
       addq.l    #1,D2
; gotoxy(x, y);
       move.l    D4,-(A7)
       move.l    D2,-(A7)
       jsr       (A4)
       addq.w    #8,A7
; while (!kbhit()) {
gameOver_7:
       jsr       _kbhit
       tst.l     D0
       bne       gameOver_9
; // change colors
; color++;
       addq.b    #1,D5
; if (color == 0xF7) {
       and.w     #255,D5
       cmp.w     #247,D5
       bne.s     gameOver_10
; set_vga_control_reg((char)color);
       ext.w     D5
       ext.l     D5
       move.l    D5,-(A7)
       jsr       (A5)
       addq.w    #4,A7
; color = 0xF0;
       move.b    #240,D5
       bra.s     gameOver_11
gameOver_10:
; }
; else {
; set_vga_control_reg((char)color);
       ext.w     D5
       ext.l     D5
       move.l    D5,-(A7)
       jsr       (A5)
       addq.w    #4,A7
gameOver_11:
; }
; delay_ms(300);
       pea       300
       jsr       (A3)
       addq.w    #4,A7
       bra       gameOver_7
gameOver_9:
; }
; printf("\r\nGAMEOVER!\r\nPress any key to continue...");
       pea       @snake_2.L
       jsr       _printf
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2/A3/A4/A5
       unlk      A6
       rts
; }
; void updateScore()
; {
       xdef      _updateScore
_updateScore:
       link      A6,#-16
; //print the score at the bottom of the screen
; char* score_text = "Score: ";
       lea       @snake_3.L,A0
       move.l    A0,-14(A6)
; char score_display[10];
; sprintf(score_display, "%d", score);
       move.l    _score.L,-(A7)
       pea       @snake_1.L
       pea       -10(A6)
       jsr       _sprintf
       add.w     #12,A7
; print_at_xy(1, NUM_VGA_ROWS - 1, score_text);
       move.l    -14(A6),-(A7)
       pea       39
       pea       1
       jsr       _print_at_xy
       add.w     #12,A7
; print_at_xy(8, NUM_VGA_ROWS - 1, (char*)score_display);
       pea       -10(A6)
       pea       39
       pea       8
       jsr       _print_at_xy
       add.w     #12,A7
       unlk      A6
       rts
; }
; void drawRect(int x, int y, int x2, int y2, char ch)
; {
       xdef      _drawRect
_drawRect:
       link      A6,#0
       movem.l   D2/D3/D4/D5/D6/A2,-(A7)
       move.l    12(A6),D3
       move.l    8(A6),D4
       lea       _putcharxy.L,A2
       move.l    20(A6),D5
       move.l    16(A6),D6
; //draws a rectangle. Left top corner: (x1,y1) length of sides = x2,y2
; int i;
; // top line
; for (i = x; i < (x + x2); i++) {
       move.l    D4,D2
drawRect_1:
       move.l    D4,D0
       add.l     D6,D0
       cmp.l     D0,D2
       bge.s     drawRect_3
; putcharxy(i, y, BORDER);
       pea       35
       move.l    D3,-(A7)
       move.l    D2,-(A7)
       jsr       (A2)
       add.w     #12,A7
       addq.l    #1,D2
       bra       drawRect_1
drawRect_3:
; }
; // left line
; for (i = y; i < (y + y2); i++) {
       move.l    D3,D2
drawRect_4:
       move.l    D3,D0
       add.l     D5,D0
       cmp.l     D0,D2
       bge.s     drawRect_6
; putcharxy(x, i, BORDER);
       pea       35
       move.l    D2,-(A7)
       move.l    D4,-(A7)
       jsr       (A2)
       add.w     #12,A7
       addq.l    #1,D2
       bra       drawRect_4
drawRect_6:
; }
; // right line
; for (i = y; i < (y + y2); i++) {
       move.l    D3,D2
drawRect_7:
       move.l    D3,D0
       add.l     D5,D0
       cmp.l     D0,D2
       bge.s     drawRect_9
; putcharxy(x2, i, BORDER);
       pea       35
       move.l    D2,-(A7)
       move.l    D6,-(A7)
       jsr       (A2)
       add.w     #12,A7
       addq.l    #1,D2
       bra       drawRect_7
drawRect_9:
; }
; // bottom line
; for (i = x; i < (x + x2); i++) {
       move.l    D4,D2
drawRect_10:
       move.l    D4,D0
       add.l     D6,D0
       cmp.l     D0,D2
       bge.s     drawRect_12
; putcharxy(i, y2, BORDER);
       pea       35
       move.l    D5,-(A7)
       move.l    D2,-(A7)
       jsr       (A2)
       add.w     #12,A7
       addq.l    #1,D2
       bra       drawRect_10
drawRect_12:
       movem.l   (A7)+,D2/D3/D4/D5/D6/A2
       unlk      A6
       rts
; }
; }
; /////////////////////////////////////////////////////////////////////////////
; //
; //  End functions you need to implement
; //
; /////////////////////////////////////////////////////////////////////////////
; void initSnake()
; {
       xdef      _initSnake
_initSnake:
; Snake.speed          = INITIAL_SNAKE_SPEED ;         
       move.l    #2,_Snake+16390.L
; Snake.speed_increase = SNAKE_SPEED_INCREASE;
       move.l    #1,_Snake+16394.L
       rts
; }
; void drawSnake()
; {
       xdef      _drawSnake
_drawSnake:
       movem.l   D2/A2,-(A7)
       lea       _Snake.L,A2
; int i;
; for(i = 0; i < Snake.length; i++)
       clr.l     D2
drawSnake_1:
       cmp.l     16384(A2),D2
       bge.s     drawSnake_3
; {
; putcharxy(Snake.xy[i].x, Snake.xy[i].y,SNAKE);
       pea       83
       move.l    D2,D1
       lsl.l     #3,D1
       lea       0(A2,D1.L),A0
       move.l    4(A0),-(A7)
       move.l    D2,D1
       lsl.l     #3,D1
       move.l    0(A2,D1.L),-(A7)
       jsr       _putcharxy
       add.w     #12,A7
       addq.l    #1,D2
       bra       drawSnake_1
drawSnake_3:
       movem.l   (A7)+,D2/A2
       rts
; }
; }
; void drawFood()
; {
       xdef      _drawFood
_drawFood:
; putcharxy(Snake.food.x, Snake.food.y,FOOD);
       pea       64
       move.l    _Snake+16402.L,-(A7)
       move.l    _Snake+16398.L,-(A7)
       jsr       _putcharxy
       add.w     #12,A7
       rts
; }
; void moveSnake()//remove tail, move array, add new head based on direction
; {
       xdef      _moveSnake
_moveSnake:
       movem.l   D2/D3/D4/A2,-(A7)
       lea       _Snake.L,A2
; int i;
; int x;
; int y;
; x = Snake.xy[0].x;
       move.l    (A2),D3
; y = Snake.xy[0].y;
       move.l    4(A2),D2
; //saves initial head for direction determination
; putcharxy(Snake.xy[Snake.length-1].x, Snake.xy[Snake.length-1].y,' ');
       pea       32
       move.l    16384(A2),D1
       subq.l    #1,D1
       lsl.l     #3,D1
       lea       0(A2,D1.L),A0
       move.l    4(A0),-(A7)
       move.l    16384(A2),D1
       subq.l    #1,D1
       lsl.l     #3,D1
       move.l    0(A2,D1.L),-(A7)
       jsr       _putcharxy
       add.w     #12,A7
; for(i = Snake.length; i > 1; i--)
       move.l    16384(A2),D4
moveSnake_1:
       cmp.l     #1,D4
       ble       moveSnake_3
; {
; Snake.xy[i-1] = Snake.xy[i-2];
       move.l    A2,D0
       move.l    D4,D1
       subq.l    #1,D1
       lsl.l     #3,D1
       add.l     D1,D0
       move.l    D0,A0
       move.l    A2,D0
       move.l    D4,D1
       subq.l    #2,D1
       lsl.l     #3,D1
       add.l     D1,D0
       move.l    D0,A1
       move.l    (A1)+,(A0)+
       move.l    (A1)+,(A0)+
       subq.l    #1,D4
       bra       moveSnake_1
moveSnake_3:
; }
; //moves the snake array to the right
; switch (Snake.direction)
       move.w    16388(A2),D0
       ext.l     D0
       cmp.l     #4,D0
       bhs       moveSnake_4
       asl.l     #1,D0
       move.w    moveSnake_6(PC,D0.L),D0
       jmp       moveSnake_6(PC,D0.W)
moveSnake_6:
       dc.w      moveSnake_7-moveSnake_6
       dc.w      moveSnake_8-moveSnake_6
       dc.w      moveSnake_9-moveSnake_6
       dc.w      moveSnake_10-moveSnake_6
moveSnake_7:
; {
; case north:
; if (y > 0)  { y--; }
       cmp.l     #0,D2
       ble.s     moveSnake_12
       subq.l    #1,D2
moveSnake_12:
; break;
       bra.s     moveSnake_5
moveSnake_8:
; case south:
; if (y < (NUM_VGA_ROWS-1)) { y++; }
       cmp.l     #39,D2
       bge.s     moveSnake_14
       addq.l    #1,D2
moveSnake_14:
; break;
       bra.s     moveSnake_5
moveSnake_9:
; case west:
; if (x > 0) { x--; }
       cmp.l     #0,D3
       ble.s     moveSnake_16
       subq.l    #1,D3
moveSnake_16:
; break;
       bra.s     moveSnake_5
moveSnake_10:
; case east:
; if (x < (NUM_VGA_COLUMNS-1))  { x++; }
       cmp.l     #79,D3
       bge.s     moveSnake_18
       addq.l    #1,D3
moveSnake_18:
; break;
       bra       moveSnake_5
moveSnake_4:
; default:
; break;
moveSnake_5:
; }
; //adds new snake head
; Snake.xy[0].x = x;
       move.l    D3,(A2)
; Snake.xy[0].y = y;
       move.l    D2,4(A2)
; waiting_for_direction_to_be_implemented = 0;
       clr.l     _waiting_for_direction_to_be_imp.L
; putcharxy(Snake.xy[0].x,Snake.xy[0].y,SNAKE);
       pea       83
       move.l    4(A2),-(A7)
       move.l    (A2),-(A7)
       jsr       _putcharxy
       add.w     #12,A7
       movem.l   (A7)+,D2/D3/D4/A2
       rts
; }
; /* Compute x mod y using binary long division. */
; int mod_bld(int x, int y)
; {
       xdef      _mod_bld
_mod_bld:
       link      A6,#0
       movem.l   D2/D3,-(A7)
; int modulus = x, divisor = y;
       move.l    8(A6),D3
       move.l    12(A6),D2
; while (divisor <= modulus && divisor <= 16384)
mod_bld_1:
       cmp.l     D3,D2
       bgt.s     mod_bld_3
       cmp.l     #16384,D2
       bgt.s     mod_bld_3
; divisor <<= 1;
       asl.l     #1,D2
       bra       mod_bld_1
mod_bld_3:
; while (modulus >= y) {
mod_bld_4:
       cmp.l     12(A6),D3
       blt.s     mod_bld_6
; while (divisor > modulus)
mod_bld_7:
       cmp.l     D3,D2
       ble.s     mod_bld_9
; divisor >>= 1;
       asr.l     #1,D2
       bra       mod_bld_7
mod_bld_9:
; modulus -= divisor;
       sub.l     D2,D3
       bra       mod_bld_4
mod_bld_6:
; }
; return modulus;
       move.l    D3,D0
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; void generateFood()
; {
       xdef      _generateFood
_generateFood:
       movem.l   D2/D3/A2,-(A7)
       lea       _Snake.L,A2
; int bol;
; int i;
; static int firsttime = 1;
; //removes last food
; if (!firsttime) {
       tst.l     generateFood_firsttime.L
       bne.s     generateFood_2
; putcharxy(Snake.food.x,Snake.food.y,' ');
       pea       32
       move.l    16402(A2),-(A7)
       move.l    16398(A2),-(A7)
       jsr       _putcharxy
       add.w     #12,A7
       bra.s     generateFood_3
generateFood_2:
; } else {
; firsttime = 0;
       clr.l     generateFood_firsttime.L
generateFood_3:
; }
; do
; {
generateFood_4:
; bol = 0;
       clr.l     D3
; //pseudo-randomly set food location
; //use clock instead of random function that is
; //not implemented in ide68k
; Snake.food.x = 3+ mod_bld(((clock()& 0xFFF0) >> 4),screensize.x-6); 
       moveq     #3,D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       move.l    _screensize.L,D0
       subq.l    #6,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       _clock
       move.l    (A7)+,D1
       and.l     #65520,D0
       asr.l     #4,D0
       move.l    D0,-(A7)
       jsr       _mod_bld
       addq.w    #8,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       add.l     D1,D0
       move.l    D0,16398(A2)
; Snake.food.y = 3+ mod_bld(clock()& 0xFFFF,screensize.y-6); 
       moveq     #3,D0
       ext.w     D0
       ext.l     D0
       move.l    D0,-(A7)
       move.l    D0,-(A7)
       move.l    _screensize+4.L,D0
       subq.l    #6,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       _clock
       move.l    (A7)+,D1
       and.l     #65535,D0
       move.l    D0,-(A7)
       jsr       _mod_bld
       addq.w    #8,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    (A7)+,D0
       add.l     D1,D0
       move.l    D0,16402(A2)
; for(i = 0; i < Snake.length; i++)
       clr.l     D2
generateFood_6:
       cmp.l     16384(A2),D2
       bge.s     generateFood_8
; {
; if (Snake.food.x == Snake.xy[i].x && Snake.food.y == Snake.xy[i].y) {
       move.l    D2,D0
       lsl.l     #3,D0
       move.l    16398(A2),D1
       cmp.l     0(A2,D0.L),D1
       bne.s     generateFood_9
       move.l    D2,D0
       lsl.l     #3,D0
       lea       0(A2,D0.L),A0
       move.l    16402(A2),D0
       cmp.l     4(A0),D0
       bne.s     generateFood_9
; bol = 1; //resets loop if collision detected
       moveq     #1,D3
generateFood_9:
       addq.l    #1,D2
       bra       generateFood_6
generateFood_8:
       tst.l     D3
       bne       generateFood_4
; }
; }
; } while (bol);//while colliding with snake
; drawFood();
       jsr       _drawFood
       movem.l   (A7)+,D2/D3/A2
       rts
; }
; int getKeypress()
; {
       xdef      _getKeypress
_getKeypress:
       movem.l   A2/A3,-(A7)
       lea       _Snake.L,A2
       lea       _waiting_for_direction_to_be_imp.L,A3
; if (kbhit()) {
       jsr       _kbhit
       tst.l     D0
       beq       getKeypress_4
; switch (_getch())
       jsr       __getch
       cmp.l     #113,D0
       beq       getKeypress_10
       bgt.s     getKeypress_12
       cmp.l     #100,D0
       beq       getKeypress_8
       bgt.s     getKeypress_13
       cmp.l     #97,D0
       beq       getKeypress_7
       bra       getKeypress_3
getKeypress_13:
       cmp.l     #112,D0
       beq       getKeypress_9
       bra       getKeypress_3
getKeypress_12:
       cmp.l     #119,D0
       beq.s     getKeypress_5
       bgt       getKeypress_3
       cmp.l     #115,D0
       beq.s     getKeypress_6
       bra       getKeypress_3
getKeypress_5:
; {
; case 'w':
; if (!waiting_for_direction_to_be_implemented && (Snake.direction != south)){
       tst.l     (A3)
       bne.s     getKeypress_14
       move.w    16388(A2),D0
       ext.l     D0
       cmp.l     #1,D0
       beq.s     getKeypress_14
; Snake.direction = north;
       clr.w     16388(A2)
; waiting_for_direction_to_be_implemented = 1;
       move.l    #1,(A3)
getKeypress_14:
; }
; break;
       bra       getKeypress_4
getKeypress_6:
; case 's':
; if (!waiting_for_direction_to_be_implemented && (Snake.direction != north)){
       tst.l     (A3)
       bne.s     getKeypress_16
       move.w    16388(A2),D0
       ext.l     D0
       tst.l     D0
       beq.s     getKeypress_16
; Snake.direction = south;
       move.w    #1,16388(A2)
; waiting_for_direction_to_be_implemented = 1;
       move.l    #1,(A3)
getKeypress_16:
; }
; break;
       bra       getKeypress_4
getKeypress_7:
; case 'a':
; if (!waiting_for_direction_to_be_implemented && (Snake.direction != east)){
       tst.l     (A3)
       bne.s     getKeypress_18
       move.w    16388(A2),D0
       ext.l     D0
       cmp.l     #3,D0
       beq.s     getKeypress_18
; Snake.direction = west;
       move.w    #2,16388(A2)
; waiting_for_direction_to_be_implemented = 1;
       move.l    #1,(A3)
getKeypress_18:
; }
; break;
       bra.s     getKeypress_4
getKeypress_8:
; case 'd':
; if (!waiting_for_direction_to_be_implemented && (Snake.direction != west)){
       tst.l     (A3)
       bne.s     getKeypress_20
       move.w    16388(A2),D0
       ext.l     D0
       cmp.l     #2,D0
       beq.s     getKeypress_20
; Snake.direction = east;
       move.w    #3,16388(A2)
; waiting_for_direction_to_be_implemented = 1;
       move.l    #1,(A3)
getKeypress_20:
; }
; break;
       bra.s     getKeypress_4
getKeypress_9:
; case 'p':
; _getch();
       jsr       __getch
; break;
       bra.s     getKeypress_4
getKeypress_10:
; case 'q':
; gameOver();
       jsr       _gameOver
; return 0;
       clr.l     D0
       bra.s     getKeypress_22
getKeypress_3:
; default:
; //do nothing
; break;
getKeypress_4:
; }
; }
; return 1;
       moveq     #1,D0
getKeypress_22:
       movem.l   (A7)+,A2/A3
       rts
; }
; int detectCollision()//with self -> game over, food -> delete food add score (only head checks)
; // returns 0 for no collision, 1 for game over
; {
       xdef      _detectCollision
_detectCollision:
       movem.l   D2/D3/A2,-(A7)
       lea       _Snake.L,A2
; int i;
; int retval;
; retval = 0;
       clr.l     D3
; if (Snake.xy[0].x == Snake.food.x && Snake.xy[0].y == Snake.food.y) {
       move.l    (A2),D0
       cmp.l     16398(A2),D0
       bne       detectCollision_1
       move.l    4(A2),D0
       cmp.l     16402(A2),D0
       bne       detectCollision_1
; //detect collision with food
; Snake.length++;
       move.l    A2,D0
       add.l     #16384,D0
       move.l    D0,A0
       addq.l    #1,(A0)
; Snake.xy[Snake.length-1].x = Snake.xy[Snake.length-2].x;
       move.l    16384(A2),D0
       subq.l    #2,D0
       lsl.l     #3,D0
       move.l    16384(A2),D1
       subq.l    #1,D1
       lsl.l     #3,D1
       move.l    0(A2,D0.L),0(A2,D1.L)
; Snake.xy[Snake.length-1].y = Snake.xy[Snake.length-2].y;
       move.l    16384(A2),D0
       subq.l    #2,D0
       lsl.l     #3,D0
       lea       0(A2,D0.L),A0
       move.l    16384(A2),D0
       subq.l    #1,D0
       lsl.l     #3,D0
       lea       0(A2,D0.L),A1
       move.l    4(A0),4(A1)
; Snake.speed = Snake.speed + Snake.speed_increase;
       move.l    16390(A2),D0
       add.l     16394(A2),D0
       move.l    D0,16390(A2)
; generateFood();
       jsr       _generateFood
; score++;
       addq.l    #1,_score.L
; updateScore();
       jsr       _updateScore
detectCollision_1:
; }
; for(i = 2; i < Snake.length; i++)
       moveq     #2,D2
detectCollision_3:
       cmp.l     16384(A2),D2
       bge.s     detectCollision_5
; {
; //detects collision of the head
; if (Snake.xy[i].x == Snake.xy[0].x && Snake.xy[i].y == Snake.xy[0].y) {
       move.l    D2,D0
       lsl.l     #3,D0
       move.l    0(A2,D0.L),D1
       cmp.l     (A2),D1
       bne.s     detectCollision_6
       move.l    D2,D0
       lsl.l     #3,D0
       lea       0(A2,D0.L),A0
       move.l    4(A0),D0
       cmp.l     4(A2),D0
       bne.s     detectCollision_6
; gameOver();
       jsr       _gameOver
; retval = 1;
       moveq     #1,D3
detectCollision_6:
       addq.l    #1,D2
       bra       detectCollision_3
detectCollision_5:
; }
; }
; if (Snake.xy[0].x == 1 || Snake.xy[0].x == (screensize.x-1) || Snake.xy[0].y == 1 || Snake.xy[0].y == (screensize.y-2)) {
       move.l    (A2),D0
       cmp.l     #1,D0
       beq.s     detectCollision_10
       move.l    _screensize.L,D0
       subq.l    #1,D0
       cmp.l     (A2),D0
       beq.s     detectCollision_10
       move.l    4(A2),D0
       cmp.l     #1,D0
       beq.s     detectCollision_10
       move.l    _screensize+4.L,D0
       subq.l    #2,D0
       cmp.l     4(A2),D0
       bne.s     detectCollision_8
detectCollision_10:
; //collision with wall
; gameOver();
       jsr       _gameOver
; retval = 1;
       moveq     #1,D3
detectCollision_8:
; }
; return retval;
       move.l    D3,D0
       movem.l   (A7)+,D2/D3/A2
       rts
; }
; void mainloop()
; {
       xdef      _mainloop
_mainloop:
       movem.l   D2/D3,-(A7)
; int current_time;
; int got_game_over;
; while(1){
mainloop_1:
; if (!getKeypress()) {
       jsr       _getKeypress
       tst.l     D0
       bne.s     mainloop_4
; return;
       bra       mainloop_6
mainloop_4:
; }
; current_time = clock();
       jsr       _clock
       move.l    D0,D3
; if (current_time >= ((MILLISECONDS_PER_SEC/Snake.speed) + timer)) {
       pea       1000
       move.l    _Snake+16390.L,-(A7)
       jsr       LDIV
       move.l    (A7),D0
       addq.w    #8,A7
       add.l     _timer.L,D0
       cmp.l     D0,D3
       blt.s     mainloop_7
; moveSnake(); //draws new snake position
       jsr       _moveSnake
; got_game_over = detectCollision();
       jsr       _detectCollision
       move.l    D0,D2
; printf("\r\nSNEK %d", got_game_over);
       move.l    D2,-(A7)
       pea       @snake_4.L
       jsr       _printf
       addq.w    #8,A7
; if (got_game_over) {
       tst.l     D2
       beq.s     mainloop_9
; break;
       bra.s     mainloop_3
mainloop_9:
; }
; timer = current_time;
       move.l    D3,_timer.L
mainloop_7:
       bra       mainloop_1
mainloop_3:
; }
; }
; printf("\r\nEND OF MAIN LOOP");
       pea       @snake_5.L
       jsr       _printf
       addq.w    #4,A7
mainloop_6:
       movem.l   (A7)+,D2/D3
       rts
; }
; void main()
; {
       xdef      _main
_main:
       link      A6,#-4
       move.l    A2,-(A7)
       lea       _Snake.L,A2
; while (1) {
main_1:
; char x;
; char y;
; Timer4Count = Timer2Count = Timer3Count = 0;
       clr.b     _Timer3Count.L
       clr.b     _Timer2Count.L
       clr.b     _Timer4Count.L
; Timer1Count = 0;
       clr.b     _Timer1Count.L
; PortA_Count = 0;
       clr.l     _PortA_Count.L
; // program time delay into timer
; InstallExceptionHandler(Timer_ISR, 27);
       pea       27
       pea       _Timer_ISR.L
       jsr       _InstallExceptionHandler
       addq.w    #8,A7
; Timer_Init();
       jsr       _Timer_Init
; score = 0;
       clr.l     _score.L
; waiting_for_direction_to_be_implemented = 0;
       clr.l     _waiting_for_direction_to_be_imp.L
; Snake.xy[0].x = 4;
       move.l    #4,(A2)
; Snake.xy[0].y = 3;
       move.l    #3,4(A2)
; Snake.xy[1].x = 3;
       move.l    #3,8(A2)
; Snake.xy[1].y = 3;
       move.l    #3,12(A2)
; Snake.xy[2].x = 2;
       move.l    #2,16(A2)
; Snake.xy[2].y = 3;
       move.l    #3,20(A2)
; Snake.length = INITIAL_SNAKE_LENGTH;
       move.l    #3,16384(A2)
; Snake.direction = east;
       move.w    #3,16388(A2)
; initSnake();
       jsr       _initSnake
; disable_cursor();
       jsr       _disable_cursor
; cls();
       jsr       _cls
; drawRect(1, 1, screensize.x - 1, screensize.y - 2, BORDER);
       pea       35
       move.l    _screensize+4.L,D1
       subq.l    #2,D1
       move.l    D1,-(A7)
       move.l    _screensize.L,D1
       subq.l    #1,D1
       move.l    D1,-(A7)
       pea       1
       pea       1
       jsr       _drawRect
       add.w     #20,A7
; drawSnake();
       jsr       _drawSnake
; generateFood();
       jsr       _generateFood
; drawFood();
       jsr       _drawFood
; timer = clock();
       jsr       _clock
       move.l    D0,_timer.L
; updateScore();
       jsr       _updateScore
; mainloop();
       jsr       _mainloop
; printf("\r\nPLAY AGAIN");
       pea       @snake_6.L
       jsr       _printf
       addq.w    #4,A7
       bra       main_1
; }
; }
       section   const
@snake_1:
       dc.b      37,100,0
@snake_2:
       dc.b      13,10,71,65,77,69,79,86,69,82,33,13,10,80,114
       dc.b      101,115,115,32,97,110,121,32,107,101,121,32
       dc.b      116,111,32,99,111,110,116,105,110,117,101,46
       dc.b      46,46,0
@snake_3:
       dc.b      83,99,111,114,101,58,32,0
@snake_4:
       dc.b      13,10,83,78,69,75,32,37,100,0
@snake_5:
       dc.b      13,10,69,78,68,32,79,70,32,77,65,73,78,32,76
       dc.b      79,79,80,0
@snake_6:
       dc.b      13,10,80,76,65,89,32,65,71,65,73,78,0
       xdef      _screensize
_screensize:
       dc.l      80,40
gameOver_gameover_text:
       dc.b      71,97,109,101,32,111,118,101,114,33,0
       section   data
gameOver_score_display:
       dc.b      83,99,111,114,101,58,32,0
generateFood_firsttime:
       dc.l      1
       section   bss
       xdef      _i
_i:
       ds.b      4
       xdef      _x
_x:
       ds.b      4
       xdef      _y
_y:
       ds.b      4
       xdef      _z
_z:
       ds.b      4
       xdef      _PortA_Count
_PortA_Count:
       ds.b      4
       xdef      _Timer1Count
_Timer1Count:
       ds.b      1
       xdef      _Timer2Count
_Timer2Count:
       ds.b      1
       xdef      _Timer3Count
_Timer3Count:
       ds.b      1
       xdef      _Timer4Count
_Timer4Count:
       ds.b      1
       xdef      _score
_score:
       ds.b      4
       xdef      _timer
_timer:
       ds.b      4
       xdef      _Snake
_Snake:
       ds.b      16406
       xdef      _waiting_for_direction_to_be_imp
_waiting_for_direction_to_be_imp:
       ds.b      4
       xref      LDIV
       xref      LMUL
       xref      _strlen
       xref      _sprintf
       xref      _strcat
       xref      _printf
