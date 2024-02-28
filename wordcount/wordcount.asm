sys_exit:       equ             60
sys_write:      equ             1

stdout:         equ             1
stderr:         equ             2

exit_failure    equ             1

                section         .text
                global          _start

_start:
                xor             bl, bl
                xor             r10, r10

.read_loop:
                xor             eax, eax
                xor             edi, edi
                mov             rsi, read_buf
                mov             rdx, read_buf_size
                syscall

                test            rax, rax
                js              .read_error
                jz              .read_end
                xor             rcx, rcx

.count_loop:
                mov             dl, byte [read_buf + rcx]
                cmp             dl, 9
                jb              .not_white_space
                cmp             dl, 13
                ja              .check_space
                jmp             .white_space
.check_space:
                cmp             dl, 32
                jne             .not_white_space
.white_space:
                xor             bl, bl
                jmp             .iterate
.not_white_space:
                test            bl, 1
                jnz             .iterate
                mov             bl, 1
                inc             r10
.iterate:
                inc             rcx
                cmp             rcx, rax
                je              .read_loop
                jmp             .count_loop

.read_end:
                mov             rax, r10
                mov             ebx, 10
                mov             byte [write_buf + write_buf_size - 1], 10
                mov             rcx, write_buf_size - 1

.write_loop:
                xor             edx, edx
                div             rbx
                add             rdx, '0'
                dec             rcx
                mov             [write_buf + rcx], dl
                test            rax, rax
                jnz             .write_loop

                mov             rax, sys_write
                mov             rdi, stdout
                lea             rsi, [write_buf + rcx]
                mov             rdx, write_buf_size
                sub             rdx, rcx
                syscall

                mov             eax, sys_exit
                xor             edi, edi
                syscall

.read_error:
                mov             rax, sys_write
                mov             rdi, stderr
                mov             rsi, error_msg
                mov             rdx, error_msg_size
                syscall

                mov             eax, sys_exit
                mov             edi, exit_failure
                syscall

                section         .rodata
error_msg:      db              "Error while reading", 0x0a
error_msg_size: equ             $ - error_msg


                section         .bss
read_buf_size:  equ             8192
read_buf:       resb            read_buf_size
write_buf_size: equ             24
write_buf:      resb            write_buf_size
