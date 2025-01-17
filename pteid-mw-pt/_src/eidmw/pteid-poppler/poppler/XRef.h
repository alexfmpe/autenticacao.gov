
//========================================================================
//
// XRef.h
//
// Copyright 1996-2003 Glyph & Cog, LLC
//
//========================================================================

//========================================================================
//
// Modified under the Poppler project - http://poppler.freedesktop.org
//
// All changes made under the Poppler project to this file are licensed
// under GPL version 2 or later
//
// Copyright (C) 2005 Brad Hards <bradh@frogmouth.net>
// Copyright (C) 2006, 2008, 2010-2012 Albert Astals Cid <aacid@kde.org>
// Copyright (C) 2007-2008 Julien Rebetez <julienr@svn.gnome.org>
// Copyright (C) 2007 Carlos Garcia Campos <carlosgc@gnome.org>
// Copyright (C) 2010 Ilya Gorenbein <igorenbein@finjan.com>
// Copyright (C) 2010 Hib Eris <hib@hiberis.nl>
// Copyright (C) 2012 Thomas Freitag <Thomas.Freitag@kabelmail.de>
// Copyright (C) 2012 Fabio D'Urso <fabiodurso@hotmail.it>
//
// To see a description of the changes please see the Changelog file that
// came with your tarball or type make ChangeLog if you are building from git
//
//========================================================================

#ifndef XREF_H
#define XREF_H

#ifdef USE_GCC_PRAGMAS
#pragma interface
#endif

#include "goo/gtypes.h"
#include "Object.h"

#include <vector>

class Dict;
class Stream;
class Parser;
class PopplerCache;

//------------------------------------------------------------------------
// XRef
//------------------------------------------------------------------------

enum XRefEntryType {
  xrefEntryFree,
  xrefEntryUncompressed,
  xrefEntryCompressed,
  xrefEntryNone
};

struct XRefEntry {
  Guint offset;
  int gen;
  XRefEntryType type;
  bool updated;
  Object obj; //if this entry was updated, obj will contains the updated object
};

class XRef {
public:

  // Constructor, create an empty XRef, used for PDF writing
  XRef();
  // Constructor, create an empty XRef but with info dict, used for PDF writing
  XRef(Object *trailerDictA);
  // Constructor.  Read xref table from stream.
  XRef(BaseStream *strA, Guint pos, Guint mainXRefEntriesOffsetA = 0, GBool *wasReconstructed = NULL, GBool reconstruct = false);

  // Destructor.
  ~XRef();

  // Is xref table valid?
  GBool isOk() { return ok; }

  // Is the last XRef section a stream or a table?
  GBool isXRefStream() { return xRefStream; }

  // Get the error code (if isOk() returns false).
  int getErrorCode() { return errCode; }

  // Set the encryption parameters.
  void setEncryption(int permFlagsA, GBool ownerPasswordOkA,
		     Guchar *fileKeyA, int keyLengthA,
		     int encVersionA, int encRevisionA,
		     CryptAlgorithm encAlgorithmA);

  // Is the file encrypted?
  GBool isEncrypted() { return encrypted; }

  // Check various permissions.
  GBool okToPrint(GBool ignoreOwnerPW = gFalse);
  GBool okToPrintHighRes(GBool ignoreOwnerPW = gFalse);
  GBool okToChange(GBool ignoreOwnerPW = gFalse);
  GBool okToCopy(GBool ignoreOwnerPW = gFalse);
  GBool okToAddNotes(GBool ignoreOwnerPW = gFalse);
  GBool okToFillForm(GBool ignoreOwnerPW = gFalse);
  GBool okToAccessibility(GBool ignoreOwnerPW = gFalse);
  GBool okToAssemble(GBool ignoreOwnerPW = gFalse);
  int getPermFlags() { return permFlags; }

  // Get catalog object.
  Object *getCatalog(Object *obj) { return fetch(rootNum, rootGen, obj); }

  // Fetch an indirect reference.
  Object *fetch(int num, int gen, Object *obj, int recursion = 0);

