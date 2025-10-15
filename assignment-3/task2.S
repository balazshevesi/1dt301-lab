.syntax unified
.thumb
.text
.global main
.type   main, %function
.thumb_func

.equ LED_PIN_1, 0
.equ LED_PIN_2, 1
.equ BTN_PIN_1, 2
.equ BTN_PIN_2, 3

.equ GPIO_OUT, 1
.equ GPIO_IN, 0

main:
    movs r0, #LED_PIN_1
    bl  gpio_init
    movs r0, #LED_PIN_1
    movs r1, #GPIO_OUT      @ Set GPIO as output (it could be set to input as well)
    bl  link_gpio_set_dir

    movs r0, #LED_PIN_2
    bl  gpio_init
    movs r0, #LED_PIN_2
    movs r1, #GPIO_OUT
    bl  link_gpio_set_dir

    movs r0, #BTN_PIN_1
    bl  gpio_init
    movs r0, #BTN_PIN_1
    movs r1, #GPIO_IN
    bl   link_gpio_set_dir
    movs r0, #BTN_PIN_1
    bl  link_gpio_pull_up

    movs r0, #BTN_PIN_2
    bl  gpio_init
    movs r0, #BTN_PIN_2
    movs r1, #GPIO_IN
    bl   link_gpio_set_dir
    movs r0, #BTN_PIN_1
    bl  link_gpio_pull_up


loop:
    movs r0, #BTN_PIN_1 @ store the state of btn_pin_1 in r5, (1 when pressed, 0 when not )
    bl   link_gpio_get
    mov  r5, r0
    

    movs r0, #BTN_PIN_2 @ store the state of btn_pin_1 in r6, (1 when pressed, 0 when not )
    bl   link_gpio_get
    mov  r6, r0

    cmp  r5, #1
    beq  check_btn2
    
    cmp  r6, #1
    beq  leds_off

    b    loop

check_btn2:
    cmp  r6, #1
    beq  loop
    b    leds_on

leds_on:
    movs r0, #LED_PIN_1
    movs r1, #1
    bl   link_gpio_put

    movs r0, #LED_PIN_2
    movs r1, #1
    bl   link_gpio_put

    b    loop

leds_off:
    movs r0, #LED_PIN_1
    movs r1, #0
    bl   link_gpio_put

    movs r0, #LED_PIN_2
    movs r1, #0
    bl   link_gpio_put

    b    loop

no_change:
    b    loop
