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
public lRun
public fDate:=filedate("configs\devices.dbf")
public lS:=.f.
public nFirstAMDGPU:=0
public AlgoLbx
public TotalDevices:=0
public TotalAlgo:=0

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
if upper(oIni:Get( "main", "Run" )) == ".T."
 lRun:=.t.
else
 lRun:=.f.
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
//dbsetorder(1) //uuid
GetDevices()

Miners:=GetMinersLocations()
mn1:=Miners[5]
//***********************************
aDirectory := DIRECTORY(alltrim(basedir)+"benchmark_*.json","F")
ld=len(aDirectory)

Select 3
// if dbcount(3)=0
  for nP=1 to ld
   if at("OLD",alltrim(aDirectory[nP,1]))==0
    GetBenchmarksFiles(basedir+alltrim(aDirectory[nP,1]))
   end if
  next
//end if

  define font oFont name "Tahoma" size 0,-12
  define font oFont2 name "Tahoma" size 0,-18


LoadOverClockData()

select 2
SET FILTER TO
dbgotop()
count to TotalDevices

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

//**
cScrypt:=upper(memoread("GPU-Scrypt.cmd"))
if at("SET NOVISIBLE=FALSE",cScrypt)<>0
 lVisible:=.t.
end if
if at("SET NOVISIBLE=TRUE",cScrypt)<>0
 lVisible:=.f.
end if

if at("SET RUN=FALSE",cScrypt)<>0
 lRun:=.f.
end if
if at("SET RUN=TRUE",cScrypt)<>0
 lRun:=.t.
end if

cReset:=memoread("GPU-Reset.cmd")
if at("SET RUN=FALSE",cReset)<>0
 lReset:=.f.
end if
if at("SET RUN=TRUE",cReset)<>0
 lReset:=.t.
end if

 oIni:Set( "main", "Visible", lVisible )
 oIni:Set( "main", "Reset", lReset )
 oIni:Set( "main", "Run", lRun )


cSay1:="Warning! Overclock may DAMAGE GPU!"
 DEFINE DIALOG oMainDlg RESOURCE "IDD_DIALOG1" TITLE "GPU-Tuning for NHML Fork Fix only"

 REDEFINE SAY oSay1 VAR cSay1 ID 23 COLOR CLR_HRED FONT oFont2
 REDEFINE GET oGet1 VAR nGET1 ID IDC_EDIT7 PICTURE "@Z 9999" UPDATE;
 VALID (dbselectarea(3), dbrlock(), Overclock->T1:=nGET1, dbunlock(), AlgoLbx:Refresh(), .t.)


 REDEFINE GET oGet2 VAR nGET2 ID IDC_EDIT8 PICTURE "9999" UPDATE;
  VALID (dbselectarea(3), dbrlock(), Overclock->T2:=nGET2, dbunlock(), AlgoLbx:Refresh(), .t.)
//  ON CHANGE (dbselectarea(3), dbrlock(), Overclock->T2:=nGET2, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet3 VAR nGET3 ID IDC_EDIT9 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T3:=nGET3, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet4 VAR nGET4 ID IDC_EDIT10 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T4:=nGET4, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet5 VAR nGET5 ID IDC_EDIT11 PICTURE "9999" UPDATE;
  VALID (dbselectarea(3), dbrlock(), Overclock->T5:=nGET5, dbunlock(), AlgoLbx:Refresh(), .t.)
//  ON CHANGE (dbselectarea(3), dbrlock(), Overclock->T5:=nGET5, dbunlock(), AlgoLbx:Refresh(), .t.)
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
 REDEFINE CHECKBOX oRun VAR lRun ID 22 ON CHANGE ifrun(lRun)
// ON CHANGE;
//    (dbselectarea(2), dbrlock(), devices->RESET0:=lReset, dbunlock(), dbselectarea(2))
//oVisible:SetCheck(lVisible)
//oReset:SetCheck(lReset)
if oMainDlg:cCaption <> decrypt("fâÑ`WŠÓ$OŒ:äj@·iØµvÉÔ%Î!ÊÉÓ¦X")
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

