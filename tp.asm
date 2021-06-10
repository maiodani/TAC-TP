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

		String_num 		db 		"Nivel:1$"
        String_palavra  db	    "          $"	;10 digitos
		String_game  	db	    "          $"	;10 digitos
		String_Pontos 	db		"000$"		;pontuacao ate 999 (3 digitos)
		Pontos 			dw		000
		num_car			db		0	
		
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

		nFich			db		0	;Saber qual .txt buscar (0-menu,1-jogo,2-top10,3-sair)

		string			db	"Teste pr�tico de T.I",0
		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]	
		POSya			db	3	; Posi��o anterior de y
		POSxa			db	3	; Posi��o anterior de x
		paredecar		db  32
		teclapress		db  0


		;NÃO USADO POR FALTA DE TEMPO
		buffer 			db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,10
						db	'xxx-xxxxxxxxxx',13,108

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
		goto_xy 0,0
        mov     ah,3dh
        mov     al,0

		cmp		nFich, 0
		je		mudaMenu

		cmp		nFich, 1
		je		mudaJogo

		cmp		nFich, 2
		je		mudaTop10

		cmp		nFich, 3
		je 		sai_f
inicio_imp:
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

mudaMenu:
		mov		Fich[0],'m'
		mov		Fich[1],'e'
		mov		Fich[2],'n'
		mov		Fich[3],'u'
				
		jmp 	inicio_imp


mudaJogo:
		mov		Fich[0],'l'
		mov		Fich[1],'a'
		mov		Fich[2],'b'
		mov		Fich[3],'i'
				
		jmp 	inicio_imp

mudaTop10:
		mov		Fich[0],'t'
		mov		Fich[1],'p'
		mov		Fich[2],'1'
		mov		Fich[3],'0'

		jmp 	inicio_imp

IMP_FICH	endp		



;NÃO ACABADA POR FALTA DE TEMPO

;GUARDAR_FICH	PROC
;		abre ficheiro
;
;       mov     ah,3dh
;       mov     al,1
;inicio_imp:
;       lea     dx,Fich_escrever
;       int     21h
;       jc      erro_abrir
;        mov     HandleFich,ax
 ;       jmp     ler_ciclo

	
;erro_abrir:
 ;       mov     ah,09h
  ;      lea     dx,Erro_Open
   ;     int     21h
    ;    jmp     sai_f

;ler_ciclo:
 ;       mov     ah,40h
  ;      mov     bx,HandleFich
   ;     mov     cx,200
	;	LEA		dx,buffer
     ;   int     21h
      ;  cmp	ax,cx		;EOF?
       ; je	fecha_ficheiro

;erro_ler:
 ;       mov     ah,09h
  ;      lea     dx,Erro_Ler_Msg
   ;     int     21h

;fecha_ficheiro:
 ;       mov     ah,3eh
  ;      mov     bx,HandleFich
   ;     int     21h
    ;    jnc     sai_f

     ;   mov     ah,09h
      ;  lea     dx,Erro_Close
       ; Int     21h
;sai_f:	
;		RET

;GUARDAR_FICH	endp	



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
	mov 	Tempo_j,0
	jmp		fim_horas
Tempo_Contador ENDP





;########################################################################
; LE UMA TECLA	
LE_TECLA	PROC
sem_tecla:
		cmp		nFich, 1
		jne		sem_teclaMENU	;se estiver no menu/top10 nao mostra o contador

		call 	Tempo_Contador
		cmp 	Fim_Jogo,1
		je		SAIR_JOGO

		MOV		AH,0BH
		INT 	21h
		cmp 	AL,0
		je	    sem_tecla
sem_teclaMENU:					;nao entra no sem_tecla, logo nao mostra o cronometro		
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET

SAIR_JOGO:	mov		nFich, 2
			jmp 	SAI_TECLA	
LE_TECLA	endp




;########################################################################
; Niveis

Nivel	PROC
	goto_xy 12,23
	MOSTRA 	String_Pontos
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
	mov		String_palavra[2],'M'
	mov		String_palavra[3],'B'
	mov		String_palavra[4],'U'
	mov		String_palavra[5],'J'
	mov		String_palavra[6],'E'
	mov		String_palavra[7],'I'
	mov		String_palavra[8],'R'
	mov		String_palavra[9],'O'
	goto_xy 10,20
	MOSTRA String_palavra
	jmp 	Sair_Nivel
Sair_Nivel: 
	mov		POSx, 3			;posicao original
	mov		POSy, 3
	RET
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

	add		Pontos,5

Diferente:
	inc		bx
	loop Ciclo_Palavra

	

	xor 	ax,ax
	mov 	ax,Pontos
	mov 	bx,2
	mov 	cx,3
	mov		dl,10
CICLO_PONTOS:	
	xor		ah,ah
	div 	dl	
	add 	ah,48
	mov		String_Pontos[bx],ah
	dec		bx
	loop	CICLO_PONTOS
	goto_xy 12,23
	MOSTRA 	String_Pontos
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
			mov 	al, String_palavra[bx]
			cmp 	al, String_game[bx]
			jne		LER_SETA
			inc		bx
			loop	Ciclo_compara
			jmp		PROXIMO_NIVEL

			

LER_SETA:	call 	LE_TECLA

			cmp		nFich, 2
			je 		FIM

			cmp		ah, 1
			je		ESTEND

ESCAPE:
			CMP 	AL, 27	; ESCAPE<
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
			goto_xy		0,0
			mov		POSx,3
			mov		POSy,3
			mov		POSxa,3
			mov		POSya,3
			call		apaga_ecran
			call		IMP_FICH
			call 	Nivel
			jmp 	INICIO

GANHAR:		goto_xy	60,20
			MOSTRA	Fim_Ganhou
			ret

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
			mov		dl, 190		; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy	; Vai para posi��o do cursor
		
			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 	POSya, al
			

LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			cmp		al,13
			je		ENTER_PRESS
			jmp		LER_SETA

				
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy	;cima
			dec		POSy
			mov 	teclapress,al	

			cmp		POSy, 7
			je		saltaParaJogo

			cmp		POSy, 9
			je		saltaParaTop10	

			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ENTER_PRESS
			
			inc 	POSy		;Baixo
			inc 	POSy
			mov 	teclapress,al

			cmp		POSy, 9
			je		saltaParaTop10

			cmp		POSy, 11
			je		saltaParaSair

			jmp		CICLO		

ENTER_PRESS:
			cmp		ah,0
			jne		colocaAHa0
			cmp		al,0Dh				;ENTER
			jne		CICLO

			cmp		POSy, 7
			je		mudaParaJogo

			cmp		POSy, 9
			je		mudaParaTop10

			cmp		POSy, 11
			je		mudaParaSair

PAREDE:		mov 	al,50h				;baixo
			cmp 	teclapress,48h
			je		BAIXO
			
			mov 	al,48h				;cima
			cmp 	teclapress,50h
			je		ESTEND


colocaAHa0:
			mov		ah, 0
			jmp		ENTER_PRESS
saltaParaJogo:
			call	MenuJogoFunc
			RET

saltaParaTop10:
			call	MenuTop10Func
			RET
saltaParaSair:
			call	MenuSairFunc
			RET

mudaParaJogo:
			mov 	nFich, 1
			jmp		FIM

mudaParaTop10:
			mov 	nFich, 2
			jmp		FIM

mudaParaSair:
			mov		nFich, 3
FIM:				
			RET


AVATAR_MENU		endp

AVATAR_TOP10	proc
INICIO:
			mov		ax,0B800h
			mov		es,ax

LER_SETA:	call 	LE_TECLA
ESCAPE:
			CMP 	AL, 27	; ESCAPE
			JE		FIM
			jmp		LER_SETA
FIM:				
			RET
AVATAR_TOP10	endp
;########################################################################
; Top 10
Top10	proc
		call		AVATAR_TOP10
		mov			nFich, 0

		RET	
Top10	endp



;########################################################################
; Menu
Menu proc	
		mov			POSx, 27
		mov			POSy, 7

		cmp			POSy, 7
		call		MenuJogoFunc

verificaNFICH:
		cmp			nFich, 0
		jne			FIM_menu

		jmp 		Menu

FIM_menu:
		RET		
Menu endp


MenuJogoFunc proc						;coloca [JOGAR] a cyan
		cmp			POSy, 7
		jne			saltaMtop

		call		LimpaSelecionado

		mov			al, 83H				;83H a piscar / 3H estático
		mov			bx, 1178
		mov 		cx, 7
CicloMenuJogar:
		mov			es:[bx+1], al
		inc			bx
		inc			bx
		loop		CicloMenuJogar
;fimCiclo		
		call		AVATAR_MENU
		RET
saltaMtop:
		call		MenuTop10Func
		RET
								
MenuJogoFunc endp

MenuTop10Func proc
		cmp			POSy, 9
		jne			saltaSair

		call		LimpaSelecionado		

		mov			al, 83H
		mov			bx, 1498
		mov			cx,	10
CicloMenuTop10:
		mov			es:[bx+1], al
		inc			bx
		inc			bx
		loop		CicloMenuTop10

		call		AVATAR_MENU
		RET
saltaSair:
		call		MenuSairFunc
			
MenuTop10Func endp


MenuSairFunc proc
		cmp			POSy, 11
		jne			saltaJogo
		
		call		LimpaSelecionado

		mov			al, 83H
		mov			bx, 1818
		mov			cx,	6

CicloSair:
		mov			es:[bx+1], al
		inc			bx
		inc			bx
		loop		CicloSair

		call		AVATAR_MENU
		RET
saltaJogo:
		RET
			
MenuSairFunc endp

LimpaSelecionado proc
		mov			al, 15
		mov			bx, 1178
		mov 		cx, 7

		CicloLimpa1:
					mov			es:[bx+1], al
					inc			bx
					inc			bx
					loop		CicloLimpa1
		;--
		mov			al, 15
		mov			bx, 1498
		mov			cx,	10

		CicloLimpa2:
					mov			es:[bx+1], al
					inc			bx
					inc			bx
					loop		CicloLimpa2
		;--
		mov			al, 15
		mov			bx, 1818	
		mov			cx,	6

		CicloLimpa3:
					mov			es:[bx+1], al
					inc			bx
					inc			bx
					loop		CicloLimpa3

		RET
LimpaSelecionado endp



;########################################################################
; MAIN
Main  proc

		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
INICIO_main:
		goto_xy		0,0
		;call 		GUARDAR_FICH
		cmp			nFich, 1
		jne			main_jump
		
		call		apaga_ecran
		call		IMP_FICH
		call 		Nivel
		call 		AVATAR
		goto_xy		0,22
		
		cmp			nFich, 2
		je			main_jump

		cmp			nFich, 0
		je			main_jump
		

		;call		apaga_ecran
		;goto_xy	0,0
		;call 		Top10
		jmp			FIM_main

main_jump:
		cmp			nFich, 3
		je			FIM_main
			
		;coloca no ecran o menu (caso nFich=0) ou o top10 (caso nFich=1)
		call		apaga_ecran
		call		IMP_FICH
		
		cmp			nFich, 2
		je			top10_main	

		call		Menu
		
		jmp 		INICIO_main

top10_main:
		call		Top10
		jmp 		INICIO_main
FIM_main:
		call		apaga_ecran
		mov			ah,4CH
		INT			21H
Main	endp
Cseg	ends
end	Main
