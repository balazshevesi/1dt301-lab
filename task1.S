.syntax unified
.thumb
.text

.global main
.type   main, %function
.thumb_func

main:
    bl  stdio_init_all
    ldr r0, =2000
    bl  sleep_ms
    movs r7, #100

loop:
    movs r1, r7
    ldr r0, =helloworld
    bl  printf
    cmp r7, #0
    bne 1f
    movs r7, #100
    b   loop
1:  subs r7, r7, #1
    b   loop
    .size main, .-main

    .section .rodata
    .align 4

helloworld:
    .asciz "Hello World %d\n"
