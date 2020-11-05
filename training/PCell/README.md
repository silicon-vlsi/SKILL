# Overview

Parameterized cells (PCells) is powerful way of creating automation using SKILL.

You can create PCells by:
- SKILL programming
- Using [PCell Designer][PCD]
- PCell menu from GUI but this is obsolete

Main principles of PCell SKILL coding:
- Using the pcDefinePCell function
- Creating PCell constructor functions
- Creating CDF parameters and callbacks
- Encrypting PCell codes

Coding is necessity for CAD engineers but can also enable to circuit designers to do complex activities efficiently.
For example:
Instead of drawing shapes for an in-house custom device and risk re-doing the whole device if any shape dimensions need to be changed, the layout designer can simply code it as a PCell and easily change the device layout as the parameters are updated.
Circuit designers can code schematic PCells that can change pin configurations as needed.
Parasitic techfile developers can code parallel line test structures as PCells so that the width and spacing of the test structures can be easily modified.

The GPDK 45nm database (Introduction_to_SKILL_pcell_programming.tar.gz) in this document contains the scripts discussed in the subsequent slides.

As basic knowledge of SKILL programming is required to follow this quide.

# PCell Supermaster and Submaster

The following points illustrate the concept of a PCell supermaster and submaster:
<PCellCompiler.png>
When you compile a SKILL PCell code (that is, load a SKILL file with the call of pcDefinePCell in CIW), a master/superMaster cell is created for it. The compiler attaches the compiled code to the master cell. The master cell contains the SKILL code of the cell’s definition along with the cell’s parameters and their default values.

A **SuperMaster** is the cell which is created with default parameters in the `Lib -> Cell -> View` format after the code is compiled and loaded. It resides on the hard disk as a `layout.oa` file.

If one or more parameters are modified, a copy of the supermaster with the modified parameters is created in the virtual memory. This is termed as a **submaster**. One submaster is created for every unique parameter combination.
Submasters are created in memory and are available for use by all cellViews. When parameters on an instance are modified, Virtuoso first checks if there is an existing submaster that contains the same unique set of modified parameters. If such a submaster is available, it will be reused. Otherwise, a new submaster will be created.
<submaster.png>
Submaster cell 1 represents a unique parameter combination of `L=10u` and `W=20u`. Instances I1 and I2 point to the same submaster. Similarly, submaster cell 2 is another unique parameter combination of `L=20u` and `W=30u`. Instances I3, I4, and I5 point to the same submaster.

# Basic PCell

Regardless of the complexity, all SKILL PCell code starts with the `pcDefinePCell` command, as shown below. Each call to `pcDefinePCell` creates one PCell master/superMaster cellview. You can create one source code file for each PCell or define several PCells in one file.

## lab1.il
```skill
pcDefinePCell(
 list( ddGetObj("myLib") "myCell1" "layout")  ;; Lib/Cell/View superMaster
 list((w 0.2) (l 0.1))                        ;; Formal parameters of PCell
 let( (cv)
  cv=pcCellView
  dbCreateRect(cv list("Metal1" "drawing") list(0:0 w:l)) ;; Create Rectangle
 ) ;let
) ;pcDefinePCell
```
The above SKILL code defines a simple PCell with the following features:

    PCell will be created in myLib/myCell1/layout.
    It consists of only a single rectangle.
    The Properties form of the PCell contains two parameters, w and l, which can be used to modify the size of the rectangle.

list( ddGetObj("myLib") "myCell1" "layout")

=> This is a fixed syntax. Specify string inputs for library, cell, and view arguments. The ddGetObj command is only required for the library name. The "myLib" library should have already been pre-created in Library Manager.

list((w 0.2) (l 0.1))

=> This is the list of PCell formal parameters and their default values.

