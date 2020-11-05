;   Description   : This code will find an instance CDF parameter
;            for a given instance cellName and change to a new value
;
;   How to Run      : In CIW load the file SITchangeParam.il:
;            e.g. load("SITchangeParam.il")
;            SITchangeParam("testLib" "testCell" "schematic" "cap" "model" "CAP")
;            where testLib   - library name
;              testCell  - cell name
;              schematic - view name
;              cap        - instance cellName
;              model     - parameter name
;              CAP        - new value
;
; **NOTE** This change of parameter will not change the layout or netlist output
; until CDF callbacks are executed.
;
procedure( SITchangeParam( libname cellname viewname findInstCellName paramName newValue "tttttg")
  let( (cv)
   ; open cell view; dbOpenCellViewByType()
   ; for eac instances (cellview~>instances)
      ;if instance cellname matches given name (findInstCellName)
          ;for each CDF parameter; cdfGetInstCDF(instance)~>parameters
              ;if parameter~>name == paramName
                  ;param~>value = newValue
   ; save schematic 
   ; close schematic
   return(t)
  ) ;let
); end procedure SITchangeParam
