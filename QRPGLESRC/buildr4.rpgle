      * BUILDR4 -- Utility to build programs by searching for compile statements
      *            in the source code.
      *                                               SCK 11/05/2007
      *
      * To compile this utility:
      *
      *> CRTBNDRPG PGM(QGPL/BUILDR4) SRCFILE(&L/&F) DBGVIEW(&DV)
      *
      *> CRTCMD CMD(QGPL/BUILD) PGM(*LIBL/BUILDR4) -
      *>        MODE(*ALL) ALLOW(*ALL) -
      *>        TEXT(&X)
      *
      *       BUILDR4 allows the following values to be substituted into
      *            the command string:
      *
      *             &O      = Object library
      *             &ON     = Object name
      *             &F      = Source File
      *             &L      = Source Library
      *             &N      = Member name
      *             &DV     = Debug View (ILE)
      *             &OV     = Debug View (OPM)
      *             &EV     = *EVENTF or *NOEVENTF
      *             &R      = Replace *YES/*NO
      *             &X      = Source member text (single quotes added)
      *             &YY     = Current Year (YY)
      *             &YYYY   = Current Year (YYYY)
      *
      * The following variables are for Klement's Sausage's special
      * values.
      *             &FYY    = Klement's Sausage Fiscal Year (YY)
      *             &FYYYY  = Klement's Sausage Fiscal Year (YYYY)
      *             &PLDATE = Klement's most recent price list date
      *
      * To compile this utility:
      *
      *>    CRTBNDRPG PGM(QTEMP/&ON) SRCFILE(&L/&F) DBGVIEW(&DV)
      *
      *
      /if defined(*CRTBNDRPG)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
      /endif
     H BNDDIR('QC2LE') OPTION(*SRCSTMT:*NODEBUGIO)

     FSOURCE    IF   F  256        DISK    EXTFILE(SrcFile)
     F                                     EXTMBR(SrcMbr)
     F                                     INFDS(SrcAttr)
     F                                     USROPN
      /undefine KLEMENT_SAUSAGE
      /if defined(KLEMENT_SAUSAGE)
     FPLFILE    IF   E           K DISK    USROPN
     FPERCAL    IF   E           K DISK    USROPN
      /endif

     D BUILDR4         PR
     D   peObj                       20a   const
     D   peSrcFile                   20a   const
     D   peMbr                       10a   const
     D   peDbgView                    7a   const
     D   peReplace                    4a   const
     D   peAllowF9                    4a   const
     D   peOption                    10a   const
      ** This is equivalent to *ENTRY PLIST:
     D BUILDR4         PI
     D   peObj                       20a   const
     D   peSrcFile                   20a   const
     D   peMbr                       10a   const
     D   peDbgView                    7a   const
     D   peReplace                    4a   const
     D   peAllowF9                    4a   const
     D   peOption                    10a   const

     D QMHSNDPM        PR                  ExtPgm('QMHSNDPM')
     D   msgid                        7a   const
     D   msgf                        20a   const
     D   msgdta                   32702a   const options(*varsize)
     D   dtalen                      10i 0 const
     D   msgtype                     10a   const
     D   callstack                   10a   const
     D   stackcount                  10i 0 const
     D   msgkey                       4a
     D   errorcode                    8a   const

     D QMHRSNEM        PR                  ExtPgm('QMHRSNEM')
     D   MsgKey                       4A   const
     D   ErrorCode                    8A   const
     D   ToStack                     10a   const
     D   ToStackLen                  10i 0 const
     D   ToStackFmt                   8a   const
     D   FromStack                     *   const
     D   FromStackCtr                10i 0 const

     D RSNM0100        ds                  qualified
     D   Count                       10i 0 inz(1)
     D   modqual                     10a   inz('*NONE')
     D   pgmqual                     10a   inz('*NONE')
     D   len                         10i 0 inz(10)
     D   ident                       10a   inz('*PGMBDY')

     D QMHMOVPM        PR                  ExtPgm('QMHMOVPM')
     D   MsgKey                       4A   const
     D   MsgTypes                    40A   const
     D   NumMsgTypes                 10I 0 const
     D   ToStack                     10A   const
     D   ToStackCnt                  10I 0 const
     D   ErrorCode                    8A   const

     D loadcmds        pr            10i 0
     D   cmd                      32702a   varying dim(MAX_CMD)
     D dosubs          pr            10i 0
     D   cmd                      32702a   varying
     D runcmds         pr             1n
     D   cmd                      32702a   varying dim(MAX_CMD)
     D   count                       10i 0 const
     D getFiscYear     PR             4a
     D getCalYear      PR             4a
     D getPriceDate    PR             6a
     D getSrcMbr       PR             1n
     D   SrcFile                     21a   const
     D   SrcMbr                      10a   const
     D   Text                        52a   varying options(*omit)
     D   Type                        10a   options(*omit)
     D   RtnLib                      10a   options(*omit)
     D replace         PR
     D   cmd                      32702a   varying
     D   old                         10a   varying const
     D   new                         52a   varying const
     D defaultcmds     pr            10i 0
     D   cmd                      32702a   varying dim(MAX_CMD)
     D liblist         pr            10i 0
     D   Libl                        10a   dim(250)

     D SrcAttr         ds                  qualified
     D   RecLen                       5I 0 overlay(SrcAttr:125)
     D MAX_CMD         c                   const(100)

     D SrcLib          s             10a
     D SrcObj          s             10a
     D SrcFile         s             21a
     D SrcMbr          s             10a
     D objname         s             10a
     D objlib          s             10a

     D count           s             10i 0
     D cmd             s          32702a   varying dim(MAX_CMD)
     D x               s             10i 0
     D SrcText         s             52a   varying
     D msgkey          s              4a

      /free
          SrcLib  = %subst(peSrcFile:11:10);
          SrcObj  = %subst(peSrcFile:1:10);
          SrcFile = %trim(SrcLib) + '/' + %trim(SrcObj);
          objlib  = %subst(peObj:11:10);
          objname = %subst(peObj:1:10);

          if (peMbr = '*OBJ');
             SrcMbr = ObjName;
          else;
             SrcMbr = peMbr;
          endif;

          getSrcMbr( SrcFile: SrcMbr: SrcText: *OMIT: SrcLib);
          SrcFile = %trim(SrcLib) + '/' + %trim(SrcObj);

          count = loadcmds(cmd);
          if (count = 0);
             count = defaultcmds(cmd);
          endif;

          for x = 1 to count;
             dosubs(cmd(x));
          endfor;

          if runcmds(cmd:count);
              QMHSNDPM( 'CPF9897'
                      : 'QCPFMSG   *LIBL'
                      : 'Commands in source code executed successfully.'
                      : %len('Commands in source code executed successfully.')
                      : '*COMP'
                      : '*PGMBDY'
                      : 1
                      : msgkey
                      : *ALLx'00' );
          endif;

          return;
      /end-free


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Load all of the build commands from the source member
      * into an array of commands.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P loadcmds        B
     D loadcmds        pi            10i 0
     D   cmd                      32702a   varying dim(MAX_CMD)

     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   rcvvar                   32767A   options(*varsize)
     D   rcvvarlen                   10i 0 const
     D   format                       8a   const
     D   stack                       10a   const
     D   stackctr                    10i 0 const
     D   type                        10a   const
     D   msgkey                       4a   const
     D   wait                        10i 0 const
     D   action                      10a   const
     D   errorcode                    8a   const

     D RCVM0100        ds                  qualified
     D   msgid                        7a   overlay(RCVM0100:13)
     D   msgkey                       4a   overlay(RCVM0100:22)
     D   msgdtalen                   10i 0 overlay(RCVM0100:45)
     D   msgdta                    8000a   overlay(RCVM0100:49)

     D LINE            ds           256    qualified
     D   seq                          6a
     D   date                         6a
     D   data                       240a

     D id1             ds
     D                                1a   inz('*')
     D                                1a   inz('>')
     D id2             ds
     D                                1a   inz('<')
     D                                1a   inz('*')
     D pos             s             10i 0
     D sublen          s             10i 0
     D x               s             10i 0
     D temp            s            240a   varying

      /free

          open SOURCE;

          // Remove the "Buffer length longer than record"
          // message from the job log.

          QMHRCVPM( RCVM0100: %size(RCVM0100): 'RCVM0100'
                  : '*': 0: '*DIAG': *blanks
                  : 0: '*REMOVE': x'00000008');

          // Scan through source for any commands to
          // build program with.

          setll *start SOURCE;
          read SOURCE LINE;

          dow not %eof(SOURCE);

             // look for start identifier

             pos = %scan(id1:%subst(Line.data:1:SrcAttr.RecLen));
             if (pos>0);

                  // extract everything after start id

                  pos += %len(id1);
                  sublen = SrcAttr.reclen
                         - %size(LINE.Seq)
                         - %size(LINE.Date)
                         - pos
                         + 1;
                  temp = %trim(%subst(line.data:pos:sublen));

                  // if there's also an end id, strip if off.

                  pos =%scan(id2: temp);
                  if (pos>1);
                     temp = %trimr(%subst(temp:1:pos-1));
                  endif;

                  // either add to the array, or add to the end of
                  // the previous command.

                  if (x>0 and %subst(cmd(x):%len(cmd(x)):1) = '-');
                     %len(cmd(x)) = %len(cmd(x)) - 1;
                     cmd(x) += temp;
                  else;
                     x += 1;
                     cmd(x) = temp;
                  endif;
             endif;

             read SOURCE LINE;
          enddo;

          close SOURCE;
          return x;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * dosubs(): This makes any necessary substitutions in the
      *           command that's to be run.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P dosubs          B
     D dosubs          pi            10i 0
     D   cmd                      32702a   varying

     D cmdname         s             10a
     D temp            s                   like(cmd)
     D DbgView         s                   like(peDbgView)
     D OpmView         s                   like(peDbgView)
     D pos             s             10i 0
      /free

        temp =  %xlate( 'abcdefghijklmnopqrstuvwxyz'
                      : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                      : cmd );

        pos = %scan(' ':temp);
        if (pos > 1);
           cmdname = %subst(temp:1:pos-1);
        endif;

        //------------------------------------------------------------
        // The embedded SQL precompiler only supports DBGVIEW(*SOURCE)
        //  and DBGVIEW(*NONE) -- but it passes DBGVIEW(*ALL) to the
        //  underlying HLL compiler.
        //
        // This works around this by switching the debug view to
        // *SOURCE when using the SQL precompiler.
        //------------------------------------------------------------

        DbgView = peDbgView;
        if (%subst(cmdname:1:9) = 'CRTSQLRPG'
             or %subst(cmdname:1:9) = 'CRTSQLCBL'
             or %subst(cmdname:1:7) = 'CRTSQLC'
             or cmdname = 'CRTSQLPLI');
            if (DbgView='*STMT' or DbgView='*NONE');
                DbgView='*NONE';
            else;
                DbgView='*SOURCE';
            endif;
        endif;


        //------------------------------------------------------------
        // WDSC requires option(*EVENTF) in order to return info
        //  about why a compiler could not compile a program.
        //
        // If *EVENTF is specified, but no OPTION() was found in
        // the commands listed in the source member, tack on the
        // OPTION(*EVENTF) parameter.
        //------------------------------------------------------------

        if (peOption='*EVENTF');
            pos = %scan(' OPTION(': temp);
            if (pos = 0);
                if ( cmdname='CRTRPGMOD'
                     or cmdname='CRTRPGPGM'
                     or cmdname='CRTBNDRPG'
                     or cmdname='CRTSQLRPGI'
                     or cmdname='CRTCLMOD'
                     or cmdname='CRTCLPGM'
                     or cmdname='CRTBNDCL'
                     or cmdname='CRTCBLMOD'
                     or cmdname='CRTBNDCBL'
                     or cmdname='CRTCPPMOD'
                     or cmdname='CRTBNDCPP'
                     or cmdname='CRTCMOD'
                     or cmdname='CRTBNDC'
                     or cmdname='CRTPF'
                     or cmdname='CRTLF'
                     or cmdname='CRTDSPF'
                     or cmdname='CRTPRTF' );
                   cmd += ' OPTION(*EVENTF)';
                endif;
            endif;
        endif;

        //------------------------------------------------------------
        //  OPM programs use OPTION(*SRCDBG) or OPTION(*LSTDBG)
        //      instead of DBGVIEW.
        //------------------------------------------------------------
        select;
        when DbgView = '*LIST' or DbgView='*ALL';
          OpmView = '*LSTDBG';
        when DbgView = '*SOURCE';
          OpmView = '*SRCDBG';
        other;
          OpmView = '*NOSRCDBG';
        endsl;


        //------------------------------------------------------------
        //  Replace the various variables in the commands with the
        //  proper values from this program.
        //
        //  Note: Longer variables should be replaced first, to
        //        avoid conflict.  For example, '&YYYY' contains
        //        the string '&YY', so if &YY was done first, the
        //        &YYYY would become 07YY and would never get the
        //        4-digit year.  So the longer ones must be done
        //        first.
        //------------------------------------------------------------

        replace(cmd: '&PLDATE': getPriceDate()             );
        replace(cmd: '&FYYYY' : getFiscYear()              );
        replace(cmd: '&FYY'   : %subst(getFiscYear(): 3: 2));
        replace(cmd: '&YYYY'  : getCalYear()               );
        replace(cmd: '&YY'    : %subst(getCalYear(): 3: 2) );
        replace(cmd: '&ON'    : %trim(objname)             );
        replace(cmd: '&DV'    : %trim(dbgview)             );
        replace(cmd: '&OV'    : %trim(OpmView)             );
        replace(cmd: '&EV'    : %trim(peOption)            );
        replace(cmd: '&O'     : %trim(objlib)              );
        replace(cmd: '&X'     : SrcText                    );
        replace(cmd: '&R'     : %trim(peReplace)           );
        replace(cmd: '&F'     : %trim(srcobj)              );
        replace(cmd: '&L'     : %trim(srclib)              );
        replace(cmd: '&N'     : %trim(srcmbr)              );

        return 0;

        begsr *pssr;
            return -1;
        endsr;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Get current fiscal year from the period calendar file
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getFiscYear     B
     D getFiscYear     PI             4a

      /if defined(KLEMENT_SAUSAGE)
     D PERCAL1         ds                  likerec(PERCALF:*INPUT)
     D found           s              1n   inz(*OFF)
     D Year            s              4a   static
      /free
         if (Year<>*blanks);
             return Year;
         endif;

         monitor;
            open PERCAL;
         on-error;
            return '0000';
         endmon;

         setll (%dec(%date():*ISO)) PERCAL;
         read PERCAL PERCAL1;
         if not %eof;
            Year = %editc(PERCAL1.pnFYer:'X');
         endif;
         close PERCAL;

         return Year;
      /end-free
      /else
     C                   return    *Blanks
      /endif
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Get current year from the system clock
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getCalYear      B
     D getCalYear      PI             4a
     D year            s              4a   static
      /free
        if (year<>*blanks);
            return year;
        endif;
        evalr year = %editc(%subdt(%date(): *YEARS): 'X');
        return year;
      /end-free
     P                 E



      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Get current price list date from PLFILE
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getPriceDate    B
     D getPriceDate    PI             6a
      /if defined(KLEMENT_SAUSAGE)
     D date            s              6a
     D PLFILE1         ds                  likerec(PLFILEF:*INPUT)
      /free
         monitor;
           open PLFILE;
         on-error;
           return '000000';
         endmon;

         setll *start PLFILE;
         read PLFILE PLFILE1;
         if not %eof;
             date = %editc(PLFILE1.PLDATE:'X');
         endif;
         close PLFILE;

         return date;
      /end-free
      /else
     C                   return    *blanks
      /endif
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Get Infomration about the source member
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P getSrcMbr       B
     D getSrcMbr       PI             1n
     D   SrcFile                     21a   const
     D   SrcMbr                      10a   const
     D   Text                        52a   varying options(*omit)
     D   Type                        10a   options(*omit)
     D   RtnLib                      10a   options(*omit)

     D QUSRMBRD        PR                  EXTPGM('QUSRMBRD')
     D   RcvVar                   65535A   options(*varsize)
     D   RcvVarLen                   10i 0 const
     D   Format                       8a   const
     D   QualFile                    20a   const
     D   MbrName                     10a   const
     D   Override                     1a   const
     D   ErrorCode                    8a

     D MBRD0100        ds           135    qualified
     D   Lib                         10a   overlay(MBRD0100:19)
     D   Type                        10a   overlay(MBRD0100:49)
     D   Text                        50a   overlay(MBRD0100:85)

     D ErrCode         ds                  qualified
     D   Prov                        10i 0 inz(%size(ErrCode))
     D   Avail                       10i 0 inz(0)

     D pos             s             10i 0
     D lib             s             10a
     D obj             s             10a
     D Quote           s              1a   inz('''') static
     D Libl            s             10a   dim(250)
     D Found           s              1n   inz(*OFF)
      /free

         // Separate the library from the object name

         pos = %scan('/': srcFile);
         if (pos>1 and pos<%len(srcFile));
            lib = %subst(srcFile:1:pos-1);
            obj = %subst(srcFile:pos+1);
         else;
            lib = '*LIBL';
            obj = %triml(srcFile);
         endif;

         // If the library name is '*LIBL' retrieve the
         // library list.

         lib = %xlate('libl':'LIBL': lib);
         if (lib = '*LIBL');
             count = liblist(libl);
         else;
             count = 1;
             libl(1) = lib;
         endif;


         // Search each library in the library list until the
         // member is found.

         found = *OFF;

         for x = 1 to count;

            ErrCode.Avail = 0;
            QUSRMBRD( MBRD0100
                    : %size(MBRD0100)
                    : 'MBRD0100'
                    : obj + libl(x)
                    : SrcMbr
                    : '0'
                    : ErrCode );

            if (errCode.avail = 0);
                found = *ON;
                leave;
            endif;

         endfor;

         if (not found);

            monitor;
               ErrCode.Prov = 0;
               QUSRMBRD( MBRD0100
                       : %size(MBRD0100)
                       : 'MBRD0100'
                       : obj + '*LIBL'
                       : SrcMbr
                       : '0'
                       : ErrCode );
                found = *ON;
            on-error;
                MBRD0100 = *blanks;
                QMHMOVPM( *BLANKS
                        : '*COMP     *DIAG     *INFO'
                        : 3
                        : '*PGMBDY'
                        : 1
                        : x'00000000');
                QMHRSNEM( *BLANKS
                        : x'00000000'
                        : RSNM0100
                        : %size(RSNM0100)
                        : 'RSNM0100'
                        : *NULL
                        : 0);
                return *OFF;
            endmon;

         endif;

         if (%addr(text) <> *null);
             Text = Quote + %trimr(MBRD0100.Text) + Quote;
         endif;
         if (%addr(Type) <> *null);
             Type = MBRD0100.Type;
         endif;
         if (%addr(RtnLib) <> *null);
             RtnLib = MBRD0100.Lib;
         endif;

         return found;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Replace(): replace old string with new string in cmd
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P replace         B
     D replace         PI
     D   cmd                      32702a   varying
     D   old                         10a   varying const
     D   new                         52a   varying const
     D pos             s             10i 0
      /free
         pos = %scan(old:cmd);
         dow pos > 0;
             cmd = %replace(new: cmd: pos: %len(old));
             pos = %scan(old:cmd);
         enddo;
      /end-free
     P                 E


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * Run the commands in the build command array.
      *
      *   a) This starts by writing/receiving the command
      *      as a RQS message so it will appear in the job log,
      *      and can be retrieved with F9=Retrieve.
      *
      *   b) The QCAPCMD API is used to run the command.  Note
      *      that QCAPCMD does allow S/36 commands if you're in
      *      the S/36 environment.  It also makes it possible
      *      to prompt the command (if special chars used)
      *
      *   c) Any errors are reported to this program's caller
      *      using QMHMOVPM / QMHRSNEM
      *
      * Note: The entire array is processed in one call to
      *       this procedure to preserve call-level semantics.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P runcmds         B
     D runcmds         pi             1n
     D   cmd                      32702a   varying dim(MAX_CMD)
     D   count                       10i 0 const

     D QCAPCMD         PR                  ExtPgm('QCAPCMD')
     D   cmd                      32702a   const options(*varsize)
     D   cmdlen                      10i 0 const
     D   ctlblk                      20a   const
     D   ctlblklen                   10i 0 const
     D   ctlblkfmt                    8a   const
     D   updcmd                   32702a   options(*varsize)
     D   updcmdsize                  10i 0 const
     D   updcmdlen                   10i 0
     D   errorcode                    8a   const

     D CPOP0100        ds                  qualified
     D   type                        10i 0 inz(2)
     D   dbcs                         1a   inz('0')
     D   prompt                       1a   inz('2')
     D   syntax                       1a   inz('0')
     D   rtvkey                       4a   inz(x'00000000')
     D   ccsid                       10i 0 inz(0)
     D                                5a   inz(x'0000000000')

     D QCMDEXC         PR                  extpgm('QCMDEXC')
     D    cmd                     32702a   const
     D    len                        15p 5 const

     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   rcvvar                   32767A   options(*varsize)
     D   rcvvarlen                   10i 0 const
     D   format                       8a   const
     D   stack                       10a   const
     D   stackctr                    10i 0 const
     D   type                        10a   const
     D   msgkey                       4a   const
     D   wait                        10i 0 const
     D   action                      10a   const
     D   errorcode                    8a   const

     D RCVM0100        ds                  qualified
     D   msgid                        7a   overlay(RCVM0100:13)
     D   msgkey                       4a   overlay(RCVM0100:22)
     D   msgdtalen                   10i 0 overlay(RCVM0100:45)
     D   msgdta                    8000a   overlay(RCVM0100:49)

     D err             s              1n   inz(*OFF)
     D msgkey          s              4a
     D stack           s             10a
     D msgtype         s             10a
     D retriev         s              1n   inz(*OFF)
     D updcmd          s          32702a
     D updcmdlen       s             10i 0
     D ignore          s              1n   inz(*OFF)
     D opt             s              4a
      /free

        for x = 1 to count;

             updcmdlen = 0;

             if %len(cmd(x))<4 or cmd(x)=*blanks;
                iter;
             endif;

             opt = %xlate('ignsql':'IGNSQL': %subst(cmd(x):1:4) );

             ignore=*Off;
             if ( opt = 'IGN:' );
                ignore = *on;
                cmd(x) = %triml(%subst(cmd(x):5));
             endif;

             if %len(cmd(x))=0 or cmd(x)=*blanks;
                iter;
             endif;

             if (peAllowF9 = '*YES');
                 QMHSNDPM( *blanks
                         : *blanks
                         : cmd(x)
                         : %len(cmd(x))
                         : '*RQS'
                         : '*EXT'
                         : 0
                         : MsgKey
                         : *ALLX'00' );

                 QMHRCVPM( RCVM0100
                         : %size(RCVM0100)
                         : 'RCVM0100'
                         : '*'
                         : 0
                         : '*RQS'
                         : msgKey
                         : 0
                         : '*OLD'
                         : x'00000000' );
                 CPOP0100.RtvKey = msgKey;
             else;
                 QMHSNDPM( 'CPF9897'
                         : 'QCPFMSG   *LIBL'
                         : cmd(x)
                         : %len(cmd(x))
                         : '*DIAG'
                         : '*EXT'
                         : 0
                         : MsgKey
                         : *ALLX'00' );

             endif;

             monitor;
                 QCAPCMD( cmd(x)
                        : %len(cmd(x))
                        : CPOP0100
                        : %size(CPOP0100)
                        : 'CPOP0100'
                        : updcmd
                        : %size(updcmd)
                        : updcmdlen
                        : x'00000000' );
                 err = *OFF;
             on-error;
                 err = *ON;
             endmon;

             if (err=*OFF and updcmdlen > 0);
                 cmd(x) = %subst(updcmd:1:updcmdlen);
             endif;

             if (err=*ON and ignore=*OFF);
                QMHMOVPM( *BLANKS
                        : '*COMP     *DIAG     *INFO'
                        : 3
                        : '*PGMBDY'
                        : 1
                        : x'00000000');
                QMHRSNEM( *BLANKS
                        : x'00000000'
                        : RSNM0100
                        : %size(RSNM0100)
                        : 'RSNM0100'
                        : *NULL
                        : 0);
             endif;

             if (err and ignore=*OFF);
                 return *OFF;
             endif;

         endfor;

         return *ON;
      /end-free
     P                 e


      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * If there's no compile command in the source, we'll
      * try this one....
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P defaultcmds     B
     D defaultcmds     pi            10i 0
     D   cmd                      32702a   varying dim(MAX_CMD)
     D type            s             10a
      /free
         getSrcMbr(srcfile: srcmbr: *omit: type: *omit);
         select;
         when type='RPGLE';
             cmd(1) = 'CRTBNDRPG PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 DBGVIEW(&DV) +
                                 REPLACE(&R) +
                                 TEXT(&X) +
                                 OPTION(&EV)';
         when type='SQLRPGLE';
             cmd(1) = 'CRTSQLRPGI OBJ(&O/&ON) +
                                  SRCFILE(&L/&F) +
                                  SRCMBR(&N) +
                                  DBGVIEW(&DV) +
                                  REPLACE(&R) +
                                  TEXT(&X) +
                                  OPTION(&EV)';
         when type='CLLE';
             cmd(1) = 'CRTBNDCL  PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 DBGVIEW(&DV) +
                                 REPLACE(&R) +
                                 TEXT(&X) +
                                 OPTION(&EV)';
         when type='CBLLE';
             cmd(1) = 'CRTBNDCBL PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 DBGVIEW(&DV) +
                                 REPLACE(&R) +
                                 TEXT(&X) +
                                 OPTION(&EV)';
         when type='SQLCBLLE';
             cmd(1) = 'CRTSQLCBLI OBJ(&O/&ON) +
                                  SRCFILE(&L/&F) +
                                  SRCMBR(&N) +
                                  DBGVIEW(&DV) +
                                  REPLACE(&R) +
                                  TEXT(&X) +
                                  OPTION(&EV)';
         when type='C' or type='CLE';
             cmd(1) = 'CRTBNDC   PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 DBGVIEW(&DV) +
                                 REPLACE(&R) +
                                 TEXT(&X) +
                                 OPTION(&EV)';
         when type='RPG';
             cmd(1) = 'CRTRPGPGM PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 OPTION(&OV &EV) +
                                 REPLACE(&R) +
                                 TEXT(&X)';
         when type='SQLRPG';
             cmd(1) = 'CRTSQLRPG PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 OPTION(&OV) +
                                 REPLACE(&R) +
                                 TEXT(&X)';
         when type='CLP';
             cmd(1) = 'CRTCLPGM  PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 REPLACE(&R) +
                                 TEXT(&X) +
                                 OPTION(&OV &EV)';
         when type='CMD';
             cmd(1) = 'CRTCMD    CMD(&O/&ON) +
                                 PGM(*LIBL/&ONCL) +
                                 MODE(*ALL) ALLOW(*ALL) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 REPLACE(&R) +
                                 TEXT(&X)';
         when type='RPG36';
             cmd(1) = 'CRTS36RPG PGM(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 REPLACE(&R) +
                                 TEXT(&X)';
         when type='DSPF';
             cmd(1) = 'CRTDSPF   FILE(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 REPLACE(&R) +
                                 OPTION(&EV) +
                                 TEXT(&X)';
         when type='PRTF';
             cmd(1) = 'CRTPRTF   FILE(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 REPLACE(&R) +
                                 OPTION(&EV) +
                                 TEXT(&X)';
         when type='LF';
             cmd(1) = 'CRTLF     FILE(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 OPTION(&EV) +
                                 TEXT(&X)';
         when type='PF';
             cmd(1) = 'CRTPF     FILE(&O/&ON) +
                                 SRCFILE(&L/&F) +
                                 SRCMBR(&N) +
                                 OPTION(&EV) +
                                 TEXT(&X)';
         other;
             cmd(1) = 'RECRT PGM(&O/&ON) MODOPT(*FULL)';
         endsl;

         return 1;
      /end-free
     P                 E

      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  Load the current library list into an array.
      *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P liblist         B
     D liblist         pi            10i 0
     D   Libl                        10a   dim(250)

     D QUSRJOBI        PR                  ExtPgm('QUSRJOBI')
     D   RcvVar                   32767a   options(*varsize)
     D   RcvVarLen                   10i 0 const
     D   Format                       8a   const
     D   QualJob                     26a   const
     D   IntJobId                    16a   const

     D JOBI0700        DS                  qualified
     D   type                         1a   overlay(JOBI0700:61)
     D   subtype                      1a   overlay(JOBI0700:62)
     D   numsys                      10i 0 overlay(JOBI0700:65)
     D   numprd                      10i 0 overlay(JOBI0700:69)
     D   numcur                      10i 0 overlay(JOBI0700:73)
     D   numusr                      10i 0 overlay(JOBI0700:77)
     D   libl                        11a   overlay(JOBI0700:81) dim(250)

     D x               s             10i 0
     D Total           s             10i 0

      /free
           QUSRJOBI( JOBI0700: %size(JOBI0700): 'JOBI0700'
                   : '*': *blanks);

           total = JOBI0700.numsys
                 + JOBI0700.numprd
                 + JOBI0700.numcur
                 + JOBI0700.numusr;

           for x = 1 to Total;
               Libl(x) = JOBI0700.libl(X);
           endfor;

           return Total;
      /end-free
     P                 E
