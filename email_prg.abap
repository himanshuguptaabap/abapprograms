REPORT zrg_email.
"Email Program is very necessary when it comes to send information
"out of SAP to end-users and head offices and
"it is also very useful if you know how we can simply design it.
"I avoided many declarations so that we can understand
"how we can acheive the same with inline declaration and
" VALUE operator and CONV operator
"you can add the document too.
"The idea behind this program is to let ABAPers understand
"how new syntax can reduce many lines of code
"how we can seperate each thing to understand it best through
"OOPs
"Method Chaining is also a good way to rid of data declaration.
"Catch exception when you are writing the program so
"it doesn't dump.

CLASS cl_send_mail DEFINITION.
 PUBLIC SECTION.
 CLASS-METHODS : main.
 
 PROTECTED SECTION.
 METHODS : create_msg ,
 add_receipent,
 add_sender,
 send_req.
 
 PRIVATE SECTION.
 DATA : lo_send_email TYPE REF TO cl_bcs.
 
ENDCLASS.

CLASS cl_send_mail IMPLEMENTATION.
 METHOD : main.
 DATA(lo_mail) = NEW cl_send_mail( ).
 lo_mail->create_msg( ) . "Create some mail body to send in a mail
 lo_mail->add_sender( ) . "Add sender
 lo_mail->add_receipent( ). "Add receipents
 lo_mail->send_req( ). "Send request
 ENDMETHOD.
 
 METHOD : create_msg.
 lo_send_email = cl_bcs=>create_persistent( ).
* "Create mail body
 lo_send_email->set_document( cl_document_bcs=>create_document(
 i_type = 'RAW'
i_text = VALUE #( ( line = 'Dear Recipient,' )
 ( line = 'This is Test Email Program.' )
 ( line = 'Thank You' ) )
 i_subject = 'Test Email' ) ).
 ENDMETHOD.
 
 METHOD : add_receipent.
 "for multiple email ids, you can use loop
 "append the ids.
 lo_send_email->add_recipient( cl_cam_address_bcs=>create_internet_address(
 CONV #( 'receiver@dummy.com' ) ) ).
 ENDMETHOD.
 
 METHOD : add_sender.
* "if we want to send the email from the user's system then
* "we can use following method
* lo_send_email->set_sender( cl_sapuser_bcs=>create( sy-uname ) ).
 lo_send_email->set_sender( cl_cam_address_bcs=>create_internet_address(
 i_address_string = CONV #( 'sender@dummy.com' ) ) ).
 ENDMETHOD.
 
 METHOD : send_req.
 DATA(lv_flag) = lo_send_email->send( ).
 MESSAGE | { SWITCH #( lv_flag WHEN 'X' THEN 'Sent' WHEN '' THEN 'Error') } | TYPE 'I'.
 COMMIT WORK.
 ENDMETHOD.
 
ENDCLASS.

START-OF-SELECTION.
 cl_send_mail=>main( ).