//DevicesLbx:bRClicked = { | nRowPos, nColumn | ShowPopupDevices( nRowPos, nColumn, DevicesLbx ) }
//DevicesLbx:bRClicked = { | nRow, nCol | msginfo( nRowPos, nCol ) }
DevicesLbx:bRClicked     = { | nRow, nCol | ShowPopupDevices( nRow, nCol, DevicesLbx ) }
//DevicesLbx:bRClicked = { MsgInfo( DevicesLbx:aCols[DevicesLbx:nColSel]:nWidth ) }


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

AlgoLbx:bRClicked     = { | nRow, nCol | ShowPopupAlgo( nRow, nCol, AlgoLbx ) }

 REDEFINE BUTTON oAmdBtn ID 10 OF oMainDlg ACTION GetCurrentAMD()
 REDEFINE BUTTON oNvidiaBtn ID 11 OF oMainDlg ACTION GetCurrentNVIDIA()

  REDEFINE BTNBMP RESOURCE "amdicon" ID 12 ACTION ( SHELLEXECUTE( 0, 0, "utils\\OverdriveNTool.exe", 0, 0, 1 )) NOBORDER NOROUND ADJUST
  REDEFINE BTNBMP RESOURCE "nvidiaicon" ID 13 ACTION ( SHELLEXECUTE( 0, 0, "utils\\nvidiaInspector.exe", 0, 0, 1 )) NOBORDER NOROUND ADJUST


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
    msgstop(decrypt("D¨YÒsŒ¸cÀÙ+'æÜ9cäÑ'n"))
   end if

return nil

function ifrun(lRun)

return nil

function ShowPopupAlgo( nRow, nCol, AlgoLbx )

   local oMenuAlgo
   local nColumn := AlgoLbx:nAtCol( nCol )
   local nRClickRow := nTCWRow( AlgoLbx:hWnd, AlgoLbx:hDC, nRow, oFont:hFont )
    if nRClickRow == 0 //header
     return nil
    end if
   AlgoLbx:nRowPos := nRClickRow
   nClickRow := AlgoLbx:nRowPos
 if nClickRow > TotalAlgo
  return nil
 end if

cDevId:=Overclock->DEVID
cMiner:=Overclock->MINER
cAlgo:=Overclock->ALGO
//return nil //disable
aAlgo:={}
select 33
//dbsetorder(3)
dbgotop()
 do while eof()=.f.
  if alltrim(Overclock33->ALGO)==alltrim(cAlgo);
   .and. alltrim(Overclock33->DEVID)==alltrim(cDevId);
   .and. alltrim(Overclock33->MINER)<>alltrim(cMiner)

   AADD(aAlgo, {Overclock33->MINER, Overclock33->ALGO})
  end if
 dbskip()
 end do

if len(aAlgo)<=0
 return nil
end if

dbgotop()
dbskip(nClickRow-1)
AlgoLbx:Refresh()
//DevicesLbx:Update()
AlgoLbx:UpStable()
//ChangeAlgos()


   MENU oMenuDevices POPUP
      MENUITEM "*** Copy algo settings from: " ACTION MsgInfo( "Select algo from the list below" )
    for nM=1 to len(aAlgo)
     if nClickRow <> nM
      oItem:="oItem"+alltrim(str(nM))
      cMiner:=alltrim(aAlgo[nM,1])
      cAlgo:=alltrim(aAlgo[nM,2])
      MENUITEM &oItem PROMPT cAlgo + " ("+cMiner+")";
       ACTION CopyAlgoSettings(nClickRow, &oItem:cPrompt, cMiner, cAlgo  )
     end if
    next
   ENDMENU

   ACTIVATE POPUP oMenuDevices OF AlgoLbx AT nRow, nCol

return nil


function ShowPopupDevices( nRow, nCol, DevicesLbx )

   local oMenuDevices
   local nColumn := DevicesLbx:nAtCol( nCol )
   local nRClickRow := nTCWRow( DevicesLbx:hWnd, DevicesLbx:hDC, nRow, oFont:hFont )
    if nRClickRow == 0 //header
     return nil
    end if
   DevicesLbx:nRowPos := nRClickRow
   nClickRow := DevicesLbx:nRowPos
 if nClickRow > TotalDevices
  return nil
 end if

