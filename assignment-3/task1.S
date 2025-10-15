.syntax unified
.thumb
.text

.global main
.type   main, %function
.thumb_func

main:
    bl stdio_init_all

loop:
    ldr r0, =my_array
    movs r1, #8
    bl average

    movs r1, r0
    ldr r0, =message_str
    bl printf
    b loop

average:
    movs    r2, #0          @ sum
1:  ldr     r3, [r0]        @ r3 = *r0
    adds    r0, r0, #4      @ r0 += 4
    adds    r2, r2, r3      @ sum += r3
    subs    r1, r1, #1      @ len--
    bne     1b
    lsrs    r0, r2, #3      @ divide by 8
    bx      lr

.data
    .align 4
    message_str: .asciz "Average value %d\n"
    .align 4
    my_array: .word 10, 20, 30, 40, 50, 60, 70, 80