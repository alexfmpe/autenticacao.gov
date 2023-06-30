/* ****************************************************************************

 * eID Middleware Project.
 * Copyright (C) 2008-2009 FedICT.
 * Copyright (C) 2019 Caixa Magica Software.
 * Copyright (C) 2011 Vasco Silva - <vasco.silva@caixamagica.pt>
 * Copyright (C) 2012 André Guerreiro - <aguerreiro1985@gmail.com>
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
#include "UnknownCard.h"

namespace eIDMW
{

bool CUnknownCard::IsUnknownCard(SCARDHANDLE hCard, CContext *poContext,
	CByteArray & oData)
{
	// This function shouldn't be called.
	return true;
}

CUnknownCard::CUnknownCard(SCARDHANDLE hCard, CContext *poContext,
	GenericPinpad *poPinpad, const CByteArray & oData) :
CCard(hCard, poContext, poPinpad)
{
}

CUnknownCard::~CUnknownCard(void)
{
}

CByteArray CUnknownCard::ReadUncachedFile(const std::string &csPath,
    unsigned long ulOffset, unsigned long ulMaxLen)
{
    throw CMWEXCEPTION(EIDMW_ERR_NOT_SUPPORTED);
}

void CUnknownCard::InitEncryptionKey()
{
    throw CMWEXCEPTION(EIDMW_ERR_NOT_SUPPORTED);
}

tCardType CUnknownCard::GetType()
{
    return CARD_UNKNOWN;
}

std::string CUnknownCard::GetSerialNr()
{
    return "";
}

std::string CUnknownCard::GetLabel()
{
    return "Unknown";
}

}
