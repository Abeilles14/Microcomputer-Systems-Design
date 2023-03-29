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
** IIC Controller registers
**************************************************************/
//IIC Registers
#define IIC_Prescale_Low            (*(volatile unsigned char *)(0x00408000))
#define IIC_Prescale_High           (*(volatile unsigned char *)(0x00408002))
#define IIC_Control                 (*(volatile unsigned char *)(0x00408004))
#define IIC_Transmit_Receive        (*(volatile unsigned char *)(0x00408006))
#define IIC_Command_Status          (*(volatile unsigned char *)(0x00408008))

// I2C Commands
#define WRITE 0x10
#define START 0x91
#define ACK 0x21

/*********************************************************************************************************************************
(( DO NOT initialise global variables here, do it main even if you want 0
(( it's a limitation of the compiler
(( YOU HAVE BEEN WARNED
*********************************************************************************************************************************/

unsigned int i, x, y, z, PortA_Count;
unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;

/*******************************************************************************************
** Function Prototypes
*******************************************************************************************/
void Wait1ms(void);
void Wait3ms(void);
void Wait500ms(void);
void Wait1s(void);
void SendI2C(char byte, char cmd);
void DAC_Blinky(void);
void WaitForAck(void);
void ReadADC(void);

void Init_LCD(void) ;
void LCDOutchar(int c);
void LCDOutMess(char *theMessage);
void LCDClearln(void);
void LCDline1Message(char *theMessage);
void LCDline2Message(char *theMessage);
int sprintf(char *out, const char *format, ...) ;

/*****************************************************************************************
**	Interrupt service routine for Timers
**
**  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
**  out which timer is producing the interrupt
**
*****************************************************************************************/

void Timer_ISR()
{
   	if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
   	    Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    //PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
   	}

  	if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
   	    Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    //PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
   	}

   	if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
   	    Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        //HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
   	}

   	if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
   	    Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        //HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
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
    int  i ;
    for(i = 0; i < 1000; i ++)
        ;
}

