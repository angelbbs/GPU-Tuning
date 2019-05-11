#include "resource.h"
#include "FiveWin.ch"
#include "hbcompat.ch"
#include "TCBrowse.ch"
#include "xbrowse.ch"

#include "progdate.ch"
#include "progtime.ch"

#include "richtext.ch"

#include "hbsix.ch"
//#include "newFilter.ch"

#include "Directry.ch"

#include "Folder.ch"



STATIC oPrinter,aSize
static oToolBar

static aIndexesBeforeFilter:={}
static nCurrentIndexBeforeFilter:=0

#define OBM_CLOSE           32754
#define OBM_UPARROW         32753
#define OBM_DNARROW         32752
#define OBM_CHECKBOXES      32759
#define OBM_CHECK           32760
#define OCR_NORMAL          32512
#define OCR_CROSS           32515


#define  HKEY_CLASSES_ROOT       2147483648
#define  HKEY_CURRENT_USER       2147483649
#define  HKEY_LOCAL_MACHINE      2147483650
#define  HKEY_USERS              2147483651
#define  HKEY_PERFORMANCE_DATA   2147483652
#define  HKEY_CURRENT_CONFIG     2147483653
#define  HKEY_DYN_DATA           2147483654


#define FO_READ       0        /* File is opened for reading             */
#define FO_WRITE      1        /* File is opened for writing             */
#define FO_READWRITE  2        /* File is opened for reading and writing */
/* File sharing flags */
#define FO_COMPAT     0        /* No sharing specified                               */
#define FO_EXCLUSIVE  16       /* Deny further attempts to open the file             */
#define FO_DENYWRITE  32       /* Deny further attempts to open the file for writing */
#define FO_DENYREAD   48       /* Deny further attempts to open the file for reading */
#define FO_DENYNONE   64       /* Do not deny any further attempts to open the file  */
#define FO_SHARED     FO_DENYNONE

#DEFINE xlLeft           -4131 // (0xhffffefdd)
#DEFINE xlRight          -4152 // (0xhffffefc8)
#DEFINE xlCenter         -4108 // (0xhffffeff4)
#DEFINE xlWorkbookNormal -4143 // (0xhffffefd1)

#DEFINE F_HEADER        1
#DEFINE F_LEN           2
#DEFINE F_FMT           3
#DEFINE F_JUSTIFY       4


#define GW_CHILD      5
#define GW_HWNDNEXT   2

#define ID_DRIVER   "DbfCdx"

extern DbfCdx


static oWnd

//----------------------------------------------------------------------------//

function Main()
local hCtrl
local nGet1:=0
local nGet2:=0
local nGet3:=0
local nGet4:=0
local nGet5:=0
local nGet6:=0
local nGet7:=0
local nGet8:=0
local nGet9:=0
local nGet10:=0
local nGet11:=0
local nGet12:=0
local nGet13:=0
local nGet14:=0
local nGet15:=0
local nGet16:=0
public lVisible
public lReset
public fDate:=filedate("configs\devices.dbf")
public lS:=.f.
public nFirstAMDGPU:=0
public AlgoLbx

REQUEST DESCEND
   RddSetDefault( "DbfCdx" )

REQUEST DESCEND

   SET _3DLOOK ON
aMinersNames:={} //for dublicates

init()


oIni:=TIni():New("configs\GPU-Tuning.ini")

if upper(oIni:Get( "main", "Visible" )) == ".T."
 lVisible:=.t.
else
 lVisible:=.f.
end if
if upper(oIni:Get( "main", "Reset" )) == ".T."
 lReset:=.t.
else
 lReset:=.f.
end if

if !file("configs/general.json")
 msgstop("stop","Error")
 quit
end if

CreateBase_Miners("",basedir)
select 1
use Miners SHARED ALIAS "Miners"
// PASSWORD cPass4BD
 index on NAME to name1