let( (cv)

=> The "let" command allows the declaration of local variables. As in all programming languages, usage of global variables should be minimized.

cv=pcCellView

=> pcCellView is an internal variable automatically created by pcDefinePCell. pcCellView contains the dbId (database identification) of the cell you are creating. Assigning pcCellView to "cv" is to simply shorten the name of the variable so that it can be used more conveniently.

dbCreateRect(cv list("Metal1" "drawing") list(0:0 w:l))

=> PCell parameters w and l are used in the dbCreateRect command so that the PCell layout can be modified according to the values defined in the Properties form. bBox (bounding box) of the rectangle will be defined by the coordinates 0:0 (lowerLeft) and w:l (upperRight).


The codes can be used as follows:

    Decompress the lab database Introduction_to_SKILL_pcell_programming.tar.gz and start Virtuoso:

Linux> tar zxvf Introduction_to_SKILL_pcell_programming.tar.gz
Linux> cd Introduction_to_SKILL_pcell_programming
Linux> virtuoso &

    Compile the PCell by loading the SKILL script in CIW:

load("./scripts/lab1.il")

The following messages appear in CIW and the PCell myCell1 layout is generated in the myLib library.
=>
Generating Pcell for 'myCell1 layout'.
Loading le.cxt
Loading drdEdit.cxt
Loading soi.cxt
...

The newly generated PCell can be tested as follows:

    Click on CIW: File > Open > Cellview, and open the cell named "lab1" in myLib library.
    Place an instance of myLib/myCell1/layout in it.
    Modify w and l in the Properties form and note the changes in the PCell layout. For example, change w from 0.2 to 0.3.

The next step is to create CDF information for the PCell.

Advantages of creating CDF include:

    Allows more variety in the input parameters (for example, instead of just a numeric field, radio fields and cyclic fields can also be used)
    Allows the specification of callbacks for each parameter
    Callback is a SKILL procedure which can do error checking, etc. when a parameter is modified
    Allows specification of default values for each parameter

Although the creation of CDF can be done using the Edit CDF form with CIW: Tools > CDF > Edit, this is usually done using SKILL commands in batch mode because of the large number of CDF parameters to be created.

A typical SKILL script for creating CDF is as shown below. It can be used as follows:

    Load the script in CIW:

load("./scripts/lab1_cdf.il")

lab1_cdf.il
let( ( lib cell libId cellId cdfId )
   lib="myLib"
   cell="myCell1"
   unless( cellId=ddGetObj(lib cell) error("Could not get cell %s." cell))
   when( cdfId=cdfGetBaseCellCDF(cellId) cdfDeleteCDF(cdfId))
   cdfId=cdfCreateBaseCellCDF(cellId)
   cdfCreateParam( cdfId
       ?name           "l"
       ?prompt         "l"
       ?defValue       0.1
       ?type           "float"
   ) ;cdfCreateParam
   cdfCreateParam( cdfId
       ?name           "w"
       ?prompt         "w"
       ?defValue       0.2
       ?type           "float"
   ) ;cdfCreateParam
    cdfSaveCDF( cdfId )
) ;let

    Go to CIW: Tools > CDF> Edit and display CDF information for myCell1. It should now have two parameters.
    This completes the creation of the basic PCell.
<CDFedit.jpg>

Adding Parameters to a PCell

Additional parameters can be easily added to the basic PCell by modifying the parameter line in the previous code. In the earlier SKILL code example (lab1.il), the rectangle uses a fixed layer (“Metal1” “drawing”).

In the following SKILL codes, the layer of the rectangle has been parameterized so that it can be modified in the Properties form.

lab2.il
pcDefinePCell(
   list( ddGetObj("myLib") "myCell2" "layout")
   list((w 0.2) (l 0.1) (layer "Metal1"))
   let( (cv)
      cv=pcCellView
      dbCreateRect(cv list(layer "drawing") list(0:0 w:l))
   ) ;let
) ;pcDefinePCell

The corresponding CDF creation script is:

lab2_cdf.il
let( ( lib cell libId cellId cdfId )
   lib="myLib"
   cell="myCell2"
   unless( cellId=ddGetObj(lib cell) error("Could not get cell %s." cell))
   when( cdfId=cdfGetBaseCellCDF(cellId) cdfDeleteCDF(cdfId))
   cdfId=cdfCreateBaseCellCDF(cellId)
   cdfCreateParam( cdfId
       ?name           "layer"
       ?prompt         "layer"
       ?defValue       "Metal1"
       ?type           "string"
   ) ;cdfCreateParam
   cdfCreateParam( cdfId
       ?name           "l"
       ?prompt         "l"
       ?defValue       0.1
       ?type           "float"
   ) ;cdfCreateParam
   cdfCreateParam( cdfId
       ?name           "w"
       ?prompt         "w"
       ?defValue       0.2
       ?type           "float"
   ) ;cdfCreateParam
    cdfSaveCDF( cdfId )
) ;let

The new PCell and CDF codes can be used as follows:

    Load the following scripts in CIW:

load("./scripts/lab2.il")
load("./scripts/lab2_cdf.il")

    Create or open the layout cell "lab2" and place an instance of myCell2 in it.
    Select the instance, open the Edit Instance Properties form, and note the addition of the "layer" parameter.

<editInstProp.jpg>

A simple improvement to the PCell is to enhance the CDF parameters so that they allow users to input the values easily.
<CDFmod.jpg>

For example, instead of using a simple string field, which is prone to typos from users, a cyclic field can be used for layer input. This can be done by modifying the CDF codes as shown below and reloading the lab2_cdf.il file in CIW.


Constructor Functions

Instead of putting all the required codes within the pcDefinePCell command, it is more common to use a SKILL procedure within pcDefinePCell to create the required shapes. This SKILL procedure is termed as a constructor/wrapper function because it "constructs" or “wraps” the body of the SKILL PCell. This is also referred to as PCell code encapsulation.

In the example below, the original code for the basic PCell has now been separated into two parts: pcDefinePCell together with a simple constructor function CCScreatePcell3.

<constructor.jpg>

Advantages of using constructor functions include:

    Modularizes the codes and makes debugging easier
    Allows debugging for the constructor function to be done independently from the PCell itself
    Avoids repeated compilation of the PCell which can take significant time for complex PCells in advanced-node PDKs (The developer can now simply reload the constructor function which is usually placed in a separate file.)

The file containing the constructor functions can be encrypted as a context file to protect the PCell codes.

The new codes with constructor function can be tested by executing the following commands in CIW:
load("./scripts/lab3_constructor.il")
load("./scripts/lab3_cdf.il")
load("./scripts/lab3.il")
Next, create or open the layout cell "lab3" and place an instance of myCell3 to test it.

The file containing the constructor functions should be loaded first so that they can be used in the subsequent PCell compilation. Otherwise, there will be a PCell evaluation error during compilation.

As the codes that create the PCell are now separated from the pcDefinePCell function and hence, are not compiled directly into the PCell layout, they need to be always loaded once before the PCell can be used.

In a typical PDK, this is done by loading the SKILL files containing the constructor functions as context files via the libInit.il file, which is placed within the directory of the technology library. When the tech library is accessed for the first time, the libInit.il file will be loaded automatically by Virtuoso.

Creation of context files can be done by entering the following commands in CIW:
setContext("test")
load("./scripts/lab3_constructor.il")
saveContext("./lab3_constructor.cxt")

The 64-bit context file will be generated in a "64bit" directory in the working directory. Loading of the context file can then be done in libInit.il or CIW using:

loadContext("./lab3_constructor.cxt")

Virtuoso will automatically append "64bit" to the path of the context file. For example, "/dir1/myfile.cxt" automatically becomes "/dir1/64bit/myfile.cxt".
Parameter Precedence

It is important to understand where you set the default values. Once the system finds a value for a parameter, it stops looking. For example, if you set a parameter value in the pcDefinePCell code (number 4 in the below image), and in the CDF of the PCell (number 2 in the below image), changing the parameter value in the PCell code does not show the same values in the Create/Edit Instance forms.

<parPrecedence.png>

.............
Using Constraint Values from Virtuoso Techfile

In addition to using CDF ID in the parameter section of pcDefinePCell, it is also possible to reference values from the Virtuoso techfile. This can be done using commands such as techGetSpacingRule as shown below. PCell parameter "spacingM1" uses the minSpacing value from the techfile.
lib="myLib"
cell="myCell4"
cv=dbOpenCellViewByType(lib cell "layout")
tf=techGetTechFile(cv)
cdf=cdfGetBaseCellCDF(ddGetObj(lib cell))
pcDefinePCell(
   list( ddGetObj(lib) cell "layout")
   list(
      (w "float" cdf->w->defValue)
      (l "float" cdf->l->defValue)
      (layer "string" cdf->layer->defValue)
      (spacingM1 "float" techGetSpacingRule(tf "minSpacing" "Metal1"))
   ) ;list
   let( (cv)
      cv=pcCellView
      CCScreatePcell4(cv w l layer)
   ) ;let
) ;pcDefinePCell
lib=nil
cell=nil
cdf=nil
tf=nil

You can use the cst* functions to access non-foundry constraints from the technology library.

............
Summary

The steps to create a PCell can be summarized as follows:

    Define the main structure using the pcDefinePCell function.
    Define one or more constructor functions to create the shapes and connectivity (for example, net, pins, etc.) of the PCell.
    Create CDF parameters and their callback functions.
    Load the files in CIW in the following order:

load("./constructor.il")
load("./callback.il")
load("./cdf.il")
load("./pcell.il")

    After debugging is completed and the PCell is fully functional, encrypt the constructor.il and callback.il files as context files:

setContext("test")
load("./constructor.il")
load("./callback.il")
saveContext("./pcell.cxt")

The pcell.cxt file will be generated in a "64bit" directory in the current working directory.

    Move the "64bit" directory into the directory of the technology library and load pcell.cxt in the libInit.il file of the PDK using:

lib=ddGetObj("yourTechLibName")
loadContext(strcat(lib~>readPath "/pcell.cxt"))

The context file (or constructor/callback SKILL files) can also be simply loaded in the .cdsinit file using:

loadContext("./pcell.cxt")

    Creation and setup of the PCell is now complete.
    
    
 * * *
 
 [PCD]:          https://www.cadence.com/content/dam/cadence-www/global/en_US/documents/services/cadence-vcad-pcell-ds.pdf
