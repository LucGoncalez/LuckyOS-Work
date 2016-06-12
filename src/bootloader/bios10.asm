;===========================================================================
;	Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
;	--------------------------------------------------------------------------
;	Copyright (C) 2013 - Luciano L. Goncalez
;	--------------------------------------------------------------------------
;	a.k.a.: Master Lucky
;	eMail : master.lucky.br@gmail.com
;	Home  : http://lucky-labs.blogspot.com.br
;===========================================================================
;	Colaboradores:
;	--------------------------------------------------------------------------
;	Frederico Lamberti Pissarra <fredericopissarra@gmail.com>
;===========================================================================
;	Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
;	sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
;	Software Foundation; na versao 2 da	Licenca.
;
;	Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
;	GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
;	ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
;	Geral GNU para obter mais detalhes.
;
;	Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
;	este programa; se nao, escreva para a Free Software Foundation, Inc., 59
;	Temple Place, Suite 330, Boston, MA	02111-1307, USA. Ou acesse o site do
;	GNU e obtenha sua licenca: http://www.gnu.org/
;===========================================================================
;	Lib BIOS10.asm
;	--------------------------------------------------------------------------
;	Esta Lib possui procedimentos da Int10h.
;	--------------------------------------------------------------------------
;	Versao: 0.3.1-RC1
;	Data: 08/06/2016
;	--------------------------------------------------------------------------
;	Compilar: Compilavel pelo nasm (montar)
;	> nasm -f obj bios10.asm
;	------------------------------------------------------------------------
;	Executar: Nao executavel diretamente.
;===========================================================================

CPU 386

GLOBAL BiosInt10x0F, BiosInt10x1130B

SEGMENT CODE PUBLIC USE 16

;===========================================================================
;	function BiosInt10x0F : DWord; external; {far; nostackframe}
; --------------------------------------------------------------------------
;	Obtem o estado do video atual.
; --------------------------------------------------------------------------
;	Retorno: DWord::
;
;		TBiosInt10x0FResult = packed record
;			Mode : Byte;	(AL)
;			Cols : Byte;	(AH)
;			Page : Byte;	(DL)
;			Nul1 : Byte;	(DH)
;		end;
;
;===========================================================================
	ALIGN 4
BiosInt10x0F:
	mov ax, 0x0F00	; Funcao Get Video State

	call near Int10$
	; AL => Modo do video
	; AH => Numero de colunas
	; BH => Numero da pagina de video atual

	movzx dx, bh
	retf

;===========================================================================
;	function BiosInt10x1130B(FuncNo : Byte) : DWord; external; {far}
; --------------------------------------------------------------------------
;	Obtem o estado do video atual.
; --------------------------------------------------------------------------
;	Retorno: DWord::
;
;		TBiosInt10x1130B_Result = packed record
;			BytesPerChar : Word;	(AX)
;			Rows : Byte;					(DL)
;			Nul1 : Byte;					(DH)
;		end;
;
;===========================================================================
	ALIGN 4
BiosInt10x1130B:
	;	bp+4	=> FuncNo
	; bp+2	=> IP-Retorno
	; bp		=> BP

	xor bx, bx
	xor dx, dx

	push bp
	mov bp, sp

	mov bh, [bp + 4]	; coloca FuncNo em BH
	mov ax, 0x1130

	call near Int10$
	; CX => Numero de bytes por caracter (pontos?)
	; DL => Numero de linhas (-1)
	; ES:BP => Ponteiro para a tabela (suprimido na chamada Int10$)

	mov ax, cx
	leave
	etf 2

;===========================================================================
;	Int10$
; --------------------------------------------------------------------------
;	Salva registradores e chama a rotina de video da BIOS.
;===========================================================================
	ALIGN 4
Int10$:
	; registradore gerais usados como parametros
	;	ax, bx, cx, dx

	; registradores de segmento que nao se alteram
	; cs, ss

	; registradores de ponteiros que nao se alteram
	; sp, ip

	; registradores que podem ser alterados durante a chamada
	push ds
	push es
	push si
	push di
	push bp

	int 0x10

	pop bp
	pop di
	pop si
	pop es
	pop ds
	retn
