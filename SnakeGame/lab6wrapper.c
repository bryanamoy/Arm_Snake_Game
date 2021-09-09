#include <stdint.h>

extern int lab6(void);
extern void UART0Handler(void);
extern void Timer0Handler(void);
//extern void PortAHandler(void);

int main(void)
{
    lab6();
}
