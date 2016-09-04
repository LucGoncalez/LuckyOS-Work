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
; Software Foundation; na versao 2 da Licenca.
;
; Este programa e distribuido na expectativa de ser util, mas SEM QUALQUER
; GARANTIA; sem mesmo a garantia implicita de COMERCIALIZACAO ou de
; ADEQUACAO A QUALQUER PROPOSITO EM PARTICULAR. Consulte a Licenca Publica
; Geral GNU para obter mais detalhes.
;
; Voce deve ter recebido uma copia da Licenca Publica Geral GNU junto com
; este programa; se nao, escreva para a Free Software Foundation, Inc., 59
; Temple Place, Suite 330, Boston, MA 02111-1307, USA. Ou acesse o site do
; GNU e obtenha sua licenca: http://www.gnu.org/
;===========================================================================
; Lib BootAux.asm
; --------------------------------------------------------------------------
; Esta Lib possui procedimentos que auxiliam o boot.
; --------------------------------------------------------------------------
; Versao: 0.6.1-RC2
; Data: 14/06/2016
; --------------------------------------------------------------------------
; Compilar: Compilavel pelo nasm (montar)
; > nasm -f obj bootaux.asm
; ------------------------------------------------------------------------
; Executar: Nao executavel diretamente.
;===========================================================================

CPU 386

; Stack Frame usado por EnableUnreal.
struc EnableUnrealStkFrame
  .oldbp    resw  1
  .retaddr  resd  1
  .descseg  resw  1
  .size:
endstruc
EnableUnrealStkCleanup equ (EnableUnrealStkFrame.size - EnableUnrealStkFrame.descseg)

struc CopyLinearStkFrame
  .oldbp    resw  1
  .retaddr  resd  1
  .count    resd  1
  .dest     resd  1
  .src      resd  1
  .size:
endstruc
CopyLinearStkCleanup equ (CopyLinearStkFrame.size - CopyLinearStkFrame.count)

struc GoKernel32PMStkFrame
  .oldbp    resw  1
  .retaddr  resd  1
  .param    resd  1
  .stack    resd  1
  .entry    resd  1
  .ss       resw  1
  .es       resw  1
  .ds       resw  1
  .cs       resw  1
endstruc

GLOBAL EnableUnreal, CopyLinear, GoKernel32PM

SEGMENT DATA PUBLIC

ALIGN 2
  ; Variaveis locais usadas por GoKernel16
  CSeg    RESW  1
  DSeg    RESW  1
  ESeg    RESW  1
  Entry   RESD  1
  Param   RESD  1

SEGMENT CODE PUBLIC USE 16

;===========================================================================
; procedure EnableUnreal(DescSeg : Word); external; {far}
; --------------------------------------------------------------------------
; Habilita o modo Unreal, usando o DescSeg passado.
;===========================================================================
ALIGN 2
EnableUnreal:
  ; cria stackframe
  push bp
  mov bp, sp

  ; salva segmentos atuais
  push ds
  push es

  ; pega o DescSeg
  mov cx, [bp + EnableUnrealStkFrame.descseg]

  ; ativa o modo protegido
  mov eax, cr0
  mov edx, eax  ; sera utilizado para desabilitar ;)
  or eax, 1
  mov cr0, eax

  ; configura descritores DS e ES
  mov ds, cx
  mov es, cx

  ; desativa o modo protegido
  mov cr0, edx

  ; reculpera segmentos antigos
  pop es
  pop ds

  ; limpa a stackframe
  leave
retf EnableUnrealStkCleanup

