/* Description:    
	This program will auto-generate placed layouts for schematics in the Library

Instruction:
	Save this program as "autogen.il" in your working directory then key in the following in the CIW input panel :
	load("autogen.il")
Sample cmd:

SITautoGenCell("ABC" "cell") ;;;A placed "layout" view will be auto-generated for the schematic "cell" in the ABC library.

SITautoGenLib("ABC") ;;;A placed "layout" view will be auto-generated for all the schematics in the ABC library.

SITautoGenCell("ABC" "layout_placed")  ;;; Call this if you want view name something other than layout.  For example, layout_placed view will be auto-generated for each schematic cell in the ABC library

NOTE: The scripts deletes the existing layout views or specified destination views of the library and create a new layout or specified view name.

*/

procedure( SITautoGenCell(myLib myCell @optional (view "layout"))
   prog( ()
      ; open schemtic dbOpenCellViewByType()
      ; open the desired view ddGetObj()
      ; if ciew exists delete it ddDeleteObj()
      ; if schematic exists then
      ;      generate layout from source lxGenFromSource()
      ;	open layout; lay=dbOpenCellViewByType(myLib myCell view "maskLayout" "a")
      ;	save layout
      ;	close layout
      ;	close schematic
      ; endif 
      return(t)
   ) ;prog
) ;procedure

procedure( SITautoGenLib(myLib @optional (view "layout"))
   prog( ()
   	;get Library object ddGetObj()
	;loop thought each cell LibObj~>cells
	;SITautoGenCell()
	return(t) 
   )
) 
