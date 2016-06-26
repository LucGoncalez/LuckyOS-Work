;===========================================================================
; Este arquivo pertence ao Projeto do Sistema Operacional LuckyOS (LOS).
; --------------------------------------------------------------------------
; Copyright (C) 2013 - Luciano L. Goncalez
; --------------------------------------------------------------------------
; a.k.a.: Master Lucky
; eMail : master.lucky.br@gmail.com
; Home  : http://lucky-labs.blogspot.com.br
;===========================================================================
; Colaboradores:
; --------------------------------------------------------------------------
; Frederico Lamberti Pissarra <fredericopissarra@gmail.com>
;===========================================================================
; Este programa e software livre; voce pode redistribui-lo e/ou modifica-lo
; sob os termos da Licenca Publica Geral GNU, conforme publicada pela Free
; Software Foundation; na versao 2 da  Licenca.
;
; Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
; GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
; ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
; Geral GNU para obter mais detalhes.
;
; Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
; este programa; se nao, escreva para a Free Software Foundation, Inc., 59
; Temple Place, Suite 330, Boston, MA  02111-1307, USA. Ou acesse o site do
; GNU e obtenha sua licenca: http://www.gnu.org/
;===========================================================================
; Lib KBC8042.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimento para acessar o controlador de teclado 8042.
; --------------------------------------------------------------------------
; Versao: 0.1.1-RC1
; Data: 14/06/2016
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj kbc8042.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

struc Write8042StkFrame
  .retaddr  resd  1
  .value    resw  1
  .size:
endstruc
Write8042StkCleanup equ (Write8042StkFrame.size - Write8042StkFrame.value)

GLOBAL Read8042StatusReg, Write8042CommandReg
GLOBAL Read8042OutputReg, Write8042DataReg
GLOBAL Wait8042Empty, Wait8042Done

; constantes
  StatusReg   EQU   0x64
  CommandReg  EQU   0x64
  OutputReg   EQU   0x60
  DataReg     EQU   0x60

;===========================================================================
;  WaitInRegEmpty
; --------------------------------------------------------------------------
;  Aguarda que a porta de comando/dados (0x64/0x60) do 8042 esteja vazia.
;===========================================================================
%macro WaitInRegEmpty 0
  align 2
%%loop:
  in al, StatusReg
  test al, 2
  jnz %%loop
%endmacro

;===========================================================================
;  WaitOutRegDone
; --------------------------------------------------------------------------
;  Aguarda que a porta de dados (0x60) do 8042 esteja cheia.
;===========================================================================
%macro WaitOutRegDone 0
  align 2
%%loop:
  in al, StatusReg
  test al, 1
  jz %%loop
%endmacro

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; function Read8042StatusReg : Byte; external; {far; nostackframe}
; --------------------------------------------------------------------------
; Le a porta de status (0x64) do 8042, retornando o valor.
;===========================================================================
ALIGN 2
Read8042StatusReg:
  xor ax, ax
  in al, StatusReg
retf

;===========================================================================
; procedure Write8042CommandReg(Value : Byte); external; {far; nostackframe}
; --------------------------------------------------------------------------
; Escreve um comando para a porta de comando (0x64) do 8042.
;===========================================================================
ALIGN 2
Write8042CommandReg:
  push bp
  mov  bp,sp

  WaitInRegEmpty  ; espera command register estar vazio

  mov  al, [bp+Write8042StkFrame.value]    ; pega Value
  out CommandReg, al

  leave
retf Write8042StkCleanup

;===========================================================================
;  function Read8042OutputReg : Byte; external; {far; nostackframe}
; --------------------------------------------------------------------------
;  Le a porta de saida (0x60) do 8042, retornando o valor.
;===========================================================================
ALIGN 2
Read8042OutputReg:
  WaitOutRegDone  ; espera que o dado esteja no registro
  xor ax, ax
  in al, OutputReg
retf

;===========================================================================
; procedure Write8042DataReg(Value : Byte); external; {far; nostackframe}
; --------------------------------------------------------------------------
; Escreve um valor para a porta de dados (0x60) do 8042.
;===========================================================================
ALIGN 2
Write8042DataReg:
  push bp
  mov  bp,sp

  WaitInRegEmpty

  mov al, [bp+Write8042StkFrame.value]  ; pega Value
  out DataReg, al

  leave
retf Write8042StkCleanup

;===========================================================================
;  procedure Wait8042Empty; external; {far; nostackframe}
; --------------------------------------------------------------------------
;  Aguarda que a porta de comando/dados (0x64/0x60) do 8042 esteja vazia.
;===========================================================================
ALIGN 2
Wait8042Empty:
  WaitInRegEmpty
retf

;===========================================================================
;  procedure Wait8042Done; external; {far; nostackframe}
; --------------------------------------------------------------------------
;  Aguarda que a porta de dados (0x60) do 8042 esteja cheia.
;===========================================================================
ALIGN 2
Wait8042Done:
  WaitOutRegDone
retf