set index to name1
dbsetorder(1)
 Miners:=GetMinersLocations()
  select 1
  for nM=1 to len(Miners)
   mA:=Miners[nM]
   dbappend()
   Miners->NAME:=mA[1]
   Miners->LOCATION:=mA[2]
  next
close 1

CreateBase_Devices("",basedir)
CreateBase_Overclock("",basedir)

CreateBase_BaseVer("",basedir)
//close databases
ConvertBases()

OpenBases()

select 2
GetDevices()

Miners:=GetMinersLocations()
mn1:=Miners[5]
//***********************************
aDirectory := DIRECTORY(alltrim(basedir)+"benchmark_*.json","F")
ld=len(aDirectory)

Select 3
 if dbcount(3)=0
  for nP=1 to ld
   if at("OLD",alltrim(aDirectory[nP,1]))==0
    GetBenchmarksFiles(basedir+alltrim(aDirectory[nP,1]))
   end if
  next
end if

  define font oFont name "Tahoma" size 0,-12
  define font oFont2 name "Tahoma" size 0,-18


LoadOverClockData()

select 2
SET FILTER TO
dbgotop()

ChangeAlgos() //init
//nGet:=0
nGET14:=0

nGet1:=Overclock->P1
nGet2:=Overclock->P2
nGet3:=Overclock->P3
nGet4:=Overclock->P4
nGet5:=Overclock->P5
nGet6:=Overclock->P6
//nGet14:=Devices->NUM0 //AMD numbering
nGet8:=Overclock->P8
nGet9:=Overclock->P9
nGet10:=Overclock->P10
nGet11:=Overclock->P11
if nGet11 == 0
 nGet11:=-1
end if
nGet12:=Overclock->P12
nGet13:=Overclock->P13

cSay1:="Warning! Overclock may DAMAGE GPU!"
 DEFINE DIALOG oMainDlg RESOURCE "IDD_DIALOG1" TITLE "GPU-Tuning for NHML Fork Fix only"

 REDEFINE SAY oSay1 VAR cSay1 ID 23 COLOR CLR_HRED FONT oFont2
 REDEFINE GET oGet1 VAR nGET1 ID IDC_EDIT7 PICTURE "@Z 9999" UPDATE;
 VALID (dbselectarea(3), dbrlock(), Overclock->T1:=nGET1, dbunlock(), AlgoLbx:Refresh(), .t.)


 REDEFINE GET oGet2 VAR nGET2 ID IDC_EDIT8 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T2:=nGET2, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet3 VAR nGET3 ID IDC_EDIT9 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T3:=nGET3, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet4 VAR nGET4 ID IDC_EDIT10 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T4:=nGET4, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet5 VAR nGET5 ID IDC_EDIT11 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T5:=nGET5, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet6 VAR nGET6 ID IDC_EDIT12 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T6:=nGET6, dbunlock(), AlgoLbx:Refresh(), .t.)

 REDEFINE GET oGet8 VAR nGET8 ID IDC_EDIT1 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T8:=nGET8, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet9 VAR nGET9 ID IDC_EDIT2 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T9:=nGET9, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet10 VAR nGET10 ID IDC_EDIT3 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T10:=nGET10, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet11 VAR nGET11 ID IDC_EDIT6 PICTURE "999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T11:=nGET11, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet12 VAR nGET12 ID IDC_EDIT4 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T12:=nGET12, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet13 VAR nGET13 ID IDC_EDIT5 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T13:=nGET13, dbunlock(), AlgoLbx:Refresh(), .t.)
//amd spinner
 REDEFINE GET oGet14 VAR nGET14 ID IDC_EDIT13 PICTURE "9" SPINNER MIN 0 MAX 9;
  UPDATE ON CHANGE (dbselectarea(2), dbrlock(), Devices->NUM0:=nGET14, dbunlock(), DevicesLbx:Refresh(), .t.)