//return nil //disable
aDev:={}
select 2
dbsetorder(3)
dbgotop()
 do while eof()=.f.
  AADD(aDev, {devices->DEVID, devices->NAME})
 dbskip()
 end do

dbgotop()
dbskip(nClickRow-1)
DevicesLbx:Refresh()
//DevicesLbx:Update()
AlgoLbx:UpStable()
ChangeAlgos()


   MENU oMenuDevices POPUP
      MENUITEM "*** Copy all settings from: " ACTION MsgInfo( "Select GPU from the list below" )
    for nM=1 to len(aDev)
     if nClickRow <> nM
      oItem:="oItem"+alltrim(str(nM))
      MENUITEM &oItem PROMPT alltrim(aDev[nM,1])+" "+alltrim(aDev[nM,2]) ACTION CopyDevSettings(nClickRow, &oItem:cPrompt )
     end if
    next
   ENDMENU

   ACTIVATE POPUP oMenuDevices OF DevicesLbx AT nRow, nCol

return nil

Function CopyDevSettings(nClickRow, nM)
//?nClickRow, nM, devices->DEVID
//nM îòêóäà â ñòðîêå
 cDevID:=devices->DEVID
 cName:=devices->NAME
select 33
dbgotop()
do while eof()=.f.
// if alltrim(overclock->DEVID)==alltrim(cDevID) .and. alltrim(overclock->NAME)==alltrim(cName)
 if alltrim(overclock33->DEVID)+" "+alltrim(overclock33->NAME)==alltrim(nM);
//? overclock->DEVID, overclock->NAME, overclock->MINER, overclock->ALGO
  cMiner:=overclock33->MINER
  cAlgo:=overclock33->ALGO
  lNVIDIA:=overclock33->NVIDIA
  lENABLED:=overclock33->ENABLED
  lOENABLED:=overclock33->OENABLED
  lOENABLE0:=overclock33->OENABLE0
  lOVISIBLE:=overclock33->OVISIBLE
  lOVISIBL0:=overclock33->OVISIBL0
   nP1:=overclock33->P1
   nP2:=overclock33->P2
   nP3:=overclock33->P3
   nP4:=overclock33->P4
   nP5:=overclock33->P5
   nP6:=overclock33->P6
   nP7:=overclock33->P7
   nP8:=overclock33->P8
   nP9:=overclock33->P9
   nP10:=overclock33->P10
   nP11:=overclock33->P11
   nP12:=overclock33->P12
   nP13:=overclock33->P13
   nP14:=overclock33->P14
   nP15:=overclock33->P15
   nP16:=overclock33->P16
   nT1:=overclock33->T1
   nT2:=overclock33->T2
   nT3:=overclock33->T3
   nT4:=overclock33->T4
   nT5:=overclock33->T5
   nT6:=overclock33->T6
   nT7:=overclock33->T7
   nT8:=overclock33->T8
   nT9:=overclock33->T9
   nT10:=overclock33->T10
   nT11:=overclock33->T11
   nT12:=overclock33->T12
   nT13:=overclock33->T13
   nT14:=overclock33->T14
   nT15:=overclock33->T15
   nT16:=overclock33->T16
    select 3
    dbgotop()
    do while eof()=.f.
     if alltrim(overclock->DEVID)==alltrim(cDevID) .and. alltrim(overclock->NAME)==alltrim(cName);
        .and. alltrim(overclock->MINER)==alltrim(cMiner) .and. alltrim(overclock->ALGO)==alltrim(cAlgo)
