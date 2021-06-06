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

		String_num 		db 		"Nivel:4$"
        String_palavra  db	    "          $"	;10 digitos
		String_game  	db	    "          $"	;10 digitos
		
		String_menu		db		"       $"		;7 digitos

		Construir_nome	db	    "            $"	
		Dim_nome		dw		5	; Comprimento do Nome
		indice_nome		dw		0	; indice que aponta para Construir_nome
		
		Fim_Jogo		db		0 ; Se for 0 o jogo não acabou se for 1 o jogo acabou
		Fim_Ganhou		db	    " Ganhou $"	
		Fim_Perdeu		db	    " Perdeu $"	

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'menu.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		nFich			db		0	;Saber qual .txt buscar (0-menu,1-jogo,2-top10)


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

mudaJogo:
		mov		Fich[0],'l'
		mov		Fich[0],'a'
		mov		Fich[0],'b'
		mov		Fich[0],'i'
	


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

Tempo_Contador PROC

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
		MOV 	STR12[0],al			 
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
		MOV 	STR12[0],al			 
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
		MOV 	STR12[0],al			 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		goto_xy	10,0
		MOSTRA	STR12 	
		

		inc		Tempo_j
		mov 	ax,Tempo_j
		MOV 	bl, 10     
		div 	bl
		
		add 	al, 30h				
		add		ah,	30h				
		MOV 	String_TJ[1],al
		MOV		String_TJ[2],ah

		cmp 	al,':'
		jne		Nao_100
		mov 	al,'0'
		MOV 	String_TJ[1],al
		cmp 	ah,'0'
		jne		Nao_100
		MOV 	String_TJ[0],'1'
		jmp		Perder

Nao_100:
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
			
Perder:
	goto_xy	60,20
	MOSTRA	Fim_Perdeu
	goto_xy	60,0
	MOSTRA	String_TJ
	mov		al,1
	mov 	Fim_Jogo,al
	jmp 	fim_horas
Tempo_Contador ENDP





;########################################################################
; LE UMA TECLA	
LE_TECLA	PROC
sem_tecla:
		cmp		nFich, 1
		jne		sem_teclaMENU	;se estiver no menu nao mostra o contador

		call 	Tempo_Contador
		cmp 	Fim_Jogo,1
		je		SAIR_JOGO
sem_teclaMENU:					;nao entra no sem_tecla, logo nao mostra o cronometro
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

SAIR_JOGO:	mov		al, 27	;tecla escape
			jmp 	SAI_TECLA	
LE_TECLA	endp




;########################################################################
; Niveis

Nivel	PROC
	mov 	al,String_num[6]	
	goto_xy 30,0
	MOSTRA	String_num
	cmp 	al,'1'
	je		nivel1
	cmp 	al,'2'
	je		nivel2
	cmp 	al,'3'
	je		nivel3
	cmp 	al,'4'
	je		nivel4
	cmp 	al,'5'
	je		nivel5
	
nivel1:
	mov		String_palavra[0],'I'
	mov		String_palavra[1],'S'
	mov		String_palavra[2],'E'
	mov		String_palavra[3],'C'
	goto_xy 10,20
	MOSTRA String_palavra
	jmp 	Sair_Nivel
nivel2:	
	mov		String_palavra[0],'A'
	mov		String_palavra[1],'R'
	mov		String_palavra[2],'R'
	mov		String_palavra[3],'O'
	mov		String_palavra[4],'Z'
	goto_xy 10,20
	MOSTRA String_palavra
	jmp 	Sair_Nivel
nivel3:
	mov		String_palavra[0],'B'
	mov		String_palavra[1],'A'
	mov		String_palavra[2],'T'
	mov		String_palavra[3],'A'
	mov		String_palavra[4],'T'
	mov		String_palavra[5],'A'
	goto_xy 10,20
	MOSTRA String_palavra
	jmp 	Sair_Nivel
nivel4:
	mov		String_palavra[0],'A'
	mov		String_palavra[1],'U'
	mov		String_palavra[2],'T'
	mov		String_palavra[3],'O'
	mov		String_palavra[4],'C'
	mov		String_palavra[5],'A'
	mov		String_palavra[6],'R'
	mov		String_palavra[7],'R'
	mov		String_palavra[8],'O'
	goto_xy 10,20
	MOSTRA String_palavra	
	jmp 	Sair_Nivel
nivel5:
	mov		String_palavra[0],'Z'
	mov		String_palavra[1],'A'

	goto_xy 10,20
	MOSTRA String_palavra
	jmp 	Sair_Nivel
