Function adbSetFilter(y)

//������ ����� ������� �� ���� ������ �������. ����� ��������
// index on NAME2 to tempbase3 FOR tempbase3->DATA_ZA=curDate .and. cNAME = tempbase3->NAME2

//adbClearFilter()

pathtoTEMPdir:=GetCurDir()+"\TEMP\"+cRDPdir
LMKDIR("TEMP\"+cRDPdir)
SET DEFAULT to &pathtoTEMPdir


cCurrentIndexBeforeFilter:=alias()+"_CurrentIndexBeforeFilter"
 &cCurrentIndexBeforeFilter:=indexord()
aIndexesBeforeFilter:=alias()+"_IndexesBeforeFilter"
aFieldIndexesBeforeFilter:=alias()+"_FieldIndexesBeforeFilter"
 &aIndexesBeforeFilter:={} //��� ���������� ������ ��������� ����� ����� ��
 &aFieldIndexesBeforeFilter:={} //��� ���������� ������ ��������� ����� ����� ��
 &cCurrentIndexBeforeFilter
cCurrentIndex:=indexkey() //������� �������� �������. ������������ ���� ��.
 if empty(cCurrentIndex)
//  cErr1:="��� ��������� ������� ����������� ������: "+alias()+" - "+ str(select())+;
//  CRLF+"�������� ������������"
//  msgstop(cErr1,"��������!")
//?len(&aIndexesBeforeFilter), len(&aFieldIndexesBeforeFilter)
  AADD(&aIndexesBeforeFilter,alias()+"TEMPINDEX") //��� �������, ������� ����
  AADD(&aFieldIndexesBeforeFilter, FieldName(1))

//  ?fieldname(1)
//  SET DEFAULT to &basedir
//  index on (fieldname(1)) to (alias()+alltrim(str(select()))+"tempindex")
//indexPath:=GetCurDir()+"\TEMP\"+cRDPdir
//  index on ID_ZAKAZ to indexPath+(alias()+alltrim(str(select())))
//  SET DEFAULT to &pathtoTEMPdir

 end if

//�� ���� � ����� �������������
cTemporaryIndexForFilter:=alias()+"_TemporaryIndexForFilter"

//��������� ������ �������
 nOrderOfIndex:=1
 do while empty(indexkey(nOrderOfIndex)) = .f.
  dbsetorder(nOrderOfIndex)
   AADD(&aIndexesBeforeFilter,ORDBAGNAME(nOrderOfIndex)) //��� �������
   AADD(&aFieldIndexesBeforeFilter,indexkey(nOrderOfIndex)) //���� �������
 nOrderOfIndex:=nOrderOfIndex + 1
 end do


//������� �����
for nAInIndex = 1 to len(&aIndexesBeforeFilter)
cCurrentIndex:=&aFieldIndexesBeforeFilter[nAInIndex]
//cTemporaryIndexForFilter:=(pathtoTEMPdir + aIndexesBeforeFilter[nAInIndex])
cTemporaryIndexForFilter:= &aIndexesBeforeFilter[nAInIndex]
// index on &cCurrentIndex tag &cTemporaryIndexForFilter to &cTemporaryIndexForFilter for &y
 index on &cCurrentIndex to &cTemporaryIndexForFilter for &y
next

ordListClear()
for nAInIndex = 1 to len(&aIndexesBeforeFilter) //��������� �������
cTemporaryIndexForFilter:=&aIndexesBeforeFilter[nAInIndex]
//cTemporaryIndexForFilter:=(pathtoTEMPdir + &aIndexesBeforeFilter[nAInIndex])
//cTemporaryIndexForFilter:=pathtoTEMPdir + &aIndexesBeforeFilter[nAInIndex]
ordListAdd( cTemporaryIndexForFilter )
next

for nAInIndex = 1 to len(&aIndexesBeforeFilter)
//?ORDBAGNAME(nAInIndex), indexkey(nAInIndex), &aIndexesBeforeFilter[nAInIndex], &aFieldIndexesBeforeFilter[nAInIndex]
next

//dbSelectArea( "2" )
//dbUseArea( .F.,, "gofro",, if(.T. .OR. .F., !.F., NIL), .F. )
//ordCondSet(,,,,,, RECNO(),,,,,,,,,,,,, ) ; ordCreate( "gofro",, "IZGOTOVL", {|| IZGOTOVL}, )
//ordCondSet(,,,,,, RECNO(),,,,,,,,,,,,, ) ; ordCreate( "idgofro",, "ZAKAZ", {|| ZAKAZ}, )
//ordCondSet(,,,,,, RECNO(),,,,,,,,,,,,, ) ; ordCreate( "clgofro",, "CLIENT", {|| CLIENT}, )
//ordCondSet(,,,,,, RECNO(),,,,,,,,,,,,, ) ; ordCreate( "idzakgofro",, "ID_ZAKAZ", {|| ID_ZAKAZ}, )
//ordCondSet(,,,,,, RECNO(),,,,,,,,,,,,, ) ; ordCreate( "idzakgofro2",, "val(ID_ZAKAZ)", {|| val(ID_ZAKAZ)}, )
//if !.F. ; ordListClear() ; end ; ordListAdd( "gofro" ) ; ordListAdd( "idgofro" ) ; ordListAdd( "clgofro" ) ; ordListAdd( "idzakgofro" ) ; ordListAdd( "idzakgofro2" )
//dbsetorder(1)


// set index to rulon, rmarka, dmarka1, dmarka2, dmarka3
//#command INDEX ON <key> TAG <(tag)> [OF <(bag)>] [TO <(bag)>] ;
//               [OPTION <eval> [STEP <every>]] ;
//               [<filter: FILTERON>] ;
//               [<cust: EMPTY>] ;
//               [<cur: SUBINDEX>] ;
//               [FOR <for>] [WHILE <while>] [NEXT <next>] ;
//               [RECORD <rec>] [<rest:REST>] [<all:ALL>] ;
//               [EVAL <eval>] [EVERY <every>] [<unique: UNIQUE>] ;
//               [<ascend: ASCENDING>] [<descend: DESCENDING>] ;
//               [<add: ADDITIVE>] [<cur: USECURRENT>] [<cust: CUSTOM>] ;
//               [<noopt: NOOPTIMIZE>] [<mem: MEMORY, TEMPORARY>] ;
//               [<filter: USEFILTER>] [<ex: EXCLUSIVE>] => ;
//         ordCondSet( <"for">, <{for}>, [<.all.>], <{while}>, ;
//                     <{eval}>, <every>, RECNO(), <next>, <rec>, ;
//                     [<.rest.>], [<.descend.>],, ;
//                     [<.add.>], [<.cur.>], [<.cust.>], [<.noopt.>], ;
//                     <"while">, [<.mem.>], [<.filter.>], [<.ex.>] ) ;;
//         ordCreate( <(bag)>, <(tag)>, <"key">, <{key}>, [<.unique.>] )


// ordListAdd(&aIndexesBeforeFilter[nAInIndex]) //����������� �������

// index on &cCurrentIndex to &cTemporaryIndexForFilter for &y MEMORY
//dbgotop()

//for nA1:=1 to len(aIndexesBeforeFilter)
// ?aIndexesBeforeFilter[nA1]
//next
SET DEFAULT to &basedir

return nil
//****************************
Function adbClearFilter()

SET AUTOPEN OFF

if len(alltrim(OrdFor())) = 0 //��� �������
 return nil
end if

//���� ������� ������ �������?
//
// nOrderOfIndex:=1
// do while empty(indexkey(nOrderOfIndex)) = .f.
//  ferase(ORDBAGNAME(nOrderOfIndex)+".cdx") //��� �������
//?ORDBAGNAME(nOrderOfIndex)+".cdx"
// nOrderOfIndex:=nOrderOfIndex + 1
// end do

pathtoTEMPdir:=GetCurDir()+"\TEMP\"+cRDPdir

//if select()>=50 .and. select()<59
// SET DEFAULT to &pathtoTEMPdir
//else
//?Set(_SET_DEFAULT), ORDBAGNAME(1)
 SET DEFAULT to &basedir
//?Set(_SET_DEFAULT)
//end if

nCurrentRecordAfterFilter:=recno()

cCurrentIndexBeforeFilter:=alias()+"_CurrentIndexBeforeFilter"
 &cCurrentIndexBeforeFilter:=indexord()
aIndexesBeforeFilter:=alias()+"_IndexesBeforeFilter"
aFieldIndexesBeforeFilter:=alias()+"_FieldIndexesBeforeFilter"
 &aIndexesBeforeFilter:={} //��� ���������� ������ ��������� ����� ����� ��
 &aFieldIndexesBeforeFilter:={} //��� ���������� ������ ��������� ����� ����� ��
 &cCurrentIndexBeforeFilter
cCurrentIndex:=indexkey() //������� �������� �������. ������������ ���� ��.
//�� ���� � ����� �������������
cTemporaryIndexForFilter:=alias()+"_TemporaryIndexForFilter"



lFilter:=.f.
 nOrderOfIndex:=1
 do while empty(indexkey(nOrderOfIndex)) = .f.
//?ORDBAGNAME(nOrderOfIndex)
//  if at("_TemporaryIndexForFilter",ORDBAGNAME(nOrderOfIndex)) <> 0 //��� ������
   lFilter:=.t.
//  end if
 nOrderOfIndex:=nOrderOfIndex + 1
 end do
//?indexord(), ORDBAGNAME(1)

if lFilter=.f.
 SET DEFAULT to &basedir
 return nil
end if

if right(ORDBAGNAME(1),9)=="TEMPINDEX" //��������� ������
// ?indexord(), ORDBAGNAME(1)
ORDDESTROY(ORDBAGNAME(1))
 ordListClear()
// ?indexord(), ORDBAGNAME(1)
end if

//�������!!!!!!!!!!!!!!
if !file(basedir+ORDBAGNAME(1)+".cdx") //������ ���� � pathtoTEMPdir
 SET DEFAULT to &pathtoTEMPdir
end if



cOldAlias:=alias()
nOldSelect:=select()
//?alias(), select(), dbf()

//��������� ������ �������
 nOrderOfIndex:=1
 do while empty(indexkey(nOrderOfIndex)) = .f.
  dbsetorder(nOrderOfIndex)
   AADD(&aIndexesBeforeFilter,ORDBAGNAME(nOrderOfIndex)) //��� �������
   AADD(&aFieldIndexesBeforeFilter,indexkey(nOrderOfIndex)) //���� �������
 nOrderOfIndex:=nOrderOfIndex + 1
 end do


//������� �����
for nAInIndex = 1 to len(&aIndexesBeforeFilter)
cCurrentIndex:=&aFieldIndexesBeforeFilter[nAInIndex]
cTemporaryIndexForFilter:=&aIndexesBeforeFilter[nAInIndex]
// index on &cCurrentIndex to &cTemporaryIndexForFilter
next
//?cCurrentIndex,cTemporaryIndexForFilter

ordListClear()


//close (nOldSelect)
//select (nOldSelect)
//use &cOldAlias SHARED alias (cOldAlias)
//?select(), alias(), nOldSelect, cOldAlias, dbf()
//?select(), alias(), indexord(), indexkey(), cTemporaryIndexForFilter

//?len(&aIndexesBeforeFilter)
if len(&aIndexesBeforeFilter) >1 //�������
 for nAInIndex = 1 to len(&aIndexesBeforeFilter) //��������� �������
 cTemporaryIndexForFilter:=&aIndexesBeforeFilter[nAInIndex]
//sx_RLock()
//?select(), alias(), indexord(), indexkey(), cTemporaryIndexForFilter
// index on &cCurrentIndex to &cTemporaryIndexForFilter
 ordListAdd( cTemporaryIndexForFilter )
//sx_Unlock()
 next
else
 index on &cCurrentIndex to &cTemporaryIndexForFilter
end if




//for nAInIndex = 1 to len(&aIndexesBeforeFilter)
//?ORDBAGNAME(nAInIndex), indexkey(nAInIndex), &aIndexesBeforeFilter[nAInIndex], &aFieldIndexesBeforeFilter[nAInIndex]
//next

//dbcommit()
//dbcommitall()

dbgoto(nCurrentRecordAfterFilter)
SET DEFAULT to &basedir

return nil