//?alltrim(overclock33->DEVID), alltrim(overclock33->NAME), alltrim(overclock33->MINER), alltrim(overclock33->ALGO)
       dbrlock()
        overclock->NVIDIA:=lNVIDIA
        overclock->ENABLED:=lENABLED
        overclock->OENABLED:=lOENABLED
        overclock->OENABLE0:=lOENABLE0
        overclock->OVISIBLE:=lOVISIBLE
        overclock->OVISIBL0:=lOVISIBL0
        overclock->P1:=nP1
        overclock->P2:=nP2
        overclock->P3:=nP3
        overclock->P4:=nP4
        overclock->P5:=nP5
        overclock->P6:=nP6
        overclock->P7:=nP7
        overclock->P8:=nP8
        overclock->P9:=nP9
        overclock->P10:=nP10
        overclock->P11:=nP11
        overclock->P12:=nP12
        overclock->P13:=nP13
        overclock->P14:=nP14
        overclock->P15:=nP15
        overclock->P16:=nP16
        overclock->T1:=nT1
        overclock->T2:=nT2
        overclock->T3:=nT3
        overclock->T4:=nT4
        overclock->T5:=nT5
        overclock->T6:=nT6
        overclock->T7:=nT7
        overclock->T8:=nT8
        overclock->T9:=nT9
        overclock->T10:=nT10
        overclock->T11:=nT11
        overclock->T12:=nT12
        overclock->T13:=nT13
        overclock->T14:=nT14
        overclock->T15:=nT15
        overclock->T16:=nT16
       dbunlock()
     end if
    select 3
    dbskip()
    end do

 end if

select 33
dbskip()
end do
dbgotop()

select 3
dbgotop()
DevicesLbx:Refresh()
//DevicesLbx:Update()
AlgoLbx:UpStable()


return nil

Function CopyAlgoSettings(nClickRow, cPrompt, cMiner, cAlgo)
cMiner:=strtran(right(cPrompt, len(cPrompt) - at("(", cPrompt)),")","" )
//?nClickRow, cPrompt, cMiner, cAlgo
 cDevID:=devices->DEVID
 cName:=devices->NAME
//?cMiner, cAlgo
select 33
dbgotop()
do while eof()=.f.
// if alltrim(overclock->DEVID)==alltrim(cDevID) .and. alltrim(overclock->NAME)==alltrim(cName)
 if alltrim(overclock33->MINER) == alltrim(cMiner) .and. alltrim(overclock33->ALGO) == alltrim(cAlgo);
    .and. alltrim(overclock33->DEVID)==alltrim(cDevID) .and. alltrim(overclock33->NAME)==alltrim(cName)
//? overclock->DEVID, overclock->NAME, overclock->MINER, overclock->ALGO
//  cMiner:=overclock33->MINER
//  cAlgo:=overclock33->ALGO
  lNVIDIA:=overclock33->NVIDIA
  lENABLED:=overclock33->ENABLED
  lOENABLED:=overclock33->OENABLED
  lOENABLE0:=overclock33->OENABLE0
  lOVISIBLE:=overclock33->OVISIBLE
  lOVISIBL0:=overclock33->OVISIBL0
   nP1:=overclock33->P1
   nP2:=overclock33->P2
   nP3:=overclock33->P3
   nP4:=overclock33->P4
   nP5:=overclock33->P5
   nP6:=overclock33->P6
   nP7:=overclock33->P7
   nP8:=overclock33->P8
   nP9:=overclock33->P9
   nP10:=overclock33->P10
   nP11:=overclock33->P11
   nP12:=overclock33->P12
   nP13:=overclock33->P13
   nP14:=overclock33->P14
   nP15:=overclock33->P15
   nP16:=overclock33->P16
   nT1:=overclock33->T1
   nT2:=overclock33->T2
   nT3:=overclock33->T3
   nT4:=overclock33->T4
   nT5:=overclock33->T5
   nT6:=overclock33->T6
   nT7:=overclock33->T7
   nT8:=overclock33->T8
   nT9:=overclock33->T9
   nT10:=overclock33->T10
   nT11:=overclock33->T11
   nT12:=overclock33->T12
   nT13:=overclock33->T13
   nT14:=overclock33->T14
   nT15:=overclock33->T15
   nT16:=overclock33->T16
    select 3
