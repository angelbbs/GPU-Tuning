Function CreateBase_BaseVer(cArch,pathtofile)
DEFAULT pathtofile:=""
DEFAULT cArch:=""

if !file(pathtofile+"BaseVer"+cArch+".dbf")
 cr_db := {}
 AADD(cr_db, { "BASEVER", "N", 2, 0 })
 DBCREATE((pathtofile+"BaseVer"+cArch+".dbf"), cr_db)
end if

return NIL


Function CreateBase_Miners(cArch,pathtofile)
DEFAULT pathtofile:=""
DEFAULT cArch:=""
newFile:=.f.

//if !file(pathtofile+"Miners"+cArch+".dbf")
 cr_db := {}
 AADD(cr_db, { "NAME", "C", 40, 0 })
 AADD(cr_db, { "LOCATION", "C", 80, 0 })
 AADD(cr_db, { "V1", "N", 6, 2 })
 AADD(cr_db, { "V2", "N", 6, 2 })
 AADD(cr_db, { "V3", "N", 6, 2 })
 AADD(cr_db, { "V4", "N", 6, 2 })
// AADD(cr_db, { "CMD", "C", 150, 0 })
 DBCREATE((pathtofile+"Miners"+cArch+".dbf"), cr_db)
 newFile:=.t.
//end if

return newFile

Function CreateBase_Devices(cArch,pathtofile)
DEFAULT pathtofile:=""
DEFAULT cArch:=""
newFile:=.f.

//if !file(pathtofile+"Devices"+cArch+".dbf")
 cr_db := {}
 AADD(cr_db, { "NUM", "N", 2, 0 })
 AADD(cr_db, { "NUM0", "N", 2, 0 })
 AADD(cr_db, { "DEVID", "C", 10, 0 })
 AADD(cr_db, { "NAME", "C", 100, 0 })
 AADD(cr_db, { "AMD", "L", 1, 0 })
 AADD(cr_db, { "NVIDIA", "L", 1, 0 })
 AADD(cr_db, { "ENABLED", "L", 1, 0 })
// AADD(cr_db, { "VISIBLE0", "L", 1, 0 })
// AADD(cr_db, { "VISIBLE", "L", 1, 0 })
// AADD(cr_db, { "RESET0", "L", 1, 0 })
// AADD(cr_db, { "RESET", "L", 1, 0 })
 AADD(cr_db, { "UUID", "C", 100, 0 })
 DBCREATE((pathtofile+"Devices"+cArch+".dbf"), cr_db)
 newFile:=.t.
//end if

return newFile

Function CreateBase_Overclock(cArch,pathtofile)
DEFAULT pathtofile:=""
DEFAULT cArch:=""
newFile:=.f.

if !file(pathtofile+"Overclock"+cArch+".dbf")
 cr_db := {}
 AADD(cr_db, { "DEVID", "C", 10, 0 })
 AADD(cr_db, { "NAME", "C", 100, 0 })
 AADD(cr_db, { "MINER", "C", 40, 0 })
 AADD(cr_db, { "ALGO", "C", 40, 0 })
 AADD(cr_db, { "AMD", "L", 1, 0 })
 AADD(cr_db, { "NVIDIA", "L", 1, 0 })
 AADD(cr_db, { "ENABLED", "L", 1, 0 })
 AADD(cr_db, { "OENABLED", "L", 1, 0 })
 AADD(cr_db, { "OENABLE0", "L", 1, 0 })
 AADD(cr_db, { "OVISIBLE", "L", 1, 0 })
 AADD(cr_db, { "OVISIBL0", "L", 1, 0 })
 AADD(cr_db, { "NH_ID", "N", 3, 0 })
 AADD(cr_db, { "NH_SID", "N", 3, 0 })
 AADD(cr_db, { "UUID", "C", 100, 0 })
 AADD(cr_db, { "P1", "N", 4, 0 })
 AADD(cr_db, { "P2", "N", 4, 0 })
 AADD(cr_db, { "P3", "N", 4, 0 })
 AADD(cr_db, { "P4", "N", 4, 0 })
 AADD(cr_db, { "P5", "N", 4, 0 })
 AADD(cr_db, { "P6", "N", 4, 0 })
 AADD(cr_db, { "P17", "N", 4, 0 })
 AADD(cr_db, { "P18", "N", 4, 0 })
 AADD(cr_db, { "P19", "N", 4, 0 })
 AADD(cr_db, { "P7", "N", 4, 0 })
 AADD(cr_db, { "P8", "N", 4, 0 })
 AADD(cr_db, { "P9", "N", 4, 0 })
 AADD(cr_db, { "P10", "N", 4, 0 })
 AADD(cr_db, { "P11", "N", 4, 0 })
 AADD(cr_db, { "P12", "N", 4, 0 })
 AADD(cr_db, { "P13", "N", 4, 0 })
 AADD(cr_db, { "P14", "N", 4, 0 })
 AADD(cr_db, { "P15", "N", 4, 0 })
 AADD(cr_db, { "P16", "N", 4, 0 })
 AADD(cr_db, { "T1", "N", 4, 0 })
 AADD(cr_db, { "T2", "N", 4, 0 })
 AADD(cr_db, { "T3", "N", 4, 0 })
 AADD(cr_db, { "T4", "N", 4, 0 })
 AADD(cr_db, { "T5", "N", 4, 0 })
 AADD(cr_db, { "T6", "N", 4, 0 })
 AADD(cr_db, { "T17", "N", 4, 0 })
 AADD(cr_db, { "T18", "N", 4, 0 })
 AADD(cr_db, { "T19", "N", 4, 0 })
 AADD(cr_db, { "T7", "N", 4, 0 })
 AADD(cr_db, { "T8", "N", 4, 0 })
 AADD(cr_db, { "T9", "N", 4, 0 })
 AADD(cr_db, { "T10", "N", 4, 0 })
 AADD(cr_db, { "T11", "N", 4, 0 })
 AADD(cr_db, { "T12", "N", 4, 0 })
 AADD(cr_db, { "T13", "N", 4, 0 })
 AADD(cr_db, { "T14", "N", 4, 0 })
 AADD(cr_db, { "T15", "N", 4, 0 })
 AADD(cr_db, { "T16", "N", 4, 0 })

 DBCREATE((pathtofile+"Overclock"+cArch+".dbf"), cr_db)
 newFile:=.t.
end if

return newFile



