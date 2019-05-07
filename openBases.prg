Function OpenBases()

aFiles := Directory(basedir+"*.cdx" )
if Len( aFiles ) > 0
 for nA=1 to Len( aFiles )
  ferror:=ferase(basedir+alltrim(aFiles[ nA ][ 1 ]))
   if ferror <> 0
    exit
 end if
 next
end if

select 1
use Miners SHARED ALIAS "Miners"
// PASSWORD cPass4BD
 index on NAME to name1
set index to name1
dbsetorder(1)

select 2
use Devices SHARED  ALIAS "Devices"
// PASSWORD cPass4BD
 index on UUID to uuid2
 index on NAME to name2
 index on DEVID to devid2
set index to uuid2, name2, devid2
dbsetorder(1)

select 22
use Devices SHARED  ALIAS "Devices22"
// PASSWORD cPass4BD
 index on UUID to uuid22
 index on NAME to name22
 index on DEVID to devid22
set index to uuid22, name22, devid22
dbsetorder(1)


select 3
use Overclock SHARED ALIAS "Overclock"
// PASSWORD cPass4BD
 index on UUID to uuid3
 index on NAME to name3
 index on MINER to miner3
 index on ALGO to algo3
 index on NH_ID to id3
 index on alltrim(UUID)+alltrim(MINER)+alltrim(ALGO)+alltrim(str(NH_ID)) to id03
set index to uuid3, name3, miner3, algo3, id3, id03
dbsetorder(1)

select 33
use Overclock SHARED ALIAS "Overclock33"
// PASSWORD cPass4BD
 index on UUID to uuid33
 index on NAME to name33
 index on MINER to miner33
 index on ALGO to algo33
 index on NH_ID to id33
set index to uuid33, name33, miner33, algo33, id33
dbsetorder(1)
return nil


