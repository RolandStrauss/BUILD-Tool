
BIN_LIB=CMPSYS
LIBLIST=$(BIN_LIB) ROLAND1
SHELL=/QOpenSys/usr/bin/qsh

all: dynarray.bnd dynarray.srv.rpgle example01.pgm.rpgle

dynarray.rpgle: dynarray.bnd

%._h.rpgle:
	system -s "CHGATR OBJ('/home/ROLAND/builds/KnowledgeSharing/QRPGLESRC/$*._h.rpgle') ATR(*CCSID) VALUE(1252)"

%.pgm.rpgle:
	system -s "CHGATR OBJ('/home/ROLAND/builds/KnowledgeSharing/QRPGLESRC/$*.pgm.rpgle') ATR(*CCSID) VALUE(1252)"
	system "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('/home/ROLAND/builds/KnowledgeSharing/QRPGLESRC/$*.pgm.rpgle') DBGVIEW(*SOURCE) OPTION(*EVENTF)"
	system "CRTPGM PGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*) ACTGRP(*NEW)"

%.srv.rpgle:
	system -s "CHGATR OBJ('/home/ROLAND/builds/KnowledgeSharing/QRPGLESRC/$*.srv.rpgle') ATR(*CCSID) VALUE(1252)"
	system "CRTRPGMOD MODULE($(BIN_LIB)/$*) SRCSTMF('/home/ROLAND/builds/KnowledgeSharing/QRPGLESRC/$*.srv.rpgle') DBGVIEW(*SOURCE) OPTION(*EVENTF)"
	system "CRTSRVPGM SRVPGM($(BIN_LIB)/$*) MODULE($(BIN_LIB)/$*) EXPORT(*SRCFILE) SRCSTMF('/home/ROLAND/builds/KnowledgeSharing/qsrvsrc/$*.bnd')"
	system "DLTOBJ OBJ($(BIN_LIB)/$*) OBJTYPE(*MODULE)"

%.bnd:
	system -s "CHGATR OBJ('/home/ROLAND/builds/KnowledgeSharing/qsrvsrc/$*.bnd') ATR(*CCSID) VALUE(1252)"