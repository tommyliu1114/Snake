#include "init.h"

/*
 *��Ȼ��������ܺķ�ʱ�䣬���Ǽ������Ǻܿ�ͻ���뱣��ģʽ��
 *���ֺ������ò��࣬Ч�ʵ͵���Կ��ǡ�
 */
void fastcall16 bios_put_cha(char cha){
	struct all_regs reg;
	reg.al = cha;
	reg.ah = 0x0e;
	reg.bx = 0x0007;
	intcall(0x13,&reg);
}

void bios_put_str(char *str){
	while(*str++)
		bios_put_cha(*(str - 1));
}
