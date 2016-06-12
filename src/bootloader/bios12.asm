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
;	Lib BIOS12.asm
;	--------------------------------------------------------------------------
;	Esta Lib possui procedimentos da Int12h.
;	--------------------------------------------------------------------------
;	Versao: 0.3.1-RC1
;	Data: 09/06/2016
;	--------------------------------------------------------------------------
;	Compilar: Compilavel pelo nasm (montar)
;	> nasm -f obj bios12.asm
;	------------------------------------------------------------------------
;	Executar: Nao executavel diretamente.
;===========================================================================

GLOBAL BiosInt12

SEGMENT CODE PUBLIC USE 16

;===========================================================================
;	function BiosInt12 : Word; external; {far; nostackframe}
; --------------------------------------------------------------------------
;	Obtem a quantidade de memoria baixa em KB.
;===========================================================================
  ALIGN 4
BiosInt12:
	xor ax, ax
	call near Int12$
	jc .error  	; funcao nao suportada
	retf

  ALIGN 4
.error:
	xor ax, ax 	; retorno zero eh erro
  retf				; finaliza a rotina

;===========================================================================
;	Int12$
; --------------------------------------------------------------------------
;	Salva registradores e chama a rotina da BIOS.
;===========================================================================
  ALIGN 4
Int12$:
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

	int 0x12

	pop bp
	pop di
	pop si
	pop es
	pop ds
  retn
