\ ---------------------------------- \
\ ------- Configure hardware ------- \
\ ---------------------------------- \
link l1: ct
link l2: rdm
link l3: rdd

link m: z, z, z, z, z, nz, 15, 14, 13, 12, 11, 10
link ra: 3, 2, 1, 0
link rb: 8, 7, 6, 5

accept dev[0]: i, 12h, 13h, 1, 10
accept dev[1]: o, 92h, 93h, 1, 10
accept dev_buf[0]: 0ch, 6h, 0fh, 0ch, 0

{cjp nz, start;}

\ -------------- TEST
dw 0:  0101000000000100%

dw 1:  0000000000000000%
dw 2:  1111111111111111%
dw 3:  0000000000000001%

dw 4:  0001000000000001%
dw 5:  0010000000000100%
dw 6:  0001000000000010%
dw 7:  0010000000000101%
dw 8:  0001000000000011%
dw 9:  0010000000000110%

dw 10: 0000000000010010%
dw 11: 0010000000000000%

dw 12: 0000000000010010%
dw 13: 0010000000000001%

dw 14: 1001100000100000%
dw 15: 0101100000011000%
dw 16: 0100100000010010%
dw 17: 0101000000010100%

dw 18: 0010100000000101%
dw 19: 0101000000010110%

dw 20: 0010100000000110%
dw 21: 0101000000010110%

dw 22: 0000100010010010%
dw 23: 0101000000001100%

dw 24: 0010100000000100%
dw 25: 0000100010010010%
dw 26: 1111110000000000%
\ -------------- TEST ENDS



\ --------------------------------- \
\ ------- Operations vector ------- \
\ --------------------------------- \
org 40h
    {cjp nz, op_in;}
org 42h
    {cjp nz, op_out;}
org 44h
    {cjp nz, op_read;}
org 46h
    {cjp nz, op_write;}
org 48h
    {cjp nz, op_get;}
org 4ah
    {cjp nz, op_put;}
org 52h
    {cjp nz, op_js;}
org 54h
    {cjp nz, op_jmp;}
org 56h
    {cjp nz, op_jz;}

org 60h
    {cjp nz, op_mov;}
org 61h
    {cjp nz, op_add;}
org 62h
    {cjp nz, op_sub;}
org 63h
    {cjp nz, op_or;}
org 64h
    {cjp nz, op_and;}
org 65h
    {cjp nz, op_xor;}
org 66h
    {cjp nz, op_cmp;}
org 67h
    {cjp nz, op_swap;}
org 68h
    {cjp nz, op_mul;}
\org 69h
\    {cjp nz, op_div;}

org 7fh
    {cjp nz, op_exit;}



\ ---------------------------------- \
\ ------- Operations details ------- \
\ ---------------------------------- \

\ ------- MOV reg1, reg2 -------
op_mov
    {cjs nz, s_chk_regb;}
    {or rb, ra, z;}
{cjp nz, caddr;}

\ ------- IN port -------
op_in
    {cjs nz, s_cut_addr;}
    {or r9, 0080h, z;}
    {or nil, r8, z; oey; ewl;}
    op_in_ldsr
        {i; cjp rdd, cp; or r11, bus_d, z;}
        {and nil, r11, r9; cjp zo, op_in_ldsr;}
    {add r8, 1;}
    {or nil, r8, z; oey; ewl;}
    {i; cjp rdd, cp; or r15, bus_d, z;}
{cjp nz, caddr;}

\ ------- OUT port -------
op_out    
    {cjs nz, s_cut_addr;}
    {or r9, 0080h, z;}
    {or nil, r8, z; oey; ewl;}
    op_out_lsr
        {i; cjp rdd, cp; or r11, bus_d, z;}
        {and nil, r11, r9; cjp zo, op_out_lsr;}
    {add r8, 1;}
    {or nil, r8, z; oey; ewl;}
    {o; cjp rdd, cp; or nil, r15, z; oey;}
{cjp nz, caddr;}

\ ------- READ address -------
op_read
    {cjs nz, s_cut_addr;}
    {or nil, r8, z; oey; ewl;}
    {r; cjp rdm, cp; or r15, bus_d, z;}
{cjp nz, caddr;}

\ ------- WRITE address -------
op_write
    {cjs nz, s_cut_addr;}
    {or nil, r8, z; oey; ewl;}
    {w; cjp rdm, cp; or nil, r15, z; oey;}
{cjp nz, caddr;}

