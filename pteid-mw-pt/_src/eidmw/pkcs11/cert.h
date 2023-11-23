/* ****************************************************************************

 * eID Middleware Project.
 * Copyright (C) 2008-2009 FedICT.
 * Copyright (C) 2019 Caixa Magica Software.
 * Copyright (C) 2011 Vasco Silva - <vasco.silva@caixamagica.pt>
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
#ifndef __CERT_H__
#define __CERT_H__

#ifndef WIN32
#define strnicmp strncasecmp
#endif

/* constants */
#define LEN_DATE  14
#define MAX_OID_SIZE  32
#define MAX_OID_STR_SIZE 1024
#define MAX_DATE_STR_SIZE 1024

/* errors */
#define E_X509_BUF_TOO_SMALL         -1
#define E_X509_TIME_WRONG_FORMAT     -2
#define E_X509_DECODE                -3
#define E_X509_ALLOC                 -4
#define E_X509_UNKNOWN_KEYTYPE       -5
#define E_X509_DN_BAD_ENC            -6
#define E_X509_INCOMPLETE            -7

#ifdef __cplusplus
extern "C" {
#endif

#define X509_VERSION          "\1\1\1\1"
#define X509_SERIAL           "\1\1\2"
#define X509_SIGN_ALGO	      "\1\1\3"
#define X509_ISSUER           "\1\1\4"
#define X509_VALID_FROM       "\1\1\5\1"
#define X509_VALID_UNTIL      "\1\1\5\2"
#define X509_SUBJECT          "\1\1\6"
#define X509_KEYTYPE          "\1\1\7\1\1"
#define X509_PUBLIC_KEY       "\1\1\7\2"
#define X509_PKINFO           "\1\1\7\2\1"
#define X509_RSA_MOD          "\1\1\7\2\1\1"
#define X509_RSA_EXP          "\1\1\7\2\1\2"

#define X509_SIGNATURE_OID    "\1\2\1"
#define X509_SIGNATURE        "\1\3"

typedef struct
  {
    unsigned char *subject;
    unsigned int l_subject;

    unsigned char *issuer;
    unsigned int l_issuer;

    unsigned char *mod;
    unsigned int l_mod;

    unsigned char *exp;
    unsigned int l_exp;

    unsigned char *serial;
    unsigned int l_serial;
  } T_OLD_CERT_INFO;

typedef struct
  {
    unsigned char *subject;
    unsigned int l_subject;

    unsigned char *issuer;
    unsigned int l_issuer;

    unsigned char *serial;
    unsigned int l_serial;
  } T_CERT_INFO;

typedef struct
  {
    unsigned char *mod;
    unsigned int l_mod;

    unsigned char *exp;
    unsigned int l_exp;

    unsigned char *pkinfo;
    unsigned int l_pkinfo;
  } T_RSA_KEY_INFO;

int cert_get_info(const unsigned char *pcert, unsigned int lcert, T_CERT_INFO *info);
int get_rsa_key_info(const unsigned char *pcert, unsigned int lcert, T_RSA_KEY_INFO *rsa_keyinfo);
unsigned char* parse_ec_params(unsigned char* pparams, long *len);
unsigned char* parse_ec_point(unsigned char* ppoint, long *len);

#ifdef __cplusplus
   }
#endif


#endif
