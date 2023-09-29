/*-****************************************************************************

 * Copyright (C) 2011 Vasco Silva - <vasco.silva@caixamagica.pt>
 * Copyright (C) 2011, 2016, 2019 André Guerreiro - <aguerreiro1985@gmail.com>
 * Copyright (C) 2019 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

/* ****************************************************************************

* eID Middleware Project.
* Copyright (C) 2008-2009 FedICT.
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
/****************************************************************************************************/

#include "globmdrv.h"

#include "log.h"
#include "util.h"
#include "smartcard.h"
#include <stdio.h>
#include <Strsafe.h>
#include <direct.h>
#include <errno.h>

/****************************************************************************************************/


void bin2AsciiHex(const unsigned char * pData, char * out, unsigned long ulLen) 
{
	char a_cHexChars[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8',
		'9', 'A', 'B', 'C', 'D', 'E', 'F'};
	char *pszHex = out;
	unsigned long i;
	if(pData != NULL)
	{
		int j = 0;
		for(i = 0; i < ulLen; i++) 
		{
			pszHex[j++] = a_cHexChars[pData[i]>>4 & 0x0F];
			pszHex[j++] = a_cHexChars[pData[i] & 0x0F];
		}
		pszHex[j] = 0;
	}

}

BOOL runningUnderService()
{
	char baseName[512];
	GetModuleFileName(NULL,(LPTSTR)baseName, sizeof(baseName));

	return strstr(baseName, "svchost")!= NULL;

}


BYTE translateCertType(DWORD dwCertSpec)
{
	switch (dwCertSpec)
	{
	case CERT_AUTH:
		return card_type == IAS_V5_CARD ? 0x02 : 0x09;

	case CERT_NONREP:
		return card_type == IAS_V5_CARD ? 0x04 : 0x08;

	case CERT_CA:
		return card_type == IAS_V5_CARD ? 0x02 : 0x0F;
		
	case CERT_ROOTCA:
		return card_type == IAS_V5_CARD ? 0x0A : 0x10;
	}

	//It should never happen...
	return 0x00;
}

#define WHERE "PteidGetPubKey"
DWORD PteidGetPubKey(PCARD_DATA  pCardData, DWORD cbCertif, PBYTE pbCertif, DWORD *pcbPubKey, PBYTE *ppbPubKey)
{
	DWORD          dwReturn = 0;
	PCCERT_CONTEXT pCertContext = NULL; 
	DWORD          cbDecoded = 0;

#ifdef _DEBUG
	BLOBHEADER     BlobHeader;
	RSAPUBKEY      RsaPubKey;
#endif

	pCertContext = CertCreateCertificateContext(X509_ASN_ENCODING,   // The encoding type
		pbCertif,            // The encoded data from the certificate retrieved
		cbCertif);           // The length of the encoded data
	if ( pCertContext == NULL )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertCreateCertificateContext() returned [0x%02x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	/* Calculate the needed memory for decoding the public key info */
	if ( !CryptDecodeObject(X509_ASN_ENCODING,
		RSA_CSP_PUBLICKEYBLOB,
		(((*((*pCertContext).pCertInfo)).SubjectPublicKeyInfo).PublicKey).pbData,
		(((*((*pCertContext).pCertInfo)).SubjectPublicKeyInfo).PublicKey).cbData,
		0,
		NULL,
		pcbPubKey) )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CryptDecodeObjectEx() returned [0x%02x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	/* Allocate memory for the target buffer */
	*ppbPubKey = pCardData->pfnCspAlloc(*pcbPubKey);
	if ( *ppbPubKey == NULL )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "Error allocating memory for [*ppbPubKey]");
		CLEANUP(SCARD_E_NO_MEMORY);
	}

	if ( !CryptDecodeObject(X509_ASN_ENCODING,
		RSA_CSP_PUBLICKEYBLOB,
		(((*((*pCertContext).pCertInfo)).SubjectPublicKeyInfo).PublicKey).pbData,
		(((*((*pCertContext).pCertInfo)).SubjectPublicKeyInfo).PublicKey).cbData,
		0,
		*ppbPubKey,
		pcbPubKey) )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CryptDecodeObjectEx() returned [0x%02x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	/* The ALG_ID should be CALG_RSA_SIGN (0x00002400) */
	(*ppbPubKey)[5] = 0x24;

#ifdef _DEBUG
	/*
	* The data in memory is stored in little endian (the least significant byte (LSB) goes first), 
	* so the modulus and all other variables in the structure will follow that format.
	* http://msdn2.microsoft.com/en-us/library/aa387453(VS.85).aspx (BLOBHEADER)
	* http://msdn2.microsoft.com/en-us/library/aa387685(VS.85).aspx (RSAPUBKEY)
	*
	*/

	memcpy (&BlobHeader, *ppbPubKey, sizeof(BLOBHEADER));
	memcpy (&RsaPubKey, *ppbPubKey + sizeof(BLOBHEADER), sizeof(RSAPUBKEY));
#endif

cleanup:

	if ( pCertContext != NULL )
	{
		CertFreeCertificateContext(pCertContext);
		pCertContext = NULL;
	}

	return (dwReturn);
}
#undef WHERE

/****************************************************************************************************/

#define WHERE "PteidCreateMSRoots"
DWORD PteidCreateMSRoots(PCARD_DATA  pCardData, DWORD *pcbMSRoots, PBYTE *ppbMSRoots)
{
	DWORD          dwReturn = 0;

	DWORD          cbCertif;
	PBYTE          pbCertif;

	HCERTSTORE     hMemoryStore = NULL;         // A memory store handle
	PCCERT_CONTEXT pCertContext = NULL; 
	CERT_BLOB      blob;

	dwReturn = PteidReadCert(pCardData, CERT_CA, &cbCertif, &pbCertif);
	if ( dwReturn != SCARD_S_SUCCESS )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "PteidReadCert[CERT_CA] returned [%d]", dwReturn);
		CLEANUP(SCARD_E_UNEXPECTED);
	}

