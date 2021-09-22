; You may customize this and other start-up templates;
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h


jmp inicio



;area de definicion de datos
new_line        db 10,13,'$'; Enter para imprimir el tablero correctamente


;definicion de las dimensiones del tablero
ancho      db 15; ancho del tablero en cantidad de caracteres
alto       db 20; alto del tablero en cantidad de caracteres


ini_cursor_x    db 0; Posición inicial en X del cursor
ini_cursor_y    db 0; Posición inicial en Y del cursor 


msj_cursor_x    EQU 10; Posición del cursor en X para imprimir mensaje de ganador
msj_cursor_y    EQU 24; Posición del cursor en Y para imprimir mensaje de ganador

flag_enter db 0
flag_ver db 0
flag_hor db 0
flag_para_arriba db 0
flag_para_abajo db 0
flag_para_derecha db 0
flag_para_izquierda db 0

palabra_elegida db ? 20 dup("$")

tablero     db "**BIT**********"
            db "*******WORD****"
            db "A**************"
            db "L***N**********"
            db "U***I**********"
            db "****B**********"
            db "****B**********"
            db "****L***LITTLE*"
            db "****E**********"
            db "***************"
            db "*****R*********"
            db "*****E****AND**"
            db "*****G*********"
            db "*****I*********"
            db "*CMP*S******P**"
            db "*****T**ROM*I**"
            db "*****R******L**"
            db "*****O******A**"
            db "***************" 
            db "***************",'$'

path       db "C:\emu8086\vdrive\tpf\a.txt", 0 
buffer     db 300 dup ("$")
preguntas  db 300 dup ("$")

respuestas db 20 dup ("$")

contador_respuesta db 0  
contador_aux_respuestas db 0 
respuestas_correctas db 0
respuestas_incorrectas db 0

handle  dw ?        
 
msg0 db "Incorrecto$",10,13
msg1 db "Correcto  $"  ,10,13



inicio:

limpieza1:   
    mov ax,0000h
    xor bx,bx
    xor cx,cx
    xor dx,dx
    mov cx, 10


procedimientos_teablero:
   
    call letra_aleatoria
    call leer_archivo
    call dividir_buffer
    
    call imprimir_tablero
    call imprimir_preguntas  
    
    
procedimientos_jugador:    
   ciclo_juego: 
    
    cmp respuestas_correctas,1
    je fin_juego
    
    call limpieza2       
    call movimiento ;devuelve palabra_elegida 
   

    call respuesta_valida
    
    jmp ciclo_juego
  
fin_juego:
    ret
 
 
 
 
;------------------------------------
PROC limpieza2

        xor bx,bx
        xor cx,cx
        xor dx,dx
        mov si, 0x0000h
        ret
