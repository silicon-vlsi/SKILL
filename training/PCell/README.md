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

(/training/PCell/images/PCellCompiler.png)

When you compile a SKILL PCell code (that is, load a SKILL file with the call of pcDefinePCell in CIW), a master/superMaster cell is created for it. The compiler attaches the compiled code to the master cell. The master cell contains the SKILL code of the cell’s definition along with the cell’s parameters and their default values.

A **SuperMaster** is the cell which is created with default parameters in the `Lib -> Cell -> View` format after the code is compiled and loaded. It resides on the hard disk as a `layout.oa` file.

If one or more parameters are modified, a copy of the supermaster with the modified parameters is created in the virtual memory. This is termed as a **submaster**. One submaster is created for every unique parameter combination.
Submasters are created in memory and are available for use by all cellViews. When parameters on an instance are modified, Virtuoso first checks if there is an existing submaster that contains the same unique set of modified parameters. If such a submaster is available, it will be reused. Otherwise, a new submaster will be created.
<submaster.png>
Submaster cell 1 represents a unique parameter combination of `L=10u` and `W=20u`. Instances I1 and I2 point to the same submaster. Similarly,