//    dbgotop()
//    do while eof()=.f.
//     if alltrim(overclock->DEVID)==alltrim(cDevID) .and. alltrim(overclock->NAME)==alltrim(cName);
//        .and. alltrim(overclock->MINER)==alltrim(cMiner) .and. alltrim(overclock->ALGO)==alltrim(cAlgo)
//?alltrim(overclock33->DEVID), alltrim(overclock33->NAME), alltrim(overclock33->MINER), alltrim(overclock33->ALGO)
       dbrlock()
        overclock->NVIDIA:=lNVIDIA
        overclock->ENABLED:=lENABLED
        overclock->OENABLED:=lOENABLED
        overclock->OENABLE0:=lOENABLE0
        overclock->OVISIBLE:=lOVISIBLE
        overclock->OVISIBL0:=lOVISIBL0
        overclock->P1:=nP1
        overclock->P2:=nP2
        overclock->P3:=nP3
        overclock->P4:=nP4
        overclock->P5:=nP5
        overclock->P6:=nP6
        overclock->P7:=nP7
        overclock->P8:=nP8
        overclock->P9:=nP9
        overclock->P10:=nP10
        overclock->P11:=nP11
        overclock->P12:=nP12
        overclock->P13:=nP13
        overclock->P14:=nP14
        overclock->P15:=nP15
        overclock->P16:=nP16
        overclock->T1:=nT1
        overclock->T2:=nT2
        overclock->T3:=nT3
        overclock->T4:=nT4
        overclock->T5:=nT5
        overclock->T6:=nT6
        overclock->T7:=nT7
        overclock->T8:=nT8
        overclock->T9:=nT9
        overclock->T10:=nT10
        overclock->T11:=nT11
        overclock->T12:=nT12
        overclock->T13:=nT13
        overclock->T14:=nT14
        overclock->T15:=nT15
        overclock->T16:=nT16
       dbunlock()
//     end if
//    select 3
//    dbskip()
//    end do

 end if

select 33
dbskip()
end do
dbgotop()

select 3
//dbgotop()
DevicesLbx:Refresh()
//DevicesLbx:Update()
AlgoLbx:UpStable()


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
 oIni:Set( "main", "Run", lRun )


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
if lRun=.t.
 cScrypt:=strtran(cScrypt,"SET RUN=FALSE", "SET RUN=TRUE")
else
 cScrypt:=strtran(cScrypt,"SET RUN=TRUE", "SET RUN=FALSE")
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
// GetCurrentAMDNum()
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
  select 22
  dbsetorder(1)

  if Overclock33->OENABLED = .t. .and. dbseek(Overclock33->UUID)
//  select 22
//  dbsetorder(3)
//?  dbseek(Overclock33->DEVID), Overclock33->DEVID
// dbseek(Overclock33->DEVID)
 //***
select 10
use BaseVer SHARED ALIAS "BaseVer"

//?nFirstAMDGPU
  if at("GPU#", Overclock33->DEVID) <> 0
    if (Overclock33->OENABLED .and. (Overclock33->P1+Overclock33->P2+Overclock33->P3+;
       Overclock33->P4+Overclock33->P5+Overclock33->P6 <> 0) .or.;
       (Overclock33->P8+Overclock33->P9+Overclock33->P10+Overclock33->P11+;
       Overclock33->P12+Overclock33->P13 <> 0) )
      if Overclock33->AMD
       cOut:=cOut +"AMD,"
     //  cDEVID:=strtran(alltrim(Devices22->DEVID), "GPU#", "")
       cDEVID:=alltrim(str(Devices22->NUM0))
       cDEVNUM:=alltrim(str(Devices22->NUM0 - nFirstAMDGPU)) //
//?cDEVID, cDEVNUM, nFirstAMDGPU, Devices22->NAME, Devices22->UUID
        if Devices22->NUM0 - nFirstAMDGPU < 0
         msgStop("Numbering error for device "+alltrim(Devices->DEVID)+" ("+cDEVNUM+")", "Error!")
        end if
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
       select 3
       if Overclock->P11 ==0
        dbrlock()
        Overclock->P11:=-1
        dbunlock()
       end if
       select 10

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
TotalAlgo:=dbcount(3)
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

GetCurrentAMDnum()
DevIDGPUAMD:=nFirstAMDGPU

for i=1 to len(aV)

if aV[i] =="LastDevicesSettup"
confError:=.f.
  aD:=aJ[i]

aDevAMD:={}
 for y=1 to len(aD) //êîë-âî óñòðîéñòâ
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
    DevIDGPU++
    if !dbseek(aJ[3])
//6213
     dbappend()
     Devices->NAME:=aJ[2]
     Devices->ENABLED:=aJ[1]
     Devices->UUID:=aJ[3]