limpieza2 endp  
;-------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc movimiento
    mov dh, ini_cursor_y  ;fila
    mov dl,ini_cursor_x   ;columna
    
    movimiento_cursor:    
        mov dh, ini_cursor_y  ;fila
        mov dl,ini_cursor_x   ;columna
        mov bh,0
        mov ah,2
        int 10h
    
    imprimir:  
        xor bx,bx
        mov ah, 0
        int 16h
    
    tecla_primero:
        cmp flag_ver,1
        je teclas_ver
        cmp flag_hor,1
        je teclas_hor
        
    teclas:        
        cmp al,13        ;si presiona: ENTER
        je enter_apretado
        cmp al,"a"       ;si presiona: a
        je flecha_izq
        cmp al,"d"       ;si presiona: d
        je flecha_der    
        cmp al,"w"       ;si presiona: w
        je flecha_arriba
        cmp al,"s"       ;si presiona: s
        je flecha_abajo
        jmp movimiento_cursor
    
    teclas_ver:
        cmp al,13        ;si presiona: ENTER
        je enter_apretado
        cmp al,"w"       ;si presiona: w
        je flecha_arriba
        cmp al,"s"
        je flecha_abajo
        jmp movimiento_cursor
        
    teclas_hor:
        cmp al,13        ;si presiona: ENTER
        je enter_apretado
        cmp al,"a"       ;si presiona: a
        je flecha_izq
        cmp al,"d"       ;si presiona: d
        je flecha_der 
        jmp movimiento_cursor
    
    flecha_izq:
        cmp ini_cursor_x,0 ;limito cursor izq
        jz movimiento_cursor
        dec ini_cursor_x
        
        cmp flag_para_derecha,1
        je borrar_letra
        cmp flag_para_izquierda,1
        je ingresa_letra
        
        cmp flag_enter,1
        je horizontalidad       
        jmp movimiento_cursor 
        
    flecha_der:
        cmp ini_cursor_x,14 ;limito cursor der
        jz movimiento_cursor
        inc ini_cursor_x
        
        cmp flag_para_izquierda,1
        je borrar_letra
        cmp flag_para_derecha,1
        je ingresa_letra
        
        cmp flag_enter,1
        je horizontalidad                     
        jmp movimiento_cursor   
    
    flecha_arriba:
        cmp ini_cursor_y,0  ;limito cursor arriba
        jz movimiento_cursor
        dec ini_cursor_y
        
        cmp flag_para_abajo,1
        je borrar_letra
        cmp flag_para_arriba,1
        je ingresa_letra 
               
        cmp flag_enter,1
        je verticalidad       
        
        jmp movimiento_cursor
    
    flecha_abajo:
        cmp ini_cursor_y,19 ;limito cursor abajo
        jz movimiento_cursor
        inc ini_cursor_y
        
        cmp flag_para_arriba,1
        je borrar_letra
        cmp flag_para_abajo,1
        je ingresa_letra 
        
        cmp flag_enter,1
        je verticalidad           
        
        jmp movimiento_cursor 
    
    verticalidad:
    mov flag_ver,1
    cmp al,"w"
    je arriba
    abajo:
    mov flag_para_abajo,1
    jmp ingresa_letra
    arriba:
    mov flag_para_arriba, 1
    jmp ingresa_letra
        
    
    horizontalidad:
    mov flag_hor,1
    cmp al,"d"
    je derecha
    izquierda:
    mov flag_para_izquierda, 1
    jmp ingresa_letra
    derecha:
    mov flag_para_derecha, 1
    jmp ingresa_letra
          
    enter_apretado:
        cmp flag_enter,0
        je entrada_enter
        jmp salida_enter 
        
        entrada_enter:
        mov flag_enter, 1
        
        mov si, 00h
        mov ch, 0
     	mov cl, 7
     	mov ah, 1
     	int 10h 
        jmp movimiento_cursor
        
        salida_enter:
        mov flag_enter,0
        mov flag_ver,0
        mov flag_hor,0
        mov flag_para_arriba, 0
        mov flag_para_abajo, 0
        mov flag_para_izquierda, 0
        mov flag_para_derecha, 0
        
        mov ch, 6
     	mov cl, 7
     	mov ah, 1
     	int 10h
        jmp ingresa_letra
           
    borrar_letra:
        mov palabra_elegida[si],"$"
        dec si
        jmp movimiento_cursor
    
    ingresa_letra:
        mov ah,08h
        int 10h       
        mov palabra_elegida[si], al
        inc si
        cmp flag_enter,0
        je fin_movimiento
        jmp movimiento_cursor
        
    fin_movimiento:
        mov palabra_elegida[si],"*"    
       
        ret     
 movimiento endp
    
    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;leer_archivo proc
 
    
;    leer_archivo endp
    
    
    
    
    
    
imprimir_tablero proc
     ;Se establece el uso de la pantalla en modo texto
     mov al, 03h
     mov ah, 0
     int 10h 
     
     xor cx,cx
     mov bx, offset tablero
     mov cl, alto
 ptr_cont_fila:  
     push cx
     mov cl, ancho
     mov ah, 02h
 ptr_fila:
     mov dl, [bx]
     inc bx
     int 21h
     loop ptr_fila
     mov dx, offset new_line
     mov ah, 09h
     int 21h
     pop cx
     loop ptr_cont_fila 
     ret
imprimir_tablero endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                       
letra_aleatoria proc
 
 
otra_vez_1a26:  
     cmp tablero[si],'$'
     je fin_ra
     
     mov ah, 2ch      
     int 21h
                      
     mov ax,0000h
     mov al,dl
     jmp entre
     mov bl,3       
     div bl   ;Dividuo por 10 y me quedo con el resto ;de la división para garantizar entero de ;un solo
     mul dh
     
     sumar:
     add al,25
     jmp entre
     
     restar:
     sub al,25
     jmp entre
     
     entre:
     
     cmp al,41h  
     jb sumar  ; Verifico que el valor este entre 1y6
                      ; si fuera mas grande , no seria valor
                      ; de dado  
          
     cmp al,5ah
     ja restar 
     
     cmp al, tablero[si-1]
     je otra_vez_1a26
       
     cmp tablero[si],"*"
     je palabra_azar
     jne no_palabra_azar
     palabra_azar:
         mov  tablero[si] ,al ;en ah el entero generado
         inc si     
         jmp otra_vez_1a26
     no_palabra_azar:
         inc si
         jmp otra_vez_1a26

     fin_ra:
     
     ret
     
