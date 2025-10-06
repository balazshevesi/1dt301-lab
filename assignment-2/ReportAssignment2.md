READ ON GITHUB: [https://github.com/balazshevesi/1dt301-lab-assignment-2/blob/main/assignment-2/ReportAssignment2.md](https://github.com/balazshevesi/1dt301-lab-assignment-2/blob/main/assignment-2/ReportAssignment2.md)

# [1DT301 Lab Assignment REPORT](https://github.com/balazshevesi/1dt301-lab-assignment-2/blob/main/assignment-2/ReportAssignment2.md)

This lab introduced bare-metal ARMv6-M assembly on the Raspberry Pi Pico (RP2040). We implemented four tasks entirely in Thumb assembly, used the SDK only via thin C “link” functions, and verified behavior over USB serial and on GPIO pins with LEDs and a 7-segment display.

## Hardware & Software Setup

**Board:** Raspberry Pi Pico / Pico W (build flag selectable). 

**Computer:** Macbook Air M2 8GB, macOS Sonoma (14.5)

**SDK & Link shims:** We expose a small set of SDK GPIO calls to assembly: `link_gpio_set_dir`, `link_gpio_put`, `link_gpio_put_masked`, and `link_gpio_put_all`. These forward directly to `gpio_set_dir`, `gpio_put`, `gpio_put_masked`, and `gpio_put_all`. 

**Build system:** CMake project with an ASM entrypoint (`main.S`), linking `pico_stdlib` and `hardware_gpio`, and enabling USB stdio. UF2 is generated for drag-and-drop flashing. 

**Typical commands:** configure, build, copy UF2 to the Pico, and open minicom for USB-CDC output. 

## How to build/run (recap)

`rm -rf build && mkdir build && cd build`

`cmake .. -DPICO_BOARD=pico_w -DPICO_SDK_FETCH_FROM_GIT=on`

`cmake --build .`

`cp main.uf2 /Volumes/RPI-RP2/`

### For serial output (Hello World):

`minicom -o -b 115200 -D /dev/cu.usbmodemXXXXX`


## ARM Assembly Calling Convention (what we used)

We followed the following conventions:

- **Arguments:** first four in r0–r3. Additional arguments spill to the stack.

- **Return value:** in `r0`.

- **Volatile (caller-saved):** r0–r3, r12, and lr may be clobbered.

In our programs we keep counters/state in `r4`/`r5`, which safely survive calls like `sleep_ms` or `link_gpio_*` per convention. We pass parameters in `r0`, `r1`, etc., and receive results in `r0`.

## [Task 1 -“Hello World](./task1.S)

We adapted the book example to print "Hello World %d\n" while counting 100 to 0 and then resetting back to 100 in an infinite loop. On each iteration set `r0` to the format string, `r1` to the current counter, and call printf. When `r7` hits 0 we reset it. 

Key points visible in the code:

- Arguments in `r0`/`r1` before bl printf.

- Loop control in `r7`, with compare/branch and reset on zero.

- USB stdio enabled in the build, viewable via minicom.

## [Task 2 - Traffic light](./task2.S)

We configured GP0–GP2 as outputs and toggled them sequentially with 1s delays to emulate a traffic light. Each pin is initialized via `gpio_init`, direction set via `link_gpio_set_dir(pin, 1)`, then driven high/low via `link_gpio_put(pin, value)` with `sleep_ms`(1000) between phases.

## [Task 3 - 3-bit binary counter](./task3.S)

We use masked writes to update three pins in one call: `link_gpio_put_masked(LED_MASK, value)`, where `LED_MASK = (1<<0)|(1<<1)|(1<<2)`. State (`r5`) tracks direction (up/down), counter (`r4`) holds the current 0–7 value. We sleep 1s between steps. On reaching 7 we flip to down; on 0 we flip to up. 

## [Task 4 - 7-segment counter](./task4.S)

We initialize GP0–GP6 as outputs, map the current digit (in `r4`) to a 7-segment bitmap via `encode_digit_to_segments`, then write all bits at once with `link_gpio_put_all(v)`. We maintain the same up/down state machine and 1s delay. 

Details:

- Pin mapping: A..G map to GP0..GP6 (least-significant 7 bits). 

- Encoder: a small branch ladder sets r0 to the correct segment pattern for digits 0–9 (e.g., 0x3F for “0”, 0x06 for “1”, ...). r0 is then consumed by `link_gpio_put_all`, which writes all GPIOs in one go. 

- Reason for put_all: single-cycle-style update avoids transient display artifacts compared to per-pin writes. The shim exposes this SDK helper. 

## Conclusion

All four tasks were implemented purely in assembly and verified on the hardware. The code adheres to ARM calling conventions.