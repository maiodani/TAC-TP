.8086
.model small
.stack 2048

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		DDMMAAAA 		db		"                     "
		
		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os �ltimos segundos que foram lidos
		Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	dw		100				; tempo m�ximo de Jogo
		String_TJ		db		"   /100$"

		String_num 		db 		"  0 $"
        String_nome  	db	    "ISEC  $"	
		Construir_nome	db	    "            $"	
		Dim_nome		dw		5	; Comprimento do Nome
		indice_nome		dw		0	; indice que aponta para Construir_nome
		
		Fim_Ganhou		db	    " Ganhou $"	
		Fim_Perdeu		db	    " Perdeu $"	

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'labi.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		string			db	"Teste pr�tico de T.I",0
		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		POSya			db	3	; Posi��o anterior de y
		POSxa			db	3	; Posi��o anterior de x
		paredecar		db  32
		teclapress		db  0
		
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

goto_xy	macro		POSx,POSy
        ;~INT 10,2~ - Set cursor position
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

MOSTRA MACRO STR 
MOV AH,09H
LEA DX,STR 
INT 21H
ENDM

; FIM DAS MACROS



;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
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
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

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
		
IMP_FICH	endp		

;########################################################################
; Imprime o tempo no monitor
Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 

Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		mov 	ax,Horas
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		goto_xy 2,0
		MOSTRA STR12 		
        
		mov 	ax,Minutos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],'$'
		goto_xy	6,0
		MOSTRA	STR12 		
		
		mov 	ax,Segundos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		goto_xy	10,0
		MOSTRA	STR12 	
		mov cx,100

		inc		Tempo_j
		mov 	ax,Tempo_j
		MOV 	bl, 10     
		div 	bl
		
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		
		MOV 	String_TJ[1],al
		MOV		String_TJ[2],ah
		goto_xy	60,0
		MOSTRA	String_TJ	

						
fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP
Tempo PROC

Tempo ENDP
;########################################################################
; LE UMA TECLA	
LE_TECLA	PROC
sem_tecla:
		call 	Trata_Horas
		MOV		AH,0BH
		INT 	21h
		cmp 	AL,0
		je	    sem_tecla
		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			mov		ax,0B800h
			mov		es,ax

			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h		; Guarda o Caracter que est� na posi��o do Cursor
			mov		bh,0			; numero da p�gina
			int		10h			
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor	

			goto_xy	1,1
			mov 	ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
			mov		bh,0			; numero da p�gina
			int		10h	
			mov paredecar,al
	

CICLO:		goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h	

			cmp 	al, paredecar
			je		PAREDE
			
			goto_xy	POSxa,POSya		; Vai para a posi��o anterior do cursor
			mov		ah, 02h
			mov		dl, Car			; Repoe Caracter guardado 
			int		21H		
		
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h		
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor

			goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posi��o no canto
			mov		dl, Car	
			int		21H			
			
			goto_xy	POSx,POSy		; Vai para posi��o do cursor
IMPRIME:	mov		ah, 02h
			mov		dl, 190	; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy	; Vai para posi��o do cursor
		
			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 	POSya, al
		
LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27	; ESCAPE
			JE		FIM
			jmp		LER_SETA


;label parede: faz o inverso (ex:caso haja uma parede na direita, o cursor após mover-se para a direita move-se para esquerda, invalidando o seu movimento, ficando na posição original)
PAREDE:		mov 	al,50h				;baixo
			cmp 	teclapress,48h
			je		BAIXO
			
			mov 	al,48h				;cima
			cmp 	teclapress,50h
			je		ESTEND

			mov 	al,4Dh				;direita
			cmp 	teclapress,4Bh
			je		DIREITA
			
			mov 	al,4Bh				;esquerda
			cmp 	teclapress,4Dh
			je		ESQUERDA
				
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy	;cima
			mov 	teclapress,al	
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			mov 	teclapress,al	
			jmp		CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			mov 	teclapress,al	
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			mov 	teclapress,al	
			jmp		CICLO

fim:				
			RET
AVATAR		endp

;########################################################################
; MAIN
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		call		apaga_ecran
		goto_xy		0,0
		call		IMP_FICH
		call 		AVATAR
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main
