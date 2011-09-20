DWCLXML ;CLD/JOLLIS - FileMan XML tools ;4:30 PM 19 Sep 2011
 ;;0.1;FileMan Web Tools;;

;
; ESCAPE escapes <, >, and & within STR for safe
; usage in XML files
;
ESCAPE(STR)
 N DIRULE
 S DIRULE(1,"<")="&lt;",DIRULE(2,">")="&gt;",DIRULE(3,"&")="&amp;"
 Q $$TRANSL8^DILF(STR,.DIRULE)


;
; TAG returns an XML tag, with open and closed parts.
;
TAG(TAG,VALUE)
 Q "<"_TAG_">"_$$ESCAPE(VALUE)_"</"_TAG_">"
 

