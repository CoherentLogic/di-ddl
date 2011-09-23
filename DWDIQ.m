DWDIQ ;CLD/JOLLIS-FileMan Web Tools FM Query ;8:01 AM  30 Aug 2011
 ;;0.9;FileMan Web Tools;****;Aug 30, 2011
 ;;$Id$

;
; Retrieve the closed root of FILENUM.
;
ROOT(FILENUM)
 N OPNGBL,OGLEN,CLSGBL
 S OPNGBL=$G(^DIC(FILENUM,0,"GL"))
 S OGLEN=$L(OPNGBL)
 I $E(OPNGBL,OGLEN)="," D
 .S OPNGBL=$E(OPNGBL,1,OGLEN-1)
 S CLSGBL=OPNGBL_")"
 Q CLSGBL

;
; Retrieve the closed root of FILENUM's header
;
HEADER(FILENUM)
 N OPNGBL
 S OPNGBL=$G(^DIC(FILENUM,0,"GL"))
 Q OPNGBL_"0)"

;
; ISSUB returns 1 if FILENUM is a subfile, otherwise
; returns 0.
; 
ISSUB(FILENUM)
 N RETVAL S RETVAL=0
 I $G(^DIC(FILENUM,0,"GL"))="" S RETVAL=1
 Q RETVAL

;
; Retrieve the total number of entries in FILENUM
;
ENTRIES(FILENUM)
 N REF
 S REF=$$HEADER(FILENUM)
 Q $P(@REF,"^",4)

;
; Retrieve the last IEN issued in FILENUM
;      
MOSTRCNT(FILENUM)
 N REF
 S REF=$$HEADER(FILENUM)
 Q $P(@REF,"^",3)

;
; Retrieve a sequentially-indexed array in TARGET
; containing all the IENs used in FILENUM;
; ALLIENS will return the total number of IENs
; retrieved.
;
ALLIENS(FILENUM,TARGET)
 N REF 
 N ENT
 N I
 S ENT=""
 S REF=$$ROOT(FILENUM)
 F I=0:1 S ENT=$O(@REF@(ENT)) Q:I>$$ENTRIES(FILENUM)  D
 .S TARGET(I)=ENT
 Q $$ENTRIES(FILENUM)

;
; Retrieve the name of entry IEN in FILENUM
;
ENTRNAME(FILENUM,IEN)
 N IENS S IENS=IEN_","
 Q $$GET1^DIQ(FILENUM,IENS,.01)

;
; Retrieve the name of FLDNUM in FILENUM
;
FLDNAME(FILENUM,FLDNUM)
 Q $P($G(^DD(FILENUM,FLDNUM,0)),"^",1)

;
; Retrieve a sequentially-indexed array in TARGET
; containing all the field numbers used in FILENUM;
; FLDNUMS will return the total number of field numbers
; retrieved.
;
FLDNUMS(FILENUM,TARGET)
 N FLDNUM S FLDNUM=""
 N CNT S CNT=0
 N FNAM S FNAM=""
 F I=0:1 S FLDNUM=$O(^DD(FILENUM,FLDNUM)) Q:FLDNUM=""  D 
 .S FNAM=$$FLDNAME(FILENUM,FLDNUM)
 .I FNAM'="" D
 ..S CNT=CNT+1
 ..S TARGET(I)=FLDNUM
 Q CNT

;
; Retrieve a sequentially-indexed array in TARGET
; containing all the field names used in FILENUM;
; FLDNAMES will return the total number of field names
; retrieved.
;
FLDNAMES(FILENUM,TARGET)
 N FLDNUM S FLDNUM=""
 N FNAM S FNAM=""
 N CNT S CNT=0
 F I=0:1 S FLDNUM=$O(^DD(FILENUM,FLDNUM)) Q:FLDNUM=""  D
 .S FNAM=$$FLDNAME(FILENUM,FLDNUM)
 .I FNAM'="" D
 ..S CNT=CNT+1
 ..S TARGET(I,"NAME")=FNAM
 ..S TARGET(I,"NUM")=FNUM
 Q CNT

;
; FLDTYPE returns the type information of FILENUM,FLDNUM
;
FLDTYPE(FILENUM,FLDNUM)
 Q $P($G(^DD(FILENUM,FLDNUM,0)),"^",2)

