.syntax unified
.thumb
.text

.global main
.type   main, %function
.thumb_func

.EQU LED_PIN_1, 0
.EQU LED_PIN_2, 1
.EQU LED_PIN_3, 2
.EQU GPIO_OUT, 1
.EQU sleep_time, 1000

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

    movs r0, #LED_PIN_3
    bl  gpio_init
    movs r0, #LED_PIN_3
    movs r1, #GPIO_OUT
    bl  link_gpio_set_dir

loop:
    movs r0, #LED_PIN_1
    movs r1, #1
    bl  link_gpio_put
    ldr r0, =sleep_time
    bl  sleep_ms
    movs r0, #LED_PIN_1
    movs r1, #0
    bl  link_gpio_put

    movs r0, #LED_PIN_2
    movs r1, #1
    bl  link_gpio_put
    ldr r0, =sleep_time
    bl  sleep_ms
    movs r0, #LED_PIN_2
    movs r1, #0
    bl  link_gpio_put

    movs r0, #LED_PIN_3
    movs r1, #1
    bl  link_gpio_put
    ldr r0, =sleep_time
    bl  sleep_ms
    movs r0, #LED_PIN_3
    movs r1, #0
    bl  link_gpio_put

    b   loop