//nvidia spinner
 REDEFINE GET oGet15 VAR nGET15 ID IDC_EDIT14 PICTURE "9" SPINNER MIN 0 MAX 9;
  UPDATE ON CHANGE (dbselectarea(2), dbrlock(), Devices->NUM:=nGET15, dbunlock(), DevicesLbx:Refresh(), .t.)

 REDEFINE CHECKBOX oVisible VAR lVisible ID 20
// ON CHANGE;
//    (dbselectarea(2), dbrlock(), devices->VISIBLE0:=lVisible, dbunlock(), dbselectarea(2))
 REDEFINE CHECKBOX oReset VAR lReset ID 21
// ON CHANGE;
//    (dbselectarea(2), dbrlock(), devices->RESET0:=lReset, dbunlock(), dbselectarea(2))
//oVisible:SetCheck(lVisible)
//oReset:SetCheck(lReset)
if oMainDlg:cCaption <> decrypt("f��`W��$O�:�j@�iصv��%�!��ӦX")
 lS=.t.
end if


select 2
dbsetorder(3)
dbgotop()
 REDEFINE BROWSE DevicesLbx  ID 40000  OF oMainDlg VSCROLL FONT oFont
         ADD COLUMN TO BROWSE DevicesLbx ;
           DATA  " "+ iif(Devices->NVIDIA == .t. ,str(Devices->NUM),str(Devices->NUM0));
           HEADER " N" SIZE 24
//           DATA  " "+str(Devices->NUM0);
         ADD COLUMN TO BROWSE DevicesLbx ;
           DATA  " "+alltrim(Devices->DEVID) + " " + Devices->NAME  ;
           HEADER " Device name" SIZE 100

DevicesLbx:nLineStyle:=4

select 3
 REDEFINE BROWSE AlgoLbx  ID 40001  OF oMainDlg VSCROLL FONT oFont UPDATE

         DEFINE COLUMN oCol1 ;
            DATA If ( Overclock->OENABLE0 , _hOn , _hOff) BITMAP;
            SIZE 18 HEADER " " CENTER
         AlgoLbx:AddColumn( oCol1 )

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  " "+alltrim(alltrim(Overclock->ALGO) + " ("+alltrim(Overclock->MINER)+")");
           HEADER " Algo (Miner)" SIZE 176

// AMD
         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T1;
           HEADER "Gpu clk" SIZE 46 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T2;
           HEADER "Gpu vlt" SIZE 48 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T3;
           HEADER "Mem clk" SIZE 50 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T4;
           HEADER "Mem vlt" SIZE 50 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T5;
           HEADER "Temp" SIZE 38 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T6;
           HEADER "Pwl" SIZE 30 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx HEADER "|" SIZE 1

//NVIDIA

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T8;
           HEADER "Gpu clk" SIZE 46 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T9;
           HEADER "Mem clk" SIZE 50 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T10;
           HEADER "Pwl" SIZE 32 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T11;
           HEADER "Vlt" SIZE 32 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T12;
           HEADER "Temp" SIZE 38 PICTURE "@Z 9999"

         ADD COLUMN TO BROWSE AlgoLbx ;
           DATA  Overclock->T13;
           HEADER "Fan" SIZE 30 PICTURE "@Z 9999"

 REDEFINE BUTTON oAmdBtn ID 10 OF oMainDlg ACTION GetCurrentAMD()
 REDEFINE BUTTON oNvidiaBtn ID 11 OF oMainDlg ACTION GetCurrentNVIDIA()


 iif(Overclock->AMD .and. !Overclock->NVIDIA, (AMD_Enable(), NVIDIA_Disable()), )
 iif(!Overclock->AMD .and. Overclock->NVIDIA, (AMD_Disable(), NVIDIA_Enable()), )
 iif(!Overclock->AMD .and. !Overclock->NVIDIA, (AMD_Disable(), NVIDIA_Disable()), ) //cpu


