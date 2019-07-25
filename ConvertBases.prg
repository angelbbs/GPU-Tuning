Function ConvertBases()

select 10
use BaseVer SHARED ALIAS "BaseVer"

if BaseVer<1
 dbappend()
 dbrlock()
 BaseVer->BaseVer:=1
 dbunlock()

select 3
use Overclock SHARED ALIAS "Overclock"
 do while eof()=.f.
  nDevID:=val(strtran(Overclock->DEVID,"GPU#","")) + 1 //fix numbering
   dbrlock()
    Overclock->DEVID:="GPU#"+alltrim(str(nDevID))
   dbunlock()
 dbskip()
 end do

end if

select 10
if BaseVer<2
//********************
 close 33
 select 3
 use Overclock SHARED ALIAS "Overclock"
 aStruct1:=Overclock->(dbstruct())
// ASIZE(aStruct1, len(aStruct1))
 ASIZE(aStruct1, len(aStruct1)+6)
 AINS(aStruct1, 21, { "P17", "N", 4, 0 })
 AINS(aStruct1, 22, { "P18", "N", 4, 0 })
 AINS(aStruct1, 23, { "P19", "N", 4, 0 })
 AINS(aStruct1, 40, { "T17", "N", 4, 0 })
 AINS(aStruct1, 41, { "T18", "N", 4, 0 })
 AINS(aStruct1, 42, { "T19", "N", 4, 0 })

 DBCREATE(("Overclock1.dbf"), aStruct1)

select 33
use Overclock1

select 3
dbgotop()
aStruct:=dbstruct()

 do while eof()=.f.
   select 33
   dbappend()
    select 3
    for nField=1 to len(aStruct)
     cField:=fieldname(nField)
     varField:=&cField
     Overclock1->&cField:=varField
    next
 select 3
 dbskip(1)
 end do

 close databases

 if ferase(basedir+"Overclock.dbf")<>0
  msgstop("Ошибка удаления "+basedir+"Overclock.dbf")
  quit
 end if
 if frename(basedir+"Overclock1.dbf",basedir+"Overclock.dbf")<>0
  msgstop("Ошибка переименования!")
  quit
 end if
end if
//*****


select 10
use BaseVer SHARED ALIAS "BaseVer"

 dbrlock()
 BaseVer->BaseVer:=2
 dbunlock()

//********************
Close Databases



return nil