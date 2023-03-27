Using Recursion

FUNCTION zfibonacci.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_NUM) TYPE  INT4
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE  INT4
*"----------------------------------------------------------------------

DATA : index_n1 TYPE int4.
DATA : index_n2 TYPE int4.
DATA : lv_result1 TYPE int4.
DATA : lv_result2 TYPE int4.

  lv_result1 = 0.
  lv_result2 = 0.

  index_n1 = im_num - 1.
  index_n2 = im_num - 2.

IF im_num = 1 OR im_num = 2.
  result = 1.
ELSE.

CALL FUNCTION 'ZFIBONACCI'
  EXPORTING
    im_num        = index_n1
 IMPORTING
   result        = lv_result1
          .

CALL FUNCTION 'ZFIBONACCI'
  EXPORTING
    im_num        = index_n2
 IMPORTING
   result        = lv_result2
          .
result = lv_result1 + lv_result2.

ENDIF.

ENDFUNCTION.
