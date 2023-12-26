# BUILD-Tool
This tool works like a "make" tool for IBM i native languages
This tool is based on Scott Klement build tool, that can be found here:
<a>href="https://www.scottklement.com/build/builddocs.html" target="_blank" rel="noreferrer"><img src="https://upload.wikimedia.org/wikipedia/commons/9/9d/IBM_i_logo_%282021%29.svg" width="40" height="40" alt="IBMi" /></a>

A General Purpose Build Tool
For years, I've found myself typing comments at the top of my code telling people how to compile it. Every source member I create, regardless of the language I do it in, always has comments telling the next programmer which steps need to be taken to compile my code. However, the popularity of development environments like WDSC and PDM make it cumbersome to type a slew of compile commands at a command line. Wouldn't it be nice if there were a tool that reads the compile commands from the source member and runs them automatically? That's what the BUILD tool presented in this article does.

Introducing the Build Tool
As technology has changed, my software tends to become more and more sophisticated, and at the same time, the steps required to compile the code becomes more and more complex. That's the reason I placed comments in my code to begin with. Here's an example of the comments I'll put at the top of my program:

      * To compile:
      *   OVRDBF FILE(CBOMASyy) TOFILE(CBOMAS08)
      *   DLTPGM PYUEMPLR4
      *   CRTBNDRPG PYUEMPLR4 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *   CHGOBJOWN OBJ(PYUEMPLR4) OBJTYPE(*PGM) NEWOWN(KLOWN)
      *   CHGPGM PGM(PYUEMPLR4) USRPRF(*OWNER)
      *   DLTOVR *ALL
