#            ,--,
#      _ ___/ /\|    05naif
#  ,;'( )__, )  ~    Fri  2 Jan, 2026: 18:22:40
# //  //   '--; 
# '   \     | ^
#      ^    ^
# 
# 'makewords' program prints words per line, a word is defined
# as anything separated by either a space or a newline (\n)
#

.section .rodata
	.UsageMessage: .string "makewords: usage: makewords filename <or> makewords\n"
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
.process_input:
	movq	%rax, -16(%rbp)
	# r8: know many bytes have been read
	# r9: writing buffer
	# r10: how many bytes have been written
	xorq	%r8, %r8
	leaq	.WritingBuffer(%rip), %r9
	xorq	%r10, %r10
.makewords_loop:
	movq	-16(%rbp), %rax
	cmpq	%rax, %r8
	je		.reading_keep
	leaq	.ReadingBuffer(%rip), %rax
	addq	%r8, %rax
	movzbl	(%rax), %edi
	cmpb	$' ', %dil
	je		.skip_chr
	cmpb	$'\n', %dil
	je		.skip_chr
	cmpb	$'\t', %dil
	je		.skip_chr
	cmpq	%r10, .WritingBufferLength(%rip)
	je		.flush
	jmp		.add_chr
.skip_chr:
	movb	$10, %dil
	decq	%r9
	movb	(%r9), %cl
	cmpb	$'\n', %cl
	je		.makewords_loop
	incq	%r9
.add_chr:
	movb	%dil, (%r9)
	incq	%r8
	incq	%r9
	incq	%r10
	jmp		.makewords_loop
.flush:
	movb	%dil, %r11b
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.WritingBuffer(%rip), %rsi
	movq	%r10, %rdx
	syscall
	movb	%r11b, %dil
	leaq	.WritingBuffer(%rip), %r9
	xorq	%r10, %r10
	jmp		.add_chr
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
	movq	.WritingBufferLength(%rip), %rdx
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
