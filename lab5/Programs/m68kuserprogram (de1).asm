; C:\IDE68K\ASS5_PARTA\M68KUSERPROGRAM (DE1).C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
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
; ** IIC Controller registers
; **************************************************************/
; //IIC Registers
; #define IIC_Prescale_Low            (*(volatile unsigned char *)(0x00408000))
; #define IIC_Prescale_High           (*(volatile unsigned char *)(0x00408002))
; #define IIC_Control                 (*(volatile unsigned char *)(0x00408004))
; #define IIC_Transmit_Receive        (*(volatile unsigned char *)(0x00408006))
; #define IIC_Command_Status          (*(volatile unsigned char *)(0x00408008))
; /*********************************************************************************************************************************
; (( DO NOT initialise global variables here, do it main even if you want 0
; (( it's a limitation of the compiler
; (( YOU HAVE BEEN WARNED
; *********************************************************************************************************************************/
; unsigned int i, x, y, z, PortA_Count;
; unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;
; /*******************************************************************************************
; ** Function Prototypes
; *******************************************************************************************/
; void Wait1ms(void);
; void Wait3ms(void);
; void Init_LCD(void) ;
; void LCDOutchar(int c);
; void LCDOutMess(char *theMessage);
; void LCDClearln(void);
; void LCDline1Message(char *theMessage);
; void LCDline2Message(char *theMessage);
; int sprintf(char *out, const char *format, ...) ;
; /*****************************************************************************************
; **	Interrupt service routine for Timers
; **
; **  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
; **  out which timer is producing the interrupt
; **
; *****************************************************************************************/
; void Timer_ISR()
; {
       section   code
       xdef      _Timer_ISR
_Timer_ISR:
; if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_1
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
Timer_ISR_1:
; //PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
; }
; if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_3
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
Timer_ISR_3:
; //PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
; }
; if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_5
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
Timer_ISR_5:
; //HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
; }
; if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_7
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
Timer_ISR_7:
       rts
; //HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
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
; int  i ;
; for(i = 0; i < 1000; i ++)
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
; int i ;
; for(i = 0; i < 3; i++)
       clr.l     D2
Wait3ms_1:
       cmp.l     #3,D2
       bge.s     Wait3ms_3
; Wait1ms() ;
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
; LCDcommand = 0x0c ;
       move.b    #12,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDcommand = 0x38 ;
       move.b    #56,4194336
; Wait3ms() ;
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
; RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
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
; int _putch( int c)
; {
       xdef      __putch
__putch:
       link      A6,#0
; while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
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
; return c ;                                              // putchar() expects the character to be returned
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
; int _getch( void )
; {
       xdef      __getch
__getch:
       link      A6,#-4
; char c ;
; while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
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
; Wait1ms() ;
       jsr       _Wait1ms
       unlk      A6
       rts
; }
; /**********************************************************************************
; *subroutine to output a message at the current cursor position of the LCD display
; ************************************************************************************/
; void LCDOutMessage(char *theMessage)
; {
       xdef      _LCDOutMessage
_LCDOutMessage:
       link      A6,#-4
; char c ;
; while((c = *theMessage++) != 0)     // output characters from the string until NULL
LCDOutMessage_1:
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-1(A6)
       move.b    (A0),D0
       beq.s     LCDOutMessage_3
; LCDOutchar(c) ;
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
; int i ;
; for(i = 0; i < 24; i ++)
       clr.l     D2
LCDClearln_1:
       cmp.l     #24,D2
       bge.s     LCDClearln_3
; LCDOutchar(' ') ;       // write a space char to the LCD display
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
; void LCDLine1Message(char *theMessage)
; {
       xdef      _LCDLine1Message
_LCDLine1Message:
       link      A6,#0
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 2 and clear that line
; *******************************************************************************/
; void LCDLine2Message(char *theMessage)
; {
       xdef      _LCDLine2Message
_LCDLine2Message:
       link      A6,#0
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
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
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #184549376,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
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
; else if((char)(c) > (char)('F'))    // assume lower case
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
; int Get2HexDigits(char *CheckSumPtr)
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
; if(CheckSumPtr)
       tst.l     8(A6)
       beq.s     Get2HexDigits_1
; *CheckSumPtr += i ;
       move.l    8(A6),A0
       add.b     D2,(A0)
Get2HexDigits_1:
; return i ;
       move.l    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get4HexDigits(char *CheckSumPtr)
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
; int Get6HexDigits(char *CheckSumPtr)
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
; int Get8HexDigits(char *CheckSumPtr)
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
; /**************************************************************************************************
; *Memory Test Functions
; ***************************************************************************************************/
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////
; //byte_func//
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////
; void byte_func(void){
       xdef      _byte_func
_byte_func:
       link      A6,#-36
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
       lea       _printf.L,A2
       lea       _scanf.L,A3
       lea       -26(A6),A5
; char  *Start, *End ;
; char *Start_temp, *End_temp;
; int *Start_hold, *End_hold;
; unsigned char filldata = 0xAA;
       move.b    #170,-22(A6)
; unsigned char tempdata;
; unsigned char readval;
; //unsigned char bytedata1, bytedata2, bytedata3, bytedata4;
; int bytedata1, bytedata2, bytedata3, bytedata4;
; int count = 0;
       clr.l     D2
; int count2 = 0;
       clr.l     D4
; int j;
; char choice;
; printf("\r\nEnter 4 bytes of Hexidecimal test data.");
       pea       @m68kus~1_1.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter First byte: ");
       pea       @m68kus~1_2.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &bytedata1) ;
       pea       -20(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //bytedata1 = Get2HexDigits(0) ;
; //printf("\r\n%X",bytedata1);
; printf("Enter Second byte: ");
       pea       @m68kus~1_4.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &bytedata2) ;
       pea       -16(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //printf("\r\n%X",bytedata2);
; //bytedata2 = Get2HexDigits(0) ;
; printf("Enter Third byte: ");
       pea       @m68kus~1_5.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &bytedata3) ;
       pea       -12(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //bytedata3 = Get2HexDigits(0) ;
; printf("Enter Fourth byte: ");
       pea       @m68kus~1_6.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &bytedata4) ;
       pea       -8(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //bytedata4 = Get2HexDigits(0) ;
; printf("Valid addresses for this program are: $0900 0000  - $097F FFFF");
       pea       @m68kus~1_7.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter Start Address: ") ;
       pea       @m68kus~1_8.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &Start_hold) ;
       pea       -30(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //Start_hold = Get8HexDigits(0) ;
; printf("Enter End Address: ") ;
       pea       @m68kus~1_9.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A5,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //End_hold = Get8HexDigits(0) ;
; while ((Start_hold < 0x09000000) || (Start_hold > 0x097FFFFF)){
byte_func_1:
       move.l    -30(A6),D0
       cmp.l     #150994944,D0
       blo.s     byte_func_4
       move.l    -30(A6),D0
       cmp.l     #159383551,D0
       bls.s     byte_func_3
byte_func_4:
; printf("ERROR. Please Enter a valid Start Address: ");
       pea       @m68kus~1_10.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &Start_hold) ;
       pea       -30(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       byte_func_1
byte_func_3:
; //Start_hold = Get8HexDigits(0) ;
; }
; while ((End_hold < 0x09000000) || (End_hold > 0x097FFFFF)){
byte_func_5:
       move.l    (A5),D0
       cmp.l     #150994944,D0
       blo.s     byte_func_8
       move.l    (A5),D0
       cmp.l     #159383551,D0
       bls.s     byte_func_7
byte_func_8:
; printf("\r\nERROR. Please Enter a valid End Address: ");
       pea       @m68kus~1_11.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A5,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       byte_func_5
byte_func_7:
; //End_hold = Get8HexDigits(0) ;
; }
; while (End_hold <= Start_hold){
byte_func_9:
       move.l    (A5),D0
       cmp.l     -30(A6),D0
       bhi.s     byte_func_11
; printf("\r\nERROR. Please enter an End Address larger than the Start Address");
       pea       @m68kus~1_12.L
       jsr       (A2)
       addq.w    #4,A7
; //printf("\r\nEnter Start Address: ") ;
; //Start_hold = Get8HexDigits(0) ;
; printf("\r\nEnter End Address: ") ;
       pea       @m68kus~1_13.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A5,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       byte_func_9
byte_func_11:
; //End_hold = Get8HexDigits(0) ;
; }
; Start = Start_hold;
       move.l    -30(A6),D3
; End = End_hold;
       move.l    (A5),A4
; Start_temp = Start_hold;
       move.l    -30(A6),D5
; End_temp = End_hold;
       move.l    (A5),-34(A6)
; printf("\r\nFilling Addresses [$%08X - $%08X] with test data", Start, End);
       move.l    A4,-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_14.L
       jsr       (A2)
       add.w     #12,A7
; while (Start <= End){
byte_func_12:
       cmp.l     A4,D3
       bhi       byte_func_14
; if ((count == 0) || ((count % 4))==0 ){
       tst.l     D2
       beq.s     byte_func_17
       move.l    D2,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       byte_func_15
byte_func_17:
; *Start = bytedata1;
       move.l    -20(A6),D0
       move.l    D3,A0
       move.b    D0,(A0)
; if ((count == 0) || ((count % 1000)==0)){
       tst.l     D2
       beq.s     byte_func_20
       move.l    D2,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_18
byte_func_20:
; printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata1);
       move.l    -20(A6),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_15.L
       jsr       (A2)
       add.w     #12,A7
byte_func_18:
; }
; Start++;
       addq.l    #1,D3
       bra       byte_func_34
byte_func_15:
; }
; else if ((count == 1) || (((count - 1)%4)==0)){
       cmp.l     #1,D2
       beq.s     byte_func_23
       move.l    D2,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       byte_func_21
byte_func_23:
; *Start = bytedata2;
       move.l    -16(A6),D0
       move.l    D3,A0
       move.b    D0,(A0)
; if ((count == 1) || (((count - 1) % 1000)==0)){
       cmp.l     #1,D2
       beq.s     byte_func_26
       move.l    D2,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_24
byte_func_26:
; printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata2);
       move.l    -16(A6),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_15.L
       jsr       (A2)
       add.w     #12,A7
byte_func_24:
; }
; Start++;
       addq.l    #1,D3
       bra       byte_func_34
byte_func_21:
; }
; else if ((count == 2) || (((count - 2)%4)==0)){
       cmp.l     #2,D2
       beq.s     byte_func_29
       move.l    D2,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       byte_func_27
byte_func_29:
; *Start = bytedata3;
       move.l    -12(A6),D0
       move.l    D3,A0
       move.b    D0,(A0)
; if ((count == 2) || (((count - 2) % 1000)==0)){
       cmp.l     #2,D2
       beq.s     byte_func_32
       move.l    D2,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_30
byte_func_32:
; printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata3);
       move.l    -12(A6),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_15.L
       jsr       (A2)
       add.w     #12,A7
byte_func_30:
; }
; Start++;
       addq.l    #1,D3
       bra       byte_func_34
byte_func_27:
; }
; else if ((count == 3) || (((count - 3)%4)==0)){
       cmp.l     #3,D2
       beq.s     byte_func_35
       move.l    D2,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       byte_func_33
byte_func_35:
; *Start = bytedata4;
       move.l    -8(A6),D0
       move.l    D3,A0
       move.b    D0,(A0)
; if ((count == 3) || (((count - 3) % 1000)==0)){
       cmp.l     #3,D2
       beq.s     byte_func_38
       move.l    D2,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_36
byte_func_38:
; printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata4);
       move.l    -8(A6),-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_15.L
       jsr       (A2)
       add.w     #12,A7
byte_func_36:
; }
; Start++;
       addq.l    #1,D3
       bra.s     byte_func_34
byte_func_33:
; }
; else {
; *Start++ = filldata;
       move.l    D3,A0
       addq.l    #1,D3
       move.b    -22(A6),(A0)
byte_func_34:
; }
; //      if ((count == 0) || ((count % 1000)==0)){
; //       printf("\r\nAdress $%08X being filled with $%02X", Start, readval);
; //}
; count++;
       addq.l    #1,D2
       bra       byte_func_12
byte_func_14:
; }
; printf("\r\nWriting to memory Complete.\r\nEnter '1' to read back the memory. Enter '0' to exit program.");
       pea       @m68kus~1_16.L
       jsr       (A2)
       addq.w    #4,A7
; choice = _getch();
       jsr       __getch
       move.b    D0,D7
; if (choice == '1'){
       cmp.b     #49,D7
       bne       byte_func_39
; // printf("\r\nwill continue");
; while (Start_temp <= End_temp){
byte_func_41:
       cmp.l     -34(A6),D5
       bhi       byte_func_43
; tempdata = *Start_temp;
       move.l    D5,A0
       move.b    (A0),D6
; if ((count2 == 0) || (count2 % 1000)==0){
       tst.l     D4
       beq.s     byte_func_46
       move.l    D4,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_44
byte_func_46:
; printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       @m68kus~1_17.L
       jsr       (A2)
       add.w     #12,A7
       bra       byte_func_53
byte_func_44:
; }
; else if ((count2 == 1) || ((count2 - 1) % 1000)==0){
       cmp.l     #1,D4
       beq.s     byte_func_49
       move.l    D4,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_47
byte_func_49:
; printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       @m68kus~1_17.L
       jsr       (A2)
       add.w     #12,A7
       bra       byte_func_53
byte_func_47:
; }
; else if ((count2 == 2) || ((count2 - 2) % 1000)==0){
       cmp.l     #2,D4
       beq.s     byte_func_52
       move.l    D4,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_50
byte_func_52:
; printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       @m68kus~1_17.L
       jsr       (A2)
       add.w     #12,A7
       bra       byte_func_53
byte_func_50:
; }
; else if ((count2 == 3) || ((count2 - 3) % 1000)==0){
       cmp.l     #3,D4
       beq.s     byte_func_55
       move.l    D4,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     byte_func_53
byte_func_55:
; printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
       move.l    D5,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       pea       @m68kus~1_17.L
       jsr       (A2)
       add.w     #12,A7
byte_func_53:
; }
; count2++;
       addq.l    #1,D4
; *Start_temp++;
       move.l    D5,A0
       addq.l    #1,D5
       bra       byte_func_41
byte_func_43:
       bra.s     byte_func_56
byte_func_39:
; }
; }
; else if (choice == '0'){
       cmp.b     #48,D7
       bne.s     byte_func_56
; printf("\r\nProgram Ended");
       pea       @m68kus~1_18.L
       jsr       (A2)
       addq.w    #4,A7
byte_func_56:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
       unlk      A6
       rts
; }
; }
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////
; //word_func//
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////
; void word_func(void){
       xdef      _word_func
_word_func:
       link      A6,#-40
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7)
       lea       _printf.L,A2
       lea       _scanf.L,A3
       lea       -14(A6),A4
