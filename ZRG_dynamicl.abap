"There are always times when you have certain type of
"internal table or work area, you don't want to change its
"previous state but you want to add an field so you can work
"around it as you wish.
"I have always been somewhat lazy person so I always prefer
"to make something work because I don't want to change everything
"and get my hands dirty, so I always find dynamic programming more
"helpful.
"This was somewhat I did last time when I had a requirement.
"I created a dynamic table and added my field into it
"played around.

"This is ABAP RTTS so you need to be familiar with classes
"and objects.

REPORT zrg_dynamic3.

"Creating a dynamic internal table to fetch data
DATA : itab TYPE REF TO data.
CREATE DATA itab TYPE TABLE OF ('MAKT').
FIELD-SYMBOLS : <fs_itab> TYPE ANY TABLE.
ASSIGN itab->* TO <fs_itab>.

SELECT * FROM makt USING CLIENT '110' INTO TABLE @<fs_itab> UP TO 10 ROWS.

"Requirement is just simple.
"We have to add an additional into the table and we don't know its structure.
"It gets complicated here.

DATA(lo_type) = cl_abap_typedescr=>describe_by_data( EXPORTING p_data = <fs_itab> ).

"Now, we can get object by casting of CL_ABAP_TABLEDESCR
DATA : lo_table TYPE REF TO cl_abap_tabledescr.
lo_table ?= lo_type.

"you can now use Widecasting as below too.
"this is just new ABAP syntax
*lo_table = CAST #( cl_abap_typedescr=>describe_by_data( EXPORTING p_data = <fs_itab> ) ).

"We can now get line type of the same table.
DATA : lo_data TYPE REF TO cl_abap_datadescr.
lo_data = lo_table->get_table_line_type( ).

"Now, we can get object by casting of CL_ABAP_STRUCTDESCR
DATA : lo_struct TYPE REF TO cl_abap_structdescr.
lo_struct ?= lo_data.

"If we use new CAST then we dont need to declarre lo_data reference at all.
"that's why I always prefer new syntax because why we need extra lines of
"code when we can use it implicitly.
*lo_struct = CAST #( lo_table2->get_table_line_type( ) ).

DATA(lt_components) = lo_struct->get_components( ).
APPEND INITIAL LINE TO lt_components ASSIGNING FIELD-SYMBOL(<fs_comp>).
<fs_comp>-name = 'MTART'.
<fs_comp>-type = cl_abap_elemdescr=>get_c( 4 ).

"Create a new structure.
DATA(lo_struct_new) = cl_abap_structdescr=>create( lt_components ).

"Create a new table
DATA(lo_table_new) = cl_abap_tabledescr=>create( lo_struct_new ).

"Create a new dyanamic table
DATA : itab_new TYPE REF TO data.
FIELD-SYMBOLS : <fs_tab_new> TYPE ANY TABLE.
CREATE DATA itab_new TYPE HANDLE lo_table_new.

"In this dynamic table, you will have extra column with field name 'MTART'.
ASSIGN itab_new->* TO <fs_tab_new>.
FIELD-SYMBOLS: <f_field>.
"you can do anything you like with this internal table.

MOVE-CORRESPONDING <fs_itab> TO <fs_tab_new>.
LOOP AT <fs_tab_new> ASSIGNING FIELD-SYMBOL(<fs_data>).
  ASSIGN COMPONENT 'MTART' OF STRUCTURE <fs_data> TO <f_field>.
  <F_fIELD> = 'FERT'.
ENDLOOP.


"Happy Learning
