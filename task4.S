.syntax unified
.thumb
.text

.global main
.type   main, %function
.thumb_func

.equ A,0 
.equ B,1 
.equ C,2 
.equ D,3 
.equ E,4 
.equ F,5 
.equ G,6
.equ GPIO_OUT,    1
.equ ONE_SECOND,  1000

main:
    movs r0,#0
    movs r6, #0

1:  movs r0, r6
    bl   gpio_init

    movs r0, r6
    movs r1, #GPIO_OUT
    bl   link_gpio_set_dir

    adds r6, r6, #1      @ increment pin
    cmp  r6, #7
    bne  1b

    movs r4, #0         @ r4 = this is our actual counter value, from 0 to 9, starts at 0
    movs r5, #0         @ r5 = this is our "state", tells us wether we're counting up or down, 0 = counting up, 1 = counting down

loop:
    bl  encode_digit_to_segments
    bl  link_gpio_put_all

    /* sleep for a second */
    ldr  r0, =ONE_SECOND
    bl   sleep_ms
    /* update counter value */
    cmp  r5, #0             @ if r5 is Zero, set the Z flag to True
    beq  increment          @ (if Z flag is True)
    bne  decrement          @ (if Z flag is False)

increment:
    adds r4, r4, #1
    cmp  r4, #9             @ if we reached 9, set the Z flag to True
    bne  loop               @ (if Z flag is False)

    movs r5, #1             @ flip state to counting down
    b    loop

decrement:
    subs r4, r4, #1
    cmp  r4, #0             @ if we reached 0, set the Z flag to True
    bne  loop               @ (if Z flag is False)

    movs r5, #0             @ at 0 -> start counting up
    b    loop               @ flip state to counting up

encode_digit_to_segments:   @ maps the digit in r4 (0-9) to 7-segment encoding in r0, each bit represents a segment
  cmp  r4,#0
  beq  d0
  cmp  r4,#1
  beq  d1
  cmp  r4,#2
  beq  d2
  cmp  r4,#3
  beq  d3
  cmp  r4,#4
  beq  d4
  cmp  r4,#5
  beq  d5
  cmp  r4,#6
  beq  d6
  cmp  r4,#7
  beq  d7
  cmp  r4,#8
  beq  d8
  cmp  r4,#9
  beq  d9

d0: movs r0,#0x3F
    bx   lr
d1: movs r0,#0x06
    bx   lr
d2: movs r0,#0x5B
    bx   lr
d3: movs r0,#0x4F
    bx   lr
d4: movs r0,#0x66
    bx   lr
d5: movs r0,#0x6D
    bx   lr
d6: movs r0,#0x7D
    bx   lr
d7: movs r0,#0x07
    bx   lr
d8: movs r0,#0x7F
    bx   lr
d9: movs r0,#0x6F
    bx   lr