; int worddata1, worddata2, worddata3, worddata4;
; int tempdata;
; int *Start_hold, *End_hold;
; short *Start, *End;
; short *Start_temp, *End_temp;
; unsigned char data, data2;
; int count1 = 0;
       clr.l     D3
; int count2 = 0;
       clr.l     D5
; char choice;
; printf("\r\nEnter 4 words (2 bytes) of Hexidecimal test data.");
       pea       @m68kus~1_19.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter First word: ");
       pea       @m68kus~1_20.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &worddata1) ;
       pea       -38(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //worddata1 = Get4HexDigits(0) ;
; printf("Enter Second word: ");
       pea       @m68kus~1_21.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &worddata2) ;
       pea       -34(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //worddata2 = Get4HexDigits(0) ;
; printf("Enter Third word: ");
       pea       @m68kus~1_22.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &worddata3) ;
       pea       -30(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //worddata3 = Get4HexDigits(0) ;
; printf("Enter Fourth word: ");
       pea       @m68kus~1_23.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &worddata4) ;
       pea       -26(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //worddata4 = Get4HexDigits(0) ;
; printf("Valid addresses for this program are: $0900 0000 - $097F FFFF");
       pea       @m68kus~1_24.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nFor this test, the start and end addresses must align to an even address");
       pea       @m68kus~1_25.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter Start Address: ") ;
       pea       @m68kus~1_8.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &Start_hold) ;
       pea       -18(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //Start_hold = Get8HexDigits(0) ;
; printf("Enter End Address: ") ;
       pea       @m68kus~1_9.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A4,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //End_hold = Get8HexDigits(0) ;
; while ((Start_hold < 0x09000000) || (Start_hold > 0x097FFFFF) || ((Start_hold % 2) != 0)){
word_func_1:
       move.l    -18(A6),D0
       cmp.l     #150994944,D0
       blo.s     word_func_4
       move.l    -18(A6),D0
       cmp.l     #159383551,D0
       bhi.s     word_func_4
       move.l    -18(A6),-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     word_func_3
word_func_4:
; printf("ERROR. Please Enter a valid Start Address: ");
       pea       @m68kus~1_10.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &Start_hold) ;
       pea       -18(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       word_func_1
word_func_3:
; //Start_hold = Get8HexDigits(0) ;
; }
; while ((End_hold < 0x09000000) || (End_hold > 0x097FFFFF) || ((End_hold % 2) != 0)){
word_func_5:
       move.l    (A4),D0
       cmp.l     #150994944,D0
       blo.s     word_func_8
       move.l    (A4),D0
       cmp.l     #159383551,D0
       bhi.s     word_func_8
       move.l    (A4),-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     word_func_7
word_func_8:
; printf("ERROR. Please Enter a valid End Address: ");
       pea       @m68kus~1_26.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A4,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       word_func_5
word_func_7:
; //End_hold = Get8HexDigits(0) ;
; }
; while (End_hold <= Start_hold){
word_func_9:
       move.l    (A4),D0
       cmp.l     -18(A6),D0
       bhi.s     word_func_11
; printf("ERROR. Please enter an End Address larger than the Start Address");
       pea       @m68kus~1_27.L
       jsr       (A2)
       addq.w    #4,A7
; //printf("\r\nEnter Start Address: ") ;
; //Start_hold = Get8HexDigits(0) ;
; printf("\r\nEnter End Address: ") ;
       pea       @m68kus~1_13.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A4,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       word_func_9
word_func_11:
; //End_hold = Get8HexDigits(0) ;
; }
; Start = Start_hold;
       move.l    -18(A6),D2
; End = End_hold;
       move.l    (A4),-10(A6)
; Start_temp = Start_hold;
       move.l    -18(A6),D4
; End_temp = End_hold;
       move.l    (A4),-6(A6)
; while (Start < End){
word_func_12:
       cmp.l     -10(A6),D2
       bhs       word_func_14
; if ((count1 == 0) || ((count1 % 4)) ==0 ){
       tst.l     D3
       beq.s     word_func_17
       move.l    D3,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       word_func_15
word_func_17:
; *Start = worddata1;
       move.l    -38(A6),D0
       move.l    D2,A0
       move.w    D0,(A0)
; if ((count1 == 0) || ((count1 % 1000)==0)){
       tst.l     D3
       beq.s     word_func_20
       move.l    D3,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_18
word_func_20:
; printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata1);
       move.l    -38(A6),-(A7)
       move.l    D2,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       pea       @m68kus~1_28.L
       jsr       (A2)
       add.w     #16,A7
word_func_18:
; }
; Start++;
       addq.l    #2,D2
word_func_15:
; }
; if ((count1 == 1) || (((count1 - 1) % 4)) ==0 ){
       cmp.l     #1,D3
       beq.s     word_func_23
       move.l    D3,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       word_func_21
word_func_23:
; *Start = worddata2;
       move.l    -34(A6),D0
       move.l    D2,A0
       move.w    D0,(A0)
; if ((count1 == 1) || (((count1 -1) % 1000)==0)){
       cmp.l     #1,D3
       beq.s     word_func_26
       move.l    D3,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_24
word_func_26:
; printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata2);
       move.l    -34(A6),-(A7)
       move.l    D2,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       pea       @m68kus~1_28.L
       jsr       (A2)
       add.w     #16,A7
word_func_24:
; }
; Start++;
       addq.l    #2,D2
word_func_21:
; }
; if ((count1 == 2) || (((count1 - 2) % 4)) ==0 ){
       cmp.l     #2,D3
       beq.s     word_func_29
       move.l    D3,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       word_func_27
word_func_29:
; *Start = worddata3;
       move.l    -30(A6),D0
       move.l    D2,A0
       move.w    D0,(A0)
; if ((count1 == 2) || (((count1 -2) % 1000)==0)){
       cmp.l     #2,D3
       beq.s     word_func_32
       move.l    D3,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_30
word_func_32:
; printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata3);
       move.l    -30(A6),-(A7)
       move.l    D2,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       pea       @m68kus~1_28.L
       jsr       (A2)
       add.w     #16,A7
word_func_30:
; }
; Start++;
       addq.l    #2,D2
