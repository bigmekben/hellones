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

loadPalettes:
  LDA $2002 		; read PPU status to reset high/low latch
  LDA #$3F	
  STA $2006		; high byte of destination address
  LDA #$00
  STA $2006		; low byte of destination address
  LDX #$00
loadPalettesLoop:
  LDA palette, x
  STA $2007
  INX
  CPX #$20
  BNE loadPalettesLoop

  LDA #$80
  STA $0200		; sprite 0's vertical coord
  STA $0203		; sprite 0's horizontal coord
  LDA #$00
  STA $0201		; tile number
  STA $0202		; color = 0; no flipping

  LDA #%10000000	; enable NMI, use pattern table 0 for sprites
  STA $2000

  LDA #%00010000	; enable sprites
  STA $2001

forever:
  JMP forever

NMI:
  ; This copies the data from RAM to the OEM.
  LDA #$00		; set low byte of RAM address
  STA $2003
  LDA #$02
  STA $4014		; set high byte of RAM address and start the transfer	
  RTI


  .bank 1
  .org $E000
palette:
  .db $0F, $31, $32, $33, $0F, $35, $36, $37, $0F, $39, $3a, $3B, $0F, $3D, $3E, $0F
  .db $0F, $1C, $15, $14, $0F, $02, $38, $3C, $0F, $1C, $15, $14, $0F, $02, $38, $3C

  .org $FFFA
  .dw NMI
  .dw RESET
  .dw 0

  .bank 2
  .org $0000
  .incbin "hellones.chr"	; SMB1 graphics, 8K 