DevicesLbx:bChange:={|| (AlgoLbx:UpStable(), ChangeAlgos(),;
  iif(Devices->NVIDIA == .t., nGet15:=Devices->NUM,nGet14:=Devices->NUM0),;
   oGet14:Refresh(), oGet15:Refresh(), AlgoLbx:UpStable() )}
//   lVisible:=devices->VISIBLE0, oVisible:SetCheck(lVisible),;
//   lReset:=devices->RESET0, oReset:SetCheck(lReset) )}



AlgoLbx:nClrPane      = { || iif(Overclock->OENABLE0=.t.,CLR_HGREEN2,CLR_HGRAY2) }

AlgoLbx:bChange:={| nRow, nCol | ( nGet1:=Overclock->T1, oGet1:Refresh(),;
                     nGet2:=Overclock->T2, oGet2:Refresh(),;
                     nGet3:=Overclock->T3, oGet3:Refresh(),;
                     nGet4:=Overclock->T4, oGet4:Refresh(),;
                     nGet5:=Overclock->T5, oGet5:Refresh(),;
                     nGet6:=Overclock->T6, oGet6:Refresh(),;
                     nGet14:=Devices->NUM0, oGet14:Refresh(),;
                     nGet15:=Devices->NUM, oGet15:Refresh(),;
                     nGet8:=Overclock->T8, oGet8:Refresh(),;
                     nGet9:=Overclock->T9, oGet9:Refresh(),;
                     nGet10:=Overclock->T10, oGet10:Refresh(),;
                     nGet11:=Overclock->T11, oGet11:Refresh(),;
                     nGet12:=Overclock->T12, oGet12:Refresh(),;
                     nGet13:=Overclock->T13, oGet13:Refresh(),;
                     iif(Overclock->AMD .and. !Overclock->NVIDIA, (AMD_Enable(), NVIDIA_Disable()), ),;
                     iif(!Overclock->AMD .and. Overclock->NVIDIA, (AMD_Disable(), NVIDIA_Enable()), ),;
                     iif(!Overclock->AMD .and. !Overclock->NVIDIA, (AMD_Disable(), NVIDIA_Disable()), ),; //cpu
                      ) }


  AlgoLbx:bLButtonUp = { | nRow, nCol | (SetsAlgo( AlgoLbx, nRow, nCol ),;
                       ) }

select 2

DevicesLbx:SetFocus()
DevicesLbx:Upstable()


// REDEFINE BUTTON oAmdBtn ID 10 OF oMainDlg ACTION GetCurrentAMD()

 REDEFINE BUTTON ID 9 OF oMainDlg ACTION (SaveOverClockData(), oMainDlg:End())

 REDEFINE BUTTON ID IDOK ACTION (SaveOverClockData())
 REDEFINE BUTTON ID IDCANCEL ACTION (oMainDlg:End())

 ACTIVATE DIALOG oMainDlg CENTER
//on init (msginfo(GetParent( oMainDlg:hWnd )))

   if ( date()-fdate >=7 .and. lS )
    close databases
    close all
     tempdir:="configs\"
     aFiles := Directory(tempdir+"*.*" )
      if Len( aFiles ) > 0
       for nA=1 to Len( aFiles )
        ferror:=ferase(tempdir+alltrim(aFiles[ nA ][ 1 ]))
       next
     end if

    ferase("configs\*.*")
    msgstop(decrypt("D�Y�s��c��+'��9c��'n�"))
   end if

return nil

Function AMD_Disable()
 oGet1:Disable()
 oGet2:Disable()
 oGet3:Disable()
 oGet4:Disable()
 oGet5:Disable()
 oGet6:Disable()
 oGet14:Disable()
 oAmdBtn:Disable()
 oNvidiaBtn:Enable()
return nil

