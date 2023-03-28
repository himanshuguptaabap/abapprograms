REPORT zj1injv_uploader.
*       NO STANDARD PAGE HEADING LINE-SIZE 255.

********************************************
TYPES: slis_t_listheader TYPE slis_listheader OCCURS 1.

DATA : heading TYPE slis_t_listheader WITH HEADER LINE.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "ALV Catalog Table
      gs_fieldcat TYPE slis_fieldcat_alv.   "ALV Catalog Structure

DATA : eventstab      TYPE   slis_t_event WITH HEADER LINE,
       gd_tab_group   TYPE   slis_t_sp_group_alv,
       gd_layout      TYPE   slis_layout_alv,
       gd_repid       LIKE   sy-repid.

DATA: it_fcat TYPE slis_t_fieldcat_alv,
      wa_fcat LIKE LINE OF it_fcat,
      is_sel_hide TYPE slis_sel_hide_alv,
      it_listheader TYPE slis_t_listheader,
      wa_listheader TYPE slis_listheader.

DATA: x_save,
      alv_variant TYPE disvariant,
      alv_layout TYPE slis_layout_alv.

******************************************************

TYPES : BEGIN OF ty_final,
        bukrs TYPE bukrs, "Company Code
        gjahr TYPE gjahr,  "Financial Year
        secco TYPE char20, "Section
        qscod TYPE char20, "Section code
        kunnr TYPE kunnr,  "Customer
        lifnr TYPE lifnr,  "Vendor
        bldat(10) TYPE c, "Document Date
        budat(10) TYPE c, "Posting Date
        witht TYPE witht, "Witholding Tax
        withcd TYPE wt_withcd, "Witholding Tax code
        dmbtr TYPE char20,     "Price
        bktxt TYPE char20,     "Text
        xblnr TYPE xblnr1,      "Refrence Text
        l_msg TYPE string,
        document TYPE string,
        END OF ty_final.

DATA : l_msg TYPE string.
DATA : it_final TYPE TABLE OF ty_final,
       wa_final TYPE ty_final.
DATA : it_raw TYPE truxs_t_text_data.
DATA : it_message LIKE it_final.



DATA: BEGIN OF bdcdata OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdcdata.

DATA: messtab TYPE  bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA:  options TYPE ctu_params.

DATA: g_mesg(80) TYPE c,
      err_msg    TYPE string.

DATA : lv_post_d TYPE datum.
DATA : lv_doc_d TYPE datum.

DATA : wa_temp LIKE LINE OF it_final.
DATA : wa_bkpf TYPE bkpf.
DATA : wa_log TYPE ty_final.

TYPES : BEGIN OF ty_bkpf,
          bukrs	TYPE bukrs,
          belnr	TYPE belnr_d,
          gjahr	TYPE gjahr,
          xblnr TYPE xblnr1,
          END OF ty_bkpf.

DATA : it_bkpf TYPE TABLE OF ty_bkpf.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
PARAMETERS: p_file TYPE  rlgrap-filename OBLIGATORY.
*PARAMETERS: p_mode TYPE char4 DEFAULT 'N'.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  t1 = 'Uploader for J1INJV T-code'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.

START-OF-SELECTION.

  IF p_file IS NOT INITIAL.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
        i_line_header        = 'X'
        i_tab_raw_data       = it_raw       " WORK TABLE
        i_filename           = p_file
      TABLES
        i_tab_converted_data = it_final    "ACTUAL DATA
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE 'Wrong Data Entered in File' TYPE 'E'.
    ENDIF.
  ENDIF.

  PERFORM upload_data.
  PERFORM alv_display.

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM upload_data .
  DATA : it_temp LIKE it_final.
  DATA : gs_bkpf TYPE bkpf.

  LOOP AT it_final INTO wa_final.
    TRANSLATE wa_final-xblnr TO UPPER CASE.
    MODIFY it_final FROM wa_final TRANSPORTING xblnr.
    CLEAR : wa_final.
  ENDLOOP.

