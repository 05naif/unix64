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
# usage:
# $ p
#   or
# $ p [filename]
# 

.section .rodata
	.UsageMessage: .string "usage: p [filename]\n"
	.UsageLength:  .quad 20

	.UnexistentFileMessage: .string "error: cannot open file\n"
	.UnexistentFileLength:  .quad 25

.section .bss
	.ReadingBuffer: .zero 512
	.WritenBytes: .zero 2

.section .text
	.equ ReadingBufferLength, 512

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
	movw	%ax, %dx
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
