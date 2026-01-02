#            ,--,
#      _ ___/ /\|    05naif
#  ,;'( )__, )  ~    Fri  2 Jan, 2026: 17:50:38
# //  //   '--; 
# '   \     | ^
#      ^    ^
#
# 'p' program works as a printer for any file given as argument,
# it will display all the content of the file provided, if no file
# is given, it will run as well but will take input as stdin.
#

.section .rodata
	.UsageMessage: .string "p: usage: p filename <or> p\n"
	.UsageLength:  .quad 28

	.ReadingBufferLength: .quad 2048

.section .bss
	.ReadingBuffer: .zero 2048

.section .text

.globl _start

_start:
	movq	(%rsp), %rax
	cmpq	$2, %rax
	je		.file_given
	cmpq	$1, %rax
	jne		.usage
	# since no file was given to read
	# from, set the fd to 2 (stdin)
	movq	$2, %r15
	jmp		.init_stack
.file_given:
	movq	16(%rsp), %rdi
	movq	$2, %rax
	xorq	%rsi, %rsi
	syscall
	cmpq	$0, %rax
	jl		.usage
	movq	%rax, %r15
.init_stack:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$8, %rsp
	movq	%r15, -8(%rbp)
.reading_loop:
	movq	$0, %rax
	movq	-8(%rbp), %rdi
	leaq	.ReadingBuffer(%rip), %rsi
	movq	.ReadingBufferLength(%rip), %rdx
	syscall
	cmpq	$0, %rax
	je		.fini
.process_input:
	movq	%rax, %rdx
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.ReadingBuffer(%rip), %rsi
	syscall
.reading_keep:
	jmp		.reading_loop
.fini:
	movq	$60, %rax
	movq	$0, %rdi
	syscall
.usage:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.UsageMessage(%rip), %rsi
	movq	.UsageLength(%rip), %rdx
	syscall
	jmp		.fini
