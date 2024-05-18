.section .text.nroEntrypointTrampoline, "ax", %progbits

.global nroEntrypointTrampoline
.type   nroEntrypointTrampoline, %function
.align 2

.global __libnx_exception_entry
.type   __libnx_exception_entry, %function

.cfi_startproc

nroEntrypointTrampoline:

    // Reset stack pointer.
    adrp x8, __stack_top                // Defined in libnx. Get the base address of the page containing __stack_top
    ldr  x8, [x8, #:lo12:__stack_top]   // Load the value of __stack_top
    mov  sp, x8                         // Set the stack pointer (SP) to the value of __stack_top

    // Call NRO.
    blr  x2                             // Call the function at the address stored in register x2

    // Save return value
    adrp x1, g_lastRet                  // Get the base address of the page containing g_lastRet
    str  w0, [x1, #:lo12:g_lastRet]     // Store the return value from register w0 into g_lastRet

    // Reset stack pointer and load next NRO.
    adrp x8, __stack_top                // Get the base address of the page containing __stack_top
    ldr  x8, [x8, #:lo12:__stack_top]   // Load the value of __stack_top
    mov  sp, x8                         // Set the stack pointer (SP) to the value of __stack_top

    b    loadNro                        // Branch to the loadNro function

.cfi_endproc

.section .text.__libnx_exception_entry, "ax", %progbits
.align 2

.cfi_startproc

__libnx_exception_entry:
    adrp x7, g_nroAddr                      // Get the base address of the page containing g_nroAddr
    ldr  x7, [x7, #:lo12:g_nroAddr]         // Load the value of g_nroAddr
    cbz  x7, __libnx_exception_entry_fail   // If g_nroAddr is zero, branch to __libnx_exception_entry_fail
    br   x7                                 // Branch to the address stored in register x7

__libnx_exception_entry_fail:
    // Otherwise, pass this unhandled exception right back to the kernel.
    mov w0, #0xf801             // Set the error code KERNELRESULT(UnhandledUserInterrupt) in w0
    bl svcReturnFromException   // Call the svcReturnFromException system call
    b .                         // Infinite loop

.cfi_endproc
