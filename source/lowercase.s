#            ,--,
#      _ ___/ /\|    05naif
#  ,;'( )__, )  ~    Fri  2 Jan, 2026: 20:47:06
# //  //   '--; 
# '   \     | ^
#      ^    ^
#
# 'lowercase' well, lowercase...
#

.section .rodata
	.UsageMessage: .string "lowercase: usage: lowercase filename <or> lowercase\n"
	.UsageLength:  .quad 52

	.ReadingBufferLength: .quad 2048
	.WritingBufferLength: .quad 1024

.section .bss
	.ReadingBuffer: .zero 2048
	.WritingBuffer: .zero 1024

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
	movq	$0, %r15
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
	subq	$16, %rsp
	movq	%r15, -8(%rbp)
.reading_loop:
	movq	$0, %rax
	movq	-8(%rbp), %rdi
	leaq	.ReadingBuffer(%rip), %rsi
	movq	.ReadingBufferLength(%rip), %rdx
	syscall
	cmpq	$0, %rax
	je		.close_file
	movq	%rax, -16(%rbp)
.process_input:	
	leaq	.WritingBuffer(%rip), %r8
	xorq	%r9, %r9
	xorq	%r10, %r10
.lowercase_loop:
	movq	-16(%rbp), %rax
	cmpq	%rax, %r10
	je		.reading_loop
	leaq	.ReadingBuffer(%rip), %rax
	addq	%r9, %rax
	movzbl	(%rax), %edi
	cmpb	$'Z', %dil
	jg		.add_chr
	cmpb	$'A', %dil
	jl		.add_chr
	addb	$32, %dil
.add_chr:
	movb	%dil, (%r8)
	incq	%r8
	incq	%r9
	incq	%r10
	cmpq	.WritingBuffer(%rip), %r9
	je		.flush
	jmp		.lowercase_loop
.flush:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.WritingBuffer(%rip), %rsi
	movq	%r9, %rdx
	syscall
	leaq	.WritingBuffer(%rip), %r8
	xorq	%r9, %r9
	jmp		.lowercase_loop
.reading_keep:
	jmp		.reading_loop
.close_file:
	movq	$3, %rax
	movq	-8(%rbp), %rdi
	syscall
.fini:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.WritingBuffer(%rip), %rsi
	movq	%r9, %rdx
	syscall
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
