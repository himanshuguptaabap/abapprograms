*&---------------------------------------------------------------------*
*& Report ZRG_VENDOR_MASTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zrg_vendor_master.
*-------------------------------------------------------------------------------
*                       ALV Variables
*-------------------------------------------------------------------------------

INITIALIZATION.
  TYPE-POOLS : slis.

  TYPES: slis_t_listheader TYPE slis_listheader OCCURS 1.

  DATA : heading TYPE slis_t_listheader WITH HEADER LINE.

  DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "ALV Catalog Table
        gs_fieldcat TYPE slis_fieldcat_alv.   "ALV Catalog Structure

  DATA : eventstab    TYPE   slis_t_event WITH HEADER LINE,
         gd_tab_group TYPE   slis_t_sp_group_alv,
         gd_layout    TYPE   slis_layout_alv,
         gd_repid     LIKE   sy-repid.

  DATA: it_fcat       TYPE slis_t_fieldcat_alv,
        wa_fcat       LIKE LINE OF it_fcat,
        is_sel_hide   TYPE slis_sel_hide_alv,
        it_listheader TYPE slis_t_listheader,
        wa_listheader TYPE slis_listheader.

  DATA: x_save,
        alv_variant TYPE disvariant,
        alv_layout  TYPE slis_layout_alv.

