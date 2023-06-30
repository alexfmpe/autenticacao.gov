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
/**
 * This class is for unknown cards.
 * It only provides some basic functionality such as SendAPDU().
 */

#include "Card.h"

namespace eIDMW
{

class CUnknownCard : public CCard
{
public:
	static bool IsUnknownCard(SCARDHANDLE hCard, CContext *poContext,
		CByteArray & oData);

	CUnknownCard(SCARDHANDLE hCard, CContext *poContext,
		GenericPinpad *poPinpad, const CByteArray & oData);
    ~CUnknownCard(void);

    virtual CByteArray ReadUncachedFile(const std::string & csPath,
        unsigned long ulOffset = 0, unsigned long ulMaxLen = FULL_FILE);

    virtual void InitEncryptionKey();

    tCardType GetType();

    std::string GetSerialNr();

	std::string GetLabel();
};

}
