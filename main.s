.section .data
fileMsg:
    .ascii "data file: "
FileMsgEnd:
.equ fileMsgSize, (FileMsgEnd-fileMsg)

powMsg:
    .ascii "%d(x, %i)\n"
powMsgEnd:
.equ powMsgSize, (powMsgEnd-powMsg)

.section .bss
.equ bufferSize, 64
.comm buffer, bufferSize

.equ dataBufferSize, 512
.comm dataBuffer, dataBufferSize

.section .text
.globl _start

.extern pow
.extern print

# FUNCTION "ladder"
# DESCRIPTION
# Subtract current from previous and store the result in previous,
# starting from index 1, while sum of the results is > 0.
# INPUT
# %rax=buffer
# %rbx=buffer_len
# OUTPUT
# %rax=buffer
# %rbx=new buffer_len
ladder:
    # save regs
    pushq %r8
    pushq %r9

    # save 0 into %xmm2 for comparison
    movq $0, %r9
    cvtsi2sd %r9, %xmm2

    movq $1, %r8                        # set lowest index / %r8 to 1
    1:                                  # LOOP 1
    movq $0, %r9                        # set %r9 to 0
    cvtsi2sd %r9, %xmm1                 # load %r9 to %xmmm1
    movq %rbx, %r9                      # set %r9 to buffer length 
    2:                                  # LOOP 2
    dec %r9                             # dec %r9

    movsd (%rax, %r9, 8), %xmm0         # load current double
    subsd -8(%rax, %r9, 8), %xmm0       # subtract current with past
    addsd %xmm0, %xmm1                  # add result to sum
    movsd %xmm0, (%rax, %r9, 8)         # store result in current

    cmpq %r8, %r9                       # while %r9 > lowest index / %r8
    ja 2b                               # jmp loop 2

    comisd %xmm2, %xmm1                 # cmp sum-0
    jz 3f                               # if equal break

    inc %r8                             # inc lowest index / %r8
    cmpq %r8, %rbx                      # while %r8 < buffer length
    ja 1b                               # jmp loop 1

    3:
    # return
    movq %r8, %rbx
    # restore regs
    popq %r9
    popq %r8
    ret

_start:
    subq $32, %rsp

    # print input msg
    movq $fileMsg, %rax
    movq $fileMsgSize, %rbx
    call print
    # fetch input fileName
    movq $0, %rax
    movq $0, %rdi
    movq $buffer, %rsi
    movq $bufferSize, %rdx
    syscall
    # open file
    movb $0, -1(%rsi, %rax, 1)
    movq $2, %rax
    movq $buffer, %rdi
    movq $0444, %rsi
    movq $0, %rdx
    syscall
    # read file & convert values
    movq $dataBuffer, %r8
    xorq %r9, %r9
    movq $buffer, %rsi
    movq $1, %rdx
    movq %rax, %rdi
    jmp 1f
    2:
    subq $buffer, %rsi
    movq $buffer, %rax
    movq %rsi, %rbx
    call stod
    movsd %xmm0, (%r8, %r9, 8)
    inc %r9
    movq $buffer, %rsi
    1:
    movq $0, %rax
    syscall
    cmpb $10, (%rsi)
    jz 2b
    inc %rsi
    cmpq $0, %rax
    ja 1b

    # calculate ladder
    movq $dataBuffer, %rax
    movq %r9, %rbx
    call ladder

    movq $dataBuffer, %r9
    movq %rbx, %r10
    1:
    dec %r10
    xorq %r8, %r8
    2:
    inc %r8
    movq %r10, -8(%rsp)
    fildl -8(%rsp)
    movq %r8, -8(%rsp)
    fildl -8(%rsp)
    call pow
    fstpl dataBufferSize/2-8(%r9, %r8, 8)
    cmpq %r8, %r10
    jae 2b

    leaq dataBufferSize/2(%r9), %rax
    movq %r8, %rbx
    call ladder

    movsd (%r9, %r10, 8), %xmm0
    divsd dataBufferSize/2(%r9, %r10, 8), %xmm0
    2:
    dec %r8
    movsd dataBufferSize/2(%r9, %r8, 8), %xmm1
    mulsd %xmm0, %xmm1
    movsd %xmm1, dataBufferSize/2(%r9, %r8, 8)
    movsd (%r9, %r8, 8), %xmm2
    subsd %xmm1, %xmm2
    movsd %xmm2, (%r9, %r8, 8)
    cmpq $0, %r8
    ja 2b

    movsd %xmm0, (%r9, %r10, 8)
    
    pushq %r10
    subq $8, %rsp
    movsd %xmm0, (%rsp)
    movq $powMsg, %rax
    movq $powMsgSize, %rbx
    call print
    addq $16, %rsp

    cmpq $0, %r10
    ja 1b

    addq $32, %rsp
    exit:
    movq $1, %rax
    movq $0, %rbx
    int $0x80
