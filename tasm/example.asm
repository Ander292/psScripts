;; An example tasm code
;; Converts a number into a string and then prints it to stdout

.model small
.stack
.data
msg     db 10, 13, '$'
num     dw 1389
cnt     dw 0
buffer  db 100 DUP(?)
pos     dw 0
len     dw -1

.code

main:

    mov ax, @data
    mov ds, ax

    mov ax, num
    mov cnt, ax

loop_start:
    ;; The condition
    mov ax, cnt
    cmp ax, 0
    je loop_end

    ;; Division
    mov dx, 0
    mov bx, 0Ah
    div bx
    mov cnt, ax
    
    add dx, '0'

    ;; Pushing into possition
    mov ax, OFFSET buffer
    add ax, pos
    mov si, ax
    mov BYTE PTR [si], dl

    ;; Incrementing possition
    mov cx, pos
    inc cx
    mov pos, cx

    jmp loop_start
loop_end:
    mov ax, OFFSET buffer
    add ax, pos
    mov dl, '$'
    mov si, ax
    mov BYTE PTR [si], dl

    ;; String reversal
    mov ax, pos
    mov len, ax
    mov pos, 0

loop_convert_start:
    ;; Condition check pos < len/2 => len/2 - pos > 0 (condition for entering the body)
    mov dx, 0
    mov ax, len
    mov bx, 02h
    div bx
    sub ax, pos
    cmp ax, 0
    jle loop_convert_end
    ;; Body
    ;; Swaping possitions (len - 1 - pos) and pos
    mov si, OFFSET buffer
    add si, pos
    mov di, OFFSET buffer
    add di, len
    sub di, 1
    sub di, pos

    ;; 
    mov al, [si]
    mov bl, [di]
    mov [si], bl
    mov [di], al
    ;; Increment
    mov ax, pos
    inc ax
    mov pos, ax
    jmp loop_convert_start
loop_convert_end:

    ;; Printing the string itself
    mov ah, 9h
    mov dx, OFFSET buffer
    int 21h

    mov ah, 4ch
    int 21h

end main