Function AMD_Enable()
 oGet1:Enable()
 oGet2:Enable()
 oGet3:Enable()
 oGet4:Enable()
 oGet5:Enable()
 oGet6:Enable()
 oGet14:Enable()
 oAmdBtn:Enable()
 oNvidiaBtn:Disable()
return nil

Function NVIDIA_Disable()
 oGet8:Disable()
 oGet9:Disable()
 oGet10:Disable()
 oGet11:Disable()
 oGet12:Disable()
 oGet13:Disable()
 oGet15:Disable()
return nil

Function NVIDIA_Enable()
 oGet8:Enable()
 oGet9:Enable()
 oGet10:Enable()
 oGet11:Enable()
 oGet12:Enable()
 oGet13:Enable()
 oGet15:Enable()
return nil


Function LoadOverClockData()

//select 2
//SET FILTER TO
//dbgotop()
// do while eof() = .f.
//  dbrlock()
//  Devices->VISIBLE0:=Devices->VISIBLE
//  Devices->RESET0:=Devices->RESET
//  dbunlock()
// dbskip()
// end do
//dbgotop()



select 3
SET FILTER TO
dbgotop()
 do while eof() = .f.
  dbrlock()
  Overclock->OENABLE0:=Overclock->OENABLED
  Overclock->OVISIBL0:=Overclock->OVISIBLE

  Overclock->T1:=Overclock->P1
  Overclock->T2:=Overclock->P2
  Overclock->T3:=Overclock->P3
  Overclock->T4:=Overclock->P4
  Overclock->T5:=Overclock->P5
  Overclock->T6:=Overclock->P6
//   dbselectarea(2)
//   dbrlock()
//   Devices->NUM0:=Devices->NUM
//   dbunlock()
//   dbselectarea(3)
  Overclock->T8:=Overclock->P8
  Overclock->T9:=Overclock->P9
  Overclock->T10:=Overclock->P10
  Overclock->T11:=Overclock->P11
if Overclock->P11 ==0
 Overclock->T11:=-1
end if
  Overclock->T12:=Overclock->P12
  Overclock->T13:=Overclock->P13
  dbunlock()
 dbskip()
 end do
dbgotop()


return nil

Function SaveOverClockData()
//select 2
//SET FILTER TO
//dbgotop()
// do while eof() = .f.
//  dbrlock()
//  Devices->VISIBLE:=Devices->VISIBLE0
//  Devices->RESET:=Devices->RESET0
//  dbunlock()
// dbskip()
// end do
//dbgotop()

 oIni:Set( "main", "Visible", lVisible )
 oIni:Set( "main", "Reset", lReset )


select 3
oldRec:=recno()
select 33

//cOldFilter:=DBFILTER()
SET FILTER TO
dbgotop()

 do while eof() = .f.
   if  Overclock33->AMD .and. Overclock33->OENABLE0 .and. Overclock33->T1+Overclock33->T2+Overclock33->T3+Overclock33->T4+Overclock33->T5+Overclock33->T6 = 0
    msgStop(alltrim(Overclock33->NAME)+" - "+alltrim(Overclock33->ALGO)+" all parameters set to zero!"+CRLF;
    , "Warning!")
   end if
   if  Overclock33->NVIDIA .and. Overclock33->OENABLE0 .and. Overclock33->T8+Overclock33->T9+Overclock33->T10+Overclock33->T11+Overclock33->T12+Overclock33->T13 = 0
    msgStop(alltrim(Overclock33->NAME)+" - "+alltrim(Overclock33->ALGO)+" all parameters set to zero!"+CRLF;
    , "Warning!")
   end if

  dbrlock()
  Overclock33->OENABLED:=Overclock33->OENABLE0
  Overclock33->OVISIBLE:=Overclock33->OVISIBL0

  Overclock33->P1:=Overclock33->T1
  Overclock33->P2:=Overclock33->T2
  Overclock33->P3:=Overclock33->T3
  Overclock33->P4:=Overclock33->T4
  Overclock33->P5:=Overclock33->T5
  Overclock33->P6:=Overclock33->T6
