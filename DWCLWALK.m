DWCLWALK ;CLD/JOLLIS - FileMan Structure Walker ;8:01 AM  30 Aug 2011
 ;;0.9;FileMan Web Tools;****;Aug 30, 2011

;
; FILE recursively walks FILENUM, calling the ONFILE
; routine for each file or subfile it finds,
; and ONFIELD for each field it finds within the file or subfile.
; When the end of a field definition is reached, ONFLDEND is called.
; When the end of a file definition is reached, ONEOF is called.
;
; ONFILE is a callback routine which must have the following prototype:
;  ONFILE(FILENUM)
;
; ONEOF is a callback routine which must have the following prototype:
;  EOF(FILENUM)
;
; ONFIELD is a callback routine which must have the following prototype:
;  ONFIELD(FILENUM,FIELDNUM)
;
; ONFLDEND is a callback routine which must have the following prototype:
;  ONFLDEND(FILENUM,FIELDNUM)
;
; Will set ^DWCLLAST(FILENUM) to 1 if this is the last field in FILENUM.
;
FILE(FILENUM,ONFILE,ONEOF,ONFIELD,ONFLDEND)
 S ^DWCLLAST(FILENUM)=0
 N NUMBERS,LINE,CNT,SUBFILE,I,ENTITY
 D CBFILE(ONFILE,FILENUM)
 S CNT=$$FLDNUMS^DWDIQ(FILENUM,.NUMBERS)
 F I=1:1:CNT  D
 .I I=CNT S ^DWCLLAST(FILENUM)=1
 .S SUBFILE=$$SUBFILE^DWDIQ(FILENUM,NUMBERS(I))
 .D CBFIELD(ONFIELD,FILENUM,NUMBERS(I))
 .I SUBFILE'=0 D FILE(SUBFILE,ONFILE,ONEOF,ONFIELD,ONFLDEND)
 .D CBFLDEND(ONFLDEND,FILENUM,NUMBERS(I))
 D CBEOF(ONEOF,FILENUM)
 Q

CBFILE(ROUTINE,FILENUM)
 N BASEROUT S BASEROUT="D "_ROUTINE_"("_FILENUM_")"
 X BASEROUT
 Q

CBEOF(ROUTINE,FILENUM)
 N BASEROUT S BASEROUT="D "_ROUTINE_"("_FILENUM_")"
 X BASEROUT
 Q

CBFIELD(ROUTINE,FILENUM,FLDNUM)
 N BASEROUT S BASEROUT="D "_ROUTINE_"("_FILENUM_","_FLDNUM_")"
 X BASEROUT
 Q

CBFLDEND(ROUTINE,FILENUM,FLDNUM)
 N BASEROUT S BASEROUT="D "_ROUTINE_"("_FILENUM_","_FLDNUM_")"
 X BASEROUT
 Q