*-------------------------------------------------------------------------------
*                       Structures
*-------------------------------------------------------------------------------

  TYPES : BEGIN OF ty_lfa1,
            lifnr TYPE lfa1-lifnr, "Vendor No
            name1 TYPE lfa1-name1, "Vendor Name
            ort02 TYPE lfa1-ort02, "District
            ort01 TYPE lfa1-ort01, "City
            pstlz TYPE lfa1-pstlz, "Postal Code
            adrnr TYPE lfa1-adrnr, "Address Number
            erdat TYPE lfa1-erdat,  "Created On
            ktokk TYPE lfa1-ktokk,  "Account Group
            sperr TYPE lfa1-sperr, "Posting Block
            telf1 TYPE lfa1-telf1, "Telephone 1
            telf2 TYPE lfa1-telf2, "Telephone 2
            telfx TYPE lfa1-telfx, "Fax
            sperq TYPE lfa1-sperq, "Block Function
            stcd3 TYPE lfa1-stcd3, "Tax Number 3
            stenr TYPE lfa1-stenr, "MSME Code
          END OF ty_lfa1,

          BEGIN OF ty_lfb1,
            lifnr TYPE lfb1-lifnr, "
            akont TYPE lfb1-akont, "Recon. account
            zahls TYPE lfb1-zahls, "Payment Block
            zterm TYPE lfb1-zterm, "payment terms
          END OF ty_lfb1,

          BEGIN OF ty_adrc,
            addrnumber TYPE adrc-addrnumber,
            str_suppl1 TYPE adrc-str_suppl1, "Street 1
            str_suppl2 TYPE adrc-str_suppl2, "Street 2
            country    TYPE adrc-country, "Country
            region     TYPE adrc-region, "Region
          END OF ty_adrc,

          BEGIN OF ty_t005u,
            spras TYPE t005u-spras,
            land1 TYPE t005u-land1,
            bland TYPE t005u-bland,
            bezei TYPE t005u-bezei, "State Code
          END OF ty_t005u,

          BEGIN OF ty_lfbk,
            lifnr TYPE lfbk-lifnr,
            bankl TYPE lfbk-bankl, "Bank Key
            bankn TYPE lfbk-bankn, "Bank Account
            koinh TYPE lfbk-koinh,  "Account Holder
          END OF ty_lfbk,

          BEGIN OF ty_bnka,
            bankl TYPE bnka-bankl, "Bank Key
            banka TYPE bnka-banka, "Bank Name
            provz TYPE bnka-provz, "Region
            stras TYPE bnka-stras, "Street
            brnch TYPE bnka-brnch, "Branch
          END OF ty_bnka,

          BEGIN OF ty_j_1imovend,
            lifnr     TYPE j_1imovend-lifnr,
            j_1ipanno TYPE j_1imovend-j_1ipanno,
          END OF ty_j_1imovend,

          BEGIN OF ty_adr6,
            addrnumber TYPE adrc-addrnumber,
            smtp_addr  TYPE adr6-smtp_addr,
          END OF ty_adr6,

          BEGIN OF ty_final,

            rowno      TYPE i,

            lifnr      TYPE lfa1-lifnr, "Vendor No
            name1      TYPE lfa1-name1, "Vendor Name
            ort02      TYPE lfa1-ort02, "District
            ort01      TYPE lfa1-ort01, "City
            pstlz      TYPE lfa1-pstlz, "Postal Code
            adrnr      TYPE lfa1-adrnr, "Address Number
            erdat      TYPE lfa1-erdat,  "Created On
            ktokk      TYPE lfa1-ktokk,  "Account Group
            sperr      TYPE lfa1-sperr, "Posting Block
            telf1      TYPE lfa1-telf1, "Telephone 1
            telf2      TYPE lfa1-telf2, "Telephone 2
            telfx      TYPE lfa1-telfx, "Fax
            sperq      TYPE lfa1-sperq, "Block Function
            stcd3      TYPE lfa1-stcd3, "Tax Number 3
            stenr      TYPE lfa1-stenr, "MSME Code

            akont      TYPE lfb1-akont, "Recon. account
            zahls      TYPE lfb1-zahls, "Payment Block
            zterm      TYPE lfb1-zterm, "payment terms

            str_suppl1 TYPE adrc-str_suppl1, "Street 1
            str_suppl2 TYPE adrc-str_suppl2, "Street 2
            country    TYPE adrc-country, "Country
            region     TYPE adrc-region, "Region

            spras      TYPE t005u-spras,
            land1      TYPE t005u-land1,
            bland      TYPE t005u-bland,
            bezei      TYPE t005u-bezei, "State Code

            j_1ipanno  TYPE j_1imovend-j_1ipanno,

            smtp_addr  TYPE adr6-smtp_addr, "Email

            bankl      TYPE lfbk-bankl, "Bank Key
            bankn      TYPE lfbk-bankn, "Bank Account
            koinh      TYPE lfbk-koinh,  "Account Holder

            banka      TYPE bnka-banka, "Bank Name
            provz      TYPE bnka-provz, "Region
            stras      TYPE bnka-stras, "Street
            brnch      TYPE bnka-brnch, "Branch

          END OF ty_final.

  DATA : row_number TYPE i.

  DATA : it_lfa1       TYPE TABLE OF ty_lfa1,
         wa_lfa1       TYPE ty_lfa1,

         it_lfb1       TYPE TABLE OF ty_lfb1,
         wa_lfb1       TYPE ty_lfb1,

         it_adrc       TYPE TABLE OF ty_adrc,
         wa_adrc       TYPE ty_adrc,

         it_lfbk       TYPE TABLE OF ty_lfbk,
         wa_lfbk       TYPE ty_lfbk,

         it_t005u      TYPE TABLE OF ty_t005u,
         wa_t005u      TYPE ty_t005u,

         it_bnka       TYPE TABLE OF ty_bnka,
         wa_bnka       TYPE ty_bnka,

         it_j_1imovend TYPE TABLE OF ty_j_1imovend,
         wa_j_1imovend TYPE ty_j_1imovend,

         it_adr6       TYPE TABLE OF ty_adr6,
         wa_adr6       TYPE ty_adr6,

         it_final      TYPE TABLE OF ty_final,
         wa_final      TYPE ty_final.

  DATA : v_lifnr TYPE lfa1-lifnr, "OBLIGATORY, "Vendor
         v_ktokk TYPE lfa1-ktokk, "Account Group
         v_akont TYPE lfb1-akont, "Recon. Acc
         v_erdat TYPE lfa1-erdat. "Creation Date.


  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t1.
    SELECT-OPTIONS : s_lifnr FOR v_lifnr, "OBLIGATORY, "Vendor
                     s_ktokk FOR v_ktokk, "Account Group
                     s_akont FOR v_akont, "Recon. Acc
                     s_erdat FOR v_erdat. "Creation Date
  SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  t1 = 'Vendor Master Report'.