Sair_Nivel: RET
Nivel	endp





;########################################################################
; Encontrar a Palavra
Encontrar_Palavra	PROC
	cmp		car,' '
	je		Sair_Palavra
	mov 	bx,0
	mov		cx,10
	mov 	al,car
Ciclo_Palavra:
	cmp		al,String_palavra[bx]
	jne		Diferente	
	mov		String_game[bx],al	
	goto_xy 10,21
	MOSTRA String_game
	mov 	car,' '
	

Diferente:
	inc		bx
	loop Ciclo_Palavra
Sair_Palavra: RET
Encontrar_Palavra	endp





;########################################################################
; Avatar
AVATAR	PROC
INICIO:
			mov		ax,0B800h
			mov		es,ax

			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
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
		

VERIFICA_CONCLUSAO:
			call 	Encontrar_Palavra
			mov 	cx,10
			mov 	bx,0
Ciclo_compara:
			mov al, String_palavra[bx]
			cmp al, String_game[bx]
			jne		LER_SETA
			inc		bx
			loop	Ciclo_compara
			jmp		PROXIMO_NIVEL

			

LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27	; ESCAPE
			JE		FIM
			jmp		LER_SETA

PROXIMO_NIVEL:
			inc		String_num[6]
			cmp 	String_num[6],'6'
			je		GANHAR
			mov 	cx,10
			mov 	bx,0
Ciclo_reset:
			mov 	String_game[bx],' '
			mov 	String_palavra[bx],' '
			inc		bx
			loop	Ciclo_reset
			mov 	String_TJ[0],' '
			mov 	String_TJ[1],' '
			mov 	String_TJ[2],' '   
			mov		Tempo_j,0
			call		apaga_ecran
			goto_xy		0,0
			call		IMP_FICH
			call 	Nivel
			jmp 	INICIO

GANHAR:		goto_xy	60,20
			MOSTRA	Fim_Ganhou
			jmp 	FIM

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

FIM:				
			RET
AVATAR		endp

;########################################################################
; Avatar_MENU
AVATAR_MENU	PROC
INICIO:
			mov		ax,0B800h
			mov		es,ax
<<<<<<< Updated upstream

			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
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
			jmp		LER_SETA

=======

			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h			; Guarda o Caracter que est� na posi��o do Cursor
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
			jmp		LER_SETA

>>>>>>> Stashed changes
				
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy	;cima
			dec		POSy
			mov 	teclapress,al	
			jmp		CICLO

BAIXO:		cmp		al,50h
			inc 	POSy		;Baixo
			inc 	POSy
			mov 	teclapress,al	
			jmp		CICLO

PAREDE:		mov 	al,50h				;baixo
			cmp 	teclapress,48h
			je		BAIXO
			
			mov 	al,48h				;cima
			cmp 	teclapress,50h
			je		ESTEND
FIM:				
			RET
AVATAR_MENU		endp


;########################################################################
; Top 10
Top10	proc
	call		apaga_ecran
	call		IMP_FICH
Top10	endp



;########################################################################
; Menu
Menu proc	
		mov			POSx, 27
		mov			POSy, 7
<<<<<<< Updated upstream

		jmp			jogar_menu

		cmp 		POSy, 9
		je			top10_menu

=======

		jmp			jogar_menu

		cmp 		POSy, 9
		je			top10_menu

>>>>>>> Stashed changes
		cmp 		POSy, 11
		;je			sair_menu
		

jogar_menu:								;coloca [JOGAR] a cyan
		mov			al, 83H				;83H a piscar / 3H estático
		mov			bx, 1178
		mov 		cx, 7
CicloMenuJogar:
		mov			es:[bx+1], al
		inc			bx
		inc			bx
		loop		CicloMenuJogar
;fimCiclo
<<<<<<< Updated upstream
			
=======
		jmp			
>>>>>>> Stashed changes
top10_menu:
		mov			bx, 1338
		mov			cx,	7

CicloMenuTop10:
		mov			es:[bx+1], al
		inc			bx
		inc			bx
		loop		CicloMenuTop10


		call 		AVATAR_MENU

		cmp 		nFich, 1
		je			menu_jogo	


		


menu_jogo:									;apaga o ecran e muda para o jogo
		call		apaga_ecran
		call		IMP_FICH

menu_top10:
		call		apaga_ecran
		call		IMP_FICH
Menu endp



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
		call		Menu	
		call 		Nivel
		call 		AVATAR
		goto_xy		0,22
		;call		apaga_ecran
		;goto_xy	0,0
		;call 		Top10

		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main
