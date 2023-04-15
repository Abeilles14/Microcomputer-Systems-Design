#ifndef SNAKE_H_
#define SNAKE_H_

#define NUM_VGA_COLUMNS   (80)
#define NUM_VGA_ROWS      (40)
#define BORDER '#'
#define FOOD '@'
#define SNAKE 'S'
#define SPACE ' '
#define INITIAL_SNAKE_SPEED (2)
#define INITIAL_SNAKE_LENGTH (3)
#define SNAKE_SPEED_INCREASE (1)
#define SNAKE_LENGTH_LIMIT (2048)
#define MILLISECONDS_PER_SEC (1000)

typedef struct {
    int x;
    int y;
} coord_t;

typedef enum {north, south, west, east} dir_t;


/*******************************************************************************************
** Function Prototypes
*******************************************************************************************/
void Wait1ms(void);
void Wait3ms(void);
void Init_LCD(void);
void LCDOutchar(int c);
void LCDOutMessage(char* theMessage);
void LCDClearln(void);
void LCDline1Message(char* theMessage);
void LCDline2Message(char* theMessage);

char xtod(int c);
int Get2HexDigits(char* CheckSumPtr);
int Get4HexDigits(char* CheckSumPtr);
int Get6HexDigits(char* CheckSumPtr);
int Get8HexDigits(char* CheckSumPtr);

int kbhit(void);


// Snake game functions

void putcharxy(int x, int y, char ch);
void print_at_xy(int x, int y, const char* str);
void cls();
void gotoxy(int x, int y);
void set_vga_control_reg(char x);
char get_vga_control_reg();
int clock();
void delay_ms(int num_ms);
void gameOver();
void updateScore();
void drawRect(int x, int y, int x2, int y2, char ch);
void initSnake();
void drawSnake();
void drawFood();
void moveSnake();
int mod_bld(int x, int y);
void generateFood();
int getKeypress();
int detectCollision();
void mainloop();
void main();


#endif