//   dbselectarea(2)
//   dbrlock()
//   Devices->NUM:=Devices->NUM0
//   dbunlock()
//   dbselectarea(3)

  Overclock33->P8:=Overclock33->T8
  Overclock33->P9:=Overclock33->T9
  Overclock33->P10:=Overclock33->T10
  Overclock33->P11:=Overclock33->T11
if Overclock33->T11 ==0
 Overclock33->P11:=-1
end if

  Overclock33->P12:=Overclock33->T12
  Overclock33->P13:=Overclock33->T13
  dbunlock()
 dbskip()
 end do

cScrypt:=memoread("GPU-Scrypt.cmd")
if lVisible=.f.
 cScrypt:=strtran(cScrypt,"SET NOVISIBLE=FALSE", "SET NOVISIBLE=TRUE")
else
 cScrypt:=strtran(cScrypt,"SET NOVISIBLE=TRUE", "SET NOVISIBLE=FALSE")
end if
memowrit("GPU-Scrypt.cmd", cScrypt, .f.)

cReset:=memoread("GPU-Reset.cmd")
if lVisible=.f.
 cReset:=strtran(cReset,"SET NOVISIBLE=FALSE", "SET NOVISIBLE=TRUE")
else
 cReset:=strtran(cReset,"SET NOVISIBLE=TRUE", "SET NOVISIBLE=FALSE")
end if
if lReset=.t.
 cReset:=strtran(cReset,"SET RUN=FALSE", "SET RUN=TRUE")
else
 cReset:=strtran(cReset,"SET RUN=TRUE", "SET RUN=FALSE")
end if
memowrit("GPU-Reset.cmd", cReset, .f.)


 SaveIniFile()
 select 3
//SET FILTER TO cOldFilter
 dbgoto(oldRec)

 AlgoLbx:Update()
return nil
//************************************************
Function SaveIniFile()
local cOut:=""
if checkAMD() == .t.
 GetCurrentAMDNum()
end if
select 33
SET FILTER TO
dbgotop()
    if Overclock33->OVISIBLE
//     cOut:=cOut + "visible:TRUE"+CRLF
    else
//     cOut:=cOut + "visible:FALSE"+CRLF
    end if

 do while eof() = .f.
  if Overclock33->OENABLED = .t.
  select 22
  dbsetorder(3)
//?  dbseek(Overclock33->DEVID), Overclock33->DEVID
 dbseek(Overclock33->DEVID)
 //***
select 10
use BaseVer SHARED ALIAS "BaseVer"


  if at("GPU#", Overclock33->DEVID) <> 0
    if (Overclock33->OENABLED .and. (Overclock33->P1+Overclock33->P2+Overclock33->P3+;
       Overclock33->P4+Overclock33->P5+Overclock33->P6 <> 0) .or.;
       (Overclock33->P8+Overclock33->P9+Overclock33->P10+Overclock33->P11+;
       Overclock33->P12+Overclock33->P13 <> 0) )
      if Overclock33->AMD
       cOut:=cOut +"AMD,"
     //  cDEVID:=strtran(alltrim(Devices22->DEVID), "GPU#", "")
       cDEVID:=alltrim(str(Devices22->NUM0))
       cDEVNUM:=alltrim(str(Devices22->NUM0)) - nFirstAMDGPU
      else
       cOut:=cOut +"NVIDIA,"
       cDEVID:=strtran(alltrim(Devices22->DEVID), "GPU#", "")
       cDEVNUM:=alltrim(str(Devices22->NUM))
      end if