letra_aleatoria endp     
  
PROC leer_archivo
limpiar1:    
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
abrir:       
    mov al, 0h                            
    mov dx, offset path           
    mov ah, 3Dh                             
    int 21h                                
    
    jc  error                              
    mov handle, ax                       
 
    mov ax, 0
    mov dx, offset buffer 

leer:
    mov ah, 3Fh
    mov cx, 1             ; cantidad de bytes q se leeran del archivo            
    mov bx, handle        ; debemos dejar en bx el handle del archivo

    int 21h
    jc  error            
    cmp ax, 0                                
    jz  cerrar
    inc dx
    jmp leer
                    
cerrar: 
    mov ah, 3Eh                 
    mov bx, handle        
    int 21h                     
              
error:
    ret  
    
endp leer_archivo

;--------------------------------

proc dividir_buffer
limpiar2:
    xor bx,bx
    xor di,di
    xor si,si 
    
punteros1:    
  
    mov bx,offset buffer
    mov di,offset preguntas
    mov si,offset respuestas          

buffer_preguntas:    
  
    cmp [bx+1],"*" 
    je buffer_respuestas
    
    ;cmp [bx],0Ah
    ;je cambiar_a_$
    
    mov ax,[bx]  
    mov [di],ax  
    
    inc bx
    inc di
    jmp buffer_preguntas

buffer_respuestas:       
    inc bx
    cmp [bx],"#"
    je  fin_dividir_buffer   
   
    mov ax,[bx]   
    mov [si],ax  
   
    ;inc bx
    inc si
    jmp buffer_respuestas

fin_dividir_buffer:

    ret

endp dividir_buffer  
                   
proc imprimir_preguntas  
    
    ubicacion_puntero:
    mov dh, 21
	mov dl, 1
	mov bh, 0
	mov ah, 2
    int 10h
    
    mov ah, 9h
    mov dx, offset preguntas
    int 21h 
 
    ret 
 
endp imprimir_preguntas  
              
PROC respuesta_valida   
    
    xor di,di
    xor si,si
    mov contador_aux_respuestas,0
    
    mov di,offset respuestas        
    mov si,offset palabra_elegida 

    inc contador_respuesta

busco_posicion_respuesta:     
     
    cmp [di],"*"
    je respuesta_a_validar
    jne incremento

incremento:
 
    inc di
    jmp busco_posicion_respuesta    

respuesta_a_validar:
    
    inc di
    inc contador_aux_respuestas 
    
    mov bh,contador_respuesta
    cmp contador_aux_respuestas,bh ;compara si esta en el * correspondiente
   
    je comparacion
    jne busco_posicion_respuesta

comparacion:
       
    mov ah,[di]
    cmp [si],ah
       
    je letra_igual
    jne letra_desigual
                               
letra_igual:                  
    
    cmp [si],"*"
    je respuesta_correcta
    
    inc di
    inc si
    jmp comparacion

letra_desigual:
    jmp respuesta_incorrecta
          
respuesta_correcta:
    
    mov dh, 2
	mov dl, 21
	mov bh, 0
	mov ah, 2
    int 10h
    
    mov ah, 9 ;imprime mensaje de correcto
    mov dx,offset msg1
    int 21h
 
    inc respuestas_correctas  
    inc contador_respuesta   ;avanza a la sig respuesta
     
    jmp fin_respuesta_valida

respuesta_incorrecta:
    
    mov dh, 2
	mov dl, 21
	mov bh, 0
	mov ah, 2
    int 10h
      
    mov ah, 9 ;imprime mensaje de incorrecto
    mov dx,offset msg0
    int 21h

    dec contador_respuesta  
    
    inc respuestas_incorrectas ;no avanza a la sig respuesta
    
    jmp fin_respuesta_valida

fin_respuesta_valida:
   
    mov contador_aux_respuestas,0
    ret  

endp respuesta_valida   
  
  
  
  
  
  
  