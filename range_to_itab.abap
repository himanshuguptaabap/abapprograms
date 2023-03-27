REPORT zrg_range_int.

"Created Range for Material which are going to be fetched.
"We can use range to avoid the joins in some cases when we have large queries.
TYPES : BEGIN OF ty_matnr,
          matnr TYPE matnr,
        END OF ty_matnr,
        tt_matnr TYPE STANDARD TABLE OF ty_matnr WITH EMPTY KEY.

SELECT 'I' AS sign,
       'EQ' AS option,
        matnr AS low,
        matnr AS high
        FROM mara
        USING CLIENT '110'
        INTO TABLE @DATA(r_matnr) UP TO 100 ROWS.

"To convert range to an internal table.
DATA(it_matnr) = VALUE tt_matnr( FOR ls_matnr
                                 IN r_matnr (  matnr = ls_matnr-low ) ).

"To convert internal to range and RSDSSELOPT_T is structure type of Range
"so you dont need declaration of range anymore explicitly.
DATA(r_range2) = VALUE rsdsselopt_t( FOR wa
                                     IN it_matnr
                                     ( sign = 'I' Option = 'EQ' Low = wa-matnr ) ).

"Since I don't have Demo system so I can't put output.
"If you like the post, so share with other ABAPers.
