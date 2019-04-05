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
inkey(2)
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

  kLine=mlcount(cData1)
  nLine=val(strtran(OverClock->DEVID,"GPU#",""))+ 1 //������� ������ ���� �� �����
   cLine=amemoline(cData1, nLine)

    parseAMDline(cLine)

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

if nDevID <> val(alltrim(cGPU))
 msgStop("GPU#"+alltrim(str(nDevID)) + " " +alltrim(Overclock->NAME)+;
  " not found in responce from OverdriveNTool.exe"+CRLF+;
  "Try to change GPU number (�)" ,"Error!")
 return nil
end if

if alltrim(Overclock->NAME) <> alltrim(cGPUname)
 msgStop(alltrim(Overclock->NAME) + " missmatch with " +alltrim(cGPUname)+CRLF+;
  "Try to change GPU number (�)" ,"Error!")
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