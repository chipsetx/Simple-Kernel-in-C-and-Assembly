Simple Kernel in C and Assembly
===============================

Hello, world ! Today I'm going to show you how to write a kernel in C and a little bit of assembly. This is a simple kernel written in C and Assembly which could be loaded with the GRUB bootloader on an x86 system. This kernel will
display a message on the screen and then hang. All the source code is available on my github [repository](https://github.com/debashisbarman/Simple-Kernel-in-C-and-Assembly).

##Tools
Before writing the kernel, make sure that the following tools are available in your system.
<ul>
<li>An x86 computer (of course)</li>
<li>Linux</li>
<li>NASM assembler</li>
<li>gcc</li>
<li>ld (GNU Linker)</li>
<li>grub</li>
</ul>

##Let's start coding
We like to write everything in C, but we cannot avoid a little bit of assembly. We will write a small file in x86
assembly-language that serves as the starting point for our kernel. 

Here is our <code>kernel.asm</code> file.
<pre>
;;kernel.asm
bits 32		;nasm directive
section .text
	;multiboot spec
	align 4
	dd 0x1BADB002			;magic
	dd 0x00				;flags
	dd - (0x1BADB002 + 0x00)	;checksum. m+f+c should be zero

global start
extern kmain	;kmain is defined in the c file

start:
	cli	;block interrupts
	call kmain
	hlt	;halt the CPU
</pre>

In the <code>kernel.asm</code> we make a call to <code>kmain</code>. So our execution starts at <code>kmain()</code> in the main C file <code>kernel.c</code>.

<pre>
/*
 *
 * kernel.c - version 1.0.2
 * 
 */


#define WHITE_TXT 0x07 /* light gray on black text */

void k_clear_screen();
unsigned int k_printf(char *message, unsigned int line);

/* simple kernel written in C */
void k_main() 
{
	k_clear_screen();
	k_printf("Hello, world! Welcome to my kernel.", 0);
};

/* k_clear_screen : to clear the entire text screen */
void k_clear_screen()
{
	char *vidmem = (char *) 0xb8000;
	unsigned int i=0;
	while(i < (80*25*2))
	{
		vidmem[i]=' ';
		i++;
		vidmem[i]=WHITE_TXT;
		i++;
	};
};

/* k_printf : the message and the line # */
unsigned int k_printf(char *message, unsigned int line)
{
	char *vidmem = (char *) 0xb8000;
	unsigned int i=0;

	i=(line*80*2);

	while(*message!=0)
	{
		if(*message=='\n') // check for a new line
		{
			line++;
			i=(line*80*2);
			*message++;
		} else {
			vidmem[i]=*message;
			*message++;
			i++;
			vidmem[i]=WHITE_TXT;
			i++;
		};
	};

	return(1);
}
</pre>

All our kernel will do is clear the screen and write to it the string "Hello, world! Welcome to my kernel."

Now the <code>linker.ld</code> script.

<pre>
/*
 * link.ld
 */

OUTPUT_FORMAT(elf32-i386)
ENTRY(start)
SECTIONS
{
	. = 0x100000;
	.text : {*(.text)}
	.data : {*(.data)}
	.bss  : {*(.bss)}
}
</pre>

That's it. All done.

##Building the kernel
We will now create object files from <code>kernel.asm</code> and <code>kernel.c</code> and then link it using our linker script.

<pre>
nasm -f elf32 kernel.asm -o kasm.o
</pre>

Now we will run the assembler to create the object file <code>kasm.o</code> in ELF-32 bit format.

<pre>
gcc -m32 -c kernel.c -o kc.o
</pre>

Now the linking part,

<pre>
ld -m elf_i386 -T link.ld -o kernel kasm.o kc.o
</pre>

##Now run your kernel
We will now run the kernel on the <code>qemu</code> emulator.

<pre>
qemu-system-i386 -kernel kernel
</pre>

That's it.