;
; SUBFILE returns the DD number of a multiple, if FLDNUM in FILENUM
; is a multiple. Otherwise, returns 0.
;
SUBFILE(FILENUM,FLDNUM)
 Q $$FLDTYPE(FILENUM,FLDNUM)+0

;
; POINTER returns the DD number of the file pointed to
; in FLDNUM of FILENUM. Note that this does NOT apply
; to Variable-Pointer fields. See VPOINTER^DWDIQ for
; use with Variable-Pointer fields. 
; 
; The LAYGO argument must be passed by reference, and
; will be set to "Yes" or "No", depending on whether
; or not LAYGO is allowed for the pointed-to file
;
POINTER(FILENUM,FLDNUM,LAYGO)
 N LG S LG="Yes"
 N RAW S RAW=$$FLDTYPE(FILENUM,FLDNUM)
 I $L(RAW,"'")>1 S LG="No"
 S LAYGO=LG
 Q $P(RAW,"P",2)+0 
 

;
; FILELIST returns a sequentially-indexed array containing
; NAME and DDNUM subscripts for all files in this installation
; in TARGET. TARGET must be passed by reference; not by value.
; FILELIST itself returns the number of files.
;
FILELIST(TARGET)
 N FNAM,FNUM
 S FNUM=0
 N COUNT S COUNT=""
 N CNT S CNT=0
 F COUNT=0:1 S FNUM=$O(^DIC(FNUM)) Q:FNUM=""  D
 .I $G(FNUM,0) D
 ..S CNT=CNT+1
 ..S TARGET(CNT,"NAME")=$P(^DIC(FNUM,0),"^",1)
 ..S TARGET(CNT,"DDNUM")=$P(^DIC(FNUM,0),"^",2)+0
 Q CNT

;
; FILENAME returns the name of FILENUM
;
FILENAME(FILENUM)
 Q $P($G(^DIC(FILENUM,0)),"^",1)

