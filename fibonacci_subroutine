Using subroutine.

This is something intresting that you would love.

"Using Recursion
REPORT zrg_fibonacci.

PARAMETERS : number TYPE int4.

DATA : result TYPE int4.
DATA : lv_num TYPE int4.

START-OF-SELECTION.

lv_num = number.

PERFORM fibonacci USING lv_num CHANGING result.

WRITE : |The fibonacci of the { number } : { result } |.
*&---------------------------------------------------------------------*
*&      Form  FIBONACCI
*&---------------------------------------------------------------------*
FORM fibonacci  USING    p_lv_num
                CHANGING p_result.

  DATA : lv_result1 TYPE int4,
         lv_result2 TYPE int4.
  DATA : index_n1 TYPE int4,
         index_n2 TYPE int4.

index_n1 = p_lv_num - 1.
index_n2 = p_lv_num - 2.

IF  p_lv_num LE 2.
 p_result = 1.
ELSE.

lv_num = index_n1.
PERFORM fibonacci USING lv_num CHANGING result.
lv_result1 = result.

lv_num = index_n2.
PERFORM fibonacci USING lv_num CHANGING result.
lv_result2 = result.

result = lv_result1 + lv_result2.
ENDIF.

ENDFORM.