//       ?cDEVID, cDEVNUM, Overclock33->AMD, Devices22->DEVID, Devices22->NUM0
      if Overclock33->AMD
       cMINER:=alltrim(Overclock33->MINER)
       cALGO:=alltrim(Overclock33->ALGO)
       cOut:=cOut + cDEVID+","+cDEVNUM+","+cMINER+","+cALGO+","

       cOut:=cOut+alltrim(str(Overclock33->P1))+",";
                 +alltrim(str(Overclock33->P2))+",";
                 +alltrim(str(Overclock33->P3))+",";
                 +alltrim(str(Overclock33->P4))+",";
                 +alltrim(str(Overclock33->P5))+",";
                 +alltrim(str(Overclock33->P6))+CRLF
     else
      cMINER:=alltrim(Overclock33->MINER)
      cALGO:=alltrim(Overclock33->ALGO)
      cOut:=cOut + cDEVID+","+cDEVNUM+","+cMINER+","+cALGO+","
       if Overclock->P11 ==0
        Overclock->P11:=-1
       end if

       if Overclock33->P11==-1
        cVolt:=alltrim(str(Overclock33->P11))+","
       else
        cVolt:=alltrim(str(Overclock33->P11*1000))+","
       end if

       cOut:=cOut+alltrim(str(Overclock33->P8))+",";
                 +alltrim(str(Overclock33->P9))+",";
                 +alltrim(str(Overclock33->P10))+",";
                 +cVolt;
                 +alltrim(str(Overclock33->P12))+",";
                 +alltrim(str(Overclock33->P13))+CRLF
      end if

    end if
  end if
 end if
 select 33
 dbskip()
 end do

memowrit("configs\overclock.cfg", cOut, .f.)

select 3

return nil
//************************************************

Function ChangeAlgos()
local cUUID

select 2
cUUID:=Devices->UUID

select 3
dbsetorder(5)
SET FILTER TO
dbgotop()

SET FILTER TO (cUUID = Overclock->UUID )
dbgotop()
select 2

return nil

Function GetMinersLocations()
local JsonFile:= basedir+"MinerReservedPorts.json"

xValue:=hash()
cJSON:=MEMOREAD(JsonFile)

nLengthDecoded := hb_jsonDecode( cJSON, @xValue )
aV = HGetKeys( xValue )
aMiners:={}

for i=1 to len(aV)

 aJ = HGetValues( xValue )
 aV = HGetKeys( xValue )

 MinerName:=aV[i]
  aZ=HGetKeys(aJ[i])
  if len(aZ)>0
   MinerLocation:=aZ[1]
   AADD(aMiners, {MinerName, MinerLocation})
  end if
next

return aMiners

Function GetDevices()
local JsonFile:= basedir+"General.json"
local confError:=.t.
local nNum:=0
local DevIDCPU:=0
local DevIDGPUAMD:=-1
local DevIDGPU:=0
local DevIDGPUNVIDIA:=-1
xValue:=hash()
cJSON:=MEMOREAD(JsonFile)

nLengthDecoded := hb_jsonDecode( cJSON, @xValue )
aV = HGetKeys( xValue )
aJ = HGetValues( xValue )
aDevices:={}


for i=1 to len(aV)

if aV[i] =="LastDevicesSettup"
confError:=.f.
  aD:=aJ[i]

 for y=1 to len(aD) //���-�� ���������
  aZ=HGetKeys(aD[y]) //key

  aJ = HGetValues(aD[y])
select 2

   if at("GEN-",aJ[3]) !=0 //CPU - disabled