#ifdef _DEBUG
	LogDumpBin ("C:\\SmartCardMinidriverTest\\certca.crt", cbCertif, (char *)pbCertif);
#endif

	//-------------------------------------------------------------------
	//  Open a memory certificate store. After the store is open,
	//  certificates can be added to it.
	hMemoryStore = CertOpenStore(CERT_STORE_PROV_MEMORY,    // A memory store
		0,                         // Encoding type 
		// Not used with a memory store
		(HCRYPTPROV)NULL,          // Use the default provider
		0,                         // No flags
		NULL);                     // Not needed
	if ( hMemoryStore == NULL )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertOpenStore returned [0x%x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	pCertContext = CertCreateCertificateContext(X509_ASN_ENCODING,   // The encoding type
		pbCertif,            // The encoded data from the certificate retrieved
		cbCertif);           // The length of the encoded data
	if ( pCertContext == NULL )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertCreateCertificateContext() returned [0x%x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	//-------------------------------------------------------------------
	// Add the certificate from the My store to the new memory store.
	if( CertAddCertificateContextToStore(hMemoryStore,                // Store handle
		pCertContext,                // Pointer to a certificate
		CERT_STORE_ADD_REPLACE_EXISTING,
		NULL) == FALSE )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertAddCertificateContextToStore() returned [0x%x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	/* Clear Certificate Context */
	if ( pCertContext != NULL )
	{
		CertFreeCertificateContext(pCertContext);
		pCertContext = NULL;
	}
	if ( pbCertif != NULL )
	{
		pCardData->pfnCspFree(pbCertif);
	}

	dwReturn = PteidReadCert(pCardData, CERT_ROOTCA, &cbCertif, &pbCertif);
	if ( dwReturn != SCARD_S_SUCCESS )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "PteidReadCert[CERT_ROOTCA] returned [%d]", dwReturn);
		CLEANUP(SCARD_E_UNEXPECTED);
	}
#ifdef _DEBUG
	LogDumpBin ("C:\\SmartCardMinidriverTest\\certroot.crt", cbCertif, (char *)pbCertif);
#endif

	pCertContext = CertCreateCertificateContext(X509_ASN_ENCODING,   // The encoding type
		pbCertif,            // The encoded data from the certificate retrieved
		cbCertif);           // The length of the encoded data
	if ( pCertContext == NULL )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertCreateCertificateContext() returned [0x%x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}
	//-------------------------------------------------------------------
	// Add the certificate from the My store to the new memory store.
	if( CertAddCertificateContextToStore(hMemoryStore,                // Store handle
		pCertContext,                // Pointer to a certificate
		CERT_STORE_ADD_REPLACE_EXISTING,
		NULL) == FALSE )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertAddCertificateContextToStore() returned [0x%x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}

	/* Get Needed memory size */
	blob.cbData = 0;
	blob.pbData = NULL;
	if ( CertSaveStore(hMemoryStore,
		X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
		CERT_STORE_SAVE_AS_PKCS7,
		CERT_STORE_SAVE_TO_MEMORY,
		&blob,
		0) == FALSE )
	{
		LogTrace(LOGTYPE_ERROR, WHERE, "CertSaveStore() returned [0x%x]", GetLastError());
		CLEANUP(SCARD_E_UNEXPECTED);
	}
	*pcbMSRoots = blob.cbData;
	if (ppbMSRoots != NULL) 
	{
		*ppbMSRoots = pCardData->pfnCspAlloc(blob.cbData);
		if ( *ppbMSRoots == NULL )
		{
			LogTrace(LOGTYPE_ERROR, WHERE, "Error allocating memory for [*ppbMSRoots]");
			CLEANUP(SCARD_E_NO_MEMORY);
		}

		blob.pbData = *ppbMSRoots;
		if ( CertSaveStore(hMemoryStore,
			X509_ASN_ENCODING | PKCS_7_ASN_ENCODING,
			CERT_STORE_SAVE_AS_PKCS7,
			CERT_STORE_SAVE_TO_MEMORY,
			&blob,
			0) == FALSE )
		{
			LogTrace(LOGTYPE_ERROR, WHERE, "CertSaveStore() returned [0x%x]", GetLastError());
			CLEANUP(SCARD_E_UNEXPECTED);
		}
	}


cleanup:
	if ( pCertContext != NULL )
	{
		CertFreeCertificateContext(pCertContext);
		pCertContext = NULL;
	}
	if ( pbCertif != NULL )
	{
		pCardData->pfnCspFree(pbCertif);
	}
	if ( hMemoryStore != NULL )
	{
		CertCloseStore(hMemoryStore, CERT_CLOSE_STORE_FORCE_FLAG);
	}

	return (dwReturn);
}
#undef WHERE