**********Delete entries in which document date is greater than posting date***********
  LOOP AT it_final INTO wa_final.
    CLEAR : lv_doc_d, lv_post_d.
    CONCATENATE wa_final-bldat+6(4) wa_final-bldat+3(2) wa_final-bldat+0(2) INTO lv_doc_d.
    CONDENSE lv_doc_d.
    CONCATENATE wa_final-budat+6(4) wa_final-budat+3(2) wa_final-budat+0(2) INTO lv_post_d.
    CONDENSE lv_post_d.
    IF lv_doc_d > lv_post_d.
      wa_final-l_msg = 'Document Date Date Greater Than Posting Date'.
      APPEND wa_final TO it_temp.
      DELETE it_final INDEX sy-tabix.
    ENDIF.
    CLEAR : wa_final.
  ENDLOOP.
*************************************Ends here********************************************

********Delete entries in which refrence number already posted ****
*******************under company code, financial year**************
  LOOP AT it_final INTO wa_final.
    TRANSLATE wa_final-xblnr TO UPPER CASE.
    CLEAR : gs_bkpf.
    SELECT SINGLE * FROM bkpf INTO gs_bkpf WHERE bukrs = wa_final-bukrs AND  gjahr = wa_final-gjahr AND xblnr = wa_final-xblnr.
    IF sy-subrc IS INITIAL.
      CONCATENATE 'Document No' gs_bkpf-belnr 'Already Posted Under' gs_bkpf-bukrs gs_bkpf-gjahr
      INTO wa_final-l_msg SEPARATED BY space.
      APPEND wa_final TO it_temp.
      DELETE it_final WHERE xblnr = wa_final-xblnr.
    ENDIF.
    CLEAR : wa_final.
  ENDLOOP.
******************************************************************************************


  LOOP AT it_final INTO wa_final.
    REFRESH : bdcdata, messtab.
    CLEAR : bdcdata, messtab.

    PERFORM bdc_dynpro      USING 'SAPMJ1INJV' '0100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/E194R'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-BELNS'.
    PERFORM bdc_dynpro      USING 'RPFIWTIN_PROCESS_194R' '1000'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ONLI'.
    PERFORM bdc_field       USING 'P_BUKRS'
                                 wa_final-bukrs.
    PERFORM bdc_field       USING 'P_GJAHR'
                                  wa_final-gjahr.
    PERFORM bdc_field       USING 'P_SECCO'
                                  wa_final-secco.
    PERFORM bdc_field       USING 'P_QSCOD'
                                  wa_final-qscod.
    PERFORM bdc_field       USING 'P_KUNNR'
                                  wa_final-kunnr.
    PERFORM bdc_field       USING 'P_LIFNR'
                                  wa_final-lifnr.
    PERFORM bdc_field       USING 'P_BLDAT'
                                  wa_final-bldat.
    PERFORM bdc_field       USING 'P_BUDAT'
                                 wa_final-budat.
    PERFORM bdc_field       USING 'P_WITHT'
                                  wa_final-witht.
    PERFORM bdc_field       USING 'P_WITHCD'
                                  wa_final-withcd.
    SHIFT wa_final-dmbtr LEFT DELETING LEADING space. "Delete extra space in the field
    PERFORM bdc_field       USING 'P_DMBTR'
                                  wa_final-dmbtr.
    PERFORM bdc_field       USING 'P_BKTXT'
                                  wa_final-bktxt.
    PERFORM bdc_field       USING 'P_XBLNR'
                                  wa_final-xblnr.
    PERFORM bdc_dynpro      USING 'SAPMJ1INJV' '0100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/EERW'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-BELNS'.
*perform bdc_transaction using 'J1INJV'.

    options-dismode = 'N'.
    options-updmode  = 'S'.