word_func_27:
; }
; if ((count1 == 3) || (((count1 - 3) % 4)) ==0 ){
       cmp.l     #3,D3
       beq.s     word_func_35
       move.l    D3,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       word_func_33
word_func_35:
; *Start = worddata4;
       move.l    -26(A6),D0
       move.l    D2,A0
       move.w    D0,(A0)
; if ((count1 == 3) || (((count1 - 3) % 1000)==0)){
       cmp.l     #3,D3
       beq.s     word_func_38
       move.l    D3,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_36
word_func_38:
; printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata4);
       move.l    -26(A6),-(A7)
       move.l    D2,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D2,-(A7)
       pea       @m68kus~1_28.L
       jsr       (A2)
       add.w     #16,A7
word_func_36:
; }
; Start++;
       addq.l    #2,D2
word_func_33:
; }
; count1++;
       addq.l    #1,D3
       bra       word_func_12
word_func_14:
; }
; printf("\r\nWriting to memory Complete.\r\nEnter '1' to read back the memory. Enter '0' to exit program.");
       pea       @m68kus~1_16.L
       jsr       (A2)
       addq.w    #4,A7
; choice = _getch();
       jsr       __getch
       move.b    D0,-1(A6)
; if (choice == '1'){
       move.b    -1(A6),D0
       cmp.b     #49,D0
       bne       word_func_39
; //printf("\r\nwill continue");
; while (Start_temp < End_temp){
word_func_41:
       cmp.l     -6(A6),D4
       bhs       word_func_43
; data = (*Start_temp >> 8) & 0xFF;
       move.l    D4,A0
       move.w    (A0),D0
       asr.w     #8,D0
       and.w     #255,D0
       move.b    D0,D7
; data2 = *Start_temp & 0xFF;
       move.l    D4,A0
       move.w    (A0),D0
       and.w     #255,D0
       move.b    D0,D6
; if ((count2 == 0) || (count2 % 1000)==0){
       tst.l     D5
       beq.s     word_func_46
       move.l    D5,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_44
word_func_46:
; printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
       move.l    D4,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_29.L
       jsr       (A2)
       add.w     #20,A7
       bra       word_func_53
word_func_44:
; //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
; }
; else if ((count2 == 1) || ((count2 - 1) % 1000)==0){
       cmp.l     #1,D5
       beq.s     word_func_49
       move.l    D5,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_47
word_func_49:
; printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
       move.l    D4,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_29.L
       jsr       (A2)
       add.w     #20,A7
       bra       word_func_53
word_func_47:
; //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
; }
; else if ((count2 == 2) || ((count2 - 2) % 1000)==0){
       cmp.l     #2,D5
       beq.s     word_func_52
       move.l    D5,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_50
word_func_52:
; printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
       move.l    D4,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_29.L
       jsr       (A2)
       add.w     #20,A7
       bra       word_func_53
word_func_50:
; //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
; }
; else if ((count2 == 3) || ((count2 - 3) % 1000)==0){
       cmp.l     #3,D5
       beq.s     word_func_55
       move.l    D5,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     word_func_53
word_func_55:
; printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
       move.l    D4,D1
       or.l      #1,D1
       move.l    D1,-(A7)
       move.l    D4,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_29.L
       jsr       (A2)
       add.w     #20,A7
word_func_53:
; //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
; }
; count2++;
       addq.l    #1,D5
; *Start_temp++;
       move.l    D4,A0
       addq.l    #2,D4
       bra       word_func_41
word_func_43:
       bra.s     word_func_56
word_func_39:
; }
; }
; else if (choice == '0'){
       move.b    -1(A6),D0
       cmp.b     #48,D0
       bne.s     word_func_56
; printf("\r\nProgram Ended");
       pea       @m68kus~1_18.L
       jsr       (A2)
       addq.w    #4,A7
word_func_56:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
       unlk      A6
       rts
; }
; /*
; *Start = 0xAAAA;
; printf("\r\n%04X", *Start);
; //  data = *Start;
; //data2 =*(Start + 0x00000001);
; data = (*Start >> 8) & 0xFF;
; data2 = *Start & 0xFF;
; printf("\r\nValue $%02X $%02X found at address $%08X - $%08X", data, data2, Start, (Start + (0x000F && Start)));
; printf("\r\nValue $%02X $%02X found at address $%08X - $%08X", data, data2, Start, (Start + 1));
; printf("\r\nValue $%02X $%02X found at address $%08X - $%08X", data, data2, Start, (Start | 0x0001));
; */
; }
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////
; //LongWord_func//
; /////////////////////////////////////////////////////////////////////////////////////////////////////////////
; void longword_func(void){
       xdef      _longword_func
_longword_func:
       link      A6,#-52
       movem.l   D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7)
       lea       _printf.L,A2
       lea       _scanf.L,A3
       lea       -26(A6),A4
; unsigned char data1a, data1b, data2a, data2b, data3a, data3b, data4a, data4b;
; int lworddata1, lworddata2, lworddata3, lworddata4;
; int *Start_hold, *End_hold;
; int *Start, *End;
; int *idk;
; short test, test1;
; int count3, count4;
; int count1 = 0;
       clr.l     D4
; int count2 = 0;
       clr.l     D5
; unsigned char add1, add2;
; short add3;
; char choice;
; printf("\r\nEnter 4 long words (4 bytes) of Hexidecimal test data.");
       pea       @m68kus~1_30.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter First long word: ");
       pea       @m68kus~1_31.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &lworddata1) ;
       pea       -46(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //lworddata1 = Get8HexDigits(0) ;
; //data1a = lworddata1 & 0xFFFF;
; //data1b = (lworddata1 >> 16) & 0xFFFF;
; printf("Enter Second long word: ");
       pea       @m68kus~1_32.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &lworddata2) ;
       pea       -42(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //lworddata2 = Get8HexDigits(0) ;
; printf("Enter Third long word: ");
       pea       @m68kus~1_33.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &lworddata3) ;
       pea       -38(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //lworddata3 = Get8HexDigits(0) ;
; printf("Enter Fourth long word: ");
       pea       @m68kus~1_34.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &lworddata4) ;
       pea       -34(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //lworddata4 = Get8HexDigits(0) ;
; // printf("\r\n%04x   %04x", data1a, data1b);
; printf("Valid addresses for this program are: $0900 0000 - $097F FFFF");
       pea       @m68kus~1_24.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nFor this test, the start and end addresses must align to an even address");
       pea       @m68kus~1_25.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter Start Address: ") ;
       pea       @m68kus~1_8.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &Start_hold) ;
       pea       -30(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //Start_hold = Get8HexDigits(0) ;
; printf("Enter End Address: ") ;
       pea       @m68kus~1_9.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A4,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; //End_hold = Get8HexDigits(0) ;
; while ((Start_hold < 0x09000000) || (Start_hold > 0x097FFFFF) || ((Start_hold % 2) != 0)){
longword_func_1:
       move.l    -30(A6),D0
       cmp.l     #150994944,D0
       blo.s     longword_func_4
       move.l    -30(A6),D0
       cmp.l     #159383551,D0
       bhi.s     longword_func_4
       move.l    -30(A6),-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     longword_func_3
longword_func_4:
; printf("ERROR. Please Enter a valid Start Address: ");
       pea       @m68kus~1_10.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &Start_hold) ;
       pea       -30(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       longword_func_1
longword_func_3:
; //Start_hold = Get8HexDigits(0) ;
; }
; while ((End_hold < 0x09000000) || (End_hold > 0x097FFFFF) || ((End_hold % 2) != 0)){
longword_func_5:
       move.l    (A4),D0
       cmp.l     #150994944,D0
       blo.s     longword_func_8
       move.l    (A4),D0
       cmp.l     #159383551,D0
       bhi.s     longword_func_8
       move.l    (A4),-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       beq.s     longword_func_7
longword_func_8:
; printf("ERROR. Please Enter a valid End Address: ");
       pea       @m68kus~1_26.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A4,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       longword_func_5
longword_func_7:
; //End_hold = Get8HexDigits(0) ;
; }
; while (End_hold <= Start_hold){
longword_func_9:
       move.l    (A4),D0
       cmp.l     -30(A6),D0
       bhi.s     longword_func_11
; printf("ERROR. Please enter an End Address larger than the Start Address");
       pea       @m68kus~1_27.L
       jsr       (A2)
       addq.w    #4,A7
; //printf("\r\nEnter Start Address: ") ;
; //Start_hold = Get8HexDigits(0) ;
; printf("\r\nEnter End Address: ") ;
       pea       @m68kus~1_13.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &End_hold) ;
       move.l    A4,-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       longword_func_9
longword_func_11:
; //End_hold = Get8HexDigits(0) ;
; }
; Start = Start_hold;
       move.l    -30(A6),D3
; End = End_hold;
       move.l    (A4),-22(A6)
