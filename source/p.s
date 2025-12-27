#            ,--,
#      _ ___/ /\|    05naif
#  ,;'( )__, )  ~    Sat 27 Dec, 2025: 16:43:35
# //  //   '--; 
# '   \     | ^
#      ^    ^
# 
# p-command stands for 'print' and it acts like a cat
# command but w/o all of its capabilities
#
# usage: $ p [filename]
# 

.section .rodata
	.UsageMessage: .string "usage: p [filename]\n"
	.UsageLength:  .long 20

	.ReadingBufferLength: .quad 512

.section .bss
	.ReadingBuffer: .zero 512

.section .text

.globl _start

_start:
	popq	%rax
	cmpq	$2, %rax
	jnz		.print_usage
	popq	%rax
	popq	%rax
	movq	%rax, %rdi
	xorq	%rsi, %rsi
	movq	$2, %rax
	syscall
	movq	%rax, %r15
.reading_loop:
	xorq	%rax, %rax
	movq	%r15, %rdi
	leaq	.ReadingBuffer(%rip), %rsi
	movq	.ReadingBufferLength(%rip), %rdx
	syscall
	cmpq	$0, %rax
	jz		.stop_reading
	movq	%rax, %rdx
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.ReadingBuffer(%rip), %rsi
	syscall
	jmp		.reading_loop
.stop_reading:
	movq	%r15, %rdi
	movq	$3, %rax
	syscall
	jmp		_fini
.print_usage:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.UsageMessage(%rip), %rsi
	movq	.UsageLength(%rip), %rdx
	syscall
	jmp		_fini
_fini:
	movq	$60, %rax
	movq	$0, %rdi
	syscall