/****************************************************************************************************/
/* ReadReg reads the registry for the specified key and value name. The key will try to read from 
 * HKEY_CURRENT_USER and if it fails it will try to read from HKEY_LOCAL_MACHINE.
 *
 * Parameters: 
 * LPCWSTR szSubKey : string with the name of the registry subkey to be opened.
 * LPCWSTR szValueName : string with the name of the registry value.
 * LPDWORD lpType : A pointer to a variable that receives a code indicating the type of data stored 
 *          in the specified value. Consult Win32 documentation.
 * LPBYTE pbOutput : Pointer to buffer where value read will be stored.
 * LPDWORD lpcbOutputSize : Pointer to variable wich stores the size in bytes of pbOutput buffer.
 *          After the call it store the number of bytes read.
 *
 * Return: TRUE if the value was read successfully, FALSE otherwise.
*/
#define WHERE "ReadReg"
BOOL ReadReg(LPCTSTR szSubKey, LPCTSTR szValueName, LPDWORD lpType, LPBYTE pbOutput, LPDWORD lpcbOutputSize)
{
#ifdef UNICODE
    LogTrace(LOGTYPE_INFO, WHERE, "Key=%S ValueName=%S", szSubKey, szValueName);
#else
    LogTrace(LOGTYPE_INFO, WHERE, "Key=%s ValueName=%s", szSubKey, szValueName);
#endif
    HKEY        hKey;
    DWORD       dwRet;
    REGSAM      flag = KEY_READ | KEY_WOW64_64KEY;
    BYTE        *pbValueCU = NULL;
    BYTE        *pbValueLM = NULL;;
    DWORD       dwData = 0;
    BOOL        bValueReadSuccess = FALSE;

    pbValueCU = (BYTE *)malloc(*lpcbOutputSize);
    dwRet = RegOpenKeyEx(HKEY_CURRENT_USER, szSubKey, 0, flag, &hKey);
    if (dwRet != ERROR_SUCCESS)
    {
        LogTrace(LOGTYPE_WARNING, WHERE, "RegOpenKeyEx for CU returned [0x%x]", dwRet);
        goto localmachine;
    }

    dwData = *lpcbOutputSize;
    dwRet = RegQueryValueEx(hKey,
        szValueName,
        NULL,
        NULL,
        (LPBYTE)pbValueCU,
        &dwData);

    if (dwRet == ERROR_SUCCESS && dwData != 0) {
        StringCchCopyA(pbOutput, *lpcbOutputSize, pbValueCU);
        bValueReadSuccess = TRUE;
        goto cleanup;
    }
    else
    {
        LogTrace(LOGTYPE_WARNING, WHERE, "RegQueryValueEx for CU returned [0x%x]", dwRet);
        RegCloseKey(hKey);
        goto localmachine;
    }


localmachine:
    pbValueLM = (BYTE *)malloc(*lpcbOutputSize);
    dwRet = RegOpenKeyEx(HKEY_LOCAL_MACHINE, szSubKey, 0, flag, &hKey);
    if (dwRet != ERROR_SUCCESS)
    {
        LogTrace(LOGTYPE_WARNING, WHERE, "RegOpenKeyEx for LM returned [0x%x]", dwRet);
        goto cleanup;
    }

    dwData = *lpcbOutputSize;
    dwRet = RegQueryValueEx(hKey,
        szValueName,
        NULL,
        NULL,
        (LPBYTE)pbValueLM,
        &dwData);

    if (dwRet == ERROR_SUCCESS && dwData != 0) {
        StringCchCopyA(pbOutput, *lpcbOutputSize, pbValueLM);
        bValueReadSuccess = TRUE;
    }
    else
    {
        LogTrace(LOGTYPE_WARNING, WHERE, "RegQueryValueEx for LM returned [0x%x]", dwRet);
    }
    RegCloseKey(hKey);
    goto cleanup;

cleanup:
    if (pbValueCU)
        free(pbValueCU);
    if (pbValueLM)
        free(pbValueLM);
    return bValueReadSuccess;
}
#undef WHERE