/* ****************************************************************************

 * eID Middleware Project.
 * Copyright (C) 2008-2009 FedICT.
 * Copyright (C) 2019 Caixa Magica Software.
 * Copyright (C) 2011 Vasco Silva - <vasco.silva@caixamagica.pt>
 * Copyright (C) 2012 lmcm - <lmcm@caixamagica.pt>
 * Copyright (C) 2012 Rui Martinho - <rui.martinho@ama.pt>
 * Copyright (C) 2016-2018 André Guerreiro - <aguerreiro1985@gmail.com>
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version
 * 3.0 as published by the Free Software Foundation.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, see
 * http://www.gnu.org/licenses/.

**************************************************************************** */
#pragma once

#ifndef CARDLAYERCONST_H
#define CARDLAYERCONST_H
namespace eIDMW
{
/**
 * The maximum number of readers; if more readers are present
 * only the first MAX_READERS that are found will used.
 */
const static unsigned long MAX_READERS = 8;


#define UNBLOCK_FLAG_NEW_PIN    1
#define UNBLOCK_FLAG_PUK_MERGE  2   // Only on pinpad readers

typedef enum
{
    DISCONNECT_LEAVE_CARD = 0,
    DISCONNECT_RESET_CARD = 1,
} tDisconnectMode;

typedef enum
{
    FILE_OP_READ,
    FILE_OP_WRITE,
} tFileOperation;

typedef enum
{
    PIN_OP_VERIFY,
    PIN_OP_CHANGE,
    PIN_OP_RESET,
    PIN_OP_RESET_NO_PUK
} tPinOperation;

const unsigned long SIGN_ALGO_RSA_RAW = 0x01;
const unsigned long SIGN_ALGO_RSA_PKCS = 0x02;
const unsigned long SIGN_ALGO_MD5_RSA_PKCS = 0x04;
const unsigned long SIGN_ALGO_SHA1_RSA_PKCS = 0x08;
const unsigned long SIGN_ALGO_SHA256_RSA_PKCS = 0x10;
const unsigned long SIGN_ALGO_SHA384_RSA_PKCS = 0x20;
const unsigned long SIGN_ALGO_SHA512_RSA_PKCS = 0x40;
const unsigned long SIGN_ALGO_RIPEMD160_RSA_PKCS = 0x80;
const unsigned long SIGN_ALGO_RSA_PSS = 0x100;

const unsigned int SHA1_LEN = 20;
const unsigned int SHA256_LEN = 32;
const unsigned int SHA384_LEN = 48;
const unsigned int SHA512_LEN = 64;


typedef enum
{
    PIN_ENC_ASCII,
    PIN_ENC_BCD,
    PIN_ENC_GP,     // Global platorm encoding e.g. "12345" -> {0x25, 0x12, 0x34, 0x5F, 0xFF, ... 0xFF}
} tPinEncoding;

typedef enum
{
	CARD_PTEID_IAS07, // v3 v4
	CARD_PTEID_IAS101, // legacy
    CARD_PTEID_IAS5, // v5 (CC 2.0)
    CARD_UNKNOWN,
} tCardType;

typedef enum
{
	CARD_INSERTED,
	CARD_NOT_PRESENT,
	CARD_STILL_PRESENT,
	CARD_REMOVED,
	CARD_OTHER,
} tCardStatus;

const unsigned int PERSODATAFILESIZE = 1000;

const unsigned long TIMEOUT_INFINITE = 0xFFFFFFFF; // used in CCardLayer::GetStatusChange()

const unsigned long ALL_READERS = 0xFFFFFFFF; // used in CCardLayer::GetStatusChange()

const unsigned long FULL_FILE = 0xFFFFFFFF; // used in CReader::ReadFile()

const unsigned long PIN_STATUS_UNKNOWN = 0xFFFFFFFE; // used in CReader::PinStatus()


/* used in CReader::Ctrl() */

const long CTRL_PTEID = 1000;

/** Returns the signed card data (28 + 128 bytes). No input data is needed.
 *  Not for V1 cards! */
const long CTRL_PTEID_GETSIGNEDCARDDATA = CTRL_PTEID + 1;

/** Returns the signed PIN status (1 + 128 bytes).
 * Not for V1 cards!
 * The input data should consist of 1 byte: the pin reference. */
const long CTRL_PTEID_GETSIGNEDPINSTATUS = CTRL_PTEID + 2;

/** Does an Internal Authenticate command, the signed challenge (128 bytes) is returned.
 *  The input data should be 21 bytes:
 *    - the key reference (1 byte)
 *    - the challenge to be signed (20 bytes) */
const long CTRL_PTEID_INTERNAL_AUTH = CTRL_PTEID + 3;
}

#endif
