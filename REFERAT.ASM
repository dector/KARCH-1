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
accept r2: 3
accept r3: 2
accept r4: 4

dw 0: 1000000001000011% \ mov r2, r3
dw 1: 0000000000010010% \ in 12h
dw 2: 0000100010010010% \ out 92h
dw 3: 0001000000001100% \ read 12h
dw 4: 0001100000001101% \ write 13h
dw 5: 0010000000000010% \ get r2
dw 6: 0010100000000100% \ put r4
dw 7: 1000000011100011% \ mov r7, r3 !!!
dw 8: 0010000000000111% \ get r7 !!!

dw 12: 22h
dw 13: 0
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
\org 4ch
\    {cjp nz, op_writed;}
\org 4eh
\    {cjp nz, op_readd;}
\org 50h
\    {cjp nz, op_geth;}
\org 52h
\    {cjp nz, op_js;}
\org 54h
\    {cjp nz, op_jmp;}
\org 56h
\    {cjp nz, op_jz;}

org 60h
    {cjp nz, op_mov;}
\org 61h
\    {cjp nz, op_add;}
\org 62h
\    {cjp nz, op_sub;}
\org 63h
\    {cjp nz, op_or;}
\org 64h
\    {cjp nz, op_and;}
\org 65h
\    {cjp nz, op_xor;}
\org 66h
\    {cjp nz, op_cmp;}
\org 67h
\    {cjp nz, op_swap;}
\org 68h
\    {cjp nz, op_mul;}
\org 69h
\    {cjp nz, op_div;}

\org 7fh
\    {cjp nz, op_exit;}



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
    {or r9, 0080h, z;}
    {or nil, r8, z; oey; ewl;}
    {r; cjp rdm, cp; or r15, bus_d, z;}
{cjp nz, caddr;}

\ ------- WRITE address -------
op_write
    {cjs nz, s_cut_addr;}
    {or r9, 0080h, z;}
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
    {or r9, 0fh;}
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


op_acc_too
{cjp nz, caddr;}

op_to_acc
{or r15, r0, z; FIELD bc1, 010%, 011%, 001%, 0, 0fh, 1;}
{cjp nz, caddr;}

op_load
{or r9, 001fh, z;}
{and nil, r9, r8; oey;}
{r; cjp rdm, cp; or rb, bus_d, z;}
{cjp nz, caddr;}

\ --- ADD operation ---------------
op_add
{add rb, ra;}
{cjp nz, caddr;}

\ --- MUL operation ---------------
op_mul
\ X = R10
\ 0.Y = R11:R12
\ Z = R14:R15

{xor r9, r9;}
{xor r10, r10;}
{or r10, r15;}
\ R11 already loaded
{xor r12, r12;}
{xor r13, r13;}
{or r13, 8000h;}
{xor r14, r14;}
{xor r15, r15;}

     {and nil, r10, r13; cjp zo, tst1;}
     {sub r10, z, r10, nz;}
     {xor r9, 8000h;}
tst1 {and nil, r11, r13; cjp zo, oper;}
     {sub r11, z, r7, nz;}
     {xor r9, 8000h;}

oper {add srl, r11, z;}                     \ Transform R11:R12=Y to R11:R12=0.Y
     {add sr.9, r12, z;}

iter {and nil, r10, r13; cjp zo, var1;}     \ Check first bit
                                            \ If it is not 1
     {add r15, r12; load rm, flags;}        \   Count sum
     {add r14, r11, rm_c;}

var1 {add sll, r10, z;}                     \ Shift other registers
     {add srl, r11, z;}                     \ } Use R11:R12 as one
     {add sr.9, r12, z;}                    \ }            register

{or r10, r10; cjp not zo, iter;}            \ Check multiplyer emptynes
                                            \ If it's not 0 - count next iteration
{and nil, r9, r13; cjp zo, caddr;}
{or r14, 8000h;}

{cjp nz, caddr;}

\ --- CJP command -----------------
op_cjp
{xor r9, r9;}
{or r9, 0080h;}
{and r9, r15; cjp not zo, caddr;}
{xor r9, r9;}
{or r9, 007fh;}
{and r8, r9;}
{xor r7, r7;}
{or r7, r8;}
{cjp nz, start;}

\ --- JMP command -----------------
op_jmp
{xor r7, r7;}
{or r7, 0001h;}
{cjp nz, start;}

\ --- ADD1 ------------------------
op_add1
{or r9, 03ffh, z;}
{and nil, r9, r8; oey; ewl;}
{r; cjp rdm, cp; or r11, bus_d, z;}
{add r15, r11;}
{cjp nz, caddr;}

\ --- SAVE ------------------------
op_save
{or r9, 03ffh, z;}
{and nil, r9, r8; oey; ewl;}
{w; cjp rdm, cp; or r15, r15; oey;}
{cjp nz, caddr;}

\ --- EXIT command ----------------
op_exit
{cjp nz, exit;}



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
    {cjs nz, s_cmp_neq;}
{crtn not zo;}
{cjp nz, caddr;}

s_chk_reg
    {or r9, 0007h, z;}
    {cjs nz, s_cmp_neq;}
{crtn not zo;}
{cjp nz, caddr;}

s_cmp_neq
    {or r11, r9, z;}
    {and r11, r8;}
    {xor nil, r11, r9;}
{crtn nz;}


\ ------------------------ \
\ ------- POWEROFF ------- \
\ ------------------------ \
exit {}
