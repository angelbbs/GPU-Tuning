Function checkAMD()
oldS:=select()
select 22
dbgotop()
do while eof()=.f.
 if devices22->AMD == .t.
  dbselectarea(oldS)
  return .t.
 end if
dbskip()
end do
dbselectarea(oldS)
return .f.

Function GetCurrentAMDNum()
   LOCAL hIn, hOut, hErr
   LOCAL cData, hProc, nLen
   cData := Space( 4096 )
   cErr := Space( 4096 )
cProgOut:=""
cSend:=""
 cProc:="utils\OverdriveNTool.exe -getcurrent"
   hProc := HB_OpenProcess( cProc , @hIn, @hOut, @hErr, .f.  )
CursorWait()
msgwait("Checking AMD GPUs...","", 2)
//inkey(2)
CursorArrow()

//1: Radeon RX 580 Series|GPU_P0=300;750|GPU_P1=600;769|GPU_P2=918;931|GPU_P3=1167;1162|GPU_P4=1239;1150|GPU_P5=1282;1150|GPU_P6=1326;1150|Mem_P0=300;750|Mem_P1=1000;800|Mem_P2=1950;950|Fan_Min=750|Fan_Max=3000|Fan_Target=70|Fan_Acoustic=918|Power_Temp=90|Power_Target=0
//2: Radeon RX 560 Series|GPU_P0=300;800|GPU_P1=719;1050|GPU_P2=819;1050|GPU_P3=919;1050|GPU_P4=1019;1050|GPU_P5=1119;1050|GPU_P6=1219;1050|GPU_P7=1319;1050|Mem_P0=300;800|Mem_P1=625;1050|Mem_P2=1950;850|Fan_Min=1155|Fan_Max=3000|Fan_Target=65|Fan_Acoustic=1045|Power_Temp=90|Power_Target=0
//3: Radeon RX 560 Series|GPU_P0=214;715|GPU_P1=603;721|GPU_P2=958;812|GPU_P3=1060;893|GPU_P4=1128;962|GPU_P5=1182;1031|GPU_P6=1230;1100|GPU_P7=1319;1100|Mem_P0=300;715|Mem_P1=625;800|Mem_P2=1950;850|Fan_Min=1155|Fan_Max=3000|Fan_Target=70|Fan_Acoustic=1045|Power_Temp=90|Power_Target=0
//4: Radeon RX 560 Series|GPU_P0=300;800|GPU_P1=719;1050|GPU_P2=819;1050|GPU_P3=919;1050|GPU_P4=1019;1050|GPU_P5=1119;1050|GPU_P6=1219;1050|GPU_P7=1319;1050|Mem_P0=300;800|Mem_P1=625;1050|Mem_P2=1950;850|Fan_Min=1155|Fan_Max=3000|Fan_Target=65|Fan_Acoustic=1045|Power_Temp=90|Power_Target=0

   nLen := Fread( hOut, @cData, 4096 )

cData1:=alltrim(cData)
if len(alltrim(cData1)) < 1
  return nil
// msgStop("Error reading from OverdriveNTool.exe", "Error!")
end if

nFirstAMDGPU:=val(left(cData1,1))
return nil

Function GetCurrentAMD()
   LOCAL hIn, hOut, hErr
   LOCAL cData, hProc, nLen
   cData := Space( 4096 )
   cErr := Space( 4096 )
cProgOut:=""
cSend:=""
 cProc:="utils\OverdriveNTool.exe -getcurrent"
   hProc := HB_OpenProcess( cProc , @hIn, @hOut, @hErr, .f.  )
CursorWait()
msgwait("Checking AMD GPUs...","", 2)
//inkey(2)
CursorArrow()