In this example, the program uses a file whose name varies because it ends in the 2-digit representation of the current year. Since the filename varies, you need to override the file from CBOMASyy (which is what's on the F-spec for this RPG program) to CBOMAS08. Furthermore, this program needs to adopt authority from the KLOWN user profile, so each time it's compiled, it must have it's owner set appropriately. So the compile steps tell you to delete the old program, create a new one, change its owner, and tell it to use the owner's authority.

While these instructions are very useful, they make it hard to build the program from within a development tool like WDSC or PDM. When you're in a tool like that, you want to simply click the "compile" button in WDSC, or select an option next to the member in PDM. Who wants to try to copy several long compile strings into a command line when they can just click "compile" or choose option 14?

For RPG programs, I could often get all of the compile options I needed into the H-spec of the program. But, when a program requires some special options (such as the OVRDBF and CHGOBJOWN commands in the preceding example) the H-specs just couldn't do the job. Furthermore, the other languages I work in (C, CL, CMD, DDS, QMQRY, and so forth) don't have an H-spec, or a place to specify these options.

For all of these reasons, I came up with the BUILD tool. This tool is a *CMD object that calls an RPG program as its CPP. You tell the command the name of the source member you want to build, and it reads that member looking for compile commands. It executes each command that it finds, letting you have a nice little build script inside your source member.

                       Build an object from source (BUILD)                      
                                                                                
 Type choices, press Enter.                                                     
                                                                                
 Object Name  . . . . . . . . . .                 Name                          
   Library  . . . . . . . . . . .     *CURLIB     Name, *CURLIB                 
 Source File  . . . . . . . . . .   QRPGLESRC     Name                          
   Library  . . . . . . . . . . .     *LIBL       Name, *LIBL, *CURLIB          
 Source member  . . . . . . . . .   *OBJ          Name, *OBJ                    
 Debug View . . . . . . . . . . .   *LIST         *LIST, *SOURCE, *STMT, *NONE  
 Replace object . . . . . . . . .   *YES          *YES, *NO                     
 Allow F9=Retrieve on commands  .   *NO           *YES, *NO                     
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                         Bottom 
 F3=Exit   F4=Prompt   F5=Refresh   F10=Additional parameters   F12=Cancel      
 F13=How to use this display        F24=More keys
For the most part, all the utility needs in order to work properly is the name of the source file and source member that the program should be compiled from. It needs to know those things in order to read the compile commands from the source member.

The remaining options supplied to the command (shown above) aren't really necessary, but I started thinking that it's sometimes nice to specify extra options at the command-line rather than having to change them in the program code. For example, I might sometimes want to compile with a debug view, and sometimes not, so I added a debug view parameter. In a moment I'll show you how that parameter can be inserted into the build commands in the program.

The "Allow F9=Retrieve" option is useful when you're running the BUILD tool from a command line environment. If you specify *YES for this option, the F9 key will retrieve the commands that the BUILD tool ran from the source member. This is useful when you want to re-run one of the steps of the compile without re-running the entire procedure. It also can be annoying, particularly when all you want F9 to do is re-run the BUILD command itself, that's why I made this option default to *NO.

You'll note that the source file parameter defaults to QRPGLESRC -- this is really just a personal preference of mine. Since I spent the majority of my development time working in RPG, it saves me a lot of typing to have this option default to QRPGLESRC. However, this tool does work with just about any programming language (as long as you store your source in a source member, that is). You just have to specify a different SRCFILE when you run the command. Of course, if you download the BUILD tool from this article, you'll receive the source code, so you can easily change the default source file to something else if you prefer.

Coding a Build Script in Your Source
The build tool needs some way of knowing which comments in the program represent commands that should be run to build the code, and which comments are just ordinary comments. I wanted my build tool to be able to work with any programming language without having to actually understand the syntax of the language itself, and since every language has its own way of denoting a comment, I really had no way of picking out a comment from the rest of the code.

The solution I came up with was to look for the *> characters in the source code. Anywhere these two characters appear together would be assumed to be the start of a compile command.

With that in mind, I could make some minor changes to my source code to turn it into a build script. Using the same example as before, I added the *> symbols into my code as follows:

      * To compile:
      *>  OVRDBF FILE(CBOMASyy) TOFILE(CBOMAS08)
      *>  DLTPGM PYUEMPLR4
      *>  CRTBNDRPG PYUEMPLR4 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *>  CHGOBJOWN OBJ(PYUEMPLR4) OBJTYPE(*PGM) NEWOWN(KLOWN)
      *>  CHGPGM PGM(PYUEMPLR4) USRPRF(*OWNER)
      *>  DLTOVR *ALL
I think that looks rather nice. The comments are just as easy to read with these symbols added in as they were without them. However, I quickly discovered that they don't work as nicely for CL programs! Consider the following example:

     /* To compile:                                          +
      *>   CRTCLPGM PGM(MYPGM) SRCFILE(xxx/QCLSRC)           +
      */
While it looks nice, this example immediately causes a problem. The + at the end of the line is treated as part of the command to run, causing a syntax error. I decided that the easiest solution to this dilemna is to add an (optional) character sequence to denote the end of each compile command. Since I used *> at the start of the command, it seemed reasonable to use <* at the end of the command. Therefore, I could code my CL comment like this:

     /* To compile:                                          +
      *<   CRTCLPGM PGM(MYPGM) SRCFILE(xxx/QCLSRC)   >*      +
      */
I also discovered rather quickly that some compile commands don't fit nicely on one line, but need to be split over several lines of code. I decided that the easiest way to do that is to have a "continuation character", like the + symbol we use in CL programs to tell the compiler that the command continues on the next line. However, I can't use + in this instance since it, too, would wreak havoc in CL programs. I decided to use - instead. For example:

      * To compile:
      *>  CRTRPGMOD TESTMOD01 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *>  CRTPGM PGM(TESTPGM) MODULE(TESTMOD01 TESTMOD02) -
      *>         ACTGRP(KLEMENT) BNDDIR(MAIN QC2LE) -
      *>          BNDSRVPGM(QHTTPSVR/QZHBCGI)
I also quickly discovered that some of the commands I put my comments are commands that don't work for all situations. Remember the program that needed to adopt authority? My build script for that program included a DLTPGM command to get rid of the existing program because it won't let me re-create it if the owner of the original program doesn't match my user profile... so I delete it, then re-compile it, and finally reset the owner with the CHGOBJOWN command. The flaw in that logic is that my program would only build successfully if it already exists! If the program doesn't exist, the DLTPGM command will fail, and my script will never complete, since the BUILD tool stops as soon as it encounters any errors.

To solve this problem, I added the IGN: (ignore) prefix. When a command that's prefixed by IGN: fails the build tool will ignore the failure and proceed to run the rest of the build script. If I prefix my DLTPGM command with IGN: it solves the problem:

      * To compile:
      *>  OVRDBF FILE(CBOMASyy) TOFILE(CBOMAS08)
      *>  IGN: DLTPGM PYUEMPLR4
      *>  CRTBNDRPG PYUEMPLR4 SRCFILE(xxx/QRPGLESRC) DBGVIEW(*LIST)
      *>  CHGOBJOWN OBJ(PYUEMPLR4) OBJTYPE(*PGM) NEWOWN(KLOWN)
      *>  CHGPGM PGM(PYUEMPLR4) USRPRF(*OWNER)
      *>  DLTOVR *ALL
Replacement Variables
You may have noticed another flaw in my logic. My OVRDBF command will work as long as it's still 2008, but each year I'd have to update OVRDBF to override to a different year. I need some way to insert the current year into the command string!

But that's not all. You'll also notice that the preceding code specifies SRCFILE(xxx/QRPGLESRC). Obviously, the "xxx" isn't an actual library name, but is intended to be replaced by the library that contains my source code.

Clearly, I need some system to let me insert values into the commands -- values that can change based on different circumstances. My solution to this was to use option letters prefixed by the & character. I picked this solution because it's the same way that PDM and WDSC let you insert a value from the environment into a compile command.

In fact, I tried to use the same letter codes that PDM and WDSC use. Since I needed to add some codes that those tools didn't have, however, I came up with some of my own. Here's the list of replacement variables that the BUILD tool supports:

             &O      = Object library
             &ON     = Object name
             &F      = Source File
             &L      = Source Library
             &N      = Member name
             &DV     = Debug View (ILE)
             &OV     = Debug View (OPM)
             &EV     = *EVENTF or *NOEVENTF
             &R      = Replace *YES/*NO
             &X      = Source member text (single quotes added)
             &YY     = Current Year (YY)
             &YYYY   = Current Year (YYYY)
For the most part, the values for these replacement variables come from the parameters you specify when you invoke the BUILD command. For example, when you call BUILD and specify SRCFILE(SRCLIB/QRPGLESRC) the BUILD tool will replace any occurrence of &L in your compile commands with the string "SRCLIB", and any occurrence of &F with the string "QRPGLESRC".

The exceptions to this rule are the &X, &YY and &YYYY options. The values to those options are calculated on-the-fly by the BUILD program, rather than being passed directly from the command-line.

Here's the same build script with the replacement variables used instead of "08" or "xxx". This is the final version, the one I'm actually using in my shop:

      * To compile:
      *>  OVRDBF FILE(CBOMASyy) TOFILE(CBOMAS&YY)
      *>  ign: DLTPGM PYUEMPLR4
      *>  CRTBNDRPG PYUEMPLR4 SRCFILE(&L/QRPGLESRC) DBGVIEW(*LIST)
      *>  CHGOBJOWN OBJ(PYUEMPLR4) OBJTYPE(*PGM) NEWOWN(KLOWN)
      *>  CHGPGM PGM(PYUEMPLR4) USRPRF(*OWNER)
      *>  DLTOVR *ALL
The build script works very nicely with RPG and CL programs as I've demonstrated above, but it really can be used to build just about anything that's stored in a source physical file. The BUILD command knows very little about the commands it's executing, and virtually nothing about the source member it's coded in. Therefore, you can stick build commands in your RPG, CL, Cobol, C, C++, DDS, and SQL code and it works nicely in all of them. You just have to put *> at the start and <* at the end of each build command you want to run.

Indeed, here's the source code for the BUILD tool's *CMD object. You'll notice that the comments at the top contain everything you need to know to build it:

/*   *> CRTCMD CMD(&O/&ON) PGM(*LIBL/BUILDR4) -     <* +
 *   *>        MODE(*ALL) ALLOW(*ALL) -             <* +
 *   *>        TEXT(&X)                             <* +
 *                                                     */
  CMD PROMPT('Build an object from source')

  PARM KWD(OBJ) TYPE(FILE1) MIN(1) +
       PROMPT('Object Name')

  PARM KWD(SRCFILE) TYPE(FILE2) +
       PROMPT('Source File')

  PARM KWD(SRCMBR) TYPE(*NAME) DFT(*OBJ) SPCVAL((*OBJ)) +
       PROMPT('Source member') EXPR(*YES)

  PARM KWD(DBGVIEW) TYPE(*CHAR) LEN(7) RSTD(*YES) +
       DFT(*LIST) VALUES(*LIST *SOURCE *STMT *NONE) +
       PROMPT('Debug View') EXPR(*YES)

  PARM KWD(REPLACE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
       DFT(*YES) VALUES(*YES *NO) EXPR(*YES) +
       PROMPT('Replace object')

  PARM KWD(ALWF9) TYPE(*CHAR) LEN(4) RSTD(*YES) +
       DFT(*NO) VALUES(*YES *NO) EXPR(*YES) +
       PROMPT('Allow F9=Retrieve on commands')

  PARM KWD(OPTION) TYPE(*CHAR) LEN(10) RSTD(*YES) +
       VALUES(*NOEVENTF *EVENTF) EXPR(*YES) +
       PMTCTL(*PMTRQS) PROMPT('Compiler Options')


 FILE1: QUAL TYPE(*NAME) EXPR(*YES)
        QUAL TYPE(*NAME) DFT(*CURLIB) EXPR(*YES) +
             SPCVAL((*CURLIB)) +
             PROMPT('Library')

 FILE2: QUAL TYPE(*NAME) DFT(QRPGLESRC) EXPR(*YES)
        QUAL TYPE(*NAME) DFT(*LIBL) EXPR(*YES) +
             SPCVAL((*LIBL) (*CURLIB)) +
             PROMPT('Library')
Like the RPG and CL examples, the BUILD tool will scan this member for the lines containing *> and will execute the command. It doesn't matter that it's not a RPG or CL program because you are the one who writes the compile logic in the comments at the top. As long as your logic is correct, it'll build the source member appropriately.

As another example, here's a snippet from the top of a DDS source member for an externally-defined print file.

      * TO COMPILE:
      *>  CRTPRTF FILE(QGPL/&ON)   -
      *>          SRCFILE(&L/&F) -
      *>          DEVTYPE(*AFPDS)         -
      *>          REDUCE(*NONE)
     A                                      INDARA
     A          R BARCUTIL1F
     A                                      DUPLEX(*NO)
     A                                      PAGRTT(0)
     A                                      FONT(011)
     A                                  4  1DATE EDTCDE(Y)
     A                                  4 64'BARCUTILR4'
     A                                  6  1'Product Code'
     A            PRPROD         5S 0   6 17
     A            PRDESC        25A     6 23
     A                                 10  1'Item Level UPC-A Barcode:'
     A            PRUPCA        11S 0  10 36BARCODE(UPCA 6 *HRZ)
Hopefully you get the idea: this code will work for any type of object, so long as it's stored in a source physical file and you can code CL commands to do the work of compiling it.

Integrating with Development Tools
Perhaps the most useful place for my BUILD tool is in conjunction with WDSC. Indeed, WDSC was a big part of my motivation for writing it to begin with. Although WDSC does have tools for building whole projects that require a more complex build script, I've found it to be overkill for what I do. Plus, not all of the developers in my shop use WDSC, and I need a build method that'll work for everyone.

I've found that the BUILD tool meets these needs nicely. I can run the BUILD tool from WDSC and it'll build my code quite effortlessly. If I want to change the build procedure to test different things, I can do so quite easily since I inevitably have the source member open in LPEX, all I have to do is change the build commands in my source member and click compile and it uses the new build procedure. What could be easier than that?

To add the BUILD tool to the list of compile commands in WDSC, do the following:

Pull down the "Compile" menu.
Click "Compile" or "Compile (Prompt)" depending on whether you want the BUILD command to be prompted or not when it's run.
Choose "Work with compile commands".
Choose "New Command"
Set the "Label" field to "BUILD".
Set the "Command" field to the following:
BUILD OBJ(&O/&N) SRCFILE(&L/&F) SRCMBR(&N) REPLACE(&R) OPTION(*EVENTF) DBGVIEW(*SOURCE)
Click "Create" to create the new compile command.
Now you should have a "BUILD" option in your compile menu. You may want to repeat this process for the "Compile (Prompt)" menu if you haven't already.
WDSC assumes that you will always have different commands for each source member type. So you'll need to open a member of each different source type you want to use the BUILD command with and re-add the BUILD command to the compile menu.
When you click the compile button (without going through the compile menu) to compile a source member, it defaults to the last compile command you used for that source type. Therefore, once you've used BUILD for each source type, it'll become the default until you use something else. That way, you can simply click the little compile button in the toolbar, and you don't have to navigate the menus each time.
You can add the same functionality to PDM. To do that follow these steps:

Start PDM with the STRPDM command.
Take option 9 (Work with user-defined options.)
The default options file is called QAUOOPT (but it can be changed with the CHGPDMDFT command). Unless you've changed it, use QAUOOPT in library QGPL as the filename to work with and pess ENTER.
you should now be on the "Work with User-Defined Options" screen. Hit F6 to add a new option.
For the option letter, I suggest using "B" (for build), but you can put anything you like.
For the command, put the following:
BUILD OBJ(&O/&N) SRCFILE(&L/&F) SRCMBR(&N) REPLACE(&R) OPTION(*EVENTF) DBGVIEW(*SOURCE)
Press ENTER to save the changes.
From this point, you should be able to place the B option (or whichever option letters you used) next to any source members in PDM to run the BUILD tool on them. In other words, in the blank where you'd traditionally type 14 in order to compile a program, type B instead.