//     DevIDGPU++

     Devices->NUM0:=DevIDGPUAMD
     Devices->DEVID:="GPU#"+alltrim(str(DevIDGPU))
     Devices->AMD:=.t.
     Devices->NVIDIA:=.f.
     DevIDGPUAMD++
    else
     DevIDGPUAMD++
//       AADD(aDevAMD, {aJ[2], aJ[1], aJ[3], DevIDGPU, DevIDGPUAMD, "GPU#"+alltrim(str(DevIDGPU)) })
    end if
   end if
   if at("GPU-",aJ[3]) !=0 //NVIDIA GPU-
    DevIDGPU++
    if !dbseek(aJ[3])
     dbappend()
     Devices->NAME:=aJ[2]
     Devices->ENABLED:=aJ[1]
     Devices->UUID:=aJ[3]
//     DevIDGPU++
     DevIDGPUNVIDIA++
     Devices->NUM:=DevIDGPUNVIDIA
     Devices->DEVID:="GPU#"+alltrim(str(DevIDGPU))
     Devices->NVIDIA:=.t.
     Devices->AMD:=.f.
    else
     DevIDGPUNVIDIA++
    end if
   end if


 next


select 2
dbgotop()
do while eof() = .f.
lFound:=.f.
 for y=1 to len(aD) //êîë-âî óñòðîéñòâ
  aZ = HGetKeys(aD[y]) //key
  aJ = HGetValues(aD[y])

   if alltrim(Devices->UUID) == alltrim(aJ[3])
    lFound:=.t.
    end id
 next
    if lFound == .f.
     dbrlock()
     dbdelete()
     dbunlock()
    end if
dbskip()
end do

//ASORT( aDevAMD,,, {| x, y | x[3] < y[3] } )
//nAMD:=DevIDGPU+1
//nnumAmd:=0
//for nA=1 to len(aDevAMD)
//     dbappend()
//     Devices->NAME:=aDevAMD[nA, 1]
//     Devices->ENABLED:=aDevAMD[nA, 2]
//     Devices->UUID:=aDevAMD[nA, 3]
//     Devices->NUM0:=nnumAmd
//     nnumAmd++
//     Devices->DEVID:="GPU#"+alltrim(str(nAMD))
//     Devices->AMD:=.t.
//     Devices->NVIDIA:=.f.
//     nAMD++
//next

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

select 3
dbgotop()
do while eof() = .f.
  AADD(aMinersNames, alltrim(cDeviceUUID)+"_"+alltrim(OverClock->DEVID)+"_"+alltrim(OverClock->MINER)+"_"+alltrim(OverClock->ALGO))
dbskip()
end do

select 2
dbsetorder(1)
dbgotop()

if dbseek(cDeviceUUID)

 cDevID:=Devices->DEVID
 lAMD:=Devices->AMD
 lNVIDIA:=Devices->NVIDIA
 lENABLED:=Devices->ENABLED
//? alltrim(Devices->NAME), cDeviceName
// if alltrim(Devices->NAME) == cDeviceName
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
         cMiner:=left(cMiner_Algo, at("_", cMiner_Algo)-1)
         cAlgo:=right(cMiner_Algo, len(cMiner_Algo) - at("_", cMiner_Algo))
//?ASCAN(aMinersNames, cDeviceUUID+"_"+cMiner+"_"+cAlgo), aMinersNames, cDeviceUUID+"_"+cMiner+"_"+cAlgo
//?ASCAN(aMinersNames, cDeviceUUID+"_"+cMiner+"_"+cAlgo),cDeviceUUID+"_"+cMiner+"_"+cAlgo
//?aMinersNames, cDeviceUUID+"_"+alltrim(cDevID)+"_"+cMiner+"_"+cAlgo
          if ASCAN(aMinersNames, cDeviceUUID+"_"+alltrim(cDevID)+"_"+cMiner+"_"+cAlgo)=0
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
            AADD(aMinersNames, cDeviceUUID+"_"+alltrim(cDevID)+"_"+cMiner+"_"+cAlgo)
          end if
        end if
      next
     next
   end if
  next
// end if
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

