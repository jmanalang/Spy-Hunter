extern int lab7(void);	
extern int uart_init(void);
extern int pin_connect_block_setup_for_uart0(void);

int main (void)
{
	pin_connect_block_setup_for_uart0();
	uart_init();
  lab7();
}
