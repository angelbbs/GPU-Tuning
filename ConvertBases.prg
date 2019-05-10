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

Close Databases



return nil