Using Recursion

FUNCTION zfactorial2.

*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(NUM) TYPE  INT4
*"  EXPORTING
*"     REFERENCE(FACT) TYPE  INT4
*"----------------------------------------------------------------------

DATA : im_num TYPE int4,
       ex_num TYPE int4.

      im_num = 0.
      ex_num = num.

IF num EQ 0.
 fact = 1.
ELSE.
  fact = num.
  ex_num = num - 1.

CALL FUNCTION 'ZFACTORIAL2'
  EXPORTING
    num           = ex_num
 IMPORTING
   fact          = im_num.

 fact = fact * im_num.
ENDIF.

ENDFUNCTION.
