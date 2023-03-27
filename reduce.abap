"This is very common code which is mostly used.
"In Purchase, we have condition number and purchase document in Purchase Order,
"we have item number in Purchase Item Table,
"and then, we have to fetch total sum of values present in Pricing Table
"with condition number present in Purchase header table and item number present
"in Purchase item Table.

REPORT zrg_reduce2.
TYPES:

  BEGIN OF y_ekko,
    ebeln TYPE ekko-ebeln,
    knumv TYPE ekko-knumv,
  END OF y_ekko,
  yt_ekko TYPE SORTED TABLE OF y_ekko
          WITH UNIQUE KEY ebeln knumv,

  BEGIN OF y_ekpo,
    ebeln TYPE ekpo-ebeln,
    ebelp TYPE ekpo-ebelp,
    netwr TYPE ekpo-netwr,
  END OF y_ekpo,
  yt_ekpo TYPE SORTED TABLE OF y_ekpo
          WITH UNIQUE KEY ebeln ebelp,

  BEGIN OF y_komv,
    knumv TYPE komv-knumv,
    kposn TYPE komv-kposn,
    kschl TYPE komv-kschl,
    kwert TYPE komv-kwert,
  END OF y_komv,
  yt_komv TYPE SORTED TABLE OF y_komv
          WITH NON-UNIQUE KEY knumv kposn kschl.

DATA it_ekpo  TYPE yt_ekpo.
DATA it_ekko  TYPE yt_ekko.
DATA it_komv  TYPE yt_komv.

DATA : lr_out TYPE REF TO if_demo_output.

lr_out = cl_demo_output=>new( ).


"We have created one purchase order header
it_ekko = VALUE #( ( ebeln = '0040000000' knumv = '0000000001' ) ).

"Purchase order item
it_ekpo = VALUE #(  ( ebeln = '0040000000' ebelp = '10'	 )
                    ( ebeln = '0040000000' ebelp = '20'	 )
                    ( ebeln = '0040000000' ebelp = '30'	 ) ).
"Pricing Table
it_komv = VALUE #(  ( knumv = '0000000001' kposn = '10'	kschl = 'RA01' kwert = '10.00'  )
                    ( knumv = '0000000001' kposn = '10'	kschl = 'PBXX' kwert = '350.00' )
                    ( knumv = '0000000001' kposn = '20'	kschl = 'RA01' kwert = '2.00'   )
                    ( knumv = '0000000001' kposn = '20'	kschl = 'RA01' kwert = '3.50'   )
                    ( knumv = '0000000001' kposn = '20'	kschl = 'PBXX' kwert = '400.00' )
                    ( knumv = '0000000001' kposn = '10'	kschl = 'RA01' kwert = '5.00'   )
                    ( knumv = '0000000001' kposn = '10'	kschl = 'PBXX' kwert = '200.00' ) ).

lr_out->begin_section( 'IT_EKKO' ).
lr_out->write( it_ekko ).

lr_out->next_section( 'IT_EKPO' ).
lr_out->write( it_ekpo ).

lr_out->next_section( 'IT_KOMV' ).
lr_out->write( it_KOMV ).

"Earlier we used to code like that.
LOOP AT it_ekpo ASSIGNING FIELD-SYMBOL(<fs_ekpo>).
  READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<fs_ekko>) WITH KEY ebeln = <fs_EKPO>-ebeln.
  IF sy-subrc IS INITIAL.
    LOOP AT it_komv ASSIGNING FIELD-SYMBOL(<fs_komv>)
      WHERE knumv = <fs_ekko>-knumv AND kposn = <fs_ekpo>-ebelp.
      <fs_ekpo>-netwr = <fs_ekpo>-netwr + <fs_komv>-kwert.
    ENDLOOP.
  ENDIF.
ENDLOOP.

"Now we can use REDUCE operator and skip the inner loop completely
LOOP AT it_ekpo ASSIGNING FIELD-SYMBOL(<fs>).
  READ TABLE it_ekko ASSIGNING FIELD-SYMBOL(<fs2>) WITH KEY ebeln = <fs>-ebeln.
  IF sy-subrc IS INITIAL.
    <fs>-netwr = REDUCE #(   INIT price = 0
                             FOR wa IN FILTER #( it_komv USING KEY primary_key
                             WHERE knumv = <fs2>-knumv AND kposn = CONV #( <fs>-ebelp ) )
                             NEXT price = price + wa-kwert ).
  ENDIF.
ENDLOOP.
*

lr_out->next_section( 'IT_EKPO' ).
lr_out->write( it_ekpo ).


"you can also use it to concatenate in a string which
"which will further reduce your efforts and bring effieciency
"you can see its use when you have to print multiple status
"in one line.
TYPES : BEGIN OF ty_str,
          str TYPE string,
        END OF  ty_str,
        tt_str TYPE TABLE OF ty_str WITH EMPTY KEY.

DATA(it_str) = VALUE tt_str(  ( str = 'string 1' )
                              ( str = 'string 2' )
                              ( str = 'string 3' )
                              ( str = 'string 4' )
                              ( str = 'string 5' )
                              ( str = 'string 6' )
                              ( str = 'string 7' )
                              ( str = 'string 8' ) ).

"one way to concatenate string
"point to be noted
"every variable initialized in INIT should also be used after NEXT
"these are implicitly created variable.
DATA(lv_str) = REDUCE #( INIT ls_str TYPE string
                              lv_sep = '-'
                         FOR wa_str IN it_str
                         NEXT ls_str = Ls_str && lv_sep && WA_stR-sTR
                         lv_sep = ' ' ).

"other way to concatenare string
"i will prefer this way to concatenate the string,
"but we can see that i have used STRING instead of #
"because reduce operator can't detect data type in which
"it is getting converted so it gives a syntax error
DATA(lv_str2) = REDUCE string(  LET lv_sep = '-' IN INIT ls_str TYPE string
                                FOR wa_str IN it_str
                                NEXT ls_str = Ls_STr && lv_sep && WA_stR-sTR ).

LR_OUT->display( ).
