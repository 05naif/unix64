#            ,--,
#      _ ___/ /\|    05naif
#  ,;'( )__, )  ~    Mon 29 Dec, 2026: 19:19:22
# //  //   '--; 
# '   \     | ^
#      ^    ^
# 
# turns all character into its lowercase version
# 

.section .rodata
	.UsageMessage: .string "usage: lowercase [filename | ]\n"
	.UsageLength:  .quad 32

	.UnexistentFileMessage: .string "error: cannot open file\n"
	.UnexistentFileLength:  .quad 25

.section .bss
	.ReadingBuffer: .zero 512
	.WritingBuffer: .zero 512
	.WritenBytes: .zero 2

.section .text
	.equ ReadingBufferLength, 512
	.equ WritingBufferLength, 512

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
	movq	%rax, %rbx
	xorq	%rcx, %rcx
	leaq	.WritingBuffer(%rip), %r14
	xorq	%r13, %r13
.scanning_loop:
	cmpq	%rcx, %rbx
	je		.print_stuff
	leaq	.ReadingBuffer(%rip), %rax
	addq	%rcx, %rax
	movzbl	(%rax), %edi
	cmpb	$90, %dil
	jg		.no_big
	cmpb	$65, %dil
	jl		.no_big
	addb	$32, %dil
.no_big:
	movb	%dil, (%r14)
	incq	%r14
	incq	%r13
	incq	%rcx
	jmp		.scanning_loop
.print_stuff:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.WritingBuffer(%rip), %rsi
	movq	%rbx, %rdx
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