START-OF-SELECTION.


  PERFORM get_data.
  PERFORM func_alv.

  PERFORM display_alv.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  SELECT lifnr
         name1
         ort02
         ort01
         pstlz
         adrnr
         erdat
         ktokk
         sperr
         telf1
         telf2
         telfx
         sperq
         stcd3
         stenr
         FROM lfa1
         INTO TABLE it_lfa1
         WHERE lifnr IN s_lifnr
         AND ktokk IN s_ktokk
         AND erdat IN s_erdat.
  IF sy-subrc IS INITIAL.
    SORT it_lfa1 BY lifnr.
  ENDIF.

  IF sy-subrc IS INITIAL
    AND it_lfa1 IS NOT INITIAL.

    SELECT lifnr
           akont
           zahls
           zterm
           FROM lfb1
           INTO TABLE it_lfb1
           FOR ALL ENTRIES IN it_lfa1
           WHERE lifnr = it_lfa1-lifnr
           AND akont IN s_akont.
    IF sy-subrc IS INITIAL.
      SORT it_lfb1 BY lifnr.
    ENDIF.


    SELECT addrnumber
           str_suppl1
           str_suppl2
           country
           region
           FROM adrc
           INTO TABLE it_adrc
           FOR ALL ENTRIES IN it_lfa1
           WHERE addrnumber = it_lfa1-adrnr.
    IF sy-subrc IS INITIAL.
      SORT it_adrc BY addrnumber.
    ENDIF.

    SELECT lifnr
           bankl
           bankn
           koinh
           FROM lfbk
           INTO TABLE it_lfbk
           FOR ALL ENTRIES IN it_lfa1
           WHERE lifnr = it_lfa1-lifnr.
    IF sy-subrc IS INITIAL.
      SORT it_lfbk BY lifnr.
    ENDIF.

    SELECT lifnr
           j_1ipanno
           FROM j_1imovend
           INTO TABLE it_j_1imovend
           FOR ALL ENTRIES IN it_lfa1
           WHERE lifnr = it_lfa1-lifnr.
    IF sy-subrc IS INITIAL.
      SORT it_j_1imovend BY lifnr.
    ENDIF.
  ENDIF.

  IF sy-subrc IS INITIAL
    AND it_adrc IS NOT INITIAL.

    SELECT spras
           land1
           bland
           bezei
           FROM t005u
           INTO TABLE it_t005u
           FOR ALL ENTRIES IN it_adrc
           WHERE spras = 'EN'
           AND bland = it_adrc-region
           AND land1 = it_adrc-country.

    SELECT addrnumber
           smtp_addr
           FROM adr6
           INTO TABLE it_adr6
           FOR ALL ENTRIES IN it_adrc
           WHERE addrnumber = it_adrc-addrnumber.

  ENDIF.

  IF sy-subrc IS INITIAL
    AND it_lfbk IS NOT INITIAL.

    SELECT bankl
           banka
           provz
           stras
           brnch
           FROM bnka
           INTO TABLE it_bnka
           FOR ALL ENTRIES IN it_lfbk
           WHERE bankl = it_lfbk-bankl.
  ENDIF.

  LOOP AT it_lfa1 INTO wa_lfa1.

    row_number = row_number + 1 .
    wa_final-rowno = row_number.

    MOVE-CORRESPONDING wa_lfa1 TO wa_final.

    CLEAR : wa_j_1imovend.
    READ TABLE it_j_1imovend INTO wa_j_1imovend WITH KEY lifnr = wa_lfa1-lifnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING wa_j_1imovend TO wa_final.
    ENDIF.

    CLEAR : wa_lfb1.
    READ TABLE it_lfb1 INTO wa_lfb1 WITH KEY lifnr = wa_lfa1-lifnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING wa_lfb1 TO wa_final.
    ENDIF.

    CLEAR : wa_adrc.
    READ TABLE it_adrc INTO wa_adrc WITH KEY addrnumber = wa_lfa1-adrnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING wa_adrc TO wa_final.

      CLEAR : wa_t005u.
      READ TABLE it_t005u INTO wa_t005u WITH KEY land1 = wa_adrc-country bland = wa_adrc-region.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING wa_t005u TO wa_final.
      ENDIF.

      CLEAR : wa_adr6.
      READ TABLE it_adr6 INTO wa_adr6 WITH KEY addrnumber = wa_adrc-addrnumber.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING wa_adr6 TO wa_final.
      ENDIF.
    ENDIF.

    CLEAR : wa_lfbk.
    READ TABLE it_lfbk INTO wa_lfbk WITH KEY lifnr = wa_lfa1-lifnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE-CORRESPONDING wa_lfbk TO wa_final.

      CLEAR : wa_bnka.
      READ TABLE it_bnka INTO wa_bnka WITH KEY bankl = wa_lfbk-bankl.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING wa_bnka TO wa_final.
      ENDIF.
    ENDIF.
    REPLACE ALL OCCURRENCES OF '"' IN wa_final-str_suppl1 WITH ''.
    REPLACE ALL OCCURRENCES OF '|' IN wa_final-str_suppl1 WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_final-brnch WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_final-stras WITH ''.
    REPLACE ALL OCCURRENCES OF '"' IN wa_final-str_suppl2 WITH ''.
    APPEND wa_final TO it_final.
    CLEAR : wa_final.
  ENDLOOP.


ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  DATA : gd_repid LIKE sy-repid.
  gd_repid = sy-repid.

  PERFORM layout_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK      = 'X'
      i_callback_program     = gd_repid
      i_callback_top_of_page = 'TOP-OF-PAGE'
      i_grid_title           = 'Vendor Master'
      is_layout              = gd_layout
      it_fieldcat            = gt_fieldcat
      i_default              = 'X'
      i_save                 = 'A'
    TABLES
      t_outtab               = it_final