\ ------- GET reg -------
op_get
    {cjs nz, s_chk_reg;}
    {cjs nz, s_cut_reg;}
    {or sll, r8, z;}
    {or sll, r8, z;}
    {or sll, r8, z;}
    {or sll, r8, z;}
    {or sll, r8, z;}
    {or r9, 0fh, z;}
    {add r8, r9; oey; load ra; load rb;}
    {or rb, ra, z;}
{cjp nz, caddr;}

\ ------- PUT reg -------
op_put
    {cjs nz, s_cut_reg;}
    {or r9, 1e0h, z;}
    {add r8, r9; oey; load ra; load rb;}
    {or rb, ra, z;}
{cjp nz, caddr;}

\ ------- ADD reg1, reg2 -------
op_add
    {cjs nz, s_chk_regb;}
    {add rb, rb, ra, z;}
{cjp nz, caddr;}

\ ------- SUB reg1, reg2 -------
op_sub
    {cjs nz, s_chk_regb;}
    {sub rb, rb, ra, nz;}
{cjp nz, caddr;}

\ ------- OR reg1, reg2 -------
op_or
    {cjs nz, s_chk_regb;}
    {or rb, ra;}
{cjp nz, caddr;}

\ ------- AND reg1, reg2 -------
op_and
    {cjs nz, s_chk_regb;}
    {and rb, ra;}
{cjp nz, caddr;}

\ ------- XOR reg1, reg2 -------
op_xor
    {cjs nz, s_chk_regb;}
    {xor rb, ra;}
{cjp nz, caddr;}

\ ------- CMP reg1, reg2 -------
op_cmp
    {sub nil, rb, ra, nz; cjp zo, op_cmp_sz;}
    {cjp nz, op_cmp_cz;}
op_cmp_s2
    {sub nil, rb, ra, nz; cjp no, op_cmp_ss;}
    {cjp nz, op_cmp_cs;}
op_cmp_sz
    {or r9, 0001h, z;}
    {or r10, r9;}
    {cjp nz, op_cmp_s2;}
op_cmp_cz
    {or r9, 0fffeh, z;}
    {and r10, r9;}
    {cjp nz, op_cmp_s2;}
op_cmp_ss
    {or r9, 0002h, z;}
    {or r10, r9;}
    {cjp nz, op_cmp_end;}
op_cmp_cs
    {or r9, 0fffdh, z;}
    {and r10, r9;}
    {cjp nz, op_cmp_end;}
op_cmp_end
{cjp nz, caddr;}

\ ------- SWAP reg1, reg2 -------
op_swap
    {cjs nz, s_chk_regb;}
    {cjs nz, s_chk_reg;}
    
    {or r11, 0180h, z;}
    {or nil, r11, z; oey; load rb;}
    {or r11, r8, z;}
    {or srl, r11, z;}
    {or srl, r11, z;}
    {or srl, r11, z;}
    {or srl, r11, z;}
    {or srl, r11, z;}
    {or nil, r11, z; oey; load ra;}
    {or rb, ra, z;}
    
    {or nil, r8, z; oey; load ra; load rb;}
    {or rb, ra, z;}
    
    {or r11, 000ch, z;}
    {or nil, r11, z; oey; load ra;}
    {or r11, r8, z;}
    {or sll, r11, z;}
    {or sll, r11, z;}
    {or sll, r11, z;}
    {or sll, r11, z;}
    {or sll, r11, z;}
    {or nil, r11, z; oey; load rb;}
    {or rb, ra, z;}    
{cjp nz, caddr;}

\ ------- JS address -------
op_js
    {cjs nz, s_cut_addr;}
    {or r9, 0002h, z;}
    {and nil, r10, r9; cjp zo, op_js_cont;}
        {or r7, r8, z;}
        {cjp nz, start;}
op_js_cont
{cjp nz, caddr;}

\ ------- JZ address -------
op_jz
    {cjs nz, s_cut_addr;}
    {or r9, 0001h, z;}
    {and nil, r10, r9; cjp zo, op_jz_cont;}
        {or r7, r8, z;}
        {cjp nz, start;}
op_jz_cont
{cjp nz, caddr;}

\ ------- JMP address -------
op_jmp
    {cjs nz, s_cut_addr;}
    {or r7, r8, z;}
{cjp nz, start;}

