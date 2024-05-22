/*-****************************************************************************

 * Copyright (C) 2020-2021 Miguel Figueira - <miguel.figueira@caixamagica.pt>
 *
 * Licensed under the EUPL V.1.2

****************************************************************************-*/

/*++

Abstract:
	 RSA key storage provider using CNG

--*/

#ifndef __CMD_KSP_H__
#define __CMD_KSP_H__

#include <ncrypt_provider.h>
#include <bcrypt_provider.h>

// NTE_USER_CANCELLED is not defined in winerror.h in the version in use.
#ifndef NTE_USER_CANCELLED
#define NTE_USER_CANCELLED 0x80090036
#endif

#ifndef STATUS_INVALID_PARAMETER
#define STATUS_INVALID_PARAMETER ((NTSTATUS)0xC000000DL)
#endif

// provider handle
typedef __struct_bcount(sizeof(CMDKSP_PROVIDER)) struct _CMDKSP_PROVIDER {
	DWORD cbLength;					 // length of the whole data struct
	DWORD dwMagic;					 // type of the provider
	DWORD dwFlags;					 // reserved flags
	LPWSTR pszName;					 // name of the KSP
	BCRYPT_ALG_HANDLE hRsaAlgorithm; // bcrypt rsa algorithm handle
	LPWSTR pszContext;				 // context
} CMDKSP_PROVIDER;

// key handle
typedef __struct_bcount(sizeof(CMDKSP_KEY)) struct _CMDKSP_KEY {
	DWORD cbLength;			// length of the whole data blob
	DWORD dwMagic;			// type of the key
	LPWSTR pszKeyName;		// name of the key
	DWORD dwKeyBitLength;	// length of the key
	DWORD dwExportPolicy;	// export policy
	DWORD dwKeyUsagePolicy; // key usage policy
	BOOL fFinished;			// Whether the key is finalized
	LPWSTR pszMobileNumber; // mobile number used to register the certificate

	// handle to cryptography providers needed to perform operations with
	// the key.
	BCRYPT_ALG_HANDLE hProvider;

	// handle to the certificate associated with this private key.
	PCCERT_CONTEXT pCert;

	// context
	LPWSTR pszContext;

	// Calling process base name
	LPSTR pszProcessBaseName;

	// Window handle to set the parent of the dialogs created by KSP
	HWND hWnd;

} CMDKSP_KEY;

// this algorithm handle can be shared by all key handles
static BCRYPT_ALG_HANDLE g_hRSAProvider;

