#include "resource.h"
#include "FiveWin.ch"
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


#define ID_DRIVER   "DbfCdx"

extern DbfCdx


static oWnd

//----------------------------------------------------------------------------//

function Main()
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

public AlgoLbx

REQUEST DESCEND
   RddSetDefault( "DbfCdx" )

REQUEST DESCEND

   SET _3DLOOK ON
aMinersNames:={} //for dublicates

init()



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

//close databases
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
nGet14:=Devices->NUM //AMD numbering
nGet8:=Overclock->P8
nGet9:=Overclock->P9
nGet10:=Overclock->P10
nGet11:=Overclock->P11
nGet12:=Overclock->P12
nGet13:=Overclock->P13


 DEFINE DIALOG oMainDlg RESOURCE "IDD_DIALOG1" TITLE "GPU-Tuning"
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
 REDEFINE GET oGet11 VAR nGET11 ID IDC_EDIT6 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T11:=nGET11, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet12 VAR nGET12 ID IDC_EDIT4 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T12:=nGET12, dbunlock(), AlgoLbx:Refresh(), .t.)
 REDEFINE GET oGet13 VAR nGET13 ID IDC_EDIT5 PICTURE "9999" UPDATE VALID (dbselectarea(3), dbrlock(), Overclock->T13:=nGET13, dbunlock(), AlgoLbx:Refresh(), .t.)

 REDEFINE GET oGet14 VAR nGET14 ID IDC_EDIT13 PICTURE "9" SPINNER MIN 0 MAX 9;
  UPDATE ON CHANGE (dbselectarea(2), dbrlock(), Devices->NUM0:=nGET14, dbunlock(), DevicesLbx:Refresh(), .t.)

select 2
 REDEFINE BROWSE DevicesLbx  ID 40000  OF oMainDlg VSCROLL FONT oFont
         ADD COLUMN TO BROWSE DevicesLbx ;
           DATA  " "+str(Devices->NUM0);
           HEADER " №" SIZE 24

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


 iif(Overclock->AMD .and. !Overclock->NVIDIA, (AMD_Enable(), NVIDIA_Disable()), )
 iif(!Overclock->AMD .and. Overclock->NVIDIA, (AMD_Disable(), NVIDIA_Enable()), )
 iif(!Overclock->AMD .and. !Overclock->NVIDIA, (AMD_Disable(), NVIDIA_Disable()), ) //cpu


DevicesLbx:bChange:={|| (AlgoLbx:UpStable(), ChangeAlgos(), nGet14:=Devices->NUM0, oGet14:Refresh(), AlgoLbx:UpStable() )};

AlgoLbx:nClrPane      = { || iif(Overclock->OENABLE0=.t.,CLR_HGREEN2,CLR_HGRAY2) }