\ ------- EXIT -------
op_exit
{cjp nz, exit;}

\ ------- MUL reg1, reg2 -------
op_mul
    {or r9, 0160h, z;}
    {or nil, r9, r9; oey; load rb;}
    {or rb, ra, z;}

    {or r9, 0180h, z;}
    {or nil, r9, r9; oey; load rb;}
    {or r9, r8, z;}
    {or srl, r9, z;}
    {or srl, r9, z;}
    {or srl, r9, z;}
    {or srl, r9, z;}
    {or srl, r9, z;}
    {or nil, r9, z; oey; load ra;}
    {or rb, ra, z;}

    {xor r13, r13;}
    {xor r14, r14;}
    {xor r15, r15;}

    {or r9, 8000h, z;}

    \ X = r11
    \ 0.Y = r12:r13
    \ Z = R14:R15

op_mul_op
    {add srl, r12, z;}                     \ Transform r12:r13=Y to r12:r13=0.Y
    {add sr.9, r13, z;}

op_mul_it
    {and nil, r11, r9; cjp zo, op_mul_vr;} \ Check first bit
                                           \ If it is not 1
    {add r15, r13; load rm, flags;}        \   Count sum
    {add r14, r12, rm_c;}

op_mul_vr
    {add sll, r11, z;}                     \ Shift other registers
    {add srl, r12, z;}                     \ } Use r12:r13 as one
    {add sr.9, r13, z;}                    \ }            register

    {or r11, r11; cjp not zo, op_mul_it;}  \ Check multiplyer emptynes
                                           \ If it's not 0 - count next op_mul_itation
{cjp nz, caddr;}



\ ------------------------------------- \
\ ------- COMMAND CYCLE program ------- \
\ ------------------------------------- \
start

\ ------- READ COMMAND FROM MEMORY -------
{or nil, r7, z; oey; ewl;}            \ Put command addr to ShD
{r; cjp rdm, cp; or r8, bus_d, z;}    \ Read command from memory

\ ------- CHECK COMMAND FORMAT -------
{or r9, 8000h, z;}                    \ Load command format mask
{and nil, r8, r9; cjp not zo, dtac;}  \ Check command format

\ ------- CHECK ADRESS TYPE (F = 0) -------
{or r9, 0400h, z;}                    \ Load adress type mask
{and nil, r8, r9; cjp not zo, caddr;} \ Check adress type

\ ------- PERFORM OPERATION (F = 0, T = 0) -------
{or nil, r8, r8; oey; jmap;}          \ ---->>>



\ ******* TWO OPERAND COMMANDS (F=1) *******
dtac

\ ------- CHECK ADRESS TYPE 1 (F = 1) -------
{or r9, 0200h, z;}                    \ Load adress type mask
{and nil, r8, r9; cjp not zo, caddr;} \ Check adress type

\ ------- CHECK ADRESS TYPE 2 (F = 1) -------
{or r9, 0010h, z;}                    \ Load adress type mask
{and nil, r8, r9; cjp not zo, caddr;} \ Check adress type

\ ------- LOAD OPERANDS (F = 1, T = 00) -------
{or nil, r8, z; oey; load ra; load rb;}

\ ------- PERFORM OPERATION (F = 1) -------
{or nil, r8, z; oey; jmap;}           \ ---->>>



\ ******* COUNT NEXT COMMAND *******
caddr {add r7, 1;}                    \ Increment IP
{cjp nz, start;}



\ --------------------------- \
\ ------- SUBPROGRAMS ------- \
\ --------------------------- \
s_load_op
    {and nil, r8, 03ffh; oey; ewl;}
    {r; cjp rdm, cp; or r11, bus_d, z;}
{crtn nz;}

s_cut_addr
    {or r9, 03ffh, z;}
    {and r8, r9;}
{crtn nz;}

s_cut_reg
    {or r9, 0007h, z;}
    {and r8, r9;}
{crtn nz;}

s_chk_regb
    {or r9, 00e0h, z;}
{cjp nz, s_cmp_neq;}

s_chk_reg
    {or r9, 0007h, z;}
{cjp nz, s_cmp_neq;}

s_cmp_neq
    {or r11, r9, z;}
    {and r11, r8;}
    {xor nil, r11, r9; crtn not zo;}
{cjp nz, caddr;}


\ ------------------------ \
\ ------- POWEROFF ------- \
\ ------------------------ \
exit {}
