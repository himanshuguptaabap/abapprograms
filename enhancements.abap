*&---------------------------------------------------------------------*
*& Report ZRG_ENH
*&---------------------------------------------------------------------*
*& Consider it as Standard Program
*& I will not discuss the definitions here,
*& But how they work in real-time.
*& These are two kinds of Enhancements which
*& I will talk about here in Detail
*& 1:Explicit Enhancements
*&  a: Enhancement Point
*&  b: Enhancement Section
*& 2:Implicit Enhancements
*& If you have any doubts regarding the same, you can comment here
*& I will try to resolve them here.
*& I have done it in a custom program, it's the same way they
*& work in standard program. There is no change in their working.
*& To give you an overview of three types of enhancements,
*& I have choosen to write a custom program and give you
*& a brief of all three enhancements.
*&---------------------------------------------------------------------*
REPORT ZRG_ENH.
Data : lv_string TYPE string.
data : lv_str TYPE string.

lv_string = 'This is about Enhancements'.
lv_string = 'This is about Enhancements'.
*The requirement is as such that Client want to change the value
*of lv_string. we don't have any BADI, and implicit options.
*but we have enhancement point.
*Enhanement point doesn't change the existing logic as it's written
*It will just overwrite the logic which you are going to write.
*So I will implement explicit enhancement implemention.
ENHANCEMENT-POINT RG_POINT SPOTS ZZSPOT .
*$*$-Start: RG_POINT----------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZENH_POINT.    "active version
lv_string = 'This is about Enhancement Point Explicit Implemention'.
ENDENHANCEMENT.
*$*$-End:   RG_POINT----------------------------------------------------------------------------$*$*

*If you run the output now, it will show the new value of lv_string.
WRITE:/ lv_string.
SKIP 3.

ENHANCEMENT-SECTION RG_SECTION SPOTS ZZSPOT .
  lv_str = 'This is about Enhancements'.
end-ENHANCEMENT-SECTION.
*$*$-Start: RG_SECTION--------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZENH_SECTION.    "active version

*  lv_str = 'This is about Enhancements'.
*It automatically copied the line no 42 as soon as I created enhancement section.
*Now you have two options, either you can continue the previous logic written
*between Enhancement section and end-enhancement-section.
*Or, you can just comment the logic and write your own logic.
*In case of Enhancement section, it will overwrite the standard logic on
*its own. When you will check the output, you will only see the output
*of your own logic written between enhancement and endenhancement.
  lv_str = 'This is about Enhancement Section Explicit Implementation'.
ENDENHANCEMENT.
*$*$-End:   RG_SECTION--------------------------------------------------------------------------$*$*

WRITE :/ lv_str.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(1) Include ZRG_ENH, End                                                                                                                              S
*$*$-Start: (1)---------------------------------------------------------------------------------$*$*
ENHANCEMENT 1  ZENH_IMPLICIT.    "active version
*Implicit Enhancements can be found at the end of program
*or at the beginning of program, at the beginning of subroutine
*at the end of subroutine, at the begining of FM or
*at end of FM, methods.
*implicit enhancements are easily available, but these
*should be avoided until you have the last resort to use them.
  SKIP 3.
  DATA : lv_str_imp TYPE string.
  lv_str_imp = 'This is about Implicit Implementation'.
  WRITE:/ lv_str_imp.
ENDENHANCEMENT.
*$*$-End:   (1)---------------------------------------------------------------------------------$*$*
