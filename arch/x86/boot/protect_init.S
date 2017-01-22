/*
 * protect_init.s
 *
 *  Created on: 2017��1��5��
 *      Author: wangqchf
 */


#include "init.h"

.code16
.section .text

.globl os_main

pro_init_mes:
	.asciz "protect mode initialize..."

location_gdt:
	.word 0x0000
	.long 0x0000

	.globl init;
init:
	movw $0x0200,%dx;		#���ù��λ�ã�3��1��
	xorw %bx,%bx;
	movw $0x0200,%ax;
	int $0x10;

	movw $0x0000,%si;		#��Ӧ��ʹ�û���ַ����Ϊds��Ϊ0x0000
	movw $0x07e0,%ax;		#�������ݶε�ַΪ���ص��ڴ�λ��
	movw %ax,%ds;

pro_print:					#��ӡ�����Ϣ
	cld;
	lodsb;
	andb %al,%al;
	jz os_main;
	movb $0x0e,%ah;
	int $0x10;
	jmp pro_print;
	
	.globl setup_gdt;
setup_gdt:					#δ�������ݶμĴ���������������
	pushl %ebp;
	movl %esp,%ebp;

	pushl %edi;
	movw $0x1000,%ax;		#��GDT����������0x10800���Ե�ַ��
	movw %ax,%ds;
	movl $0x0800,%ebx;		#�˴�����ʹ��32λ�Ĵ�������Ȼ��ַѰַGAS����
	movl $0x0000,%edi;

	movl $0x00,(%ebx,%edi,4);	#��һ���հ�GDT��
	inc %edi;
	movl $0x00,(%ebx,%edi,4);

	inc %edi;				#�����GDT��
	movl $0x0000ffff,(%ebx,%edi,4);
	inc %edi;
	movl $0x00c09800,(%ebx,%edi,4);

	inc %edi;				#ȫ�����ݶ�GDT��
	movl $0x0000ffff,(%ebx,%edi,4);
	inc %edi;
	movl $0x00cf9200,(%ebx,%edi,4);

	#ϵͳ��ջ�Σ�TODO��

	movw $0x07c0,%ax;
	movw %ax,%ds;

	movw $location_gdt,%bx;	#����GDT��Ӧ����
	movw $23,(%bx);
	movl $0x10800,2(%bx)		#movl $0x10000,2(%bx) �����

	lgdt location_gdt;		#����GDTR

	popl %edi;
	movl %ebp,%esp;
	popl %ebp;

	ret;
	
	.globl setup_idt;
setup_idt:				#���ÿ�IDT��
	pushw $0;
	pushl $0;
	lidt (%esp);
	addl $6,%esp;
	ret;

	.globl goto_protect;
goto_protect:
	pushl %eax;
	pushl %ebx;

	movw $1f,%bx;

	xorl %eax,%eax;
	movw %ds,%ax;
	shll $4,%eax;
	addl %eax,1f;

	movw $0x0008,4(%bx);

	cli;

	movl %cr0,%ebx;
	orl $0x0001,%ebx;
	movl %ebx,%cr0;

	.byte 0x66,0xea;	#true long jump!!
1:
	.long in_pm32;
	.word 0x00;

.code32
.globl in_pm32;
in_pm32:
	jmp goto_hlt;
	ret;

	.globl goto_hlt;
goto_hlt:

1:
	hlt;
	jmp 1b;
	ret;			#never use!


