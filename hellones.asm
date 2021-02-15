  .inesprg 1 ; 16KB PRG code
  .ineschr 1 ; 8KB CHR data
  .inesmap 0 ; mapper 0  (NROM)
  .inesmir 1 ; background mirror mode = 

  .bank 0
  .org $C000
RESET:
  SEI		; disable IRQs
  CLD		; disable decimal mode
  LDX #$40
  STX $4017	; disable APU frame IRQ
  LDX #$FF
  TXS		; start the stack at 255th byte
  INX		; cause X = 0
  STX $2000	; disable NMI
  STX $2001	; disable rendering
  STX $4010	; disable DMC IRQs

firstvblankwait:
  BIT $2002
  BPL firstvblankwait	; wait for PPU wakeup at system startup

resetmemory:
  LDA #$00	; clear out the OEM
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE resetmemory

secondvblankwait:
  BIT $2002		; second PPU vblank means PPU is fully woken up
  BPL secondvblankwait

  LDA #%10000000	; for demo purposes, just intensify blues 
  STA $2001

forever:
  JMP forever

NMI:
  RTI


  .bank 1
  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0

  .bank 2
  .org $0000
  .incbin "mario.chr"	; SMB1 graphics, 8K 