/************************************************************************************
**  Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i ;
    for(i = 0; i < 3; i++)
        Wait1ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
**  Sets it for parallel port and 2 line display mode (if I recall correctly)
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = 0x0c ;
    Wait3ms() ;
    LCDcommand = 0x38 ;
    Wait3ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
    RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
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

int _putch( int c)
{
    while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
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
int _getch( void )
{
    char c ;
    while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
}

/******************************************************************************
**  Subroutine to output a single character to the 2 row LCD display
**  It is assumed the character is an ASCII code and it will be displayed at the
**  current cursor position
*******************************************************************************/
void LCDOutchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms() ;
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void LCDOutMessage(char *theMessage)
{
    char c ;
    while((c = *theMessage++) != 0)     // output characters from the string until NULL
        LCDOutchar(c) ;
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void LCDClearln(void)
{
    int i ;
    for(i = 0; i < 24; i ++)
        LCDOutchar(' ') ;       // write a space char to the LCD display
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 1 and clear that line
*******************************************************************************/
void LCDLine1Message(char *theMessage)
{
    LCDcommand = 0x80 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0x80 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 2 and clear that line
*******************************************************************************/
void LCDLine2Message(char *theMessage)
{
    LCDcommand = 0xC0 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0xC0 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/*********************************************************************************************************************************
**  IMPORTANT FUNCTION
**  This function install an exception handler so you can capture and deal with any 68000 exception in your program
**  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
**  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
**  Calling this function allows you to deal with Interrupts for example
***********************************************************************************************************************************/

void InstallExceptionHandler( void (*function_ptr)(), int level)
{
    volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
}

char xtod(int c)
{
    if ((char)(c) <= (char)('9'))
        return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
    else if((char)(c) > (char)('F'))    // assume lower case
        return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
    else
        return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
}

int Get2HexDigits(char *CheckSumPtr)
{
    register int i = (xtod(_getch()) << 4) | (xtod(_getch()));

    if(CheckSumPtr)
        *CheckSumPtr += i ;

    return i ;
}

int Get4HexDigits(char *CheckSumPtr)
{
    return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get6HexDigits(char *CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get8HexDigits(char *CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
}

/**************************************************************************************************
*Memory Test Functions
***************************************************************************************************/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//byte_func//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void byte_func(void){
    char  *Start, *End ;
    char *Start_temp, *End_temp;
    int *Start_hold, *End_hold;
    unsigned char filldata = 0xAA;
    unsigned char tempdata;
    unsigned char readval;
    //unsigned char bytedata1, bytedata2, bytedata3, bytedata4;
    int bytedata1, bytedata2, bytedata3, bytedata4;
    int count = 0;
    int count2 = 0;
    int j;
    char choice;


    printf("\r\nEnter 4 bytes of Hexidecimal test data.");

    printf("\r\nEnter First byte: ");
    scanf("%x", &bytedata1) ;
    //bytedata1 = Get2HexDigits(0) ;
    //printf("\r\n%X",bytedata1);

    printf("Enter Second byte: ");
    scanf("%x", &bytedata2) ;
    //printf("\r\n%X",bytedata2);
    //bytedata2 = Get2HexDigits(0) ;

    printf("Enter Third byte: ");
    scanf("%x", &bytedata3) ;
    //bytedata3 = Get2HexDigits(0) ;

    printf("Enter Fourth byte: ");
    scanf("%x", &bytedata4) ;
    //bytedata4 = Get2HexDigits(0) ;

    printf("Valid addresses for this program are: $0900 0000  - $097F FFFF");

    printf("\r\nEnter Start Address: ") ;
    scanf("%x", &Start_hold) ;
    //Start_hold = Get8HexDigits(0) ;
    printf("Enter End Address: ") ;
    scanf("%x", &End_hold) ;
    //End_hold = Get8HexDigits(0) ;

    while ((Start_hold < 0x09000000) || (Start_hold > 0x097FFFFF)){
        printf("ERROR. Please Enter a valid Start Address: ");
        scanf("%x", &Start_hold) ;
        //Start_hold = Get8HexDigits(0) ;
    }
    while ((End_hold < 0x09000000) || (End_hold > 0x097FFFFF)){
        printf("\r\nERROR. Please Enter a valid End Address: ");
        scanf("%x", &End_hold) ;
        //End_hold = Get8HexDigits(0) ;
    }
    while (End_hold <= Start_hold){
        printf("\r\nERROR. Please enter an End Address larger than the Start Address");
        //printf("\r\nEnter Start Address: ") ;
        //Start_hold = Get8HexDigits(0) ;
        printf("\r\nEnter End Address: ") ;
        scanf("%x", &End_hold) ;
        //End_hold = Get8HexDigits(0) ;
    }

    Start = Start_hold;
    End = End_hold;
    Start_temp = Start_hold;
    End_temp = End_hold;

    printf("\r\nFilling Addresses [$%08X - $%08X] with test data", Start, End);

    while (Start <= End){
        if ((count == 0) || ((count % 4))==0 ){
            *Start = bytedata1;
            if ((count == 0) || ((count % 1000)==0)){
                printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata1);
            }
            Start++;
        }
        else if ((count == 1) || (((count - 1)%4)==0)){
            *Start = bytedata2;
            if ((count == 1) || (((count - 1) % 1000)==0)){
                printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata2);
            }
            Start++;
        }
        else if ((count == 2) || (((count - 2)%4)==0)){
            *Start = bytedata3;
            if ((count == 2) || (((count - 2) % 1000)==0)){
                printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata3);
            }
            Start++;
        }
        else if ((count == 3) || (((count - 3)%4)==0)){
            *Start = bytedata4;
            if ((count == 3) || (((count - 3) % 1000)==0)){
                printf("\r\nAddress $%08X being filled with $%02X", Start, bytedata4);
            }
            Start++;
        }
        else {
            *Start++ = filldata;
        }
  //      if ((count == 0) || ((count % 1000)==0)){
     //       printf("\r\nAdress $%08X being filled with $%02X", Start, readval);
        //}
        count++;
    }

    printf("\r\nWriting to memory Complete.\r\nEnter '1' to read back the memory. Enter '0' to exit program.");
    choice = _getch();
    if (choice == '1'){
       // printf("\r\nwill continue");
        while (Start_temp <= End_temp){
            tempdata = *Start_temp;
            if ((count2 == 0) || (count2 % 1000)==0){
                printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
            }
            else if ((count2 == 1) || ((count2 - 1) % 1000)==0){
                printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
            }
            else if ((count2 == 2) || ((count2 - 2) % 1000)==0){
                printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
            }
            else if ((count2 == 3) || ((count2 - 3) % 1000)==0){
                printf("\r\n$%02X Read from address $%08X", tempdata, Start_temp);
            }
            count2++;
            *Start_temp++;
        }
    }
    else if (choice == '0'){
        printf("\r\nProgram Ended");
    }


}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//word_func//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void word_func(void){
    int worddata1, worddata2, worddata3, worddata4;
    int tempdata;
    int *Start_hold, *End_hold;
    short *Start, *End;
    short *Start_temp, *End_temp;
    unsigned char data, data2;
    int count1 = 0;
    int count2 = 0;
    char choice;


    printf("\r\nEnter 4 words (2 bytes) of Hexidecimal test data.");
    printf("\r\nEnter First word: ");
    scanf("%x", &worddata1) ;
    //worddata1 = Get4HexDigits(0) ;

    printf("Enter Second word: ");
    scanf("%x", &worddata2) ;
    //worddata2 = Get4HexDigits(0) ;

    printf("Enter Third word: ");
    scanf("%x", &worddata3) ;
    //worddata3 = Get4HexDigits(0) ;

    printf("Enter Fourth word: ");
    scanf("%x", &worddata4) ;
    //worddata4 = Get4HexDigits(0) ;

    printf("Valid addresses for this program are: $0900 0000 - $097F FFFF");
    printf("\r\nFor this test, the start and end addresses must align to an even address");

    printf("\r\nEnter Start Address: ") ;
    scanf("%x", &Start_hold) ;
    //Start_hold = Get8HexDigits(0) ;

    printf("Enter End Address: ") ;
    scanf("%x", &End_hold) ;
    //End_hold = Get8HexDigits(0) ;

    while ((Start_hold < 0x09000000) || (Start_hold > 0x097FFFFF) || ((Start_hold % 2) != 0)){
        printf("ERROR. Please Enter a valid Start Address: ");
        scanf("%x", &Start_hold) ;
        //Start_hold = Get8HexDigits(0) ;
    }
    while ((End_hold < 0x09000000) || (End_hold > 0x097FFFFF) || ((End_hold % 2) != 0)){
        printf("ERROR. Please Enter a valid End Address: ");
        scanf("%x", &End_hold) ;
        //End_hold = Get8HexDigits(0) ;
    }
    while (End_hold <= Start_hold){
        printf("ERROR. Please enter an End Address larger than the Start Address");
        //printf("\r\nEnter Start Address: ") ;
        //Start_hold = Get8HexDigits(0) ;
        printf("\r\nEnter End Address: ") ;
        scanf("%x", &End_hold) ;
        //End_hold = Get8HexDigits(0) ;
    }

    Start = Start_hold;
    End = End_hold;
    Start_temp = Start_hold;
    End_temp = End_hold;

    while (Start < End){
        if ((count1 == 0) || ((count1 % 4)) ==0 ){
            *Start = worddata1;
            if ((count1 == 0) || ((count1 % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata1);
            }
            Start++;
        }
        if ((count1 == 1) || (((count1 - 1) % 4)) ==0 ){
            *Start = worddata2;
            if ((count1 == 1) || (((count1 -1) % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata2);
            }
            Start++;
        }
        if ((count1 == 2) || (((count1 - 2) % 4)) ==0 ){
            *Start = worddata3;
            if ((count1 == 2) || (((count1 -2) % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata3);
            }
            Start++;
        }
        if ((count1 == 3) || (((count1 - 3) % 4)) ==0 ){
            *Start = worddata4;
            if ((count1 == 3) || (((count1 - 3) % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%04X", Start, (Start | 0x0001), worddata4);
            }
            Start++;
        }
        count1++;
    }

    printf("\r\nWriting to memory Complete.\r\nEnter '1' to read back the memory. Enter '0' to exit program.");
    choice = _getch();

    if (choice == '1'){
        //printf("\r\nwill continue");
        while (Start_temp < End_temp){
            data = (*Start_temp >> 8) & 0xFF;
            data2 = *Start_temp & 0xFF;
            if ((count2 == 0) || (count2 % 1000)==0){
                printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
                //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
            }
            else if ((count2 == 1) || ((count2 - 1) % 1000)==0){
                printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
                //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
            }
            else if ((count2 == 2) || ((count2 - 2) % 1000)==0){
                printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
                //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
            }
            else if ((count2 == 3) || ((count2 - 3) % 1000)==0){
                printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_temp, (Start_temp | 0x0001));
                //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
            }
            count2++;
            *Start_temp++;
        }
    }
    else if (choice == '0'){
        printf("\r\nProgram Ended");
    }

    /*
    *Start = 0xAAAA;
    printf("\r\n%04X", *Start);
  //  data = *Start;
    //data2 =*(Start + 0x00000001);
    data = (*Start >> 8) & 0xFF;
    data2 = *Start & 0xFF;
    printf("\r\nValue $%02X $%02X found at address $%08X - $%08X", data, data2, Start, (Start + (0x000F && Start)));
    printf("\r\nValue $%02X $%02X found at address $%08X - $%08X", data, data2, Start, (Start + 1));
    printf("\r\nValue $%02X $%02X found at address $%08X - $%08X", data, data2, Start, (Start | 0x0001));
    */


}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//LongWord_func//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


void longword_func(void){
    unsigned char data1a, data1b, data2a, data2b, data3a, data3b, data4a, data4b;
    int lworddata1, lworddata2, lworddata3, lworddata4;
    int *Start_hold, *End_hold;
    int *Start, *End;
    int *idk;
    short test, test1;
    int count3, count4;
    int count1 = 0;
    int count2 = 0;
    unsigned char add1, add2;
    short add3;
    char choice;


    printf("\r\nEnter 4 long words (4 bytes) of Hexidecimal test data.");
    printf("\r\nEnter First long word: ");
    scanf("%x", &lworddata1) ;
    //lworddata1 = Get8HexDigits(0) ;
    //data1a = lworddata1 & 0xFFFF;
    //data1b = (lworddata1 >> 16) & 0xFFFF;

    printf("Enter Second long word: ");
    scanf("%x", &lworddata2) ;
    //lworddata2 = Get8HexDigits(0) ;

    printf("Enter Third long word: ");
    scanf("%x", &lworddata3) ;
    //lworddata3 = Get8HexDigits(0) ;

    printf("Enter Fourth long word: ");
    scanf("%x", &lworddata4) ;
    //lworddata4 = Get8HexDigits(0) ;


   // printf("\r\n%04x   %04x", data1a, data1b);

    printf("Valid addresses for this program are: $0900 0000 - $097F FFFF");
    printf("\r\nFor this test, the start and end addresses must align to an even address");

    printf("\r\nEnter Start Address: ") ;
    scanf("%x", &Start_hold) ;
    //Start_hold = Get8HexDigits(0) ;
    printf("Enter End Address: ") ;
    scanf("%x", &End_hold) ;
    //End_hold = Get8HexDigits(0) ;

    while ((Start_hold < 0x09000000) || (Start_hold > 0x097FFFFF) || ((Start_hold % 2) != 0)){
        printf("ERROR. Please Enter a valid Start Address: ");
        scanf("%x", &Start_hold) ;
        //Start_hold = Get8HexDigits(0) ;
    }
    while ((End_hold < 0x09000000) || (End_hold > 0x097FFFFF) || ((End_hold % 2) != 0)){
        printf("ERROR. Please Enter a valid End Address: ");
        scanf("%x", &End_hold) ;
        //End_hold = Get8HexDigits(0) ;
    }
    while (End_hold <= Start_hold){
        printf("ERROR. Please enter an End Address larger than the Start Address");
        //printf("\r\nEnter Start Address: ") ;
        //Start_hold = Get8HexDigits(0) ;
        printf("\r\nEnter End Address: ") ;
        scanf("%x", &End_hold) ;
        //End_hold = Get8HexDigits(0) ;
    }

    Start = Start_hold;
    End = End_hold;

    while (Start < End){
        if ((count1 == 0) || ((count1 % 4)) ==0 ){
            *Start = lworddata1;
            idk = Start;
            idk = (int *)((char *)idk + 3);
            if ((count1 == 0) || ((count1 % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata1);
            }
            Start++;
        }
        if ((count1 == 1) || (((count1 - 1) % 4)) ==0 ){
            *Start = lworddata2;
            idk = Start;
            idk = (int *)((char *)idk + 3);
            if ((count1 == 1) || (((count1 -1) % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata2);
            }
            Start++;
        }
        if ((count1 == 2) || (((count1 - 2) % 4)) ==0 ){
            *Start = lworddata3;
            idk = Start;
            idk = (int *)((char *)idk + 3);
            if ((count1 == 2) || (((count1 -2) % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata3);
            }
            Start++;
        }
        if ((count1 == 3) || (((count1 - 3) % 4)) ==0 ){
            *Start = lworddata4;
            idk = Start;
            idk = (int *)((char *)idk + 3);
            if ((count1 == 3) || (((count1 - 3) % 1000)==0)){
                printf("\r\nAddresses $%08X - $%08X being filled with $%08X", Start, idk, lworddata4);
            }
            Start++;
        }
        count1++;
    }

    printf("\r\nWriting to memory Complete.\r\nEnter '1' to read back the memory. Enter '0' to exit program.");
    choice = _getch();

    if (choice == '1'){
        //printf("\r\nwill continue");
        while (Start_hold < End_hold){
            data1a = (*Start_hold >> 8) & 0xFF;
            data1b = *Start_hold & 0xFF;
            data2a = (*Start_hold >> 24) & 0xFF;
            data2b = (*Start_hold >> 16) & 0xFF;
            idk = Start_hold;
            idk = (int *)((char *)idk + 3);
            //data = (*Start_hold >> 8) & 0xFF;
            //data2 = *Start_hold & 0xFF;
            if ((count2 == 0) || (count2 % 1000)==0){
                printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
                //printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_hold, (Start_hold | 0x0001));
                //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
            }
            else if ((count2 == 1) || ((count2 - 1) % 1000)==0){
                printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
                //printf("\r\nValues $%02X $%02X found at addresses $%08X - $%08X", data, data2, Start_hold, (Start_hold | 0x0001));
                //printf("\r\n$%02X Read from address $%08X", tempdata, Start_hold);
            }
            else if ((count2 == 2) || ((count2 - 2) % 1000)==0){
                printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
            }
            else if ((count2 == 3) || ((count2 - 3) % 1000)==0){
                printf("\r\nValues $%02X $%02X $%02X $%02X found at addresses $%08X - $%08X", data2a, data2b, data1a, data1b, Start_hold, idk);
            }
            count2++;
            *Start_hold++;
        }
    }
    else if (choice == '0'){
        printf("\r\nProgram Ended");
    }
}

//////////////////////////////////////////////////////////
//******IIC Program Functions Begin Here***************///
//////////////////////////////////////////////////////////

void IIC_Init(void)
{

    IIC_Prescale_Low = 0x31; //31
    //IIC_Prescale_Low = 0x63;
    IIC_Prescale_High = 0x00; //0xFF for reset

    IIC_Control = 0x80; // core enabled, interupts disabled
    //IIC_Control = 0xC0;

    //IIC_Transmit_Receive = 0x00;
    //IIC_Command_Status = 0x00;
    printf("\r\n%x",IIC_Command_Status);

}

void PollTIPFlag(void){
    char status;

    status = IIC_Command_Status;
    //Check that TIP flag is negated
    while ((status & 0x02) != 0){
        1;
        //printf("%x",status);
        //printf("TIP ");
    }
}

void Delay(void){
    int i;
    int counter = 0;

    for (i = 0; i < 2000; i++){
        counter = counter + 1;
    }
}

void IIC_StartCommand(int block_sel){
    char dog;
    int cat*;
    int slave_addr = 0x00;

    if (block_sel == 0){
        //printf("\r\nBlock is set to 0");
        slave_addr = 0xA0;
    }
    else if (block_sel == 1){
        //printf("\r\nBlock is set to 1");
        slave_addr = 0xA2;
    }
    //printf("\r\nSending Start Command...");
    //printf("\r\nControl Register is %x", IIC_Control);
    //Check that no transmit is in progress
    //IIC_Command_Status = 0x80;
    //PollTIPFlag();
    dog = IIC_Command_Status;
    //printf("\r\n%x", dog);

    IIC_Transmit_Receive = slave_addr; //Slave Adress and write bit
    //IIC_Command_Status = 0x10; //Set STA and WR bit
    //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
    Delay();
    IIC_Command_Status = 0x90; //set WR bit
    Delay();
    //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);

    dog = IIC_Command_Status;
    //printf("\r\n%x", dog);
    //Wait for transmit to complete
    PollTIPFlag();

    WaitForAck();
    //printf("\r\nStart Command Received");
}

void IIC_RepeatedStartCommand(int block_sel){
    int slave_addr = 0x00;

    if (block_sel == 0){
        //printf("\r\nBlock is set to 0");
        slave_addr = 0xA1;
    }
    else if (block_sel == 1){
        //printf("\r\nBlock is set to 1");
        slave_addr = 0xA3;
    }

    //printf("\r\nSending Start Command...");
    //printf("\r\nControl Register is %x", IIC_Control);
    //Check that no transmit is in progress
    //IIC_Command_Status = 0x80;
    //PollTIPFlag();

    IIC_Transmit_Receive = slave_addr; //Slave Adress and write bit
    //IIC_Command_Status = 0x10; //Set STA and WR bit
    //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
    Delay();
    IIC_Command_Status = 0x90; //
    Delay();
    //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);


    //Wait for transmit to complete
    PollTIPFlag();

    WaitForAck();
    //printf("\r\nStart Command Received");
}

void IIC_SendAddress(int address_high, int address_low){

    //printf("\r\nSending address");

    //IIC_Command_Status = 0x10;
    IIC_Transmit_Receive = address_high; //High byte internal address

    //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
    Delay();
    IIC_Command_Status = 0x10; //set WR bit
    Delay();
    //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);

    //Wait for transmit to complete
    PollTIPFlag();

    WaitForAck();
    //printf("\r\nHigh byte address sent");


    //IIC_Command_Status = 0x10;
    IIC_Transmit_Receive = address_low; //Low byte internal address
    PollTIPFlag();
    //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
    Delay();
    IIC_Command_Status = 0x10; //set WR bit
    Delay();
    //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);

    //Wait for transmit to complete
    PollTIPFlag();

    WaitForAck();
    //printf("\r\nLow byte address sent");
}

void IIC_WriteData(int data){

    //IIC_Command_Status = 0x10;

    IIC_Transmit_Receive = data; //High byte internal address

    //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
    Delay();
    IIC_Command_Status = 0x10; //set WR bit
    Delay();
    //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);

    //Wait for transmit to complete
    PollTIPFlag();

    WaitForAck();

    IIC_Command_Status = 0x40; //Set STO bit
    PollTIPFlag();

    //printf("\r\nData Writen");
}

void IIC_PageWrite(int data, int numbytes, int address){
    int i = 0x00;
    int j = 0x00;
    int count = 0;

    //printf("\r\nData Written To Memory");
    while (j < numbytes){
        if ((data + i) > 0xFF){
            data = 0x00;
            i = 0x00;
        }
        IIC_Transmit_Receive = (data + i);
        // printf(".");
        // IIC_Command_Status = 0x10; //set WR bit
        // printf(".");
        if ((count == 0) || ((count % 16) == 0)){
            printf("\r\nAddress %05X: ", (address + count));
        }
        printf("%02X ", (data + i));
        //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
        Delay();
        IIC_Command_Status = 0x10; //set WR bit
        Delay();
        //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);

        //Wait for transmit to complete
        PollTIPFlag();
        WaitForAck();
        i += 1;
        count = count + 1;
        j += 1;
    }

    IIC_Command_Status = 0x40; //Set STO bit
    PollTIPFlag();
}

void IIC_ReadData(void){
    int recieved;

    //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
    Delay();
    IIC_Command_Status = 0x20; //set R bit
    Delay();
    //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
    PollTIPFlag();

    printf("\r\n");
    while ((IIC_Command_Status & 0x01) != 1){
        1;
    }
    //IIC_Command_Status &= 0xFE;

    recieved = IIC_Transmit_Receive;

    printf("DATA READ IS %02X ", recieved);

    //IIC_Command_Status |= 0x48; //set STO bit, ACK bit
    IIC_Command_Status = 0x48;

    recieved = IIC_Transmit_Receive;
}

void IIC_SequentialRead(int blocksize, int address){
    int received;
    int i = 0;
    int count = 0;

    //printf("\r\n");
    while (i < blocksize){
        //printf("\r\nTransmit/receive before: %x", IIC_Transmit_Receive);
        Delay();
        IIC_Command_Status = 0x20; //set R bit
        Delay();
        //printf("\r\nTransmit/receive after: %x", IIC_Transmit_Receive);
        PollTIPFlag();

        while ((IIC_Command_Status & 0x01) != 1){
            1;
        }
        //IIC_Command_Status &= 0xFE;

        received = IIC_Transmit_Receive;

        if ((count == 0) || ((count % 16) == 0)){
            printf("\r\nAddress %05X: ", address);
        }
        printf("%02X ", received);

        count += 1;
        i += 1;
        address = address + 1;
    }

    //IIC_Command_Status |= 0x48; //set STO bit, ACK bit
    IIC_Command_Status = 0x48;
    PollTIPFlag();
}

int CheckAck(void){
    int val;
    char test;

    test = IIC_Command_Status;

    val = (test & 0x80);

    if (val == 0){
        return 0;
    }
    else{
        return 1;
    }
}

void WaitForAck(void){

    while (CheckAck() == 1){
        1;
    }
}

void IIC_WriteDataByte(int data, int address){
    int block_sel = (address >> 16) & 0xF;  // extract most significant byte
    int address_high = (address >> 8) & 0xFF;  // extract high byte
    int address_low = address & 0xFF;  // extract low byte


    //Send start command
    IIC_StartCommand(block_sel);

    IIC_SendAddress(address_high, address_low);

    IIC_WriteData(data);

}

void IIC_ReadDataByte(int address){
    int block_sel = (address >> 16) & 0xF;  // extract most significant byte
    int address_high = (address >> 8) & 0xFF;  // extract high byte
    int address_low = address & 0xFF;  // extract low byte


    //Send start command
    IIC_StartCommand(block_sel);

    IIC_SendAddress(address_high, address_low);

    IIC_RepeatedStartCommand(block_sel);

    IIC_ReadData();
}

void IIC_WriteDataBlock(int address, int blocksize, int datastart){
    int block_sel;// = (address >> 16) & 0xF;  // extract most significant byte
    int address_high;// = (address >> 8) & 0xFF;  // extract high byte
    int address_low;// = address & 0xFF;  // extract low byte

    int data = datastart;
    int numbytes = 0;
    int byteswritten = 0;

    int i = 0;

    int memflag = 0;

    int blocksize_temp = blocksize;

    // print the results
    // printf("\r\nBlock Sel: %X", block_sel);
    // printf("\r\nAddress High: %X", address_high);
    // printf("\r\nAddress Low: %X", address_low);

    // //Send start command
    // IIC_StartCommand(block_sel);

    // IIC_SendAddress(address_high, address_low);

    printf("\r\nData Written To Memory");

    while (byteswritten < blocksize_temp){ /////////////////////////////////////maybe just <
        //Send start command
        address = address + numbytes;

        block_sel = (address >> 16) & 0xF;  // extract most significant byte
        address_high = (address >> 8) & 0xFF;  // extract high byte
        address_low = address & 0xFF;  // extract low byte

        if (block_sel == 0){
            if ((address + 128 + 1) > 0x0ffff){
                numbytes = (0x0ffff - address + 1);
                memflag = 1;
                i = 0;
            }
            else if (blocksize > 128){
            numbytes = 128;
            }
            else{
                numbytes = blocksize;
            }
        }
        else {
            if (blocksize > 128){
                numbytes = 128;
            }
            else{
                numbytes = blocksize;
            }
        }

        IIC_StartCommand(block_sel);

        IIC_SendAddress(address_high, address_low);

        byteswritten = byteswritten + numbytes; //95

        //printf("\r\nADDRESS IS %05X", address);
        IIC_PageWrite(data, numbytes, address);
        i = i + numbytes; //95
        //printf("\r\nI VALUE IS %02X", i);
        data = data + numbytes; //5F
        blocksize = blocksize - numbytes; //135
    }
}

void Wait500ms(void)
{
    int i;
    for (i = 0; i < 500; i++){
        Wait1ms();
    }
}

void Wait1s(void)
{
    int i;
    for (i = 0; i < 1000; i++){
        Wait1ms();
    }
}

IIC_ReadDataBlock(int address, int blocksize){
    int block_sel = (address >> 16) & 0xF;  // extract most significant byte
    int address_high = (address >> 8) & 0xFF;  // extract high byte
    int address_low = address & 0xFF;  // extract low byte

    int temp_blocksize;

    //Send start command

    printf("\r\nData Read From Memory");
    if (block_sel == 1){
        IIC_StartCommand(block_sel);

        IIC_SendAddress(address_high, address_low);

        IIC_RepeatedStartCommand(block_sel);

        IIC_SequentialRead(blocksize, address);
    }
    else if (block_sel == 0){
        if ((address + blocksize + 1) > 0x0ffff){
            temp_blocksize = (0xffff - address + 1);
        }
        else{
            temp_blocksize = blocksize;
        }
        IIC_StartCommand(block_sel);

        IIC_SendAddress(address_high, address_low);

        IIC_RepeatedStartCommand(block_sel);

        IIC_SequentialRead(temp_blocksize, address);

        temp_blocksize = blocksize - temp_blocksize;

        IIC_StartCommand(1);

        IIC_SendAddress(0x00, 0x00);

        IIC_RepeatedStartCommand(1);

        IIC_SequentialRead(temp_blocksize, 0x10000);
    }
}

void SendI2C(char byte, char cmd) {
    IIC_Transmit_Receive = byte;
    IIC_Command_Status = cmd;
}

void DAC_Blinky() {
    // Write Address
    printf("\r\nSending Slave Address");
    PollTIPFlag();
    SendI2C(0x90, START);    // ADC/DAC Slave Address at 0x92, Start writing 0x91
    WaitForAck();

    // Set Control
    printf("\r\nSending Control Byte");
    SendI2C(0x40, WRITE);     // DAC Output, Write cmd 0x10
    WaitForAck();

    printf("\r\nLED will pulse ON and OFF at a frequency of 500ms, with a duty cycle of 50%");

    // Continuous data stream w/ Blinky until reset
    while (1) {
        SendI2C(0xFF, WRITE);   // ON
        Wait500ms();
        SendI2C(0x00, WRITE);   // OFF
        Wait500ms();
    }
}

void ReadADC() {
    char ch0, ch1, ch2, ch3;

    while (1) {
        // Write Address
        printf("\r\nSending Slave Address");
        PollTIPFlag();
        SendI2C(0x90, START);    // ADC/DAC Slave Address at 0x92, Start writing 0x91
        WaitForAck();

        // Auto Increment A0
        printf("\r\nAuto Increment A0");
        SendI2C(0x04, WRITE);     // DAC Output, Write cmd 0x10
        WaitForAck();

        // Set Slave Reading Mode
        printf("\r\nSet Slave Reading Mode");
        PollTIPFlag();
        SendI2C(0x91, START);     // DAC Output, Write cmd 0x10
        WaitForAck();

        // Read data and set ACK
        IIC_Command_Status = ACK;

        printf("\r\nWait for Data");
        // wait for data 0
        // disconnected, no jumper
        PollTIPFlag();
        ch0 = IIC_Transmit_Receive;
        IIC_Command_Status = ACK;
        printf("\r\nCH0 Data Received");

        // wait for data 1
        PollTIPFlag();
        ch1 = IIC_Transmit_Receive;
        IIC_Command_Status = ACK;
        printf("\r\nCH1 Data Received");

        // wait for data 2
        PollTIPFlag();
        ch2 = IIC_Transmit_Receive;
        IIC_Command_Status = ACK;
        printf("\r\nCH2 Data Received");

        // wait for data 3
        PollTIPFlag();
        ch3 = IIC_Transmit_Receive;
        printf("\r\nCH3 Data Received");

        IIC_Command_Status = 0x41;

        printf("\r\n............................");
        printf("\r\nExt. Analog Source: Disconnected");
        printf("\r\nPotentiometer: %d", ch3);
        printf("\r\nThermistor: %d", ch1);
        printf("\r\nPhotoresistor: %d", ch2);

        Wait1s();
    }
}



/******************************************************************************************************************************
* Start of user program
******************************************************************************************************************************/

void main()
{
    unsigned int row, i=0, count=0, counter1=1;
    char c, text[150] ;

	int PassFailFlag = 1 ;

    //IIC variables
    char choice = '0';

    int WriteData;
    int WriteAddress;

    int ReadAddress;

    int WriteBlockAddress;
    int WriteBlockSize;
    int WriteBlockMaxSize;
    int WriteBlockDataStart;

    int ReadBlockAddress;
    int ReadBlockMaxSize;
    int ReadBlockSize;

    int num;

    /////Mem Test Variables
    // unsigned int *RamPtr;
    // unsigned int Start, End ;
    // unsigned int data_byte1, data_byte2, data_byte3, data_byte4; //Test data recieved from user (bytes)
    // unsigned int data_word1, data_word2, data_word3, data_word4;
    // unsigned int data_Lword1, data_Lword2, data_Lword3, data_Lword4;
    // char type;
    // int testnum = 1;
    /////Mem Test Variables

    i = x = y = z = PortA_Count =0;
    Timer1Count = Timer2Count = Timer3Count = Timer4Count = 0;

    InstallExceptionHandler(PIA_ISR, 25) ;          // install interrupt handler for PIAs 1 and 2 on level 1 IRQ
    InstallExceptionHandler(ACIA_ISR, 26) ;		    // install interrupt handler for ACIA on level 2 IRQ
    InstallExceptionHandler(Timer_ISR, 27) ;		// install interrupt handler for Timers 1-4 on level 3 IRQ
    InstallExceptionHandler(Key2PressISR, 28) ;	    // install interrupt handler for Key Press 2 on DE1 board for level 4 IRQ
    InstallExceptionHandler(Key1PressISR, 29) ;	    // install interrupt handler for Key Press 1 on DE1 board for level 5 IRQ

    Timer1Data = 0x10;		// program time delay into timers 1-4
    Timer2Data = 0x20;
    Timer3Data = 0x15;
    Timer4Data = 0x25;

    Timer1Control = 3;		// write 3 to control register to Bit0 = 1 (enable interrupt from timers) 1 - 4 and allow them to count Bit 1 = 1
    Timer2Control = 3;
    Timer3Control = 3;
    Timer4Control = 3;

    Init_LCD();             // initialise the LCD display to use a parallel data interface and 2 lines of display
    Init_RS232() ;          // initialise the RS232 port for use with hyper terminal

/*************************************************************************************************
**  User Program
*************************************************************************************************/

    printf("\r\nIIC program will begin");
    printf("\r\nEnter 0 ... Write Single Byte");
    printf("\r\nEnter 1 ... Read Single Byte");
    printf("\r\nEnter 2 ... Write Data Block");
    printf("\r\nEnter 3 ... Read Data Block");
    printf("\r\nEnter 4 ... Waveform DAC and LED Blinky");
    printf("\r\nEnter 5 ... Read Analog input from ADC Channel\r\n");
    scanf("%c", &choice);

    IIC_Init();

    while (1) {

        if (choice == '0') {
            printf("Single Byte Write Initiated\r\nEnter Data Byte: ");
            scanf("%x", &WriteData);
            while (WriteData > 0xFF) {
                printf("Enter Valid Data Byte: ");
                scanf("%x", &WriteData);
            }
            printf("Enter Address (00000 - 1FFFF): ");
            scanf("%x", &WriteAddress);
            while (WriteAddress > 0x1FFFF) {
                printf("Enter Valid Address: ");
                scanf("%x", WriteAddress);
            }
            printf("\r\nWriting Data Byte ...");
            IIC_WriteDataByte(WriteData, WriteAddress);
        }
        else if (choice == '1') {
            printf("\r\nSingle Byte Read Initiated\r\nEnter Address (00000 - 1FFFF): ");
            scanf("%x", &ReadAddress);
            while (ReadAddress > 0x1FFFF) {
                printf("Enter Valid Address: ");
                scanf("%x", &ReadAddress);
            }
            printf("\r\nReading Data Byte ...");
            IIC_ReadDataByte(ReadAddress);
        }
        else if (choice == '2') {
            printf("\r\nData Block Write Initiated\r\nEnter Starting Address (00000 - 1FFFF): ");
            scanf("%x", &WriteBlockAddress);
            while (WriteBlockAddress > 0x1FFFF) {
                printf("Enter Valid Address: ");
                scanf("%x", &WriteBlockAddress);
            }
            WriteBlockMaxSize = (0x1FFFF - WriteBlockAddress);
            printf("Enter Data Block Size (00000 - %d): ", WriteBlockMaxSize);
            scanf("%d", &WriteBlockSize);
            while (WriteBlockSize > WriteBlockMaxSize){
                printf("Enter Valid Block Size (00000 - %d): ", WriteBlockMaxSize);
                scanf("%d", &WriteBlockSize);
            }
            printf("Enter Starting Data Byte: ");
            scanf("%x", &WriteBlockDataStart);
            while (WriteBlockDataStart > 0xFF) {
                printf("Enter Valid Data Byte: ");
                scanf("%x", &WriteBlockDataStart);
            }
            IIC_WriteDataBlock(WriteBlockAddress, WriteBlockSize, WriteBlockDataStart);
        }
        else if (choice == '3') {
            printf("\r\nData Block Read Initiated\r\nEnter Starting Address (00000 - 1FFFF): ");
            scanf("%x", &ReadBlockAddress);
            while (ReadBlockAddress > 0x1FFFF) {
                printf("Enter Valid Address");
                scanf("%x", &ReadBlockAddress);
            }
            ReadBlockMaxSize = (0x1FFFF - ReadBlockAddress);
            printf("Enter Data Block Size (0 - %d): ", ReadBlockMaxSize);
            scanf("%d", &ReadBlockSize);
            while (ReadBlockSize > ReadBlockMaxSize) {
                printf("Enter Valid Block Size (00000 - %d): ", ReadBlockMaxSize);
                scanf("%d", &ReadBlockSize);
            }
            IIC_ReadDataBlock(ReadBlockAddress, ReadBlockSize);

        }
        else if (choice == '4') {
            printf("\r\nWaveform DAC and LED Blinky Initiated\r\n");
            DAC_Blinky();
        }
        else if (choice == '5') {
            printf("\r\nRead Analog input from ADC Channel Initiated");
            ReadADC();
        }
        else {
            printf("\r\nInvalid Selection, Please Select an Option Between 0-5.");
        }
        printf("\r\nProgram ended");
    }

}