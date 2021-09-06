.section ".text.boot"

.global _start

//	.org 0x80000
_start:
    // Set the stack pointer, which progresses downwards through memory
    // Set it at 64MB which we know our application will not crash into
    // and we also know will be available to the ARM CPU. No matter what
    // settings we use to split the memory between the GPU and ARM CPU
    mov     sp, #(64*1024*1024)

    // Run the c startup function - should not return and
    // will call main
    bl       _cstartup

_inf_loop:
    b       _inf_loop