;
; DATATYPE returns a string describing the type of 
; FLDNUM in FILENUM.
;
DATATYPE(FILENUM,FLDNUM)
 N T S T=""
 N RAW S RAW=$$FLDTYPE(FILENUM,FLDNUM)
 I RAW["B" S T="Boolean"
 I RAW["D" S T="Date Valued"
 I RAW["F" S T="Free Text"
 I RAW["K" S T="MUMPS Code"
 I RAW["N" S T="Numeric Valued"
 I RAW["P" S T="Pointer"
 I RAW["S" S T="Set of Codes"
 I RAW["V" S T="Variable Pointer"
 I RAW["W" S T="Word Processing"
 I $$SUBFILE(FILENUM,FLDNUM)'=0 S T="Multiple"
 Q T

;
; DDLTYPE returns a string describing the type of 
; FLDNUM in FILENUM.
;
DDLTYPE(FILENUM,FLDNUM)
 N T S T=""
 N RAW S RAW=$$FLDTYPE(FILENUM,FLDNUM)
 I RAW["B" S T="BOOLEAN"
 I RAW["D" S T="DATE"
 I RAW["F" S T="FREETEXT"
 I RAW["K" S T="MUMPS"
 I RAW["N" S T="NUMERIC"
 I RAW["P" S T="POINTER"
 I RAW["S" S T="SET"
 I RAW["V" S T="VARPTR"
 I RAW["W" S T="WORDPROC"
 I $$SUBFILE(FILENUM,FLDNUM)'=0 S T="MULTIPLE"
 I T="" S T="NONE"
 Q T

;
; FLDAUDIT returns one of the following audit characteristics for FLDNUM in FILENUM:
;  Never
;  Always
;  Edit/Delete Only
; 
FLDAUDIT(FILENUM,FLDNUM)
 N RAW S RAW="Never"
 N TYP S TYP=$$FLDTYPE(FILENUM,FLDNUM)
 I TYP["a" S RAW="Always"
 I TYP["e" S RAW="Edit/Delete Only"
 Q RAW

;
; FLDREQD returns "Yes" or "No", depending on whether data entry
; for FLDNUM in FILENUM is required.
; 
FLDREQD(FILENUM,FLDNUM)
 N RAW S RAW="No"
 N TYP S TYP=$$FLDTYPE(FILENUM,FLDNUM)
 I TYP["R" S RAW="Yes"
 Q RAW

;
; IMUTABLE returns "Yes" or "No", depending on whether
; FLDNUM in FILENUM is immutable.
;
IMUTABLE(FILENUM,FLDNUM)
 N RAW S RAW="No"
 N TYP S TYP=$$FLDTYPE(FILENUM,FLDNUM)
 I TYP["I" S RAW="Yes"
 Q RAW

;
; COMPUTED returns "Yes" if FLDNUM in FILENUM
; is a computed field.
;
COMPUTED(FILENUM,FLDNUM)
 N RAW S RAW="No"
 N TYP S TYP=$$FLDTYPE(FILENUM,FLDNUM)
 I TYP["C" S RAW="Yes"
 Q RAW

;
; HELPMSG returns the short help message for 
; FILENUM, FLDNUM
;
HELPMSG(FILENUM,FLDNUM)
 Q $G(^DD(FILENUM,FLDNUM,3))

;
; PRTLEN returns the print length for FLDNUM in FILENUM,
; if it is defined.
;
PRTLEN(FILENUM,FLDNUM)
 N RAW S RAW=$$FLDTYPE(FILENUM,FLDNUM)
 N PLEN S PLEN="Undefined"
 I RAW["J" S PLEN=+$P(RAW,"J",2)
 Q PLEN

;
; FLDSEC returns the read, write, and delete access 
; for FLDNUM in FILENUM in TARGET, which must be
; passed by reference.
;
FLDSEC(FILENUM,FLDNUM,TARGET)
 S TARGET("READ")=$G(^DD(FILENUM,FLDNUM,8),"Undefined")
 S TARGET("DELETE")=$G(^DD(FILENUM,FLDNUM,8.5),"Undefined")
 S TARGET("WRITE")=$G(^DD(FILENUM,FLDNUM,9),"Undefined")
 Q

;
; CODES returns an array (TARGET) of key-value pairs for the set of codes
; defined by FLDNUM in FILENUM. CODES itself returns the number of 
; key-value pairs.
;
; TARGET layout:
;  TARGET(KEY)=VALUE
;
CODES(FILENUM,FLDNUM,TARGET)
 N CS S CS=$P($G(^DD(FILENUM,FLDNUM,0)),"^",3)
 N CNT S CNT=$L(CS,";")-1
 N CC,KEY,VAL
 F I=1:1:CNT D
 .S CC=$P(CS,";",I)   ;one pair
 .S KEY=$P(CC,":",1)  ;key of pair
 .S VAL=$P(CC,":",2)  ;value of pair
 .S TARGET(KEY)=VAL
 Q CNT
 

;
; XREFS populates the array TARGET with information about the
; cross-references defined for FILENUM.
; 
; XREFS returns nothing.
;
; TARGET format:
;  TARGET(file-number,field-number,cross-reference-name)=""
;
XREFS(FILENUM,TARGET)
 N XRNAME,XRFILE,XRFIELD S (XRNAME,XRFILE,XRFIELD)=""
 F  S XRNAME=$O(^DD(FILENUM,0,"IX",XRNAME)) Q:XRNAME=""  D
 .F  S XRFILE=$O(^DD(FILENUM,0,"IX",XRNAME,XRFILE)) Q:XRFILE=""  D
 ..F  S XRFIELD=$O(^DD(FILENUM,0,"IX",XRNAME,XRFILE,XRFIELD)) Q:XRFIELD=""  D
 ...S TARGET(XRFILE,XRFIELD,XRNAME)=""
 Q

;
; FLDXREFS populates TARGET as a sequentially-indexed 
; array of cross-reference names defined for FILENUM,FLDNUM.
;
; Returns the total number of cross-references.
;
FLDXREFS(FILENUM,FLDNUM,TARGET)
 N XRS S XRS="" D XREFS^DWDIQ(FILENUM,.XRS)
 N CNT,IDX S (CNT,IDX)=0
 F CNT=1:1 S IDX=$O(XRS(FILENUM,FLDNUM,IDX)) Q:IDX=""  D
 .S TARGET(CNT)=IDX
 Q CNT-1