*        OPTIONS-DEFSIZE = 'X'.
    options-racommit = 'X'.

    CALL TRANSACTION 'J1INJV' USING bdcdata "MODE p_mode
          OPTIONS FROM options
          MESSAGES INTO messtab.

    DELETE messtab WHERE msgtyp NE 'I'.

    LOOP AT messtab.
      IF messtab-msgtyp EQ 'I'.
        CALL FUNCTION 'FORMAT_MESSAGE'
          EXPORTING
            id  = messtab-msgid
            no  = messtab-msgnr
            v1  = messtab-msgv1
            v2  = messtab-msgv2
            v3  = messtab-msgv3
            v4  = messtab-msgv4
          IMPORTING
            msg = wa_final-l_msg.          "Confirmation Msg
        wa_final-document = messtab-msgv1. "Document Number
        MODIFY it_final FROM wa_final TRANSPORTING l_msg document.
      ELSE.
        wa_final-l_msg = 'Document Not Posted'.
        MODIFY it_final FROM wa_final TRANSPORTING l_msg document.
      ENDIF.
    ENDLOOP.

    CLEAR : wa_final.
  ENDLOOP.


*******Append all entries in one internal table to display the status of documents posted or not**************
  LOOP AT it_temp INTO wa_temp.
    wa_log-kunnr = wa_temp-kunnr.
    wa_log-lifnr = wa_temp-lifnr.
    wa_log-budat = wa_temp-budat.
    wa_log-bldat = wa_temp-bldat.
    wa_log-l_msg = wa_temp-l_msg.
    APPEND wa_log TO it_final.
    CLEAR : wa_log.
  ENDLOOP.
************************************Ends here*************************
ENDFORM.

" UPLOAD_DATA
*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                  " GET_MSG
*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
FORM alv_display .
  PERFORM alv_layout.
  PERFORM alv_output.

  DATA : gd_repid LIKE sy-repid.
  gd_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
*    I_INTERFACE_CHECK                 = 'X'
     i_callback_program                = gd_repid
*     i_callback_top_of_page            = 'TOP-OF-PAGE'
*     i_grid_title                      = 'Costing Report'
     is_layout                         = gd_layout
     it_fieldcat                       = gt_fieldcat
     i_default                         = 'X'
     i_save                            = 'A'
   TABLES
     t_outtab                          = it_final
*  EXCEPTIONS
*    PROGRAM_ERROR                     = 1
*    OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " ALV_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  ALV_LAYOUT
*&---------------------------------------------------------------------*
FORM alv_layout .
  gd_layout-no_input          = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  gd_layout-zebra             = 'X'.
*  gd_layout-info_fieldname    = 'LINE_COLOR'.
*  gd_layout-coltab_fieldname = 'CELLCOLOR'.
ENDFORM.                    " ALV_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  ALV_OUTPUT
*&---------------------------------------------------------------------*
FORM alv_output .
  PERFORM fieldcat USING '' 'KUNNR'  '' '' ''  'Customer'   '' ''.
  PERFORM fieldcat USING '' 'LIFNR'  '' '' ''  'Vendor'   '' ''.
  PERFORM fieldcat USING '' 'BLDAT'  '' '' ''  'Document Date'   '' ''.
  PERFORM fieldcat USING '' 'BUDAT'  '' '' ''  'Posting Date'   '' ''.
  PERFORM fieldcat USING '' 'DOCUMENT'  '' '' ''  'Document Number'   '' ''.
  PERFORM fieldcat USING '' 'L_MSG'  '' '' ''  'Description'   '' ''.
ENDFORM.                    " ALV_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
FORM fieldcat  USING    p_tab_name
                        p_fld_name
                        p_key
                        p_ref_tab
                        p_ref_fld
                        p_col_text
                        p_col_len
                        p_no_zero.

  gs_fieldcat-fieldname     = p_fld_name.
  gs_fieldcat-tabname       = p_tab_name.
  gs_fieldcat-key           = p_key.
  gs_fieldcat-ref_tabname   = p_ref_tab.
  gs_fieldcat-ref_fieldname = p_ref_fld.
  gs_fieldcat-reptext_ddic  = p_col_text.
  gs_fieldcat-outputlen     = p_col_len.
  gs_fieldcat-no_zero       = p_no_zero.
  APPEND gs_fieldcat  TO gt_fieldcat.
ENDFORM.