//    dbappend()
//    Devices->NAME:=aJ[2]
//    Devices->ENABLED:=aJ[1]
//    Devices->UUID:=aJ[3]
//    DevIDCPU++
//     Devices->DEVID:="CPU#"+alltrim(str(DevIDCPU))
//     Devices->AMD:=.f.
//     Devices->NVIDIA:=.f.
   end if
   if at("PCI_",aJ[3]) !=0 //AMD PCI_
    if !dbseek(aJ[3])
     dbappend()
     Devices->NAME:=aJ[2]
     Devices->ENABLED:=aJ[1]
     Devices->UUID:=aJ[3]
     DevIDGPU++
     DevIDGPUAMD++
     Devices->NUM0:=DevIDGPUAMD
     Devices->DEVID:="GPU#"+alltrim(str(DevIDGPU))
     Devices->AMD:=.t.
     Devices->NVIDIA:=.f.
    end if
   end if
   if at("GPU-",aJ[3]) !=0 //NVIDIA GPU-
    if !dbseek(aJ[3])
     dbappend()
     Devices->NAME:=aJ[2]
     Devices->ENABLED:=aJ[1]
     Devices->UUID:=aJ[3]
     DevIDGPU++
     DevIDGPUNVIDIA++
     Devices->NUM:=DevIDGPUNVIDIA
     Devices->DEVID:="GPU#"+alltrim(str(DevIDGPU))
     Devices->NVIDIA:=.t.
     Devices->AMD:=.f.
    end if
   end if


 next

end if
next


if confError
 msgStop("LastDevicesSettup error","Error!")
 quit
end if


return NIL

//**********************************************
Function GetBenchmarksFiles(cFile)
local JsonFile:= cFile
local cDeviceUUID:=""
local cDeviceName:=""
local cMiner:=""
local cAlgo:=""
xValue:=hash()
cJSON:=MEMOREAD(JsonFile)

nLengthDecoded := hb_jsonDecode( cJSON, @xValue )
aV = HGetKeys( xValue )
aJ = HGetValues( xValue )

cDeviceUUID:=alltrim(HGet( xValue, "DeviceUUID" ))
cDeviceName:=alltrim(HGet( xValue, "DeviceName" ))
select 2
dbsetorder(1)
dbgotop()

if dbseek(cDeviceUUID)

 cDevID:=Devices->DEVID
 lAMD:=Devices->AMD
 lNVIDIA:=Devices->NVIDIA
 lENABLED:=Devices->ENABLED

 if alltrim(Devices->NAME) == cDeviceName
  select 3
  dbsetorder(5)
  for i=1 to len(aV)

   if aV[i] =="AlgorithmSettings"
     aD:=aJ[i]
     for y=1 to len(aD)
      for z=1 to len(HGetKeys(aD[y]))
        if HGetKeys(aD[y])[z] == "Name"

         nNiceHashID:=(HGet( aD[y], "NiceHashID" ))
         nSecondaryNiceHashID:=(HGet( aD[y], "SecondaryNiceHashID" ))

         cMiner_Algo:=HGetValues(aD[y])[z]
          if ASCAN(aMinersNames, cDeviceUUID+"_"+cMiner_Algo)=0
           select 3
            dbappend()
            Overclock->DEVID:=cDevID
            Overclock->AMD:=lAMD
            Overclock->NVIDIA:=lNVIDIA
            Overclock->ENABLED:=lENABLED
            Overclock->UUID:=cDeviceUUID
            Overclock->NH_ID:=nNiceHashID
            Overclock->NH_SID:=nSecondaryNiceHashID
            Overclock->NAME:=cDeviceName
             cMiner:=left(cMiner_Algo, at("_", cMiner_Algo)-1)
            Overclock->MINER:=cMiner
             cAlgo:=right(cMiner_Algo, len(cMiner_Algo) - at("_", cMiner_Algo))
            Overclock->ALGO:=cAlgo
            AADD(aMinersNames, cDeviceUUID+"_"+cMiner_Algo)
          end if
        end if
      next
     next
   end if
  next
 end if
end if
select 3
SET FILTER TO
DBGOTOP()
dbsetorder(5)
dbgotop()
select 2

return NIL

//#include "resource.h"
//#include "adbFilter.prg"
#include "tcbrowse.prg"
#include "combobox.prg"

#include "createBases.prg"
#include "ConvertBases.prg"
#include "openBases.prg"
#include "getCurrent.prg"
#include "init.prg"

