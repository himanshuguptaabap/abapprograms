REPORT zrg_virtual_sort.

"Virtual sorting is nothing but a way to sort an internal table
"without the need of modification of the original table.

"virtual sort method returns an sorted array of index number by company,
"then we use same index number to read our ITAB table and print it out.

TYPES : BEGIN OF ty_data,
          id      TYPE int4,
          name    TYPE char40,
          desig   TYPE char40,
          company TYPE char40,
        END OF ty_data,
        tt_type TYPE TABLE OF ty_Data WITH EMPTY KEY.

DATA : lr_out TYPE REF TO if_demo_output.

DATA(itab) = VALUE
                 tt_type(
                          ( id = '1200' name = 'Ram'    desig = 'Manager'     company = 'ETT' )
                          ( id = '1400' name = 'Aman'   desig = 'IT Head'     company = 'CTT' )
                          ( id = '1500' name = 'Bhuvan' desig = 'Social Head' company = 'PTT' )
                          ( id = '1600' name = 'Aditya' desig = 'Developer'   company = 'ITT' ) ).

lr_out = cl_demo_output=>new( ).
lr_out->begin_section( 'ITAB non-sorted by company' ).
lr_out->write( itab ).
lr_out->next_section( 'ITAB sorted by company' ).
lr_out->write( VALUE tt_type( FOR <index>
                              IN cl_abap_itab_utilities=>virtual_sort(
                                 im_virtual_source =
                                 VALUE #( (  source     = REF #( itab )
                                             components = VALUE #( ( name = 'company' )  ) ) ) )
                                ( itab[ <index> ] ) ) ).

lr_out->next_section( 'Our ITAB is still intact' ).
lr_out->write( itab ).
lr_out->display( ).