//1: Radeon RX 580 Series|GPU_P0=300;750|GPU_P1=600;769|GPU_P2=918;931|GPU_P3=1167;1162|GPU_P4=1239;1150|GPU_P5=1282;1150|GPU_P6=1326;1150|Mem_P0=300;750|Mem_P1=1000;800|Mem_P2=1950;950|Fan_Min=750|Fan_Max=3000|Fan_Target=70|Fan_Acoustic=918|Power_Temp=90|Power_Target=0
//2: Radeon RX 560 Series|GPU_P0=300;800|GPU_P1=719;1050|GPU_P2=819;1050|GPU_P3=919;1050|GPU_P4=1019;1050|GPU_P5=1119;1050|GPU_P6=1219;1050|GPU_P7=1319;1050|Mem_P0=300;800|Mem_P1=625;1050|Mem_P2=1950;850|Fan_Min=1155|Fan_Max=3000|Fan_Target=65|Fan_Acoustic=1045|Power_Temp=90|Power_Target=0
//3: Radeon RX 560 Series|GPU_P0=214;715|GPU_P1=603;721|GPU_P2=958;812|GPU_P3=1060;893|GPU_P4=1128;962|GPU_P5=1182;1031|GPU_P6=1230;1100|GPU_P7=1319;1100|Mem_P0=300;715|Mem_P1=625;800|Mem_P2=1950;850|Fan_Min=1155|Fan_Max=3000|Fan_Target=70|Fan_Acoustic=1045|Power_Temp=90|Power_Target=0
//4: Radeon RX 560 Series|GPU_P0=300;800|GPU_P1=719;1050|GPU_P2=819;1050|GPU_P3=919;1050|GPU_P4=1019;1050|GPU_P5=1119;1050|GPU_P6=1219;1050|GPU_P7=1319;1050|Mem_P0=300;800|Mem_P1=625;1050|Mem_P2=1950;850|Fan_Min=1155|Fan_Max=3000|Fan_Target=65|Fan_Acoustic=1045|Power_Temp=90|Power_Target=0

   nLen := Fread( hOut, @cData, 4096 )

cData1:=alltrim(cData)
if len(alltrim(cData1)) < 1
 msgStop("Error reading from OverdriveNTool.exe", "Error!")
end if

//aAmd:={}
  kLine_p=mlcount(cData1)
//  nLine=val(strtran(Devices->DEVID,"GPU#",""))+ 1 //нулевой строки быть не может
//   cLine=amemoline(cData1, nLine)
//?kLine_p
nDevID:=devices->NUM0
lParse:=.f.
nFirstAMDGPU:=val(left(cData1,1))
for nLp=1 to kLine_p
// AADD(aAmd, amemoline(cData1, nL))
//?nLp
 cLine=amemoline(cData1, nLp)
//?cLine
cGPU:=left(cLine,1) //9 GPU max
//?left(cLine, 1), strtran(Devices->DEVID,"GPU#","")
//?val(left(cLine, 1)), val(strtran(Devices->DEVID,"GPU#","")), nDevID, val(alltrim(cGPU))
//  if val(left(cLine, 1)) == val(strtran(Devices->DEVID,"GPU#","")) .and. nDevID == val(alltrim(cGPU))
  if val(left(cLine, 1)) == val(strtran(Devices->DEVID,"GPU#",""))-nFirstAMDGPU+1 //
//  if val(left(cLine, 1)) == nDevID
   parseAMDline(cLine)
   lParse:=.t.
  end if
next

//if nDevID <> val(alltrim(cGPU))
if !lParse
 msgStop("GPU#"+alltrim(str(nDevID)) + " " +alltrim(Overclock->NAME)+;
  " not found in responce from OverdriveNTool.exe"+CRLF+;
  "Try to change GPU number (№)" ,"Error!")
// return nil
end if


//    parseAMDline(cLine)

   FClose( hProc )
   FClose( hIn )
   FClose( hOut )
   FClose( hErr )
//**************************
return nil

Function parseAMDline(cLine)
local cGPU:=""
local cGPUname:=""
local cGPU_core:=""
local cGPU_volt:=""
local cMem_core:=""
local cMem_volt:=""
local cFanMin:=""
local cFanMax:=""
local cFanTarget:=""
local cFanAcoustic:=""
local cPowerTemp:=""
local cPowerTarget:=""

//?"Parse:", cLine
cGPU:=alltrim(strtran(alltrim(left(cLine,3)),":",""))

cOstLine:=right(cLine, len(cLine)-3)
cGPUname:=alltrim(left(cOstLine, at("|",cOstLine) - 1))
cOstLine2:=strtran(cOstLine, "|", CRLF)
  kLine=mlcount(cOstLine2)
  for nLine=1 to kLine
   cLine=alltrim(amemoline(cOstLine2, nLine))

     if left(cLine, 5) == "GPU_P"
        ost=right(cLine, len(cLine) - at("=", cLine))
        cGPU_core:=left(ost, at(";", ost) - 1)
        cGPU_volt:=right(ost, len(ost) - at(";", ost))
     end if
     if left(cLine, 5) == "Mem_P"
        ost=right(cLine, len(cLine) - at("=", cLine))
        cMem_core:=left(ost, at(";", ost) - 1)
        cMem_volt:=right(ost, len(ost) - at(";", ost))
     end if
     if left(cLine, 7) == "Fan_Min"
      cFanMin:=strtran(cLine,"Fan_Min=","")
     end if
     if left(cLine, 7) == "Fan_Max"
      cFanMax:=strtran(cLine,"Fan_Max=","")
     end if
     if left(cLine, 10) == "Fan_Target"
      cFanTarget:=strtran(cLine,"Fan_Target=","")
     end if
     if left(cLine, 12) == "Fan_Acoustic"
      cFanAcoustic:=strtran(cLine,"Fan_Acoustic=","")
     end if
     if left(cLine, 10) == "Power_Temp"
      cPowerTemp:=strtran(cLine,"Power_Temp=","")
     end if
     if left(cLine, 12) == "Power_Target"
      cPowerTarget:=strtran(cLine,"Power_Target=","")
     end if
  next