  // Return the document's Info dictionary (if any).
  Object *getDocInfo(Object *obj);
  Object *getDocInfoNF(Object *obj);

  // Return the number of objects in the xref table.
  int getNumObjects() { return size; }

  // Return the catalog object reference.
  int getRootNum() { return rootNum; }
  int getRootGen() { return rootGen; }

  // Get end position for a stream in a damaged file.
  // Returns false if unknown or file is not damaged.
  GBool getStreamEnd(Guint streamStart, Guint *streamEnd);

  // Retuns the entry that belongs to the offset
  int getNumEntry(Guint offset);

  // Direct access.
  XRefEntry *getEntry(int i, GBool complainIfMissing = gTrue);
  Object *getTrailerDict() { return &trailerDict; }

  // Write access
  void setModifiedObject(Object* o, Ref r);
  Ref addIndirectObject (Object* o);
  void removeIndirectObject(Ref r);
  void removeEntry(XRefEntry * e);
  void add(int num, int gen,  Guint offs, GBool used);

  // Output XRef table to stream
  void writeTableToFile(OutStream* outStr, GBool writeAllEntries);
  // Output XRef stream contents to GooString and fill trailerDict fields accordingly
  void writeStreamToBuffer(GooString *stmBuf, Dict *xrefDict, XRef *xref);

  Guint getStartXRef() { return start; }


private:

  BaseStream *str;		// input stream
  Guint start;			// offset in file (to allow for garbage
				//   at beginning of file)
  XRefEntry *entries;		// xref entries
  int capacity;			// size of <entries> array
  int size;			// number of entries
  int rootNum, rootGen;		// catalog dict
  GBool ok;			// true if xref table is valid
  int errCode;			// error code (if <ok> is false)
  Object trailerDict;		// trailer dictionary
  Guint *streamEnds;		// 'endstream' positions - only used in
				//   damaged files
  int streamEndsLen;		// number of valid entries in streamEnds
  PopplerCache *objStrs;	// cached object streams
  GBool encrypted;		// true if file is encrypted
  int encRevision;		
  int encVersion;		// encryption algorithm
  CryptAlgorithm encAlgorithm;	// encryption algorithm
  int keyLength;		// length of key, in bytes
  int permFlags;		// permission bits
  Guchar fileKey[32];		// file decryption key
  GBool ownerPasswordOk;	// true if owner password is correct
  Guint prevXRefOffset;		// position of prev XRef section (= next to read)
  Guint mainXRefEntriesOffset;	// offset of entries in main XRef table
  GBool xRefStream;		// true if last XRef section is a stream

  void init();
  int reserve(int newSize);
  int resize(int newSize);
  Guint getStartXref();
  GBool readXRef(Guint *pos, std::vector<Guint> *followedXRefStm);
  GBool readXRefTable(Parser *parser, Guint *pos, std::vector<Guint> *followedXRefStm);
  GBool readXRefStreamSection(Stream *xrefStr, int *w, int first, int n);
  GBool readXRefStream(Stream *xrefStr, Guint *pos);
  GBool constructXRef(GBool *wasReconstructed);
  GBool parseEntry(Guint offset, XRefEntry *entry);

  class XRefWriter {
  public:
    virtual void startSection(int first, int count) = 0;
    virtual void writeEntry(Guint offset, int gen, XRefEntryType type) = 0;
    virtual ~XRefWriter() {};
  };

  class XRefTableWriter: public XRefWriter {
  public:
    XRefTableWriter(OutStream* outStrA);
    void startSection(int first, int count);
    void writeEntry(Guint offset, int gen, XRefEntryType type);
  private:
    OutStream* outStr;
  };

  class XRefStreamWriter: public XRefWriter {
  public:
    XRefStreamWriter(Object *index, GooString *stmBuf);
    void startSection(int first, int count);
    void writeEntry(Guint offset, int gen, XRefEntryType type);
  private:
    Object *index;
    GooString *stmBuf;
  };

  void writeXRef(XRefWriter *writer, GBool writeAllEntries);
};

#endif
