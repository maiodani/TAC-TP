.8086
.model small
.stack 2048

dseg segment para public 'data'
        Fich_escrever   db      'teste.TXT',0
        HandleFich      dw      0
        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
dseg ends

cseg segment para public 'code'
assume cs:cseg, ds:dseg

GUARDAR_FICH	PROC
		;abre ficheiro

        mov     ah,3dh
        mov     al,1
inicio_imp:
        lea     dx,Fich_escrever
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo

	
erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,40h
        mov     bx,HandleFich
        mov     cx,1
        mov     dx,"s"
        int     21h
        jc	erro_ler
        cmp	ax,0		;EOF?
        je	fecha_ficheiro

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET

GUARDAR_FICH	endp	
main proc
     mov ax, dseg
     mov ds, ax

     call GUARDAR_FICH

     mov al, 0
     mov ah, 4ch
     int 21h
main endp

cseg ends

end main