;===========================================================================
;  procedure CopyLinear(Src, Dest, Count : DWord); external; {far}
; --------------------------------------------------------------------------
;  Copia Count bytes de Src para Dest.
;===========================================================================
ALIGN 2
CopyLinear:
  ; cria a stackframe
  push bp
  mov bp, sp

  mov eax, [bp + CopyLinearStkFrame.count]    ; carrega Count

  ; Testa de Count = 0
  test eax, eax
  jz .exitcpy

  ; salva registradores
  push ds
  push si
  push di

  mov edi, [bp + CopyLinearStkFrame.dest]  ; carrega Dest
  mov esi, [bp + CopyLinearStkFrame.src]  ; carrega Src

  ; fazendo a copia manualmente, nao garantido que "rep movsb"
  ;    faca isso corretamente neste modo "misto"

  ; copiando blocos de 4 bytes
  mov ecx, eax
  and eax, 3  ; pega o resto
  shr ecx, 2  ; divide por 2^2 = 4
  cmp eax, 1  ; CF=1 if EAX == 0; CF=0 if EAX > 0.
  sbb ecx, -1  ; ECX = ECX -(-1 + CF)

  ; trabalhando com enderecos lineares, segmento igual a zero
  xor ax, ax
  mov ds, ax

  align 4
.docpy:
  dec ecx
  mov eax, [esi + ecx * 4]
  mov [edi + ecx * 4], eax
  jnz .docpy

  ; recupera registradores
  pop di
  pop si
  pop ds

.exitcpy:
  ; limpa a stackframe
  leave
retf CopyLinearStkCleanup

;===========================================================================
;  procedure GoKernel32PM(CS, DS, ES, SS : Word; Entry, Stack : DWord; Param : DWord);
;    external; {far}
; --------------------------------------------------------------------------
;  Configura e chama o kernel previamente carregado:
;
;    CS : Segmento/descritor do codigo;
;    DS : Segmento/descritor de dados;
;    ES : Segmento/descritor extra;
;    SS : Segmento/descritor da pilha;
;
;    Entry : Ponto de entrada do kernel (Offset em CS);
;    Stack : Base da pilha (Offset em SS);
;    Param : Parametro passado ao kernel em EAX;
;===========================================================================
ALIGN 2
GoKernel32PM:
  ; cria stackframe
  push bp
  mov bp, sp

  ; salva valores em variaveis no segmento de dados
  mov ax, [bp + GoKernel32PMStkFrame.cs]  ; CS
  mov [CSeg], ax

  mov ax, [bp + GoKernel32PMStkFrame.ds]  ; DS
  mov [DSeg], ax

  mov ax, [bp + GoKernel32PMStkFrame.es]  ; ES
  mov [ESeg], ax

  mov eax, [bp + GoKernel32PMStkFrame.entry]  ; Entry
  mov [Entry], eax

  mov eax, [bp + GoKernel32PMStkFrame.param]  ; Param
  mov [Param], eax

  ; Liga o flag PE
  ; O modo protegido só será ativado depois do próximo farjmp.
  mov eax, cr0
  or eax, 1
  mov cr0, eax

  ; configura nova pilha
  mov dx, [bp + GoKernel32PMStkFrame.ss]    ; pega SS
  mov eax, [bp + GoKernel32PMStkFrame.stack]  ; pega ESP (Stack)

  mov ss, dx    ; atualiza o segmento da pilha
  mov esp, eax  ; atualiza ponteiro do topo da pilha
  mov ebp, eax  ; atualiza ponteiro da base da pilha

  mov dword [ebp], 0  ; grava elemento nulo no comeco da pilha

  ; coloca endereco do salto na pilha
  push word [CSeg]
  push dword [Entry]

  ; coloca valores de DS e ES na pilha
  push word [DSeg]
  push word [ESeg]

  ; pega parametro
  mov eax, [Param]

  ; atualiza segmentos de dados
  pop es
  pop ds

  mov ebx, esp  ; poe o ponteiro para o salto em EBX (EAX contem parametro)
  mov esp, ebp  ; limpa o ponteiro da pilha (mantem valores la...)

  ; salta para o kernel e para o modo protegido! (atualiza CS e Entry)
  jmp dword far [ebx]

; Fim da rotina, impossivel retornar a esse ponto...