; while (Start < End){
longword_func_12:
       cmp.l     -22(A6),D3
       bhs       longword_func_14
; if ((count1 == 0) || ((count1 % 4)) ==0 ){
       tst.l     D4
       beq.s     longword_func_17
       move.l    D4,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_15
longword_func_17:
; *Start = lworddata1;
       move.l    D3,A0
       move.l    -46(A6),(A0)
; idk = Start;
       move.l    D3,D2
; idk = (int *)((char *)idk + 3);
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D2
; if ((count1 == 0) || ((count1 % 1000)==0)){
       tst.l     D4
       beq.s     longword_func_20
       move.l    D4,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     longword_func_18
longword_func_20:
; printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata1);
       move.l    -46(A6),-(A7)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_35.L
       jsr       (A2)
       add.w     #16,A7
longword_func_18:
; }
; Start++;
       addq.l    #4,D3
longword_func_15:
; }
; if ((count1 == 1) || (((count1 - 1) % 4)) ==0 ){
       cmp.l     #1,D4
       beq.s     longword_func_23
       move.l    D4,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_21
longword_func_23:
; *Start = lworddata2;
       move.l    D3,A0
       move.l    -42(A6),(A0)
; idk = Start;
       move.l    D3,D2
; idk = (int *)((char *)idk + 3);
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D2
; if ((count1 == 1) || (((count1 -1) % 1000)==0)){
       cmp.l     #1,D4
       beq.s     longword_func_26
       move.l    D4,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     longword_func_24
longword_func_26:
; printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata2);
       move.l    -42(A6),-(A7)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_35.L
       jsr       (A2)
       add.w     #16,A7
longword_func_24:
; }
; Start++;
       addq.l    #4,D3
longword_func_21:
; }
; if ((count1 == 2) || (((count1 - 2) % 4)) ==0 ){
       cmp.l     #2,D4
       beq.s     longword_func_29
       move.l    D4,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_27
longword_func_29:
; *Start = lworddata3;
       move.l    D3,A0
       move.l    -38(A6),(A0)
; idk = Start;
       move.l    D3,D2
; idk = (int *)((char *)idk + 3);
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D2
; if ((count1 == 2) || (((count1 -2) % 1000)==0)){
       cmp.l     #2,D4
       beq.s     longword_func_32
       move.l    D4,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     longword_func_30
longword_func_32:
; printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata3);
       move.l    -38(A6),-(A7)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_35.L
       jsr       (A2)
       add.w     #16,A7
longword_func_30:
; }
; Start++;
       addq.l    #4,D3
longword_func_27:
; }
; if ((count1 == 3) || (((count1 - 3) % 4)) ==0 ){
       cmp.l     #3,D4
       beq.s     longword_func_35
       move.l    D4,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       4
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_33
longword_func_35:
; *Start = lworddata4;
       move.l    D3,A0
       move.l    -34(A6),(A0)
; idk = Start;
       move.l    D3,D2
; idk = (int *)((char *)idk + 3);
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D2
; if ((count1 == 3) || (((count1 - 3) % 1000)==0)){
       cmp.l     #3,D4
       beq.s     longword_func_38
       move.l    D4,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     longword_func_36
longword_func_38:
; printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata4);
       move.l    -34(A6),-(A7)
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       pea       @m68kus~1_35.L
       jsr       (A2)
       add.w     #16,A7
longword_func_36:
; }
; Start++;
       addq.l    #4,D3
longword_func_33:
; }
; count1++;
       addq.l    #1,D4
       bra       longword_func_12
longword_func_14:
; }
; printf("\r\nWriting to memory Complete.\r\nEnter '1' to read back the memory. Enter '0' to exit program.");
       pea       @m68kus~1_16.L
       jsr       (A2)
       addq.w    #4,A7
; choice = _getch();
       jsr       __getch
       move.b    D0,-1(A6)
