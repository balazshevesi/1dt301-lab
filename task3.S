.syntax unified
.thumb
.text

.global main
.type   main, %function
.thumb_func

.equ LED0,        0
.equ LED1,        1
.equ LED2,        2
.equ GPIO_OUT,    1
.equ LED_MASK,  (1<<LED0)|(1<<LED1)|(1<<LED2)   @ = 7
.equ ONE_SECOND,  1000

main:
    movs r0, #LED0      @ GP0
    bl   gpio_init
    movs r0, #LED0
    movs r1, #GPIO_OUT
    bl   link_gpio_set_dir

    movs r0, #LED1      @ GP1
    bl   gpio_init
    movs r0, #LED1
    movs r1, #GPIO_OUT
    bl   link_gpio_set_dir

    movs r0, #LED2      @ GP2
    bl   gpio_init
    movs r0, #LED2
    movs r1, #GPIO_OUT
    bl   link_gpio_set_dir

    movs r4, #0         @ r4 = this is our actual counter value, from 0 to 7, starts at 0
    movs r5, #0         @ r5 = this is our "state", tells us wether we're counting up or down, 0 = counting up, 1 = counting down

loop:
    /* update the state of all 3 pins in one call */
    movs r0, #LED_MASK          @ sets argument, selects GP0, GP1, GP2
    mov  r1, r4                 @ sets argument, current counter value (0-7)
    bl   link_gpio_put_masked
    /* sleep for a second */
    ldr  r0, =ONE_SECOND
    bl   sleep_ms
    /* update counter value */
    cmp  r5, #0             @ if r5 is Zero, set the Z flag to True
    beq  increment          @ (if Z flag is True)
    bne  decrement          @ (if Z flag is False)

increment:
    adds r4, r4, #1
    cmp  r4, #7             @ if we reached 7, set the Z flag to True
    bne  loop               @ (if Z flag is False)

    movs r5, #1             @ flip state to counting down
    b    loop

decrement:
    subs r4, r4, #1
    cmp  r4, #0             @ if we reached 0, set the Z flag to True
    bne  loop               @ (if Z flag is False)

    movs r5, #0             @ at 0 -> start counting up
    b    loop               @ flip state to counting up