NTSTATUS
WINAPI
GetKeyStorageInterface(__in LPCWSTR pszProviderName, __out NCRYPT_KEY_STORAGE_FUNCTION_TABLE **ppFunctionTable,
					   __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPOpenProvider(__out NCRYPT_PROV_HANDLE *phProvider, __in LPCWSTR pszProviderName, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPFreeProvider(__in NCRYPT_PROV_HANDLE hProvider);

SECURITY_STATUS
WINAPI
KSPOpenKey(__inout NCRYPT_PROV_HANDLE hProvider, __out NCRYPT_KEY_HANDLE *phKey, __in LPCWSTR pszKeyName,
		   __in_opt DWORD dwLegacyKeySpec, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPCreatePersistedKey(__in NCRYPT_PROV_HANDLE hProvider, __out NCRYPT_KEY_HANDLE *phKey, __in LPCWSTR pszAlgId,
					  __in_opt LPCWSTR pszKeyName, __in DWORD dwLegacyKeySpec, __in DWORD dwFlags);

__success(return == 0) SECURITY_STATUS WINAPI
	KSPGetProviderProperty(__in NCRYPT_PROV_HANDLE hProvider, __in LPCWSTR pszProperty,
						   __out_bcount_part_opt(cbOutput, *pcbResult) PBYTE pbOutput, __in DWORD cbOutput,
						   __out DWORD *pcbResult, __in DWORD dwFlags);

__success(return == 0) SECURITY_STATUS WINAPI
	KSPGetKeyProperty(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in LPCWSTR pszProperty,
					  __out_bcount_part_opt(cbOutput, *pcbResult) PBYTE pbOutput, __in DWORD cbOutput,
					  __out DWORD *pcbResult, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPSetProviderProperty(__in NCRYPT_PROV_HANDLE hProvider, __in LPCWSTR pszProperty, __in_bcount(cbInput) PBYTE pbInput,
					   __in DWORD cbInput, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPSetKeyProperty(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in LPCWSTR pszProperty,
				  __in_bcount(cbInput) PBYTE pbInput, __in DWORD cbInput, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPFinalizeKey(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPDeleteKey(__in NCRYPT_PROV_HANDLE hProvider, __inout NCRYPT_KEY_HANDLE hKey, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPFreeKey(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey);

SECURITY_STATUS
WINAPI
KSPFreeBuffer(__deref PVOID pvInput);

__success(return == 0) SECURITY_STATUS WINAPI
	KSPEncrypt(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in_bcount(cbInput) PBYTE pbInput,
			   __in DWORD cbInput, __in VOID *pPaddingInfo, __out_bcount_part_opt(cbOutput, *pcbResult) PBYTE pbOutput,
			   __in DWORD cbOutput, __out DWORD *pcbResult, __in DWORD dwFlags);

__success(return == 0) SECURITY_STATUS WINAPI
	KSPDecrypt(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in_bcount(cbInput) PBYTE pbInput,
			   __in DWORD cbInput, __in VOID *pPaddingInfo, __out_bcount_part_opt(cbOutput, *pcbResult) PBYTE pbOutput,
			   __in DWORD cbOutput, __out DWORD *pcbResult, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPIsAlgSupported(__in NCRYPT_PROV_HANDLE hProvider, __in LPCWSTR pszAlgId, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPEnumAlgorithms(__in NCRYPT_PROV_HANDLE hProvider,
				  __in DWORD dwAlgOperations, // this is the crypto operations that are to be enumerated
				  __out DWORD *pdwAlgCount, __deref_out_ecount(*pdwAlgCount) NCryptAlgorithmName **ppAlgList,
				  __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPEnumKeys(__in NCRYPT_PROV_HANDLE hProvider, __in_opt LPCWSTR pszScope, __deref_out NCryptKeyName **ppKeyName,
			__inout PVOID *ppEnumState, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPImportKey(__in NCRYPT_PROV_HANDLE hProvider, __in_opt NCRYPT_KEY_HANDLE hImportKey, __in LPCWSTR pszBlobType,
			 __in_opt NCryptBufferDesc *pParameterList, __out NCRYPT_KEY_HANDLE *phKey,
			 __in_bcount(cbData) PBYTE pbData, __in DWORD cbData, __in DWORD dwFlags);

__success(return == 0) SECURITY_STATUS WINAPI
	KSPExportKey(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in_opt NCRYPT_KEY_HANDLE hExportKey,
				 __in LPCWSTR pszBlobType, __in_opt NCryptBufferDesc *pParameterList,
				 __out_bcount_part_opt(cbOutput, *pcbResult) PBYTE pbOutput, __in DWORD cbOutput,
				 __out DWORD *pcbResult, __in DWORD dwFlags);

__success(return == 0) SECURITY_STATUS WINAPI
	KSPSignHash(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in_opt VOID *pPaddingInfo,
				__in_bcount(cbHashValue) PBYTE pbHashValue, __in DWORD cbHashValue,
				__out_bcount_part_opt(cbSignature, *pcbResult) PBYTE pbSignature, __in DWORD cbSignature,
				__out DWORD *pcbResult, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPVerifySignature(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hKey, __in_opt VOID *pPaddingInfo,
				   __in_bcount(cbHashValue) PBYTE pbHashValue, __in DWORD cbHashValue,
				   __in_bcount(cbSignature) PBYTE pbSignature, __in DWORD cbSignature, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPPromptUser(__in NCRYPT_PROV_HANDLE hProvider, __in_opt NCRYPT_KEY_HANDLE hKey, __in LPCWSTR pszOperation,
			  __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPNotifyChangeKey(__in NCRYPT_PROV_HANDLE hProvider, __inout HANDLE *phEvent, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPSecretAgreement(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_KEY_HANDLE hPrivKey, __in NCRYPT_KEY_HANDLE hPubKey,
				   __out NCRYPT_SECRET_HANDLE *phAgreedSecret, __in DWORD dwFlags);

SECURITY_STATUS
WINAPI
KSPDeriveKey(__in NCRYPT_PROV_HANDLE hProvider, __in_opt NCRYPT_SECRET_HANDLE hSharedSecret, __in LPCWSTR pwszKDF,
			 __in_opt NCryptBufferDesc *pParameterList,
			 __out_bcount_part_opt(cbDerivedKey, *pcbResult) PUCHAR pbDerivedKey, __in DWORD cbDerivedKey,
			 __out DWORD *pcbResult, __in ULONG dwFlags);

SECURITY_STATUS
WINAPI
KSPFreeSecret(__in NCRYPT_PROV_HANDLE hProvider, __in NCRYPT_SECRET_HANDLE hSharedSecret);

SECURITY_STATUS
WINAPI
CreateNewKeyObject(__in_opt LPCWSTR pszKeyName, __deref_out CMDKSP_KEY **ppKey);

SECURITY_STATUS
WINAPI
DeleteKeyObject(__inout CMDKSP_KEY *pKey);

SECURITY_STATUS
NormalizeNteStatus(__in NTSTATUS NtStatus);

CMDKSP_PROVIDER *CmdKspValidateProvHandle(__in NCRYPT_PROV_HANDLE hProvider);

CMDKSP_KEY *CmdKspValidateKeyHandle(__in NCRYPT_KEY_HANDLE hKey);

void getDocName(__in HWND hParentWindow, __in LPSTR lpProcessName, __out LPSTR pszBuffer, __in DWORD cbBuffer,
				__in PBYTE pbHash, __in DWORD cbHash);

BOOL validateCert(__in PCCERT_CONTEXT pCert, bool showDialog);

#endif //__CMD_KSP_H__