AlgoLbx:bChange:={| nRow, nCol | ( nGet1:=Overclock->T1, oGet1:Refresh(),;
                     nGet2:=Overclock->T2, oGet2:Refresh(),;
                     nGet3:=Overclock->T3, oGet3:Refresh(),;
                     nGet4:=Overclock->T4, oGet4:Refresh(),;
                     nGet5:=Overclock->T5, oGet5:Refresh(),;
                     nGet6:=Overclock->T6, oGet6:Refresh(),;
                     nGet14:=Devices->NUM0, oGet14:Refresh(),;
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

 REDEFINE BUTTON ID 10 OF oMainDlg ACTION GetCurrentAMD()

 REDEFINE BUTTON ID 9 OF oMainDlg ACTION (SaveOverClockData(), oMainDlg:End())

 REDEFINE BUTTON ID IDOK ACTION (SaveOverClockData())
 REDEFINE BUTTON ID IDCANCEL ACTION (oMainDlg:End())

 ACTIVATE DIALOG oMainDlg CENTER



return nil

Function AMD_Disable()
 oGet1:Disable()
 oGet2:Disable()
 oGet3:Disable()
 oGet4:Disable()
 oGet5:Disable()
 oGet6:Disable()
return nil

Function AMD_Enable()
 oGet1:Enable()
 oGet2:Enable()
 oGet3:Enable()
 oGet4:Enable()
 oGet5:Enable()
 oGet6:Enable()
return nil

Function NVIDIA_Disable()
 oGet8:Disable()
 oGet9:Disable()
 oGet10:Disable()
 oGet11:Disable()
 oGet12:Disable()
 oGet13:Disable()
return nil

Function NVIDIA_Enable()
 oGet8:Enable()
 oGet9:Enable()
 oGet10:Enable()
 oGet11:Enable()
 oGet12:Enable()
 oGet13:Enable()
return nil


Function LoadOverClockData()
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
   dbselectarea(2)
   dbrlock()
   Devices->NUM0:=Devices->NUM
   dbunlock()
   dbselectarea(3)
  Overclock->T8:=Overclock->P8
  Overclock->T9:=Overclock->P9
  Overclock->T10:=Overclock->P10
  Overclock->T11:=Overclock->P11
  Overclock->T12:=Overclock->P12
  Overclock->T13:=Overclock->P13
  dbunlock()
 dbskip()
 end do
dbgotop()


return nil

Function SaveOverClockData()
select 3
oldRec:=recno()
dbgotop()

 do while eof() = .f.
   if  Overclock->OENABLE0 .and. Overclock->T1+Overclock->T2+Overclock->T3+Overclock->T4+Overclock->T5+Overclock->T6 = 0
    msgStop(alltrim(Overclock->NAME)+" - "+alltrim(Overclock->ALGO)+" all parameters set to zero"+CRLF;
    , "Warning!")
   end if
  dbrlock()
  Overclock->OENABLED:=Overclock->OENABLE0
  Overclock->OVISIBLE:=Overclock->OVISIBL0

  Overclock->P1:=Overclock->T1
  Overclock->P2:=Overclock->T2
  Overclock->P3:=Overclock->T3
  Overclock->P4:=Overclock->T4
  Overclock->P5:=Overclock->T5
  Overclock->P6:=Overclock->T6
   dbselectarea(2)
   dbrlock()
   Devices->NUM:=Devices->NUM0
   dbunlock()
   dbselectarea(3)


  Overclock->P8:=Overclock->T8
  Overclock->P9:=Overclock->T9
  Overclock->P10:=Overclock->T10
  Overclock->P11:=Overclock->T11
  Overclock->P12:=Overclock->T12
  Overclock->P13:=Overclock->T13
  dbunlock()
 dbskip()
 end do

 SaveIniFile()
 select 3
 dbgoto(oldRec)

 AlgoLbx:Update()
return nil
//************************************************
Function SaveIniFile()
local cOut:=""
select 33
dbgotop()
    if Overclock33->OVISIBLE
//     cOut:=cOut + "visible:TRUE"+CRLF
    else
//     cOut:=cOut + "visible:FALSE"+CRLF
    end if

 do while eof() = .f.

  if at("GPU#", Overclock33->DEVID) <> 0
   cDEVID:=alltrim(str(Devices->NUM))
   cMINER:=alltrim(Overclock33->MINER)
   cALGO:=alltrim(Overclock33->ALGO)
    if Overclock33->OENABLED
      if Overclock33->AMD
       cOut:=cOut +"AMD,"
      else
       cOut:=cOut +"NVIDIA,"
      end if
     cOut:=cOut + cDEVID+","+cMINER+","+cALGO+","

      if Overclock33->AMD
       cOut:=cOut+alltrim(str(Overclock33->P1))+",";
                 +alltrim(str(Overclock33->P2))+",";
                 +alltrim(str(Overclock33->P3))+",";
                 +alltrim(str(Overclock33->P4))+",";
                 +alltrim(str(Overclock33->P5))+",";
                 +alltrim(str(Overclock33->P6))+CRLF
      else
       cOut:=cOut+alltrim(str(Overclock33->P8))+",";
                 +alltrim(str(Overclock33->P9))+",";
                 +alltrim(str(Overclock33->P10))+",";
                 +alltrim(str(Overclock33->P11))+",";
                 +alltrim(str(Overclock33->P12))+",";
                 +alltrim(str(Overclock33->P13))+CRLF
      end if

    end if
  end if
 dbskip()
 end do

memowrit("overclock.cfg", cOut, .f.)
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
local DevIDCPU:=-1
local DevIDGPU:=-1
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

 for y=1 to len(aD) //кол-во устройств
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
   if at("PCI_",aJ[3]) !=0 //AMD
    if !dbseek(aJ[3])
     dbappend()
     Devices->NAME:=aJ[2]
     Devices->ENABLED:=aJ[1]
     Devices->UUID:=aJ[3]
     DevIDGPU++
     Devices->NUM:=DevIDGPU
     Devices->DEVID:="GPU#"+alltrim(str(DevIDGPU))
     Devices->AMD:=.t.
     Devices->NVIDIA:=.f.
    end if
   end if
   if at("GPU-",aJ[3]) !=0 //NVIDIA
    if !dbseek(aJ[3])
     dbappend()
     Devices->NAME:=aJ[2]
     Devices->ENABLED:=aJ[1]
     Devices->UUID:=aJ[3]
     DevIDGPU++
     Devices->NUM:=DevIDGPU
     Devices->DEVID:="GPU#"+alltrim(str(DevIDGPU))
     Devices->NVIDIA:=.t.
     Devices->AMD:=.t.
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
#include "openBases.prg"
#include "getCurrent.prg"
#include "init.prg"

