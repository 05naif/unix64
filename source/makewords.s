#            ,--,
#      _ ___/ /\|    05naif
#  ,;'( )__, )  ~    Mon 29 Dec, 2026: 18:32:54
# //  //   '--; 
# '   \     | ^
#      ^    ^
# 
# makewords prints all the words in the given input
# in a newline
# 

.section .rodata
	.UsageMessage: .string "usage: makewords [filename | ]\n"
	.UsageLength:  .quad 31

	.UnexistentFileMessage: .string "error: cannot open file\n"
	.UnexistentFileLength:  .quad 25

.section .bss
	.ReadingBuffer: .zero 512
	.WritenBytes: .zero 2
	.Word: .zero 64

.section .text
	.equ ReadingBufferLength, 512
	.equ WordLength, 64

.globl _start

_start:
	movq	(%rsp), %rax
	cmpq	$2, %rax
	jz		.file_provided
	cmpq	$1, %rax
	jz		.read_from_stdin
	jmp		.print_usage
.read_from_stdin:
	movq	$0, %r15
	jmp		.reading_loop
.file_provided:
	movq	16(%rsp), %rax
	movq	%rax, %rdi
	xorq	%rsi, %rsi
	movq	$2, %rax
	syscall
	cmpq	$0, %rax
	jl		.unexistent_file
	movq	%rax, %r15
.reading_loop:
	xorq	%rax, %rax
	movq	%r15, %rdi
	leaq	.ReadingBuffer(%rip), %rsi
	xorq	%rdx, %rdx
	movw	$ReadingBufferLength, %dx
	syscall
	cmpw	$0, %ax
	jz		.stop_reading
	xorq	%rcx, %rcx
	movq	%rax, %rbx
	leaq	.Word(%rip), %r14
	xorq	%r13, %r13
.split_loop:
	cmpq	%rbx, %rcx
	jz		.reading_loop
	cmpq	$WordLength, %r13
	jz		.print_word
	leaq	.ReadingBuffer(%rip), %rax
	addq	%rcx, %rax
	movzbl	(%rax), %edi
	cmpb	$10, %dil
	jz		.check_word
	cmpb	$32, %dil
	jz		.check_word
	movb	%dil, (%r14)
	incq	%r13
	incq	%r14
	incq	%rcx
	jmp		.split_loop
.check_word:
	movzbl	-1(%rax), %edi
	cmpb	$10, %dil
	jnz		.word_found
	incq	%rcx
	jmp		.split_loop
.word_found:	
	movb	$10, (%r14)
	incq	%r13
	incq	%rcx
.print_word:
	pushq	%rbx
	pushq	%rcx
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.Word(%rip), %rsi
	movq	%r13, %rdx
	syscall
	popq	%rcx
	popq	%rbx
	xorq	%r13, %r13
	leaq	.Word(%rip), %r14
	jmp		.split_loop
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
	jmp		_killit
.unexistent_file:
	movq	$1, %rax
	movq	$2, %rdi
	leaq	.UnexistentFileMessage(%rip), %rsi
	movq	.UnexistentFileLength(%rip), %rdx
	syscall
	jmp		_killit
_fini:
	movq	$60, %rax
	movq	$0, %rdi
	syscall
_killit:
	movq	$60, %rax
	movq	$1, %rdi
	syscall
