.syntax unified
.thumb
.text
.global main
.type   main, %function
.thumb_func

//RP2040
//The addresses of the constants are taken straight from the RP2040 docs

// The following memory addresses are "starting addresses", basically arrays, they are used for setting different kinds of state of the different pins
.equ SIO_BASE,         0xD0000000       @starting memory adress of the Single Cycle Input Output block, defines direct low-level control of the GPIO pins, direct setting and reading
.equ IO_BANK0_BASE,    0x40014000       @starting memory adress for configuring the functions for all of the different GP-pins. (handles PWM among other things)
.equ PADS_BANK0_BASE,  0x4001C000       @starting memory adress for the electrical behavior (pull-up resistor (on-state), pull-down resistor (off-state)) for all of the different GPIO pins. used for defining a clear and stable voltage level for the pins (so that they don't pickup noise)

// The following memory addresses all use bitmasks for setting state
.equ GPIO_IN,          0x004            @memory adress for getting the state of all the GP-pins (only pins which are configured as inputs)
.equ GPIO_OUT_SET,     0x014            @memory adress for setting the state of GP-output pins. uses a bitmask. only for setting the output pins on
.equ GPIO_OUT_CLR,     0x018            @memory adress for clearing the state of GP-output pins. uses a bitmask. only for setting the output pins off. counter part of GPIO_OUT_SET
.equ GPIO_OE_SET,      0x024            @memory adress for setting which pin should function as an output. (OE, Output Enable)
.equ GPIO_OE_CLR,      0x028            @memory adress for setting which pin should NOT function as an output (turns pins back into inputs)

// IO_BANK0 controls
.equ GPIO_CTRL_OFFS,   0x04             @the offset, the bit-length of the elements in the control-arrays, used for IO_BANK0
.equ FUNCSEL_SIO,      5                @function selection value, we use this to enable the SIO-mode for a GPIO-pin. used in IO_BANK0

// PADS_BANK0 controls
.equ PADS_PIN_OFFS,    0x04             @the offset, the bit-length of the elements in the control-arrays. used for PADS_BANK0
.equ PUE_BIT,          (1<<3)           @pull-up enable value
.equ PDE_BIT,          (1<<2)           @pull-down enable value
.equ SCHMITT_BIT,      (1<<1)           @used to stabilize the voltage level of pin (Hysteres?) filters out tiny noise, kind of like a noise-gate (especially in input pins), (causes a few microseconds of delay), setting it to 1 means that we're using it

// GP-pins which we will be using
.equ LED_PIN_1, 0
.equ LED_PIN_2, 1
.equ BTN_PIN_1, 2
.equ BTN_PIN_2, 3

/* === macros (IMMEDIATE pin args only) === */
.macro set_func_sio pin
    ldr     r1, =IO_BANK0_BASE + GPIO_CTRL_OFFS + (8 * \pin)
    movs    r2, #FUNCSEL_SIO
    str     r2, [r1]
.endm

.macro sio_dir_out pin
    ldr     r1, =SIO_BASE + GPIO_OE_SET
    movs    r2, #1
    lsls    r2, r2, #\pin
    str     r2, [r1]
.endm

.macro sio_dir_in pin
    ldr     r1, =SIO_BASE + GPIO_OE_CLR
    movs    r2, #1
    lsls    r2, r2, #\pin
    str     r2, [r1]
.endm

.macro sio_put_high pin
    ldr     r1, =SIO_BASE + GPIO_OUT_SET
    movs    r2, #1
    lsls    r2, r2, #\pin
    str     r2, [r1]
.endm

.macro sio_put_low pin
    ldr     r1, =SIO_BASE + GPIO_OUT_CLR
    movs    r2, #1
    lsls    r2, r2, #\pin
    str     r2, [r1]
.endm

/* Enable pull-up, disable pull-down, Schmitt on */
.macro pads_pullup pin
    ldr     r1, =PADS_BANK0_BASE + PADS_PIN_OFFS + (4 * \pin)
    ldr     r2, [r1]
    ldr     r3, =PDE_BIT
    bics    r2, r3                 /* r2 = r2 & ~r3 */
    ldr     r3, =(PUE_BIT|SCHMITT_BIT)
    orrs    r2, r3                 /* r2 = r2 | r3 */
    str     r2, [r1]
.endm

/* ===== main ===== */
main:
    /* LEDs: GPIO0,1 -> SIO + OUT */
    set_func_sio LED_PIN_1
    sio_dir_out  LED_PIN_1

    set_func_sio LED_PIN_2
    sio_dir_out  LED_PIN_2

    /* Buttons: GPIO2,3 -> SIO + IN + pull-up */
    set_func_sio BTN_PIN_1
    sio_dir_in   BTN_PIN_1
    pads_pullup  BTN_PIN_1

    set_func_sio BTN_PIN_2
    sio_dir_in   BTN_PIN_2
    pads_pullup  BTN_PIN_2

loop:
    /* read all pins once */
    ldr   r0, =SIO_BASE + GPIO_IN
    ldr   r1, [r0]

    /* r5 = (r1>>BTN1) & 1  (two-operand AND) */
    lsrs  r2, r1, #BTN_PIN_1
    movs  r3, #1
    mov   r5, r2
    ands  r5, r3

    /* r6 = (r1>>BTN2) & 1 */
    lsrs  r2, r1, #BTN_PIN_2
    mov   r6, r2
    ands  r6, r3

    /* if BTN1==1 -> check BTN2; else if BTN2==1 -> leds_off; else loop */
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
    sio_put_high LED_PIN_1
    sio_put_high LED_PIN_2
    b    loop

leds_off:
    sio_put_low  LED_PIN_1
    sio_put_low  LED_PIN_2
    b    loop
