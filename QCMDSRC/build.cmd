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