*  EXCEPTIONS
*     PROGRAM_ERROR          = 1
*     OTHERS                 = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " DISPLAY_ALV
FORM top-of-page.
  DATA: count TYPE int2.
  wa_listheader-typ = 'H'.
  wa_listheader-info = 'Vendor Master Report'.
  APPEND wa_listheader TO it_listheader.

  wa_listheader-typ = 'S'.
  wa_listheader-key = 'DATE'.
  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO wa_listheader-info.
  APPEND wa_listheader TO it_listheader.

  wa_listheader-typ = 'S'.
  wa_listheader-key = 'No.Of.Records'.
  DESCRIBE TABLE it_final LINES count.
  wa_listheader-info = count."

  APPEND wa_listheader TO it_listheader.

  wa_listheader-typ = 'S'.
  wa_listheader-key = 'CLIENT'.
  wa_listheader-info = sy-mandt.
  APPEND wa_listheader TO it_listheader.

  CLEAR wa_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_listheader. "it_listheader.

  REFRESH it_listheader.         "it_listheader.

ENDFORM. "top-of-page
*&---------------------------------------------------------------------*
*&      Form  FUNC_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM func_alv .

  PERFORM fieldcat USING '' 'ROWNO'  '' '' ''  'Serial No'   '' ''.
  PERFORM fieldcat USING '' 'LIFNR'  '' '' ''  'Vendor Code'   '' ''.
  PERFORM fieldcat USING '' 'NAME1'  '' '' ''  'Vendor Name'   '' ''.
  PERFORM fieldcat USING '' 'ERDAT'  '' '' ''  'Creation Date'   '' ''.
  PERFORM fieldcat USING '' 'KTOKK'  '' '' ''  'Vendor Account Group' '' ''.
  PERFORM fieldcat USING '' 'AKONT'  '' '' ''  'Vendor Recon Account'   '' 'X'.
  PERFORM fieldcat USING '' 'STR_SUPPL1'  '' '' ''  'Street 2'   '' ''.
  PERFORM fieldcat USING '' 'STR_SUPPL2'  '' '' ''  'Street 3'   '' ''.
  PERFORM fieldcat USING '' 'ORT02'  '' '' ''  'District'   '' ''.
  PERFORM fieldcat USING '' 'ORT01'  '' '' ''  'City'   '' ''.
  PERFORM fieldcat USING '' 'PSTLZ'  '' '' ''  'Pin code'   '' ''.
  PERFORM fieldcat USING '' 'REGION'  '' '' ''  'Region'   '' ''.
  PERFORM fieldcat USING '' 'BEZEI'  '' '' ''  'State Name'   '' ''.
  PERFORM fieldcat USING '' 'TELF1'  '' '' ''  'Telephone 1'   '' ''.
  PERFORM fieldcat USING '' 'TELF2'  '' '' ''  'Telephone 2'   '' ''.
  PERFORM fieldcat USING '' 'TELFX'  '' '' ''  'Fax Number'   '' ''.
  PERFORM fieldcat USING '' 'SMTP_ADDR'  '' '' ''  'Email ID'   '' ''.
  PERFORM fieldcat USING '' 'STCD3'  '' '' ''  'GST CODE'   '' ''.
  PERFORM fieldcat USING '' 'J_1IPANNO'  '' '' ''  'PAN No.'   '' ''.
  PERFORM fieldcat USING '' 'STENR'  '' '' ''  'MSME Code'   '' ''.
  PERFORM fieldcat USING '' 'BANKA'  '' '' ''  'Bank Name'   '' ''.
  PERFORM fieldcat USING '' 'BRNCH'  '' '' ''  'Bank Branch'   '' ''.
  PERFORM fieldcat USING '' 'PROVZ'  '' '' ''  'Bank Street'   '' ''.
  PERFORM fieldcat USING '' 'STRAS'  '' '' ''  'Bank Region'   '' ''.
  PERFORM fieldcat USING '' 'BANKL'  '' '' ''  'Bank Key'   '' ''.
  PERFORM fieldcat USING '' 'BANKN'  '' '' ''  'Bank Account'   '' ''.
  PERFORM fieldcat USING '' 'KOINH'  '' '' ''  'Account Holder'   '' ''.
  PERFORM fieldcat USING '' 'ZTERM'  '' '' ''  'Pay Terms'   '' ''.
  PERFORM fieldcat USING '' 'ZAHLS'  '' '' ''  'Payment Block'   '' ''.
  PERFORM fieldcat USING '' 'SPERR'  '' '' ''  'Posting Block'   '' ''.
  PERFORM fieldcat USING '' 'SPERQ'  '' '' ''  'Overall block'   '' ''.
  PERFORM fieldcat USING '' 'ADRNR'  '' '' ''  'Address'   '' 'X'.

ENDFORM.                    " FUNC_ALV
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TAB_NAME  text
*      -->P_FLD_NAME  text
*      -->P_KEY  text
*      -->P_REF_TAB  text
*      -->P_REF_FLD  text
*      -->P_COL_TEXT  text
*      -->P_COL_LEN  text
*      -->P_NO_ZERO  text
*----------------------------------------------------------------------*
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
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM layout_alv .
  gd_layout-no_input          = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  gd_layout-zebra             = 'X'.
*  gd_layout-info_fieldname    = 'LINE_COLOR'.
*  gd_layout-coltab_fieldname = 'CELLCOLOR'.

ENDFORM.                    " LAYOUT_ALV
" FIELDCAT
