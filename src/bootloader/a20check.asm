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
;	Lib A20Check.asm
;	--------------------------------------------------------------------------
;	Esta Lib possui procedimento para verificacao da A20.
;	--------------------------------------------------------------------------
;	Versao: 0.1.1-RC1
;	Data: 11/06/2016
;	--------------------------------------------------------------------------
;	Compilar: Compilavel pelo nasm (montar)
;	> nasm -f obj a20check.asm
;	------------------------------------------------------------------------
;	Executar: Nao executavel diretamente.
;===========================================================================

CPU 386

GLOBAL CheckA20

SEGMENT CODE PUBLIC USE 16

;===========================================================================
;	function CheckA20 : Boolean; external; {far; nostackframe}
; --------------------------------------------------------------------------
;	Faz o teste "Wrap Around", e retorna se habilitado ou nao.
;===========================================================================
CheckA20:
	; NOTA: Instruções rearranjadas para aproveitar o paralelismo das
	;       Unidades de execução processadores 486 ou superioers.

	; definindo posicoes de memoria para testar
	xor ax, ax		; ax = 0

	push ds
	push es

	mov es, ax		; ES = 0x0000

	push di
	push si

	not ax				; ax = 0xFFFF

	mov di, 0x0500
	mov si, 0x0510

	mov ds, ax		; DS = 0xFFFF
	xor ax, ax

	; desabilita as interrrupcoes por seguranca
	cli

	; salvando valores originais
  mov cl, [es:di]
  mov ch, [si]

	; gravando novos valores na memoria
	mov [es:di], al				; es:di = 0000:0500 => 000500 = 0x00
	mov byte [si], 0xFF		; ds:si = FFFF:0510 => 100500 = 0xFF

	; Necessita "invalidar" a cache do processador?

	; copia valor da memoria para AL, 0x00 => A20-ON, 0xFF => A20-OFF
	mov al, [es:di]

	; devolvendo os valores originais
  mov [es:di], cl
	mov [si], ch

	; reabilitando as interrupcoes
	sti

	; verifica se houve wrap around
	test al, al		; al = 0 (ON) => ZF = 1
	sete al				; ZF = 1 => al = 1

	; Retorna
	;		0 = A20 Desligada
	;		1 = A20 Ligada

	; recupera registradores
	pop si
	pop di
	pop es
	pop ds
retf
