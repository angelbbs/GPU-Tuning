Function init()
public basedir:="configs\"

NETERR(.T.)

SET DEFAULT to &basedir
SET DELETED ON
SET EPOCH TO 1950
SET CENTURY ON
SET EXACT ON

SET DATE FORMAT "dd.mm.yyyy"

public _hOn  := LoadBitMap(GetResources(),"checkon")
public _hOff := LoadBitMap(GetResources(),"checkoff")


return nil

//***** Количество записей при фильтре
static function dbcount(cAlias)
local nLastArea:= SELECT()
local nRecCount
SELECT(cAlias)
nRecCount:=0
nCurRec:=recno()
dbgotop()
do while eof()=.f.
nRecCount:=nRecCount+1

dbskip(1)
end do
SELECT (nLastArea)
dbgoto(nCurRec)
return nRecCount

static function SetsAlgo( oLbx, nRow, nCol )

   local nColumn := oLbx:nAtCol( nCol )
    if nColumn == 1
     select 3
     DBRLOCK()
      Overclock->OENABLE0:=!Overclock->OENABLE0
     dbunlock()
    end if
return nil

//*************************************************************
Function aMemoLine(cText, nLine)

local cMemoLine:=""
local nPosinLine:=1
local nKolStrok:=0
local nextPosInLine:=1
local nPos:=1
local lencText:=len(cText)

Default cText:=""

if cText==""
 return ""
end uf

if right(cText,2)<>CRLF
 cText+=CRLF
end if

do while nPos<lencText
cMemoLine+=SubSTR(cText, nPos, 1)

if RAt( CRLF, cMemoLine) > 0
 nKolStrok++
 if nKolStrok=nLine
   exit
 else
  cMemoLine=""
 end if
end if

nPos++
enddo

return cMemoLine