; if (choice == '1'){
       move.b    -1(A6),D0
       cmp.b     #49,D0
       bne       longword_func_39
; //printf("\r\nwill continue");
; while (Start_hold < End_hold){
longword_func_41:
       move.l    -30(A6),D0
       cmp.l     (A4),D0
       bhs       longword_func_43
; data1a = (*Start_hold >> 8) & 0xFF;
       move.l    -30(A6),A0
       move.l    (A0),D0
       asr.l     #8,D0
       and.l     #255,D0
       move.b    D0,-52(A6)
; data1b = *Start_hold & 0xFF;
       move.l    -30(A6),A0
       move.l    (A0),D0
       and.l     #255,D0
       move.b    D0,-51(A6)
; data2a = (*Start_hold >> 24) & 0xFF;
       move.l    -30(A6),A0
       move.l    (A0),D0
       asr.l     #8,D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D7
; data2b = (*Start_hold >> 16) & 0xFF;
       move.l    -30(A6),A0
       move.l    (A0),D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.b    D0,D6
; idk = Start_hold;
       move.l    -30(A6),D2
; idk = (int *)((char *)idk + 3);
       move.l    D2,D0
       addq.l    #3,D0
       move.l    D0,D2
; //data = (*Start_hold >> 8) & 0xFF;
; //data2 = *Start_hold & 0xFF;
; if ((count2 == 0) || (count2 % 1000)==0){
       tst.l     D5
       beq.s     longword_func_46
       move.l    D5,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_44
longword_func_46:
; printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
       move.l    D2,-(A7)
       move.l    -30(A6),-(A7)
       move.b    -51(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -52(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_36.L
       jsr       (A2)
       add.w     #28,A7
       bra       longword_func_53
longword_func_44:
; //printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_hold, (Start_hold | 0x0001));
; //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
; }
; else if ((count2 == 1) || ((count2 - 1) % 1000)==0){
       cmp.l     #1,D5
       beq.s     longword_func_49
       move.l    D5,D0
       subq.l    #1,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_47
longword_func_49:
; printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
       move.l    D2,-(A7)
       move.l    -30(A6),-(A7)
       move.b    -51(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -52(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_36.L
       jsr       (A2)
       add.w     #28,A7
       bra       longword_func_53
longword_func_47:
; //printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_hold, (Start_hold | 0x0001));
; //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
; }
; else if ((count2 == 2) || ((count2 - 2) % 1000)==0){
       cmp.l     #2,D5
       beq.s     longword_func_52
       move.l    D5,D0
       subq.l    #2,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne       longword_func_50
longword_func_52:
; printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
       move.l    D2,-(A7)
       move.l    -30(A6),-(A7)
       move.b    -51(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -52(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_36.L
       jsr       (A2)
       add.w     #28,A7
       bra       longword_func_53
longword_func_50:
; }
; else if ((count2 == 3) || ((count2 - 3) % 1000)==0){
       cmp.l     #3,D5
       beq.s     longword_func_55
       move.l    D5,D0
       subq.l    #3,D0
       move.l    D0,-(A7)
       pea       1000
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       tst.l     D0
       bne.s     longword_func_53
longword_func_55:
; printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
       move.l    D2,-(A7)
       move.l    -30(A6),-(A7)
       move.b    -51(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       move.b    -52(A6),D1
       and.l     #255,D1
       move.l    D1,-(A7)
       and.l     #255,D6
       move.l    D6,-(A7)
       and.l     #255,D7
       move.l    D7,-(A7)
       pea       @m68kus~1_36.L
       jsr       (A2)
       add.w     #28,A7
longword_func_53:
; }
; count2++;
       addq.l    #1,D5
; *Start_hold++;
       move.l    -30(A6),A0
       addq.l    #4,-30(A6)
       bra       longword_func_41
longword_func_43:
       bra.s     longword_func_56
longword_func_39:
; }
; }
; else if (choice == '0'){
       move.b    -1(A6),D0
       cmp.b     #48,D0
       bne.s     longword_func_56
; printf("\r\nProgram Ended");
       pea       @m68kus~1_18.L
       jsr       (A2)
       addq.w    #4,A7
longword_func_56:
       movem.l   (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
       unlk      A6
       rts
; }
; }
; //////////////////////////////////////////////////////////
; //******IIC Program Functions Begin Here***************///
; //////////////////////////////////////////////////////////
; void IIC_Init(void)
; {
       xdef      _IIC_Init
_IIC_Init:
; IIC_Prescale_Low = 0x31; //31
       move.b    #49,4227072
; //IIC_Prescale_Low = 0x63;
; IIC_Prescale_High = 0x00; //0xFF for reset
       clr.b     4227074
; IIC_Control = 0x80; // core enabled, interupts disabled
       move.b    #128,4227076
; //IIC_Control = 0xC0;
; //IIC_Transmit_Receive = 0x00;
; //IIC_Command_Status = 0x00;
; printf("\r\n%x",IIC_Command_Status);
       move.b    4227080,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_37.L
       jsr       _printf
       addq.w    #8,A7
       rts
; }
; void PollTIPFlag(void){
       xdef      _PollTIPFlag
_PollTIPFlag:
       link      A6,#-4
; char status;
; status = IIC_Command_Status;
       move.b    4227080,-1(A6)
; //Check that TIP flag is negated
; while ((status & 0x02) != 0){
PollTIPFlag_1:
       move.b    -1(A6),D0
       and.b     #2,D0
       beq.s     PollTIPFlag_3
; 1;
       bra       PollTIPFlag_1
PollTIPFlag_3:
       unlk      A6
       rts
; //printf("%x",status);
; //printf("TIP ");
; }
; }
; void IIC_StartCommand(int block_sel){
       xdef      _IIC_StartCommand
_IIC_StartCommand:
       link      A6,#-4
       movem.l   D2/D3/A2,-(A7)
       lea       _printf.L,A2
; char dog;
; int cat*;
; int slave_addr = 0x00;
       clr.l     D3
; if (block_sel == 0){
       move.l    8(A6),D0
       bne.s     IIC_StartCommand_1
; printf("\r\nBlock is set to 0");
       pea       @m68kus~1_38.L
       jsr       (A2)
       addq.w    #4,A7
; slave_addr = 0xA0;
       move.l    #160,D3
       bra.s     IIC_StartCommand_3
IIC_StartCommand_1:
; }
; else if (block_sel == 1){
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     IIC_StartCommand_3
; printf("\r\nBlock is set to 1");
       pea       @m68kus~1_39.L
       jsr       (A2)
       addq.w    #4,A7
; slave_addr = 0xA2;
       move.l    #162,D3
IIC_StartCommand_3:
; }
; printf("\r\nSending Start Command...");
       pea       @m68kus~1_40.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nControl Register is %x", IIC_Control);
       move.b    4227076,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_41.L
       jsr       (A2)
       addq.w    #8,A7
; //Check that no transmit is in progress
; //IIC_Command_Status = 0x80;
; //PollTIPFlag();
; dog = IIC_Command_Status;
       move.b    4227080,D2
; printf("\r\n%x", dog);
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       pea       @m68kus~1_37.L
       jsr       (A2)
       addq.w    #8,A7
; IIC_Transmit_Receive = slave_addr; //Slave Adress and write bit
       move.b    D3,4227078
; //IIC_Command_Status = 0x10; //Set STA and WR bit
; IIC_Command_Status = 0x90;
       move.b    #144,4227080
; dog = IIC_Command_Status;
       move.b    4227080,D2
; printf("\r\n%x", dog);
       ext.w     D2
       ext.l     D2
       move.l    D2,-(A7)
       pea       @m68kus~1_37.L
       jsr       (A2)
       addq.w    #8,A7
; //Wait for transmit to complete
; PollTIPFlag();
       jsr       _PollTIPFlag
; WaitForAck();
       jsr       _WaitForAck
; printf("\r\nStart Command Received");
       pea       @m68kus~1_42.L
       jsr       (A2)
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/A2
       unlk      A6
       rts
; }
; void IIC_RepeatedStartCommand(int block_sel){
       xdef      _IIC_RepeatedStartCommand
_IIC_RepeatedStartCommand:
       link      A6,#0
       movem.l   D2/A2,-(A7)
       lea       _printf.L,A2
; int slave_addr = 0x00;
       clr.l     D2
; if (block_sel == 0){
       move.l    8(A6),D0
       bne.s     IIC_RepeatedStartCommand_1
; printf("\r\nBlock is set to 0");
       pea       @m68kus~1_38.L
       jsr       (A2)
       addq.w    #4,A7
; slave_addr = 0xA1;
       move.l    #161,D2
       bra.s     IIC_RepeatedStartCommand_3
IIC_RepeatedStartCommand_1:
; }
; else if (block_sel == 1){
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     IIC_RepeatedStartCommand_3
; printf("\r\nBlock is set to 1");
       pea       @m68kus~1_39.L
       jsr       (A2)
       addq.w    #4,A7
; slave_addr = 0xA3;
       move.l    #163,D2
IIC_RepeatedStartCommand_3:
; }
; printf("\r\nSending Start Command...");
       pea       @m68kus~1_40.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nControl Register is %x", IIC_Control);
       move.b    4227076,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_41.L
       jsr       (A2)
       addq.w    #8,A7
; //Check that no transmit is in progress
; //IIC_Command_Status = 0x80;
; //PollTIPFlag();
; IIC_Transmit_Receive = slave_addr; //Slave Adress and write bit
       move.b    D2,4227078
; //IIC_Command_Status = 0x10; //Set STA and WR bit
; printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_43.L
       jsr       (A2)
       addq.w    #8,A7
; IIC_Command_Status = 0x90; //
       move.b    #144,4227080
; printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_44.L
       jsr       (A2)
       addq.w    #8,A7
; //Wait for transmit to complete
; PollTIPFlag();
       jsr       _PollTIPFlag
; WaitForAck();
       jsr       _WaitForAck
; printf("\r\nStart Command Received");
       pea       @m68kus~1_42.L
       jsr       (A2)
       addq.w    #4,A7
       movem.l   (A7)+,D2/A2
       unlk      A6
       rts
; }
; void IIC_SendAddress(int address_high, int address_low){
       xdef      _IIC_SendAddress
_IIC_SendAddress:
       link      A6,#0
       move.l    A2,-(A7)
       lea       _printf.L,A2
; printf("\r\nSending address");
       pea       @m68kus~1_45.L
       jsr       (A2)
       addq.w    #4,A7
; //IIC_Command_Status = 0x10;
; IIC_Transmit_Receive = address_high; //High byte internal address
       move.l    8(A6),D0
       move.b    D0,4227078
; printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_43.L
       jsr       (A2)
       addq.w    #8,A7
; IIC_Command_Status = 0x10; //set WR bit
       move.b    #16,4227080
; printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_44.L
       jsr       (A2)
       addq.w    #8,A7
; //Wait for transmit to complete
; PollTIPFlag();
       jsr       _PollTIPFlag
; WaitForAck();
       jsr       _WaitForAck
; printf("\r\nHigh byte address sent");
       pea       @m68kus~1_46.L
       jsr       (A2)
       addq.w    #4,A7
; //IIC_Command_Status = 0x10;
; IIC_Transmit_Receive = address_low; //Low byte internal address
       move.l    12(A6),D0
       move.b    D0,4227078
; printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_43.L
       jsr       (A2)
       addq.w    #8,A7
; IIC_Command_Status = 0x10; //set WR bit
       move.b    #16,4227080
; printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_44.L
       jsr       (A2)
       addq.w    #8,A7
; //Wait for transmit to complete
; PollTIPFlag();
       jsr       _PollTIPFlag
; WaitForAck();
       jsr       _WaitForAck
; printf("\r\nLow byte address sent");
       pea       @m68kus~1_47.L
       jsr       (A2)
       addq.w    #4,A7
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; void IIC_WriteData(int data){
       xdef      _IIC_WriteData
_IIC_WriteData:
       link      A6,#0
       move.l    A2,-(A7)
       lea       _printf.L,A2
; //IIC_Command_Status = 0x10;
; IIC_Transmit_Receive = data; //High byte internal address
       move.l    8(A6),D0
       move.b    D0,4227078
; printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_43.L
       jsr       (A2)
       addq.w    #8,A7
; IIC_Command_Status = 0x10; //set WR bit
       move.b    #16,4227080
; printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_44.L
       jsr       (A2)
       addq.w    #8,A7
; //Wait for transmit to complete
; PollTIPFlag();
       jsr       _PollTIPFlag
; WaitForAck();
       jsr       _WaitForAck
; IIC_Command_Status = 0x40; //Set STO bit
       move.b    #64,4227080
; PollTIPFlag();
       jsr       _PollTIPFlag
; printf("\r\nData Writen");
       pea       @m68kus~1_48.L
       jsr       (A2)
       addq.w    #4,A7
       move.l    (A7)+,A2
       unlk      A6
       rts
; }
; void IIC_ReadData(void){
       xdef      _IIC_ReadData
_IIC_ReadData:
       movem.l   D2/A2,-(A7)
       lea       _printf.L,A2
; int recieved;
; printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_43.L
       jsr       (A2)
       addq.w    #8,A7
; IIC_Command_Status = 0x20; //set WR bit
       move.b    #32,4227080
; printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
       move.b    4227078,D1
       and.l     #255,D1
       move.l    D1,-(A7)
       pea       @m68kus~1_44.L
       jsr       (A2)
       addq.w    #8,A7
; PollTIPFlag();
       jsr       _PollTIPFlag
; while ((IIC_Command_Status & 0x01) != 1){
IIC_ReadData_1:
       move.b    4227080,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     IIC_ReadData_3
; 1;
       bra       IIC_ReadData_1
IIC_ReadData_3:
; }
; //IIC_Command_Status &= 0xFE;
; recieved = IIC_Transmit_Receive;
       move.b    4227078,D0
       and.l     #255,D0
       move.l    D0,D2
; printf("\r\nDATA READ IS: %02X", recieved);
       move.l    D2,-(A7)
       pea       @m68kus~1_49.L
       jsr       (A2)
       addq.w    #8,A7
; //IIC_Command_Status |= 0x48; //set STO bit, ACK bit
; IIC_Command_Status = 0x48;
       move.b    #72,4227080
; recieved = IIC_Transmit_Receive;
       move.b    4227078,D0
       and.l     #255,D0
       move.l    D0,D2
       movem.l   (A7)+,D2/A2
       rts
; }
; int CheckAck(void){
       xdef      _CheckAck
_CheckAck:
       link      A6,#-8
; int val;
; char test;
; test = IIC_Command_Status;
       move.b    4227080,-1(A6)
; val = (test & 0x80);
       move.b    -1(A6),D0
       ext.w     D0
       ext.l     D0
       and.l     #128,D0
       move.l    D0,-6(A6)
; if (val == 0){
       move.l    -6(A6),D0
       bne.s     CheckAck_1
; return 0;
       clr.l     D0
       bra.s     CheckAck_3
CheckAck_1:
; }
; else{
; return 1;
       moveq     #1,D0
CheckAck_3:
       unlk      A6
       rts
; }
; }
; void WaitForAck(void){
       xdef      _WaitForAck
_WaitForAck:
; while (CheckAck() == 1){
WaitForAck_1:
       jsr       _CheckAck
       cmp.l     #1,D0
       bne.s     WaitForAck_3
; 1;
       bra       WaitForAck_1
WaitForAck_3:
       rts
; }
; }
; void IIC_WriteDataByte(int data, int address){
       xdef      _IIC_WriteDataByte
_IIC_WriteDataByte:
       link      A6,#-12
       move.l    D2,-(A7)
       move.l    12(A6),D2
; int block_sel = (address >> 16) & 0xF;  // extract most significant byte
       move.l    D2,D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #15,D0
       move.l    D0,-12(A6)
; int address_high = (address >> 8) & 0xFF;  // extract high byte
       move.l    D2,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; int address_low = address & 0xFF;  // extract low byte
       move.l    D2,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; //Send start command
; IIC_StartCommand(block_sel);
       move.l    -12(A6),-(A7)
       jsr       _IIC_StartCommand
       addq.w    #4,A7
; IIC_SendAddress(address_high, address_low);
       move.l    -4(A6),-(A7)
       move.l    -8(A6),-(A7)
       jsr       _IIC_SendAddress
       addq.w    #8,A7
; IIC_WriteData(data);
       move.l    8(A6),-(A7)
       jsr       _IIC_WriteData
       addq.w    #4,A7
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; void IIC_ReadDataByte(int address){
       xdef      _IIC_ReadDataByte
_IIC_ReadDataByte:
       link      A6,#-8
       movem.l   D2/D3,-(A7)
       move.l    8(A6),D2
; int block_sel = (address >> 16) & 0xF;  // extract most significant byte
       move.l    D2,D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #15,D0
       move.l    D0,D3
; int address_high = (address >> 8) & 0xFF;  // extract high byte
       move.l    D2,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; int address_low = address & 0xFF;  // extract low byte
       move.l    D2,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; //Send start command
; IIC_StartCommand(block_sel);
       move.l    D3,-(A7)
       jsr       _IIC_StartCommand
       addq.w    #4,A7
; IIC_SendAddress(address_high, address_low);
       move.l    -4(A6),-(A7)
       move.l    -8(A6),-(A7)
       jsr       _IIC_SendAddress
       addq.w    #8,A7
; IIC_RepeatedStartCommand(block_sel);
       move.l    D3,-(A7)
       jsr       _IIC_RepeatedStartCommand
       addq.w    #4,A7
; IIC_ReadData();
       jsr       _IIC_ReadData
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; void IIC_WriteDataBlock(int address, int blocksize, int blockstart){
       xdef      _IIC_WriteDataBlock
_IIC_WriteDataBlock:
       link      A6,#0
       movem.l   D2/D3/D4/D5/A2,-(A7)
       lea       _printf.L,A2
       move.l    8(A6),D4
; int block_sel = (address >> 16) & 0xF;  // extract most significant byte
       move.l    D4,D0
       asr.l     #8,D0
       asr.l     #8,D0
       and.l     #15,D0
       move.l    D0,D5
; int address_high = (address >> 8) & 0xFF;  // extract high byte
       move.l    D4,D0
       asr.l     #8,D0
       and.l     #255,D0
       move.l    D0,D3
; int address_low = address & 0xFF;  // extract low byte
       move.l    D4,D0
       and.l     #255,D0
       move.l    D0,D2
; // print the results
; printf("\r\nBlock Sel: %X", block_sel);
       move.l    D5,-(A7)
       pea       @m68kus~1_50.L
       jsr       (A2)
       addq.w    #8,A7
; printf("\r\nAddress High: %X", address_high);
       move.l    D3,-(A7)
       pea       @m68kus~1_51.L
       jsr       (A2)
       addq.w    #8,A7
; printf("\r\nAddress Low: %X", address_low);
       move.l    D2,-(A7)
       pea       @m68kus~1_52.L
       jsr       (A2)
       addq.w    #8,A7
; //Send start command
; IIC_StartCommand(block_sel);
       move.l    D5,-(A7)
       jsr       _IIC_StartCommand
       addq.w    #4,A7
; IIC_SendAddress(address_high, address_low);
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       jsr       _IIC_SendAddress
       addq.w    #8,A7
       movem.l   (A7)+,D2/D3/D4/D5/A2
       unlk      A6
       rts
; }
; /******************************************************************************************************************************
; * Start of user program
; ******************************************************************************************************************************/
; void main()
; {
       xdef      _main
_main:
       link      A6,#-212
       movem.l   D2/D3/A2/A3/A4,-(A7)
       lea       _printf.L,A2
       lea       _scanf.L,A3
       lea       _InstallExceptionHandler.L,A4
; unsigned int row, i=0, count=0, counter1=1;
       clr.l     -206(A6)
       clr.l     -202(A6)
       move.l    #1,-198(A6)
; char c, text[150] ;
; int PassFailFlag = 1 ;
       move.l    #1,-42(A6)
; //IIC variables
; char choice = '0';
       move.b    #48,-37(A6)
; int WriteData;
; int WriteAddress;
; int ReadAddress;
; int WriteBlockAddress;
; int WriteBlockSize;
; int WriteBlockMaxSize;
; int WriteBlockDataStart;
; int ReadBlockAddress;
; int ReadBlockMaxSize;
; int ReadBlockSize;
; int num;
; /////Mem Test Variables
; // unsigned int *RamPtr;
; // unsigned int Start, End ;
; // unsigned int data_byte1, data_byte2, data_byte3, data_byte4; //Test data recieved from user (bytes)
; // unsigned int data_word1, data_word2, data_word3, data_word4;
; // unsigned int data_Lword1, data_Lword2, data_Lword3, data_Lword4;
; // char type;
; // int testnum = 1;
; /////Mem Test Variables
; i = x = y = z = PortA_Count =0;
       clr.l     _PortA_Count.L
       clr.l     _z.L
       clr.l     _y.L
       clr.l     _x.L
       clr.l     -206(A6)
; Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;
       clr.b     _Timer4Count.L
       clr.b     _Timer3Count.L
       clr.b     _Timer2Count.L
       clr.b     _Timer1Count.L
; InstallExceptionHandler(PIA_ISR, 25) ;          // install interrupt handler for PIAs 1 and 2 on level 1 IRQ
       pea       25
       pea       _PIA_ISR.L
       jsr       (A4)
       addq.w    #8,A7
; InstallExceptionHandler(ACIA_ISR, 26) ;		    // install interrupt handler for ACIA on level 2 IRQ
       pea       26
       pea       _ACIA_ISR.L
       jsr       (A4)
       addq.w    #8,A7
; InstallExceptionHandler(Timer_ISR, 27) ;		// install interrupt handler for Timers 1-4 on level 3 IRQ
       pea       27
       pea       _Timer_ISR.L
       jsr       (A4)
       addq.w    #8,A7
; InstallExceptionHandler(Key2PressISR, 28) ;	    // install interrupt handler for Key Press 2 on DE1 board for level 4 IRQ
       pea       28
       pea       _Key2PressISR.L
       jsr       (A4)
       addq.w    #8,A7
; InstallExceptionHandler(Key1PressISR, 29) ;	    // install interrupt handler for Key Press 1 on DE1 board for level 5 IRQ
       pea       29
       pea       _Key1PressISR.L
       jsr       (A4)
       addq.w    #8,A7
; Timer1Data = 0x10;		// program time delay into timers 1-4
       move.b    #16,4194352
; Timer2Data = 0x20;
       move.b    #32,4194356
; Timer3Data = 0x15;
       move.b    #21,4194360
; Timer4Data = 0x25;
       move.b    #37,4194364
; Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
       move.b    #3,4194354
; Timer2Control = 3;
       move.b    #3,4194358
; Timer3Control = 3;
       move.b    #3,4194362
; Timer4Control = 3;
       move.b    #3,4194366
; Init_LCD();             // initialise the LCD display to use a parallel data interface and 2 lines of display
       jsr       _Init_LCD
; Init_RS232() ;          // initialise the RS232 port for use with hyper terminal
       jsr       _Init_RS232
; /*************************************************************************************************
; **  User Program
; *************************************************************************************************/
; printf("\r\nIIC program will begin");
       pea       @m68kus~1_53.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter 0 ... Write Single Byte\r\nEnter 1 ... Read Single Byte\r\nEnter 2 ... Write Data Block\r\nEnter 3 ... Read Data Block\r\n");
       pea       @m68kus~1_54.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%c", &choice);
       pea       -37(A6)
       pea       @m68kus~1_55.L
       jsr       (A3)
       addq.w    #8,A7
; IIC_Init();
       jsr       _IIC_Init
; if(choice == '0'){
       move.b    -37(A6),D0
       cmp.b     #48,D0
       bne       main_1
; printf("Single Byte Write Initiated\r\nEnter Data Byte: ");
       pea       @m68kus~1_56.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteData);
       pea       -36(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (WriteData > 0xFF){
main_3:
       move.l    -36(A6),D0
       cmp.l     #255,D0
       ble.s     main_5
; printf("Enter Valid Data Byte: ");
       pea       @m68kus~1_57.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteData);
       pea       -36(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_3
main_5:
; }
; printf("Enter Address (00000 - 1FFFF): ");
       pea       @m68kus~1_58.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteAddress);
       pea       -32(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (WriteAddress > 0x1FFFF){
main_6:
       move.l    -32(A6),D0
       cmp.l     #131071,D0
       ble.s     main_8
; printf("Enter Valid Address: ");
       pea       @m68kus~1_59.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", WriteAddress);
       move.l    -32(A6),-(A7)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_6
main_8:
; }
; printf("\r\nWriting Data Byte ...");
       pea       @m68kus~1_60.L
       jsr       (A2)
       addq.w    #4,A7
; IIC_WriteDataByte(WriteData, WriteAddress);
       move.l    -32(A6),-(A7)
       move.l    -36(A6),-(A7)
       jsr       _IIC_WriteDataByte
       addq.w    #8,A7
main_1:
; }
; if(choice == '1'){
       move.b    -37(A6),D0
       cmp.b     #49,D0
       bne       main_9
; printf("\r\nSingle Byte Read Initiated\r\nEnter Address (00000 - 1FFFF): ");
       pea       @m68kus~1_61.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &ReadAddress);
       pea       -28(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (ReadAddress > 0x1FFFF){
main_11:
       move.l    -28(A6),D0
       cmp.l     #131071,D0
       ble.s     main_13
; printf("Enter Valid Address: ");
       pea       @m68kus~1_59.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &ReadAddress);
       pea       -28(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_11
main_13:
; }
; printf("\r\nReading Data Byte ...");
       pea       @m68kus~1_62.L
       jsr       (A2)
       addq.w    #4,A7
; IIC_ReadDataByte(ReadAddress);
       move.l    -28(A6),-(A7)
       jsr       _IIC_ReadDataByte
       addq.w    #4,A7
main_9:
; }
; if (choice == '2'){
       move.b    -37(A6),D0
       cmp.b     #50,D0
       bne       main_14
; printf("\r\nData Block Write Initiated\r\nEnter Starting Address (00000 - 1FFFF): ");
       pea       @m68kus~1_63.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteBlockAddress);
       pea       -24(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (WriteBlockAddress > 0x1FFFF){
main_16:
       move.l    -24(A6),D0
       cmp.l     #131071,D0
       ble.s     main_18
; printf("Enter Valid Address: ");
       pea       @m68kus~1_59.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteBlockAddress);
       pea       -24(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_16
main_18:
; }
; WriteBlockMaxSize = (0x1FFFF - WriteBlockAddress);
       move.l    #131071,D0
       sub.l     -24(A6),D0
       move.l    D0,D3
; printf("Enter Data Block Size (00000 - %05X): ", WriteBlockMaxSize);
       move.l    D3,-(A7)
       pea       @m68kus~1_64.L
       jsr       (A2)
       addq.w    #8,A7
; scanf("%x", &WriteBlockSize);
       pea       -20(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (WriteBlockSize > WriteBlockMaxSize){
main_19:
       cmp.l     -20(A6),D3
       bge.s     main_21
; printf("Enter Valid Block Size (00000 - %05X): ", WriteBlockMaxSize);
       move.l    D3,-(A7)
       pea       @m68kus~1_65.L
       jsr       (A2)
       addq.w    #8,A7
; scanf("%x", &WriteBlockSize);
       pea       -20(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_19
main_21:
; }
; printf("Enter Starting Data Byte: ");
       pea       @m68kus~1_66.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteBlockDataStart);
       pea       -16(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (WriteBlockDataStart > 0xFF){
main_22:
       move.l    -16(A6),D0
       cmp.l     #255,D0
       ble.s     main_24
; printf("Enter Valid Data Byte: ");
       pea       @m68kus~1_57.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &WriteBlockDataStart);
       pea       -16(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_22
main_24:
; }
; IIC_WriteDataBlock(WriteBlockAddress, WriteBlockSize, WriteBlockDataStart);
       move.l    -16(A6),-(A7)
       move.l    -20(A6),-(A7)
       move.l    -24(A6),-(A7)
       jsr       _IIC_WriteDataBlock
       add.w     #12,A7
main_14:
; }
; if (choice == '3'){
       move.b    -37(A6),D0
       cmp.b     #51,D0
       bne       main_32
; printf("\r\nData Block Read Initiated\r\nEnter Starting Address (00000 - 1FFFF): ");
       pea       @m68kus~1_67.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &ReadBlockAddress);
       pea       -12(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (ReadBlockAddress > 0x1FFFF){
main_27:
       move.l    -12(A6),D0
       cmp.l     #131071,D0
       ble.s     main_29
; printf("Enter Valid Address");
       pea       @m68kus~1_68.L
       jsr       (A2)
       addq.w    #4,A7
; scanf("%x", &ReadBlockAddress);
       pea       -12(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_27
main_29:
; }
; ReadBlockMaxSize = (0x1FFFF - ReadBlockAddress);
       move.l    #131071,D0
       sub.l     -12(A6),D0
       move.l    D0,D2
; printf("Enter Data Block Size (00000 - %05X): ", ReadBlockMaxSize);
       move.l    D2,-(A7)
       pea       @m68kus~1_64.L
       jsr       (A2)
       addq.w    #8,A7
; scanf("%x", &ReadBlockSize);
       pea       -8(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
; while (ReadBlockSize > ReadBlockMaxSize){
main_30:
       cmp.l     -8(A6),D2
       bge.s     main_32
; printf("Enter Valid Block Size (00000 - %05X): ", ReadBlockMaxSize);
       move.l    D2,-(A7)
       pea       @m68kus~1_65.L
       jsr       (A2)
       addq.w    #8,A7
; scanf("%x", &ReadBlockSize);
       pea       -8(A6)
       pea       @m68kus~1_3.L
       jsr       (A3)
       addq.w    #8,A7
       bra       main_30
main_32:
; }
; }
; printf("\r\nProgram ended");
       pea       @m68kus~1_69.L
       jsr       (A2)
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/A2/A3/A4
       unlk      A6
       rts
; }
       section   const
@m68kus~1_1:
       dc.b      13,10,69,110,116,101,114,32,52,32,98,121,116
       dc.b      101,115,32,111,102,32,72,101,120,105,100,101
       dc.b      99,105,109,97,108,32,116,101,115,116,32,100
       dc.b      97,116,97,46,0
@m68kus~1_2:
       dc.b      13,10,69,110,116,101,114,32,70,105,114,115,116
       dc.b      32,98,121,116,101,58,32,0
@m68kus~1_3:
       dc.b      37,120,0
@m68kus~1_4:
       dc.b      69,110,116,101,114,32,83,101,99,111,110,100
       dc.b      32,98,121,116,101,58,32,0
@m68kus~1_5:
       dc.b      69,110,116,101,114,32,84,104,105,114,100,32
       dc.b      98,121,116,101,58,32,0
@m68kus~1_6:
       dc.b      69,110,116,101,114,32,70,111,117,114,116,104
       dc.b      32,98,121,116,101,58,32,0
@m68kus~1_7:
       dc.b      86,97,108,105,100,32,97,100,100,114,101,115
       dc.b      115,101,115,32,102,111,114,32,116,104,105,115
       dc.b      32,112,114,111,103,114,97,109,32,97,114,101
       dc.b      58,32,36,48,57,48,48,32,48,48,48,48,32,32,45
       dc.b      32,36,48,57,55,70,32,70,70,70,70,0
@m68kus~1_8:
       dc.b      13,10,69,110,116,101,114,32,83,116,97,114,116
       dc.b      32,65,100,100,114,101,115,115,58,32,0
@m68kus~1_9:
       dc.b      69,110,116,101,114,32,69,110,100,32,65,100,100
       dc.b      114,101,115,115,58,32,0
@m68kus~1_10:
       dc.b      69,82,82,79,82,46,32,80,108,101,97,115,101,32
       dc.b      69,110,116,101,114,32,97,32,118,97,108,105,100
       dc.b      32,83,116,97,114,116,32,65,100,100,114,101,115
       dc.b      115,58,32,0
@m68kus~1_11:
       dc.b      13,10,69,82,82,79,82,46,32,80,108,101,97,115
       dc.b      101,32,69,110,116,101,114,32,97,32,118,97,108
       dc.b      105,100,32,69,110,100,32,65,100,100,114,101
       dc.b      115,115,58,32,0
@m68kus~1_12:
       dc.b      13,10,69,82,82,79,82,46,32,80,108,101,97,115
       dc.b      101,32,101,110,116,101,114,32,97,110,32,69,110
       dc.b      100,32,65,100,100,114,101,115,115,32,108,97
       dc.b      114,103,101,114,32,116,104,97,110,32,116,104
       dc.b      101,32,83,116,97,114,116,32,65,100,100,114,101
       dc.b      115,115,0
@m68kus~1_13:
       dc.b      13,10,69,110,116,101,114,32,69,110,100,32,65
       dc.b      100,100,114,101,115,115,58,32,0
@m68kus~1_14:
       dc.b      13,10,70,105,108,108,105,110,103,32,65,100,100
       dc.b      114,101,115,115,101,115,32,91,36,37,48,56,88
       dc.b      32,45,32,36,37,48,56,88,93,32,119,105,116,104
       dc.b      32,116,101,115,116,32,100,97,116,97,0
@m68kus~1_15:
       dc.b      13,10,65,100,100,114,101,115,115,32,36,37,48
       dc.b      56,88,32,98,101,105,110,103,32,102,105,108,108
       dc.b      101,100,32,119,105,116,104,32,36,37,48,50,88
       dc.b      0
@m68kus~1_16:
       dc.b      13,10,87,114,105,116,105,110,103,32,116,111
       dc.b      32,109,101,109,111,114,121,32,67,111,109,112
       dc.b      108,101,116,101,46,13,10,69,110,116,101,114
       dc.b      32,39,49,39,32,116,111,32,114,101,97,100,32
       dc.b      98,97,99,107,32,116,104,101,32,109,101,109,111
       dc.b      114,121,46,32,69,110,116,101,114,32,39,48,39
       dc.b      32,116,111,32,101,120,105,116,32,112,114,111
       dc.b      103,114,97,109,46,0
@m68kus~1_17:
       dc.b      13,10,36,37,48,50,88,32,82,101,97,100,32,102
       dc.b      114,111,109,32,97,100,100,114,101,115,115,32
       dc.b      36,37,48,56,88,0
@m68kus~1_18:
       dc.b      13,10,80,114,111,103,114,97,109,32,69,110,100
       dc.b      101,100,0
@m68kus~1_19:
       dc.b      13,10,69,110,116,101,114,32,52,32,119,111,114
       dc.b      100,115,32,40,50,32,98,121,116,101,115,41,32
       dc.b      111,102,32,72,101,120,105,100,101,99,105,109
       dc.b      97,108,32,116,101,115,116,32,100,97,116,97,46
       dc.b      0
@m68kus~1_20:
       dc.b      13,10,69,110,116,101,114,32,70,105,114,115,116
       dc.b      32,119,111,114,100,58,32,0
@m68kus~1_21:
       dc.b      69,110,116,101,114,32,83,101,99,111,110,100
       dc.b      32,119,111,114,100,58,32,0
@m68kus~1_22:
       dc.b      69,110,116,101,114,32,84,104,105,114,100,32
       dc.b      119,111,114,100,58,32,0
@m68kus~1_23:
       dc.b      69,110,116,101,114,32,70,111,117,114,116,104
       dc.b      32,119,111,114,100,58,32,0
@m68kus~1_24:
       dc.b      86,97,108,105,100,32,97,100,100,114,101,115
       dc.b      115,101,115,32,102,111,114,32,116,104,105,115
       dc.b      32,112,114,111,103,114,97,109,32,97,114,101
       dc.b      58,32,36,48,57,48,48,32,48,48,48,48,32,45,32
       dc.b      36,48,57,55,70,32,70,70,70,70,0
@m68kus~1_25:
       dc.b      13,10,70,111,114,32,116,104,105,115,32,116,101
       dc.b      115,116,44,32,116,104,101,32,115,116,97,114
       dc.b      116,32,97,110,100,32,101,110,100,32,97,100,100
       dc.b      114,101,115,115,101,115,32,109,117,115,116,32
       dc.b      97,108,105,103,110,32,116,111,32,97,110,32,101
       dc.b      118,101,110,32,97,100,100,114,101,115,115,0
@m68kus~1_26:
       dc.b      69,82,82,79,82,46,32,80,108,101,97,115,101,32
       dc.b      69,110,116,101,114,32,97,32,118,97,108,105,100
       dc.b      32,69,110,100,32,65,100,100,114,101,115,115
       dc.b      58,32,0
@m68kus~1_27:
       dc.b      69,82,82,79,82,46,32,80,108,101,97,115,101,32
       dc.b      101,110,116,101,114,32,97,110,32,69,110,100
       dc.b      32,65,100,100,114,101,115,115,32,108,97,114
       dc.b      103,101,114,32,116,104,97,110,32,116,104,101
       dc.b      32,83,116,97,114,116,32,65,100,100,114,101,115
       dc.b      115,0
@m68kus~1_28:
       dc.b      13,10,65,100,100,114,101,115,115,101,115,32
       dc.b      36,37,48,56,88,32,45,32,36,37,48,56,88,32,98
       dc.b      101,105,110,103,32,102,105,108,108,101,100,32
       dc.b      119,105,116,104,32,36,37,48,52,88,0
@m68kus~1_29:
       dc.b      13,10,86,97,108,117,101,115,32,36,37,48,50,88
       dc.b      32,36,37,48,50,88,32,102,111,117,110,100,32
       dc.b      97,116,32,97,100,100,114,101,115,115,101,115
       dc.b      32,36,37,48,56,88,32,45,32,36,37,48,56,88,0
@m68kus~1_30:
       dc.b      13,10,69,110,116,101,114,32,52,32,108,111,110
       dc.b      103,32,119,111,114,100,115,32,40,52,32,98,121
       dc.b      116,101,115,41,32,111,102,32,72,101,120,105
       dc.b      100,101,99,105,109,97,108,32,116,101,115,116
       dc.b      32,100,97,116,97,46,0
@m68kus~1_31:
       dc.b      13,10,69,110,116,101,114,32,70,105,114,115,116
       dc.b      32,108,111,110,103,32,119,111,114,100,58,32
       dc.b      0
@m68kus~1_32:
       dc.b      69,110,116,101,114,32,83,101,99,111,110,100
       dc.b      32,108,111,110,103,32,119,111,114,100,58,32
       dc.b      0
@m68kus~1_33:
       dc.b      69,110,116,101,114,32,84,104,105,114,100,32
       dc.b      108,111,110,103,32,119,111,114,100,58,32,0
@m68kus~1_34:
       dc.b      69,110,116,101,114,32,70,111,117,114,116,104
       dc.b      32,108,111,110,103,32,119,111,114,100,58,32
       dc.b      0
@m68kus~1_35:
       dc.b      13,10,65,100,100,114,101,115,115,101,115,32
       dc.b      36,37,48,56,88,32,45,32,36,37,48,56,88,32,98
       dc.b      101,105,110,103,32,102,105,108,108,101,100,32
       dc.b      119,105,116,104,32,36,37,48,56,88,0
@m68kus~1_36:
       dc.b      13,10,86,97,108,117,101,115,32,36,37,48,50,88
       dc.b      32,36,37,48,50,88,32,36,37,48,50,88,32,36,37
       dc.b      48,50,88,32,102,111,117,110,100,32,97,116,32
       dc.b      97,100,100,114,101,115,115,101,115,32,36,37
       dc.b      48,56,88,32,45,32,36,37,48,56,88,0
@m68kus~1_37:
       dc.b      13,10,37,120,0
@m68kus~1_38:
       dc.b      13,10,66,108,111,99,107,32,105,115,32,115,101
       dc.b      116,32,116,111,32,48,0
@m68kus~1_39:
       dc.b      13,10,66,108,111,99,107,32,105,115,32,115,101
       dc.b      116,32,116,111,32,49,0
@m68kus~1_40:
       dc.b      13,10,83,101,110,100,105,110,103,32,83,116,97
       dc.b      114,116,32,67,111,109,109,97,110,100,46,46,46
       dc.b      0
@m68kus~1_41:
       dc.b      13,10,67,111,110,116,114,111,108,32,82,101,103
       dc.b      105,115,116,101,114,32,105,115,32,37,120,0
@m68kus~1_42:
       dc.b      13,10,83,116,97,114,116,32,67,111,109,109,97
       dc.b      110,100,32,82,101,99,101,105,118,101,100,0
@m68kus~1_43:
       dc.b      13,10,84,114,97,110,115,109,105,116,47,114,101
       dc.b      99,101,105,118,101,32,98,101,102,111,114,101
       dc.b      58,32,37,120,0
@m68kus~1_44:
       dc.b      13,10,84,114,97,110,115,109,105,116,47,114,101
       dc.b      99,101,105,118,101,32,97,102,116,101,114,58
       dc.b      32,37,120,0
@m68kus~1_45:
       dc.b      13,10,83,101,110,100,105,110,103,32,97,100,100
       dc.b      114,101,115,115,0
@m68kus~1_46:
       dc.b      13,10,72,105,103,104,32,98,121,116,101,32,97
       dc.b      100,100,114,101,115,115,32,115,101,110,116,0
@m68kus~1_47:
       dc.b      13,10,76,111,119,32,98,121,116,101,32,97,100
       dc.b      100,114,101,115,115,32,115,101,110,116,0
@m68kus~1_48:
       dc.b      13,10,68,97,116,97,32,87,114,105,116,101,110
       dc.b      0
@m68kus~1_49:
       dc.b      13,10,68,65,84,65,32,82,69,65,68,32,73,83,58
       dc.b      32,37,48,50,88,0
@m68kus~1_50:
       dc.b      13,10,66,108,111,99,107,32,83,101,108,58,32
       dc.b      37,88,0
@m68kus~1_51:
       dc.b      13,10,65,100,100,114,101,115,115,32,72,105,103
       dc.b      104,58,32,37,88,0
@m68kus~1_52:
       dc.b      13,10,65,100,100,114,101,115,115,32,76,111,119
       dc.b      58,32,37,88,0
@m68kus~1_53:
       dc.b      13,10,73,73,67,32,112,114,111,103,114,97,109
       dc.b      32,119,105,108,108,32,98,101,103,105,110,0
@m68kus~1_54:
       dc.b      13,10,69,110,116,101,114,32,48,32,46,46,46,32
       dc.b      87,114,105,116,101,32,83,105,110,103,108,101
       dc.b      32,66,121,116,101,13,10,69,110,116,101,114,32
       dc.b      49,32,46,46,46,32,82,101,97,100,32,83,105,110
       dc.b      103,108,101,32,66,121,116,101,13,10,69,110,116
       dc.b      101,114,32,50,32,46,46,46,32,87,114,105,116
       dc.b      101,32,68,97,116,97,32,66,108,111,99,107,13
       dc.b      10,69,110,116,101,114,32,51,32,46,46,46,32,82
       dc.b      101,97,100,32,68,97,116,97,32,66,108,111,99
       dc.b      107,13,10,0
@m68kus~1_55:
       dc.b      37,99,0
@m68kus~1_56:
       dc.b      83,105,110,103,108,101,32,66,121,116,101,32
       dc.b      87,114,105,116,101,32,73,110,105,116,105,97
       dc.b      116,101,100,13,10,69,110,116,101,114,32,68,97
       dc.b      116,97,32,66,121,116,101,58,32,0
@m68kus~1_57:
       dc.b      69,110,116,101,114,32,86,97,108,105,100,32,68
       dc.b      97,116,97,32,66,121,116,101,58,32,0
@m68kus~1_58:
       dc.b      69,110,116,101,114,32,65,100,100,114,101,115
       dc.b      115,32,40,48,48,48,48,48,32,45,32,49,70,70,70
       dc.b      70,41,58,32,0
@m68kus~1_59:
       dc.b      69,110,116,101,114,32,86,97,108,105,100,32,65
       dc.b      100,100,114,101,115,115,58,32,0
@m68kus~1_60:
       dc.b      13,10,87,114,105,116,105,110,103,32,68,97,116
       dc.b      97,32,66,121,116,101,32,46,46,46,0
@m68kus~1_61:
       dc.b      13,10,83,105,110,103,108,101,32,66,121,116,101
       dc.b      32,82,101,97,100,32,73,110,105,116,105,97,116
       dc.b      101,100,13,10,69,110,116,101,114,32,65,100,100
       dc.b      114,101,115,115,32,40,48,48,48,48,48,32,45,32
       dc.b      49,70,70,70,70,41,58,32,0
@m68kus~1_62:
       dc.b      13,10,82,101,97,100,105,110,103,32,68,97,116
       dc.b      97,32,66,121,116,101,32,46,46,46,0
@m68kus~1_63:
       dc.b      13,10,68,97,116,97,32,66,108,111,99,107,32,87
       dc.b      114,105,116,101,32,73,110,105,116,105,97,116
       dc.b      101,100,13,10,69,110,116,101,114,32,83,116,97
       dc.b      114,116,105,110,103,32,65,100,100,114,101,115
       dc.b      115,32,40,48,48,48,48,48,32,45,32,49,70,70,70
       dc.b      70,41,58,32,0
@m68kus~1_64:
       dc.b      69,110,116,101,114,32,68,97,116,97,32,66,108
       dc.b      111,99,107,32,83,105,122,101,32,40,48,48,48
       dc.b      48,48,32,45,32,37,48,53,88,41,58,32,0
@m68kus~1_65:
       dc.b      69,110,116,101,114,32,86,97,108,105,100,32,66
       dc.b      108,111,99,107,32,83,105,122,101,32,40,48,48
       dc.b      48,48,48,32,45,32,37,48,53,88,41,58,32,0
@m68kus~1_66:
       dc.b      69,110,116,101,114,32,83,116,97,114,116,105
       dc.b      110,103,32,68,97,116,97,32,66,121,116,101,58
       dc.b      32,0
@m68kus~1_67:
       dc.b      13,10,68,97,116,97,32,66,108,111,99,107,32,82
       dc.b      101,97,100,32,73,110,105,116,105,97,116,101
       dc.b      100,13,10,69,110,116,101,114,32,83,116,97,114
       dc.b      116,105,110,103,32,65,100,100,114,101,115,115
       dc.b      32,40,48,48,48,48,48,32,45,32,49,70,70,70,70
       dc.b      41,58,32,0
@m68kus~1_68:
       dc.b      69,110,116,101,114,32,86,97,108,105,100,32,65
       dc.b      100,100,114,101,115,115,0
@m68kus~1_69:
       dc.b      13,10,80,114,111,103,114,97,109,32,101,110,100
       dc.b      101,100,0
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
       xref      LDIV
       xref      _scanf
       xref      ULDIV
       xref      _printf
