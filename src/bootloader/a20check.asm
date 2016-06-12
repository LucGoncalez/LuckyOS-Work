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

A20_ADDRESS_LOW   equ 0x0500
A20_ADDRESS_HIGH  equ 0x0510

;===========================================================================
;	function CheckA20 : Boolean; external; {far; nostackframe}
; --------------------------------------------------------------------------
;	Faz o teste "Wrap Around", e retorna se habilitado ou nao.
;===========================================================================
	ALIGN 4
CheckA20:
	; NOTA: Instruções rearranjadas para aproveitar o paralelismo das
	;       Unidades de execução processadores 486 ou superioers.
	; NOTA: Não precisamos salvar FS e GS pq não são usados pelo TP ou pela BIOS.

	; definindo posicoes de memoria para testar
	xor ax, ax		; ax = 0
	mov fs, ax		; FS = 0x0000
	not ax				; ax = 0xFFFF
	mov gs, ax		; GS = 0xFFFF

	; desabilita as interrrupcoes por seguranca
	cli

	movzx ax,byte [fs:A20_ADDRESS_LOW]  ; Lê da memória baixa (Zera AH).
	mov cl,al                           ; Salva valor lido.
	not al                              ; Inverte todos os bits de AL.
	mov [gs:A20_ADDRESS_HIGH], al       ; Grava na memória alta.
	xor al,[fs:A20_ADDRESS_LOW]         ; Se forem iguais AL=0 (e ZF=1).
	                                    ; Se forem diferentes AL=0xff (e ZF=0).
	mov [fs:A20_ADDRESS_LOW],cl         ; Devolve o valor original para 0x0000:0x0500.

	; reabilitando as interrupcoes
	sti

	; Retorna
	;	0 = A20 Desligada
	;	1 = A20 Ligada
	retf