nDevID:=devices->NUM0


if alltrim(Overclock->NAME) <> alltrim(cGPUname)
 msgStop(alltrim(Overclock->NAME) + " missmatch with " +alltrim(cGPUname)+CRLF,"Error!")
 return nil
end if

select 3
dbrlock()

  nGet1:=val(cGPU_core)
   oGet1:VarPut(nGet1)
   oGet1:Refresh()

  nGet2:=val(cGPU_volt)
   oGet2:VarPut(nGet2)
   oGet2:Refresh()

  nGet3:=val(cMem_core)
   oGet3:VarPut(nGet3)
   oGet3:Refresh()

  nGet4:=val(cMem_volt)
   oGet4:VarPut(nGet4)
   oGet4:Refresh()

  nGet5:=val(cPowerTemp)
   oGet5:VarPut(nGet5)
   oGet5:Refresh()

  nGet6:=val(cPowerTarget)
   oGet6:VarPut(nGet6)
   oGet6:Refresh()
  AlgoLbx:Refresh()

  Overclock->T1:=val(cGPU_core)
  Overclock->T2:=val(cGPU_volt)
  Overclock->T3:=val(cMem_core)
  Overclock->T4:=val(cMem_volt)
  Overclock->T5:=val(cPowerTemp)
  Overclock->T6:=val(cPowerTarget)

dbunlock()

return nil

//*************************************************************************
Function GetCurrentNVIDIA()
   LOCAL hIn, hOut, hErr
   LOCAL cData, hProc, nLen
   cData := Space( 131072 )
   cErr := Space( 131072 )

cProgOut:=""
cSend:=""
ferase("nvidia-smi.log")

__CopyFile( "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe", "utils\nvidia-smi.exe" )
nErr=waitrun("utils\\nvidia-smi.exe --query -f nvidia-smi.log", 0)
msgwait("Checking NVIDIA GPUs...","", 1)
if nErr <> 0
  msgStop("Error code "+alltrim(str(nErr))+" nvidia-smi.exe", "Error!")
  return nil
end if

cData = memoread("nvidia-smi.log")

cData1:=alltrim(cData)
if len(alltrim(cData1)) < 1
 msgStop("Error reading from NVSMI", "Error!")
end if

nPL:=0
cUUID:=""
select 2

  kLine=mlcount(cData1)
for nLine=1 to kLine
   cLine=memoline(cData1,128, nLine)
   if at("GPU UUID", cLine) <> 0
      c1=at(":", cLine)
      cUUID:=right(cLine, len(cLine)-c1)
    end if
 if alltrim(devices->UUID) = alltrim(cUUID)

    if at("Default Power Limit", cLine) <> 0
      c1=at(":", cLine)
      cDefPL:=right(cLine, len(cLine)-c1)
    end if
    if at("Enforced Power Limit", cLine) <> 0
//?devices->UUID, UUID, devices->NAME
      c1=at(":", cLine)
      cEnfPL:=right(cLine, len(cLine)-c1)
//      ?cEnfPL
      if val(cEnfPL)<>0 .and. val(cDefPL)<>0
       nPL=val(cEnfPL)/val(cDefPL)*100
          nGet10:=nPL
          oGet10:VarPut(nGet10)
          oGet10:Refresh()

          nGet11:=-1
          oGet11:VarPut(nGet11)
          oGet11:Refresh()

          nGet12:=75
          oGet12:VarPut(nGet12)
          oGet12:Refresh()

          nGet13:=-1
          oGet13:VarPut(nGet13)
          oGet13:Refresh()

          AlgoLbx:Refresh()
          select 3
          dbrlock()
           Overclock->T10:=nPL
           Overclock->T12:=-1
           Overclock->T12:=75
           Overclock->T13:=-1
          dbunlock()
          select 2
      end if
    end if
 end if



next

//**************************
return nil
