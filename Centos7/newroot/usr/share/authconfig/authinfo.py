# -*- coding: UTF-8 -*-
#
# Authconfig - client authentication configuration program
# Copyright (c) 1999-2014 Red Hat, Inc.
#
# Authors: Preston Brown <pbrown@redhat.com>
#          Nalin Dahyabhai <nalin@redhat.com>
#          Matt Wilson <msw@redhat.com>
#          Tomas Mraz <tmraz@redhat.com>
#          Ray Strode <rstrode@redhat.com>
#          Paolo Bonzini <pbonzini@redhat.com>
#          Miloslav Trmac <mitr@redhat.com>
#          Jan Lieskovsky <jlieskov@redhat.com>
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

import string
import re
import os
import copy
import fcntl
import socket
import select
import signal
import stat
import shvfile
import dnsclient
import sys
import errno
import urllib2
import urlparse
import time
import tempfile
from subprocess import *
import acutil
import gettext
_ = gettext.lgettext
try:
        import SSSDConfig
except ImportError:
        SSSDConfig = None

SYSCONFDIR = "/etc"
AUTH_PAM_SERVICE = "system-auth"
AUTH_PAM_SERVICE_AC = "system-auth-ac"

POSTLOGIN_PAM_SERVICE = "postlogin"
POSTLOGIN_PAM_SERVICE_AC = "postlogin-ac"

PASSWORD_AUTH_PAM_SERVICE = "password-auth"
PASSWORD_AUTH_PAM_SERVICE_AC = "password-auth-ac"

FINGERPRINT_AUTH_PAM_SERVICE = "fingerprint-auth"
FINGERPRINT_AUTH_PAM_SERVICE_AC = "fingerprint-auth-ac"

SMARTCARD_AUTH_PAM_SERVICE = "smartcard-auth"
SMARTCARD_AUTH_PAM_SERVICE_AC = "smartcard-auth-ac"

SSSD_AUTHCONFIG_DOMAIN = "default"

if "lib64" in str(globals()["acutil"]):
	LIBDIR = "/usr/lib64"
else:
	LIBDIR = "/usr/lib"

AUTH_MODULE_DIR = LIBDIR + "/security"

PATH_PWCONV = "/usr/sbin/pwconv"
PATH_RPCBIND = "/sbin/rpcbind"
PATH_NSCD = "/usr/sbin/nscd"
PATH_NSLCD = "/usr/sbin/nslcd"
PATH_WINBIND = "/usr/sbin/winbindd"
PATH_SSSD = "/usr/sbin/sssd"
PATH_YPBIND = "/usr/sbin/ypbind"
PATH_ODDJOBD = "/usr/sbin/oddjobd"
PATH_SEBOOL = "/usr/sbin/setsebool"
PATH_SCEVENTD = "/usr/bin/pkcs11_eventmgr"
PATH_SCSETUP = "/usr/bin/pkcs11_setup"

PATH_LIBNSS_DB = LIBDIR + "/libnss_db.so.2"
PATH_LIBNSS_LDAP = LIBDIR + "/libnss_ldap.so.2"
if not os.path.isfile(PATH_LIBNSS_LDAP):
	PATH_LIBNSS_LDAP = LIBDIR + "/libnss_ldap.so.2"
PATH_LIBNSS_NIS = LIBDIR + "/libnss_nis.so.2"
PATH_LIBNSS_HESIOD = LIBDIR + "/libnss_hesiod.so.2"
PATH_LIBNSS_ODBCBIND = LIBDIR + "/libnss_odbcbind.so.2"
PATH_LIBNSS_WINBIND = LIBDIR + "/libnss_winbind.so.2"
PATH_LIBNSS_WINS = LIBDIR + "/libnss_wins.so.2"
PATH_LIBNSS_SSS = LIBDIR + "/libnss_sss.so.2"

PATH_PAM_KRB5 = AUTH_MODULE_DIR + "/pam_krb5.so"
PATH_PAM_LDAP = AUTH_MODULE_DIR + "/pam_ldap.so"
PATH_PAM_WINBIND = AUTH_MODULE_DIR + "/pam_winbind.so"
PATH_PAM_PKCS11 = AUTH_MODULE_DIR + "/pam_pkcs11.so"
PATH_PAM_FPRINTD = AUTH_MODULE_DIR + "/pam_fprintd.so"
PATH_PAM_SSS = AUTH_MODULE_DIR + "/pam_sss.so"

PATH_LIBSSS_AUTOFS = LIBDIR + "/sssd/modules/libsss_autofs.so"

PATH_KRB5_INCLUDEDIR = "/var/lib/sss/pubconf/krb5.include.d/"

PATH_WINBIND_NET = "/usr/bin/net"
PATH_IPA_CLIENT_INSTALL = "/usr/sbin/ipa-client-install"

PATH_LDAP_CACERTS = "/etc/openldap/cacerts"
LDAP_CACERT_DOWNLOADED = "authconfig_downloaded.pem"

PATH_CONFIG_BACKUPS = "/var/lib/authconfig"

PATH_SSSD_CONFIG = SYSCONFDIR + "/sssd/sssd.conf"

LOGIC_REQUIRED = "required"
LOGIC_REQUISITE	= "requisite"
LOGIC_SUFFICIENT = "sufficient"
LOGIC_OPTIONAL = "optional"
LOGIC_IGNORE_UNKNOWN = "[default=bad success=ok user_unknown=ignore]"
LOGIC_IGNORE_AUTH_ERR = "[default=bad success=ok auth_err=ignore user_unknown=ignore ignore=ignore]"
LOGIC_PKCS11 = "[success=done authinfo_unavail=ignore ignore=ignore default=die]"
LOGIC_FORCE_PKCS11 = "[success=done ignore=ignore default=die]"
LOGIC_PKCS11_KRB5 = "[success=ok authinfo_unavail=2 ignore=2 default=die]"
LOGIC_FORCE_PKCS11_KRB5 = "[success=ok ignore=2 default=die]"
LOGIC_SKIPNEXT = "[success=1 default=ignore]"
LOGIC_SKIPNEXT3 = "[success=3 default=ignore]"
LOGIC_ALWAYS_SKIP = "[default=1]"
LOGIC_SKIPNEXT_ON_FAILURE = "[default=1 ignore=ignore success=ok]"

# Snip off line terminators and final whitespace from a passed-in string.
def snipString(s):
	return s.split("\n",1)[0].rstrip()

# Make a list presentable.
def cleanList(lst):
	if not lst:
		return lst
	s = lst.replace("\t"," ")
	return ",".join(filter(None, s.split(" ")))

def matchKey(line, key):
	if line.startswith(key):
		# Skip intervening whitespace.
		return line[len(key):].lstrip()
	else:
		return False

def matchKeyEquals(line, key):
	if line.startswith(key):
		# Skip intervening whitespace.
		return line[len(key):].lstrip(string.whitespace+"=")
	else:
		return False

def matchLine(line, key):
	return line.startswith(key)

def matchLineI(line, key):
	return line.lower().startswith(key.lower())
				
def commaAppend(lst, value):
	if lst:
		return lst + "," + value
	else:
		return value
def stringsDiffer(a, b, case_sensitive):
	if not a and not b:
		return False
	if not a or not b:
		return True
	if case_sensitive:
		return a != b
	else:
		return a.lower() != b.lower()

# Heuristic check whether a string is LDAP DN
def checkDN(value):
	lst = value.lstrip().split("=",1)
	if len(lst) != 2:
		return False
	if " " in lst[0]:
		return False
	return True

def matchBaseLine(line, key):
	value = matchKey(line, key)
	if value:
		return checkDN(value)
	else:
		return False

# Check for a string in an nss configuration line.
def checkNSS(configuration, candidate):
	lst = configuration.split(":",1)
	if len(lst) > 1:
		configuration = lst[1]
	start = 0
	clen = len(candidate)
	while True:
		start = configuration.find(candidate, start)
		if start < 0:
			return None
		if start > 0 and configuration[start-1].isalnum():
			start += clen
			continue
		if start+clen < len(configuration) and configuration[start+clen].isalnum():
			start += clen
			continue
		return start
	return None

def openfdLocked(filename, mode, perms):
	fd = None
	try:
		fd = os.open(filename, mode, perms)
		if mode == os.O_RDONLY:
			fcntl.lockf(fd, fcntl.LOCK_SH)
		else:
			fcntl.lockf(fd, fcntl.LOCK_EX)
	except OSError as (errno, strerr):
		if fd != None:
			try:
				os.close(fd)
			except OSError:
				pass
		raise IOError(errno, strerr)
	return fd

def openLocked(filename, perms):
	return os.fdopen(openfdLocked(filename, os.O_RDWR | os.O_CREAT, perms),
		"r+")

def krbKdc(kdclist):
	output = ""
	kdclist = kdclist.split(",")
	for kdc in kdclist:
		if kdc:
			output += "  kdc = " + kdc + "\n"
	return output

def krbAdminServer(adminservers):
	output = ""
	adminservers = adminservers.split(",")
	for adminserver in adminservers:
		if adminserver:
			output += "  admin_server = "
			output += adminserver + "\n"
	return output

def krbRealm(realm, kdclist, adminservers):
	output = ""
	if realm:
		output += " " + realm + " = {\n"
		output += krbKdc(kdclist)
		output += krbAdminServer(adminservers)
		output += " }\n\n"
	return output

# Compare two strings, one a possible data line, the other a Samba-style key
# name.  Returns False on non-match, value of the key if matched.
def matchLineSMB(line, key):
	linelst = line.split("=", 1)
	if len(linelst) < 2:
		param = ""
	else:
		param = linelst[1]

	linelst = linelst[0].lower().split(None)
	keylst = key.lower().split(None)
	# Compare the lists
	if keylst == linelst:
		return param.lstrip(string.whitespace+"=")
	return False

# Mandatory arguments for the various modules.
argv_unix_auth = [
	"try_first_pass"
]

argv_unix_password = [
	"try_first_pass",
	"use_authtok"
]

argv_afs_auth = [
	"use_first_pass"
]

argv_afs_password = [
	# It looks like current pam_afs (from OpenAFS 1.1.1) doesn't support
	# "use_authtok", so it'll probably interact badly with pam_pwquality,
	# but thanks to stack-traversal changes in Linux-PAM 0.75 and higher,
	# the password-changing should work anyway.
	"use_first_pass"
]

argv_pwquality_password = [
	"try_first_pass",
	"local_users_only",
	"retry=3",
	"authtok_type="
]

argv_passwdqc_password = [
	"enforce=users"
]

argv_eps_auth = [
	"use_first_pass"
]

argv_eps_password = [
	"use_authtok"
]

argv_fprintd_auth = [
]

argv_pkcs11_auth = [
	"nodebug"
]

argv_force_pkcs11_auth = [
	"nodebug",
	"wait_for_card"
]

argv_sssd_missing_name = [
   "allow_missing_name"
]

argv_krb5_auth = [
	"use_first_pass"
]

argv_krb5_sc_auth = [
	"use_first_pass",
	"no_subsequent_prompt"
]

argv_krb5_password = [
	"use_authtok"
]

argv_ldap_auth = [
	"use_first_pass"
]

argv_ldap_password = [
	"use_authtok"
]

# This probably won't work straight-off because pam_unix won't give the right
# challenge, but what the heck.
argv_otp_auth = [
	"use_first_pass"
]

argv_succeed_if_auth = [
	"uid >=",
	"500", # this must be the second arg - to be replaced
	"quiet_success"  # this will be replaced in the first entry
]

argv_succeed_if_account = [
	"uid <",
	"500", # this must be the second arg - to be replaced
	"quiet"
]

argv_succeed_if_session = [
	"service in crond",
	"quiet",
	"use_uid"
]

argv_succeed_if_nonlogin = [
	"service notin login:gdm:xdm:kdm:xscreensaver:gnome-screensaver:kscreensaver",
	"quiet",
	"use_uid"
]

argv_winbind_auth = [
	"use_first_pass"
]

argv_winbind_password = [
	"use_authtok"
]

argv_sss_auth = [
	"use_first_pass"
]

argv_sss_password = [
	"use_authtok"
]

argv_keyinit_session = [
	"revoke"
]

argv_ecryptfs_auth = [
	"unwrap"
]

argv_ecryptfs_password = [
	"unwrap"
]

argv_ecryptfs_session = [
	"unwrap"
]

argv_succeed_if_not_gdm = [
	"service !~ gdm*",
        "service !~ su*",
	"quiet"
]

argv_lastlog_gdm = [
	"nowtmp",
	"showfailed"
]

argv_lastlog_not_gdm = [
	"silent",
	"noupdate",
	"showfailed"
]

argv_faildelay = [
	"delay=2000000"
]

# Password hashing algorithms.
password_algorithms = ["descrypt", "bigcrypt", "md5", "sha256", "sha512"]

# Enumerations for PAM control flags and stack names.
(AUTH, ACCOUNT, SESSION, PASSWORD) = range(0,4)

pam_stacks = ["auth", "account", "session", "password"]

(MANDATORY, STACK, LOGIC, NAME, ARGV) = range(0,5)

(STANDARD, POSTLOGIN, PASSWORD_ONLY, FINGERPRINT, SMARTCARD) = range(0,5)

pam_modules = [[] for service in (STANDARD, POSTLOGIN, PASSWORD_ONLY, FINGERPRINT, SMARTCARD)]

# The list of stacks, module flags, and arguments, if there are any.
# [ MANDATORY, STACK, LOGIC, NAME, ARGV ]
pam_modules[STANDARD] = [
	[True,  AUTH,		LOGIC_REQUIRED,
	 "env",			[]],
	[True,  AUTH,		LOGIC_REQUIRED,
	 "faildelay",		argv_faildelay],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["preauth", "silent"]],
	[False,  AUTH,          LOGIC_SKIPNEXT,
	 "succeed_if",		argv_succeed_if_nonlogin],
	[False,  AUTH,          LOGIC_PKCS11,
	 "pkcs11",		argv_pkcs11_auth],
	[False, AUTH,		LOGIC_OPTIONAL,
	 "krb5",		argv_krb5_sc_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "permit",		[]],
	[False,  AUTH,          LOGIC_SUFFICIENT,
	 "fprintd",		[]],
	[False, AUTH,		LOGIC_SKIPNEXT_ON_FAILURE,
	 "succeed_if",		argv_succeed_if_auth],
	[False, AUTH,		LOGIC_SKIPNEXT_ON_FAILURE,
	 "localuser",		[]],
	[True,  AUTH,		LOGIC_SUFFICIENT,
	 "unix",		argv_unix_auth],
	[False, AUTH,		LOGIC_REQUISITE,
	 "succeed_if",		argv_succeed_if_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "sss",			argv_sss_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "afs",			argv_afs_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "afs.krb",		argv_afs_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "eps_auth",		argv_eps_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "krb5",		argv_krb5_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "ldap",		argv_ldap_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "otp",			argv_otp_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "winbind",		argv_winbind_auth],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["authfail"]],
	[True,  AUTH,		LOGIC_REQUIRED,
	 "deny",		[]],
# Account management is tricky.  Because we've implicitly committed to
# getting it "right" for any combination of nss and pam, we have to be
# careful about how we handle cases where networked sources of information
# are unavailable.
# At the very least, proper handling of password expiration depends on
# this, and in the case of pam_ldap, we also may be depending on the
# directory server for actual "is allowed to log in on this host" data.
# The frequently-suggested method of using pam_localuser to short-circuit
# pam_ldap may be only optional, but we can use pam_succeed_if 
# to short-circuit any network checks for *system* accounts
# without allowing actual users in who should be legitimately denied by
# LDAP (if not overriden by enabling the optional pam_localuser).
# Because we'd now be ending the stack with sufficient modules, and PAM's
# behavior isn't defined if none of them return success, we add a
# successful call to pam_permit at the end as a requirement.
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "access",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "faillock",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "localuser",		[]],
	[True,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "succeed_if",		argv_succeed_if_account],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "sss",			[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "ldap",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "krb5",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "winbind",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "permit",		[]],
	[False,  PASSWORD,	LOGIC_REQUISITE,
	 "pwquality",		argv_pwquality_password],
	[False,  PASSWORD,	LOGIC_REQUISITE,
	 "passwdqc",		argv_passwdqc_password],
	[True,  PASSWORD,	LOGIC_SUFFICIENT,
	 "unix",		argv_unix_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "sss",			argv_sss_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "afs",			argv_afs_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "afs.krb",		argv_afs_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "eps_passwd",		argv_eps_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "krb5",		argv_krb5_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "ldap",		argv_ldap_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "winbind",		argv_winbind_password],
	[True,  PASSWORD,	LOGIC_REQUIRED,
	 "deny",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "keyinit",		argv_keyinit_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "limits",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "systemd",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "mkhomedir",		[]],
	[True,  SESSION,	LOGIC_SKIPNEXT,
	 "succeed_if",		argv_succeed_if_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "sss",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs.krb",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "krb5",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "ldap",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "winbind",		[]]
]

pam_modules[POSTLOGIN] = [
	[False, AUTH,		LOGIC_OPTIONAL,
	 "ecryptfs",		argv_ecryptfs_auth],
	[False, PASSWORD,	LOGIC_OPTIONAL,
	 "ecryptfs",		argv_ecryptfs_password],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "ecryptfs",		argv_ecryptfs_session],
	[True,  SESSION,	LOGIC_SKIPNEXT,
	 "succeed_if",		argv_succeed_if_not_gdm],
	[True,  SESSION,	LOGIC_ALWAYS_SKIP,
	 "lastlog",		argv_lastlog_gdm],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "lastlog",		argv_lastlog_not_gdm],
]

pam_modules[PASSWORD_ONLY] = [
	[True,  AUTH,		LOGIC_REQUIRED,
	 "env",			[]],
	[True,  AUTH,		LOGIC_REQUIRED,
	 "faildelay",		argv_faildelay],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["preauth", "silent"]],
	[False, AUTH,		LOGIC_REQUIRED,
	 "deny",		[]],
	[False, AUTH,		LOGIC_SKIPNEXT_ON_FAILURE,
	 "succeed_if",		argv_succeed_if_auth],
	[False, AUTH,		LOGIC_SKIPNEXT_ON_FAILURE,
	 "localuser",		[]],
	[True,  AUTH,		LOGIC_SUFFICIENT,
	 "unix",		argv_unix_auth],
	[False, AUTH,		LOGIC_REQUISITE,
	 "succeed_if",		argv_succeed_if_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "sss",			argv_sss_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "afs",			argv_afs_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "afs.krb",		argv_afs_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "eps_auth",		argv_eps_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "krb5",		argv_krb5_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "ldap",		argv_ldap_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "otp",			argv_otp_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "winbind",		argv_winbind_auth],
	[True,  AUTH,		LOGIC_REQUIRED,
	 "deny",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "access",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "faillock",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "localuser",		[]],
	[True,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "succeed_if",		argv_succeed_if_account],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "sss",			[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "ldap",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "krb5",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "winbind",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "permit",		[]],
	[False,  PASSWORD,	LOGIC_REQUISITE,
	 "pwquality",		argv_pwquality_password],
	[False,  PASSWORD,	LOGIC_REQUISITE,
	 "passwdqc",		argv_passwdqc_password],
	[True,  PASSWORD,	LOGIC_SUFFICIENT,
	 "unix",		argv_unix_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "sss",			argv_sss_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "afs",			argv_afs_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "afs.krb",		argv_afs_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "eps_passwd",		argv_eps_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "krb5",		argv_krb5_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "ldap",		argv_ldap_password],
	[False, PASSWORD,	LOGIC_SUFFICIENT,
	 "winbind",		argv_winbind_password],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["authfail"]],
	[True,  PASSWORD,	LOGIC_REQUIRED,
	 "deny",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "keyinit",		argv_keyinit_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "limits",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "systemd",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "mkhomedir",		[]],
	[True,  SESSION,	LOGIC_SKIPNEXT,
	 "succeed_if",		argv_succeed_if_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "sss",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs.krb",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "krb5",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "ldap",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "winbind",		[]]
]

pam_modules[FINGERPRINT] = [
	[True,  AUTH,		LOGIC_REQUIRED,
	 "env",			[]],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["preauth", "silent"]],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "deny",		[]],
	[False,  AUTH,		LOGIC_SUFFICIENT,
	 "fprintd",		[]],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["authfail"]],
	[True,  AUTH,		LOGIC_REQUIRED,
	 "deny",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "access",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "faillock",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "localuser",		[]],
	[True,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "succeed_if",		argv_succeed_if_account],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "sss",			[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "ldap",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "krb5",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "winbind",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "permit",		[]],
	[True,  PASSWORD,	LOGIC_REQUIRED,
	 "deny",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "keyinit",		argv_keyinit_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "limits",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "systemd",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "mkhomedir",		[]],
	[True,  SESSION,	LOGIC_SKIPNEXT,
	 "succeed_if",		argv_succeed_if_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "sss",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs.krb",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "krb5",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "ldap",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "winbind",		[]]
]

pam_modules[SMARTCARD] = [
	[True,  AUTH,		LOGIC_REQUIRED,
	 "env",			[]],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["preauth", "silent"]],
	[False,  AUTH,		LOGIC_SUFFICIENT,
	 "sss",			argv_sssd_missing_name],
	[False,  AUTH,		LOGIC_PKCS11,
	 "pkcs11",		argv_force_pkcs11_auth],
	[False, AUTH,		LOGIC_OPTIONAL,
	 "krb5",		argv_krb5_sc_auth],
	[False, AUTH,		LOGIC_SUFFICIENT,
	 "permit",		[]],
	[False,  AUTH,		LOGIC_REQUIRED,
	 "faillock",		["authfail"]],
	[True,  AUTH,		LOGIC_REQUIRED,
	 "deny",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "access",		[]],
	[False, ACCOUNT,	LOGIC_REQUIRED,
	 "faillock",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "localuser",		[]],
	[True,  ACCOUNT,	LOGIC_SUFFICIENT,
	 "succeed_if",		argv_succeed_if_account],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "sss",			[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "ldap",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "krb5",		[]],
	[False, ACCOUNT,	LOGIC_IGNORE_UNKNOWN,
	 "winbind",		[]],
	[True,  ACCOUNT,	LOGIC_REQUIRED,
	 "permit",		[]],
	[False,  PASSWORD,	LOGIC_REQUIRED,
	 "pkcs11",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "keyinit",		argv_keyinit_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "limits",		[]],
	[True,  SESSION,	LOGIC_OPTIONAL,
	 "systemd",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "mkhomedir",		[]],
	[True,  SESSION,	LOGIC_SKIPNEXT,
	 "succeed_if",		argv_succeed_if_session],
	[True,  SESSION,	LOGIC_REQUIRED,
	 "unix",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "sss",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs",			[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "afs.krb",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "krb5",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "ldap",		[]],
	[False, SESSION,	LOGIC_OPTIONAL,
	 "winbind",		[]]
]

def domain2dn(domain):
	output = "DC="
	domain = domain.rstrip(".")
	output += domain.replace(".", ",DC=")
	return output

DEFAULT_DNS_QUERY_SIZE = 1024

# No, this is not particularly nice, but "compatible" is more important than
# "beautiful".
ld_line_re = re.compile(r'^[ \t]*'     # Initial whitespace
                       r'([^ \t]+)'    # Variable name
                       r'[ \t][ \t"]*' # Separator - yes, may have multiple \"s
                       r'(([^"]*)".*'  # Value, case 1 - terminated by \"
                       r'|([^"]*\S)?\s*' # Value, case 2 - only drop trailing \s
                       r')$')
# for matching uid in succeeded if options
succ_if_re = re.compile(r'^.*[ \t]*uid[ \t]+(<|>=)[ \t]+([0-9]+)')

class SysVInitService:
	def start(self, service):
		os.system("/sbin/service " + service + " start")

	def stop(self, service):
		os.system("/sbin/service " + service + " stop >/dev/null 2>&1")

	def enable(self, service):
		os.system("/sbin/chkconfig --add " + service)
		os.system("/sbin/chkconfig --level 345 " + service + " on")

	def disable(self, service):
		os.system("/sbin/chkconfig --level 345 " + service + " off")

	def isEnabled(self, service):
		rv = os.system("/sbin/chkconfig " + service + " >/dev/null 2>&1")
		return os.WIFEXITED(rv) and os.WEXITSTATUS(rv) == 0

	def tryRestart(self, service):
		os.system("/sbin/service " + service + " condrestart >/dev/null 2>&1")

class SystemdService:
	def start(self, service):
		os.system("/bin/systemctl start " + service + ".service")

	def stop(self, service):
		os.system("/bin/systemctl stop " + service + ".service >/dev/null 2>&1")

	def enable(self, service):
		os.system("/bin/systemctl enable " + service + ".service >/dev/null 2>&1")

	def disable(self, service):
		os.system("/bin/systemctl disable " + service + ".service >/dev/null 2>&1")

	def isEnabled(self, service):
		rv = os.system("/bin/systemctl is-enabled " + service + ".service >/dev/null 2>&1")
		return os.WIFEXITED(rv) and os.WEXITSTATUS(rv) == 0

	def tryRestart(self, service):
		os.system("/bin/systemctl try-restart " + service + ".service >/dev/null 2>&1")

try:
	if "systemd" in os.readlink("/sbin/init"):
		Service = SystemdService()
	else:
		Service = SysVInitService()
except OSError:
	Service = SysVInitService()

def toggleSplatbindService(enable, path, name, nostart):
	if enable:
		try:
			os.stat(path)
			Service.enable(name)
			if not nostart:
				Service.stop(name)
				Service.start(name)
		except OSError:
			pass
	else:
		try:
			os.stat(path)
			if not nostart:
				try:
					Service.stop(name)
				except OSError:
					pass
			Service.disable(name)
		except OSError:
			pass
	return True

def formatBool(val):
	if val:
		return "enabled"
	else:
		return "disabled"

def feedFork(command, echo, query, response):
	try:
		(pid, master) = os.forkpty()
	except OSError:
		return 255
	if not pid:
		# child
		if query:
			child = Popen([command], shell=True)
		else:
			child = Popen([command], stdin=PIPE, shell=True)
			child.communicate(input=(response or '')+'\n')

		# wait for the child to terminate & set the returncode
		child.wait()
		status = child.returncode
		os._exit(status)
	(output, error) = ("","")
	try:
		i = fcntl.fcntl(master, fcntl.F_GETFL)
		fcntl.fcntl(master, fcntl.F_SETFL, i & ~os.O_NONBLOCK)
	except IOError:
		pass
		
	eof = False
	while not eof:
		try:
			ifds = []
			efds = []
			(ifds,ofds,efds) = select.select([master],[],[master], 60)
		except select.error, (err, text):
			sys.stderr.write("select: " + text + "\n")
		if not ifds and not efds:
			# timeout or error
			os.close(master)
			eof = True
			continue
		c = ""
		try:
			c = os.read(master, 1)
		except OSError as (err, text):
			if err == errno.EINTR or err == errno.EAGAIN:
				pass
			elif err == errno.EIO:
				os.close(master)
				eof = True
			else:
				sys.stderr.write("read: " + text + "\n")
				os.close(master)
				eof = True
			continue
		if c:
			try:
				output += c
				error += c
				if echo:
					sys.stderr.write(c)
				if query and query in output:
					# Search for password prompt start
					index = error.rfind("\r\n")
					os.write(master, response or '')
					os.write(master, "\r\n")
					if index != -1:
						# Drop password prompt substring from error
						error = "\n" + error[:index]
					else:
						# Drop whole error content, password prompt
						# was the first line
						error = ""
					output = ""
					if echo:
						sys.stderr.write("<...>\n")
			except OSError, (err, text):
				sys.stderr.write("write: " + text + "\n")
				os.close(master)
				eof = True
		else:
			os.close(master)
			eof = True
	try:
		os.kill(pid, signal.SIGTERM)
	except OSError:
		pass
	status = 255
	try:
		(child, status) = os.waitpid(pid, 0)
	except OSError, (err, text):
		sys.stderr.write("waitpid: " + text + "\n")
	return (status, error)

def isEmptyDir(path):
	try:
		lst = os.listdir(path)
	except OSError:
		# we don't know but return True anyway
		return True
	
	for filename in lst:
		try:
			st = os.stat(path + "/" + filename)
			if stat.S_ISREG(st.st_mode):
				return False
		except OSError:
			pass
	return True

def callPKCS11Setup(options):
	try:
		child = Popen([PATH_SCSETUP] + options, stdout=PIPE)
		lst = child.communicate()[0].split("\n")
		if child.returncode != 0:
			return None
		if lst[-1] == '':
			del lst[-1:]
	except OSError:
		return None
	return lst

def getSmartcardModules():
	mods = callPKCS11Setup(["list_modules"])
	if mods == None:
		return []
	return mods

def getSmartcardActions():
	return [_("Lock"), _("Ignore")]

def read(msgcb):
	info = AuthInfo(msgcb)
	info.read()
	return info

class SaveGroup:
	def __init__(self, savefunc, togglefunc, attrlist):
		self.saveFunction = savefunc
		self.toggleFunction = togglefunc
		self.attrlist = attrlist

	def attrsDiffer(self, a, b):
		for (aname, atype) in self.attrlist:
			if aname in a.inconsistentAttrs:
				return True
			if atype == "b":
				if getattr(a, aname) != getattr(b, aname):
					return True
			elif atype == "c":
				if stringsDiffer(getattr(a, aname), getattr(b, aname), True):
					return True
			elif atype == "i":
				if stringsDiffer(getattr(a, aname), getattr(b, aname), False):
					return True
		return False

class SafeFile:
	def __init__(self, filename, default_mode):
		(base, name) = os.path.split(filename)
		self.missing = False
		self.file = tempfile.NamedTemporaryFile(dir=base, prefix=name, delete=True)
		# overwrite the inode attributes and contents
		if call(["/bin/cp", "-af", filename, self.file.name],
			stderr=os.open('/dev/null', os.O_WRONLY)) == 1:
			self.missing = True
			# the mode was not copied, use the default
			os.fchmod(self.file.fileno(), default_mode)
		self.filename = filename

	def save(self):
		self.file.flush()
		os.fsync(self.file.fileno())
		os.rename(self.file.name, self.filename)
		if self.missing:
			call(["/usr/sbin/restorecon", self.filename],
				stderr=os.open('/dev/null', os.O_WRONLY))

	def close(self):
		# we may have renamed the temp file, need to catch OSError
		try:
			self.file.close()
		except OSError:
			pass

	def write(self, s):
		return self.file.write(s)

	def rewind(self):
		self.file.seek(0)
		self.file.truncate(0)

class FileBackup:
	def __init__(self, backupname, origpath):
		self.backupName = backupname
		self.origPath = origpath

	def safeCopy(self, src, dest):
		rv = True
		srcfd = None
		destfile = None

		try:
			srcfd = openfdLocked(src, os.O_RDONLY, 0)
		except IOError:
			return True
		try:
			mode = stat.S_IMODE(os.fstat(srcfd).st_mode)
		except (IOError, OSError):
			os.close(srcfd)
			return True

		try:
			destfile = SafeFile(dest, mode)
			destfile.rewind()
		except IOError:
			rv = False
		try:
			while rv:
				b = os.read(srcfd, 4096)
				if not b:
					rv = True
					break
				os.write(destfile.file.fileno(), b)
		except (IOError, OSError):
			rv = False
		try:
			if srcfd:
				os.close(srcfd)
		except (IOError, OSError):
			pass
		try:
			if destfile and rv:
				destfile.save()
				destfile.close()
		except (IOError, OSError):
			rv = False
		return rv

	def backup(self, destdir):
		rv = True
		try:
			if not os.path.isdir(destdir):
				os.mkdir(destdir)
		except (OSError, IOError):
			rv = False

		backuppath = destdir+"/"+self.backupName
		if rv:
			rv = self.safeCopy(self.origPath,
				backuppath)

		return rv

	def restore(self, backupdir):
		rv = True
		try:
			if not os.path.isdir(backupdir):
				return False
		except (IOError, OSError):
			rv = False

		backuppath = backupdir+"/"+self.backupName
		if rv and os.path.isfile(backuppath):
			rv = self.safeCopy(backuppath, self.origPath)

		try:
			if rv:
				call(["/usr/sbin/restorecon", self.origPath],
					stderr=os.open('/dev/null', os.O_WRONLY))
		except (IOError, OSError):
			pass

		return rv

def readCache():
	return Service.isEnabled("nscd")

def writeCache(enabled):
	if enabled:
		Service.enable("nscd")
	else:
		try:
			os.stat(PATH_NSCD)
			Service.disable("nscd")
		except OSError:
			pass
	return True

class CacheBackup(FileBackup):
	def backup(self, destdir):
		rv = True
		try:
			if not os.path.isdir(destdir):
				os.mkdir(destdir)
		except (OSError, IOError):
			rv = False

		backuppath = destdir+"/"+self.backupName
		if rv:
			dest = None
			try:

				enabled = readCache()
				dest = open(backuppath, "w")
				dest.write(str(int(enabled)))
			except IOError:
				rv = False
			if dest:
				dest.close()

		if not rv:
			try:
				os.unlink(backuppath)
			except OSError:
				pass
		return rv

	def restore(self, backupdir):
		rv = True
		try:
			if not os.path.isdir(backupdir):
				return False
		except (IOError, OSError):
			rv = False

		backuppath = backupdir+"/"+self.backupName
		if rv and os.path.isfile(backuppath):
			backup = None
			try:
				backup = open(backuppath, "r")
				enabled = int(backup.read())
				writeCache(enabled)
			except (IOError, OSError, ValueError):
				rv = False
			if backup:
				backup.close()

		return rv

# indexes for the configs
(CFG_HESIOD, CFG_YP, CFG_LDAP, CFG_NSSLDAP, CFG_PAMLDAP, CFG_NSLCD, CFG_OPENLDAP, CFG_KRB5,
	CFG_KRB, CFG_PAM_PKCS11, CFG_SMB, CFG_NSSWITCH, CFG_CACHE,
	CFG_PAM, CFG_POSTLOGIN_PAM, CFG_PASSWORD_PAM, CFG_FINGERPRINT_PAM, CFG_SMARTCARD_PAM, CFG_AUTHCONFIG, CFG_NETWORK, CFG_LIBUSER, CFG_PWQUALITY,
	CFG_LOGIN_DEFS, CFG_SSSD, CFG_SHADOW, CFG_PASSWD, CFG_GSHADOW, CFG_GROUP, CFG_DCONF, CFG_DCONF_LOCKS) = range(0, 30)
all_configs = [
	FileBackup("hesiod.conf", SYSCONFDIR+"/hesiod.conf"),
	FileBackup("yp.conf", SYSCONFDIR+"/yp.conf"),
	FileBackup("ldap.conf", SYSCONFDIR+"/ldap.conf"),
	FileBackup("nss_ldap.conf", SYSCONFDIR+"/nss_ldap.conf"),
	FileBackup("pam_ldap.conf", SYSCONFDIR+"/pam_ldap.conf"),
	FileBackup("nslcd.conf", SYSCONFDIR+"/nslcd.conf"),
	FileBackup("openldap.conf", SYSCONFDIR+"/openldap/ldap.conf"),
	FileBackup("krb5.conf", SYSCONFDIR+"/krb5.conf"),
	FileBackup("krb.conf", SYSCONFDIR+"/krb.conf"),
	FileBackup("pam_pkcs11.conf", SYSCONFDIR+"/pam_pkcs11/pam_pkcs11.conf"),
	FileBackup("smb.conf", SYSCONFDIR+"/samba/smb.conf"),
	FileBackup("nsswitch.conf", SYSCONFDIR+"/nsswitch.conf"),
	CacheBackup("cacheenabled.conf", ""),
	FileBackup("system-auth-ac", SYSCONFDIR+"/pam.d/"+AUTH_PAM_SERVICE_AC),
	FileBackup("postlogin-ac", SYSCONFDIR+"/pam.d/"+POSTLOGIN_PAM_SERVICE_AC),
	FileBackup("password-auth-ac", SYSCONFDIR+"/pam.d/"+PASSWORD_AUTH_PAM_SERVICE_AC),
	FileBackup("fingerprint-auth-ac", SYSCONFDIR+"/pam.d/"+FINGERPRINT_AUTH_PAM_SERVICE_AC),
	FileBackup("smartcard-auth-ac", SYSCONFDIR+"/pam.d/"+SMARTCARD_AUTH_PAM_SERVICE_AC),
	FileBackup("authconfig", SYSCONFDIR+"/sysconfig/authconfig"),
	FileBackup("network", SYSCONFDIR+"/sysconfig/network"),
	FileBackup("libuser.conf", SYSCONFDIR+"/libuser.conf"),
	FileBackup("pwquality.conf", SYSCONFDIR+"/security/pwquality.conf"),
	FileBackup("login.defs", SYSCONFDIR+"/login.defs"),
	FileBackup("sssd.conf", PATH_SSSD_CONFIG),
	FileBackup("shadow", SYSCONFDIR+"/shadow"),
	FileBackup("passwd", SYSCONFDIR+"/passwd"),
	FileBackup("gshadow", SYSCONFDIR+"/gshadow"),
	FileBackup("group", SYSCONFDIR+"/group"),
	FileBackup("10-authconfig", SYSCONFDIR+"/dconf/db/distro.d/10-authconfig"),
	FileBackup("10-authconfig-locks", SYSCONFDIR+"/dconf/db/distro.d/locks/10-authconfig-locks")]

sssd_options = [
	('ldapServer', 'ldap_uri'),
	('ldapBaseDN', 'ldap_search_base'),
	('enableLDAPS', 'ldap_id_use_start_tls'),
	('ldapSchema', 'ldap_schema'),
	('ldapCacertDir', 'ldap_tls_cacertdir'),
	('kerberosKDC', 'krb5_server'),
	('kerberosAdminServer', 'krb5_kpasswd'),
	('kerberosRealm', 'krb5_realm'),
	('enableCacheCreds', 'cache_credentials'),
	('enableCacheCreds', 'krb5_store_password_if_offline')]

class AuthInfo:
	def __init__(self, msgcb):
		self.messageCB = msgcb
		self.backupDir = ""
		self.inconsistentAttrs = []

		# Service-specific settings.
		self.hesiodLHS = ""
		self.hesiodRHS = ""

		self.ldapServer = ""
		self.ldapBaseDN = ""

		self.kerberosRealm = None
		self.kerberosRealmviaDNS = None
		self.kerberosKDC = ""
		self.kerberosKDCviaDNS = None
		self.kerberosAdminServer = ""

		self.nisServer = ""
		self.nisDomain = ""
		self.nisLocalDomain = ""

		self.smbWorkgroup = ""
		self.smbRealm = ""
		self.smbServers = ""
		self.smbSecurity = ""
		self.smbIdmapRange = ""

		self.winbindSeparator = ""
		self.winbindTemplateHomedir = ""
		self.winbindTemplateShell = ""
		self.winbindUseDefaultDomain = None
		self.winbindOffline = None
		self.winbindKrb5 = None

		self.ipav2Server = None
		self.ipav2Domain = None
		self.ipav2Realm = None
		self.ipav2NoNTP = None
		self.ipaDomainJoined = False
		self.ipaUninstall = False

		self.smartcardModule = ""
		self.smartcardAction = ""

		# NSSwitch setup.  Files is always in there.
		self.enableCache = None
		self.enableCompat = None
		self.enableDB = None
		self.enableDirectories = None
		self.enableHesiod = None
		self.enableLDAP = None
		self.enableLDAPS = None
		self.enableNIS = None
		self.enableNIS3 = None
		self.enableDBbind = None
		self.enableDBIbind = None
		self.enableHesiodbind = None
		self.enableLDAPbind = None
		self.enableOdbcbind = None
		self.enableWinbind = None
		self.enableWINS = None
		self.enableMDNS = None
		self.enableMyhostname = None
		self.preferDNSinHosts = None
		self.enableSSSD = None
		self.enableIPAv2 = None
                # This one we don't have a config entry, we just
                # preserve the entry if we see it.
		self.enableAltfiles = None

		# Authentication setup.
		self.enableAFS = None
		self.enableAFSKerberos = None
		self.enableNullOk = True
		self.enablePWQuality = None
		self.enableEcryptfs = None
		self.enableEPS = None
		self.enableKerberos = None
		self.enableLDAPAuth = None
		self.passwordAlgorithm = ""
		self.algoRounds = ""
		self.uidMin = None
		self.enableOTP = None
		self.enablePasswdQC = None
		self.enableShadow = None
		self.enableWinbindAuth = None
		self.enableLocAuthorize = None
		self.enablePAMAccess = None
		self.enableSysNetAuth = None
		self.enableMkHomeDir = None
		self.enableSmartcard = None
		self.enableSSSDAuth = None

		self.brokenShadow = None
		self.forceBrokenShadow = None
		self.forceSmartcard = None
		self.enableFprintd = None
		self.enableForceLegacy = None
		self.implicitSSSD = False
		self.implicitSSSDAuth = False
		self.enableCacheCreds = None

                # Password quality
                self.passMinLen = "9"
                self.passMinClass = "1"
                self.passMaxRepeat = "0"
                self.passMaxClassRepeat = "0"
                self.passReqLower = None
                self.passReqUpper = None
                self.passReqDigit = None
                self.passReqOther = None

		# Faillock
		self.enableFaillock = None
		self.faillockArgs = "deny=4 unlock_time=1200"


		# Not really options.
		self.joinUser = ""
		self.joinPassword = ""
		self.pwqualityArgs = ""
		self.passwdqcArgs = ""
		self.localuserArgs = ""
		self.pamAccessArgs = ""
		self.mkhomedirArgs = "umask=0077"
		self.systemdArgs = ""
		self.ldapCacertDir = ""
		self.ldapCacertURL = ""
		self.ldapSchema = ""

		self.pamLinked = True

		global SSSDConfig
		self.sssdConfig = None
		self.sssdDomain = None
		self.forceSSSDUpdate = None
		self.sssdConfigPresent = False
		if SSSDConfig:
			try:
				self.sssdConfig = SSSDConfig.SSSDConfig()
				self.sssdConfig.new_config()
			except IOError:
				pass
		self.toggleFunctions = set()
		self.save_groups = [
	SaveGroup(self.writeCache, self.toggleCachingService, [("enableCache", "b"), ("implicitSSSD", "b")]),
	SaveGroup(self.writeHesiod, None, [("hesiodLHS", "i"), ("hesiodRHS", "i")]),
	SaveGroup(self.writeNIS, self.toggleNisService, [("nisDomain", "c"), ("nisLocalDomain", "c"), ("nisServer", "c")]),
	SaveGroup(self.writeLDAP, None, [("ldapServer", "i"), ("ldapBaseDN", "c"), ("enableLDAPS", "b"),
		("ldapSchema", "c"), ("ldapCacertDir", "c"), ("passwordAlgorithm", "i")]),
	SaveGroup(self.writeLibuser, None, [("passwordAlgorithm", "i")]),
	SaveGroup(self.writeLogindefs, None, [("passwordAlgorithm", "i")]), # for now we do not rewrite uidMin
        SaveGroup(self.writePWQuality, None,  [("passMinLen", "c"), ("passMinClass", "c"),
                ("passMaxRepeat", "c"), ("passMaxClassRepeat", "c"), ("passReqLower", "b"),
                ("passReqUpper", "b"), ("passReqDigit", "b"), ("passReqOther", "b")]),
	SaveGroup(self.writeKerberos, None, [("kerberosRealm", "c"), ("kerberosKDC", "i"),
		("smbSecurity", "i"), ("smbRealm", "c"), ("smbServers", "i"),
		("kerberosAdminServer", "i"), ("kerberosRealmviaDNS", "b"),
		("kerberosKDCviaDNS", "b")]),
	SaveGroup(self.writeSSSD, self.toggleSSSDService, [("ldapServer", "i"), ("ldapBaseDN", "c"), ("enableLDAPS", "b"),
		("ldapSchema", "c"), ("ldapCacertDir", "c"), ("enableCacheCreds", "b"), ("enableSmartcard", "b"),
		("kerberosRealm", "c"), ("kerberosKDC", "i"), ("kerberosAdminServer", "i"),
		("forceSSSDUpdate", "b"), ("enableLDAP", "b"), ("enableKerberos", "b"),
		("enableLDAPAuth", "b"), ("enableIPAv2", "b")]),
	SaveGroup(self.writeSmartcard, None, [("smartcardAction", "i"), ("smartcardModule", "c")]),
	SaveGroup(self.writeDConf, None, [("smartcardAction", "i"), ("smartcardModule", "c"),
		("enableFprintd", "b"), ("enableSmartcard", "b"), ("forceSmartcard", "b")]),
	SaveGroup(self.writeWinbind, self.toggleWinbindService, [("smbWorkgroup", "i"), ("smbServers", "i"),
		("smbRealm", "c"), ("smbSecurity", "i"), ("smbIdmapRange", "i"),
		("winbindSeparator", "c"), ("winbindTemplateHomedir", "c"), ("winbindTemplateShell", "c"),
		("winbindUseDefaultDomain", "b"), ("winbindOffline", "b"), ("winbindKrb5", "b")]),
	SaveGroup(self.writeNSS, None, [("enableDB", "b"), ("enableDirectories", "b"), ("enableWinbind", "b"),
		("enableOdbcbind", "b"), ("enableNIS3", "b"), ("enableNIS", "b"),
		("enableLDAPbind", "b"), ("enableLDAP", "b"), ("enableHesiodbind", "b"),
		("enableHesiod", "b"), ("enableDBIbind", "b"), ("enableDBbind", "b"),
		("enableCompat", "b"), ("enableWINS", "b"), ("enableMDNS", "b"), ("enableMyhostname", "b"),
		("enableNIS3", "b"), ("enableNIS", "b"), ("enableIPAv2", "b"),
		("enableSSSD", "b"), ("preferDNSinHosts", "b"), ("implicitSSSD", "b")]),
	SaveGroup(self.writePAM, None, [("pwqualityArgs", "c"), ("passwdqcArgs", "c"),
		("faillockArgs", "c"), ("enableFaillock", "b"),
		("localuserArgs", "c"), ("pamAccessArgs", "c"), ("enablePAMAccess", "b"),
		("mkhomedirArgs", "c"), ("enableMkHomeDir", "b"), ("algoRounds", "c"),
		("passwordAlgorithm", "i"), ("enableShadow", "b"), ("enableNIS", "b"),
		("enableNullOk", "b"), ("forceBrokenShadow", "b"), ("enableLDAPAuth", "b"),
		("enableKerberos", "b"), ("enableSmartcard", "b"), ("forceSmartcard", "b"),
		("enableWinbindAuth", "b"), ("enableMkHomeDir", "b"), ("enableAFS", "b"),
		("enableAFSKerberos", "b"), ("enablePWQuality", "b"), ("enableEPS", "b"),
		("enableEcryptfs", "b"), ("enableOTP", "b"), ("enablePasswdQC", "b"),
		("enableLocAuthorize", "b"), ("enableSysNetAuth", "b"),
		("winbindOffline", "b"), ("winbindKrb5", "b"),
		("enableSSSDAuth", "b"), ("enableFprintd", "b"), ("pamLinked", "b"),
		("implicitSSSDAuth", "b"), ("systemdArgs", "c"), ("uidMin", "i"), ("enableIPAv2", "b")]),
	SaveGroup(self.writeSysconfig, None, [("passwordAlgorithm", "i"), ("enableShadow", "b"), ("enableNIS", "b"),
		("enableLDAP", "b"), ("enableLDAPAuth", "b"), ("enableKerberos", "b"),
		("enableEcryptfs", "b"), ("enableSmartcard", "b"), ("forceSmartcard", "b"),
		("enableWinbindAuth", "b"), ("enableWinbind", "b"), ("winbindKrb5", "b"), ("enableDB", "b"),
		("enableHesiod", "b"), ("enablePWQuality", "b"), ("enablePasswdQC", "b"),
		("enableFaillock", "b"), ("faillockArgs", "c"),
		("enableLocAuthorize", "b"), ("enablePAMAccess", "b"), ("enableCacheCreds", "b"),
		("enableMkHomeDir", "b"), ("enableSysNetAuth", "b"), ("enableFprintd", "b"),
		("enableSSSD", "b"), ("enableSSSDAuth", "b"), ("enableForceLegacy", "b"),
		("ipav2Server", "i"), ("ipav2Domain", "i"), ("ipav2Realm", "c"),
		("enableIPAv2", "b"), ("ipaDomainJoined", "b"), ("ipav2NoNTP", "b")]),
	SaveGroup(self.writeNetwork, None, [("nisDomain", "c")]),
	SaveGroup(self.toggleShadow, None, [("enableShadow", "b")]),
	SaveGroup(None, self.toggleNisService, [("enableNIS", "b")]),
	SaveGroup(None, self.toggleOddjobService, [("enableMkHomeDir", "b")]),
	SaveGroup(None, self.toggleLDAPService, [("enableLDAP", "b"), ("enableLDAPAuth", "b"),
		("implicitSSSD", "b"), ("implicitSSSDAuth", "b"), ("enableForceLegacy", "b")]),
	SaveGroup(None, self.toggleSSSDService, [("implicitSSSD", "b"), ("implicitSSSDAuth", "b"),
		("enableIPAv2", "b"), ("enableSSSD", "b"), ("enableSSSDAuth", "b"), ("enableForceLegacy", "b")]),
	SaveGroup(None, self.toggleWinbindService, [("enableWinbind", "b"), ("enableWinbindAuth", "b")])]

	def setParam(self, attr, value, ref):
		oldval = getattr(self, attr)
		if oldval != value:
			setattr(self, attr, value)
			if oldval != getattr(ref, attr):
				self.inconsistentAttrs.append(attr)

        def setIntParam(self, attr, value, ref):
                try:
                        value = int(value)
                except ValueError:
                        return
                return self.setParam(attr, str(value), ref)

        def setClassReqParam(self, attr, value, ref):
                try:
                        value = int(value)
                except ValueError:
                        return
                if value < 0:
                        return self.setParam(attr, True, ref)
                return self.setParam(attr, False, ref)

	def sssdSupported(self):
		if self.enableForceLegacy or not self.sssdConfig:
			return False
		# we just ignore things which have no support on command line
		nssall = ('NIS', 'LDAP', 'Winbind', 'Hesiod', 'IPAv2')
		pamall = ('Kerberos', 'LDAPAuth', 'WinbindAuth', 'Smartcard')
		idsupported = ('LDAP')
		authsupported = ('Kerberos', 'LDAPAuth')
		num = 0
		for t in nssall:
			if getattr(self, 'enable'+t):
				if t not in idsupported:
					return False
				num += 1
		if num != 1:
			return False
		num = 0
		for t in pamall:
			if getattr(self, 'enable'+t):
				if t not in authsupported:
					return False
				num += 1
		if num != 1:
			return False
		# realm via DNS is not supported by the current SSSD
		if self.enableKerberos and self.kerberosRealmviaDNS:
			return False
		return True

	# Read hesiod setup.  Luckily, /etc/hesiod.conf is simple enough that shvfile
	# can read it just fine.
	def readHesiod(self, ref):
		# Open the file.  Bail if it's not there.
		try:
			shv = shvfile.read(all_configs[CFG_HESIOD].origPath)
		except IOError:
			return False

		# Read the LHS.
		self.setParam("hesiodLHS", snipString(shv.getValue("lhs")), ref)

		# Read the RHS.
		self.setParam("hesiodRHS", snipString(shv.getValue("rhs")), ref)

		shv.close()
		return True

	# Read NIS setup from /etc/yp.conf.
	def readNIS(self, ref):
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_YP].origPath, "r")
		except IOError:
			return False

		nisserver = ""
		for line in f:
			line = line.strip()

			# Is it a "ypserver" statement?  If so, extract the server.
			value = matchKey(line, "ypserver")
			if value and self.nisLocalDomain:
				# Save the server's name.
				nisserver = commaAppend(nisserver, value)
				continue

			# It had better be a "domain" statement, because the man page
			# for this file states that this is all there is.
			value = matchKey(line, "domain")
			if value:
				# Save the domain's name.  To do that, find its end.
				value = value.split(None, 1)
				if len(value) < 1:
					continue
				if value[0] != self.nisLocalDomain:
					continue
				if len(value) < 2:
					continue
				value = value[1]

				# Is it "server"?  If not, assume "broadcast".
				value = matchKey(value, "server")
				if value:
					nisserver = commaAppend(nisserver, value)

		self.setParam("nisServer", nisserver, ref)
		f.close()
		return True

	def validateLDAPURI(self, s):
		"""
		Check whether LDAP URI is valid.
		"""
		if ',' in s:
			uris = s.split(',')
		else:
			uris = s.split()
		for uri in uris:
			try:
				p = urlparse.urlparse(uri).port
			except (ValueError, socket.error):
				return False
		return True

	def ldapHostsToURIs(self, s, validate):
		if ',' in s:
			l = s.split(',')
		else:
			l = s.split()
		ret = ""
		for item in l:
			if item:
				if ret:
					ret += ","
				if "://" in item:
					ret += item
				else:
					ret += "ldap://" + item + "/"
		if validate and not self.validateLDAPURI(ret):
			self.messageCB(_("Invalid LDAP URI."))
		return ret

	# Read LDAP setup from /etc/ldap.conf.
	def readLDAP(self, ref):
		self.ldapCacertDir = PATH_LDAP_CACERTS
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_NSSLDAP].origPath, "r")
		except IOError:
			try:
				f = open(all_configs[CFG_NSLCD].origPath, "r")
			except IOError:
				try:
					f = open(all_configs[CFG_PAMLDAP].origPath, "r")
				except IOError:
					try:
						f = open(all_configs[CFG_LDAP].origPath, "r")
					except IOError:
						return False

		for line in f:
			line = line.strip()

			# Is it a "base" statement?
			value = matchKey(line, "base")
			if value and checkDN(value):
				# Save the base DN.
				self.setParam("ldapBaseDN", value, ref)
				continue
			# Is it a "host" statement?
			value = matchKey(line, "host")
			if value:
				# Save the host name or IP.
				self.setParam("ldapServer", value, ref)
				continue
			# Is it a "uri" statement?
			value = matchKey(line, "uri")
			if value:
				# Save the host name or IP.
				self.setParam("ldapServer", value, ref)
				continue
			# Is it a "ssl" statement?
			value = matchKey(line, "ssl")
			if value:
				self.setParam("enableLDAPS", matchLine(value, "start_tls"), ref)
				continue
			# Is it a "nss_schema" statement?
			value = matchKey(line, "nss_schema")
			if value:
				self.setParam("ldapSchema", value, ref)
				continue
			# We'll pull MD5/DES crypt ("pam_password") from the config
			# file, or from the pam_unix PAM config lines.

		self.ldapServer = self.ldapHostsToURIs(cleanList(self.ldapServer), False)
		f.close()
		return True

	# Read Kerberos setup from /etc/krb5.conf.
	def getKerberosKDC(self, realm):
		try:
			return self.allKerberosKDCs[realm]
		except KeyError:
			return ""

	def getKerberosAdminServer(self, realm):
		try:
			return self.allKerberosAdminServers[realm]
		except KeyError:
			return ""

	def readKerberos(self, ref):
		section = ""
		self.allKerberosKDCs = {}
		self.allKerberosAdminServers = {}
		realm_found = False
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_KRB5].origPath, "r")
		except IOError:
			return False
	
		for line in f:
			line = line.split('#')[0]
			line = line.strip()

			# If it's a new section, note which one we're "in".
			if line[0:1] == "[":
				section = line[1:-1]
				subsection = ""
				continue;

			if section == "libdefaults":
				# Check for the default realm setting.
				value = matchKeyEquals(line, "default_realm")
				if value:
					self.setParam("kerberosRealm", value, ref)
					realm_found = True;
					continue;
				# Check for the DNS settings.
				value = matchKeyEquals(line, "dns_lookup_kdc")
				if value:
					self.setParam("kerberosKDCviaDNS", matchKey(value, "true") == "", ref)
					continue
				value = matchKeyEquals(line, "dns_lookup_realm")
				if value:
					self.setParam("kerberosRealmviaDNS", matchKey(value, "true") == "", ref)
					continue;

			elif section == "realms":
				if not subsection:
					# Read the name of the realm.
					value = line.split(None,1)
					if len(value) < 1:
						continue
					subsection = value[0]
				# Check for the end of a realm section.
				else:
					if line[0:1] == "}":
						subsection = ""
						continue
					if not self.kerberosRealm:
						# No reason to use setParam here
						self.kerberosRealm = subsection
						realm_found = True;
					# See if this is a key we care about.
					value = matchKeyEquals(line, "kdc")
					if value:
						self.allKerberosKDCs[subsection] = commaAppend(self.getKerberosKDC(subsection), value)
						continue
					value = matchKeyEquals(line, "admin_server")
					if value:
						self.allKerberosAdminServers[subsection] = commaAppend(self.getKerberosAdminServer(subsection), value)
		f.close()
		if realm_found:
			if self.kerberosRealm:
				self.setParam("kerberosKDC", self.getKerberosKDC(self.kerberosRealm), ref)
				self.setParam("kerberosAdminServer", self.getKerberosAdminServer(self.kerberosRealm), ref)
		else:
			if self.kerberosRealm:
				self.inconsistentAttrs.append("kerberosRealm")
			else:
				self.setParam("kerberosRealm", "", ref)
		return True

	def readLibuser(self, ref):
		section = ""
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_LIBUSER].origPath, "r")
		except IOError:
			return False
	
		for line in f:
			line = line.strip()

			# If it's a new section, note which one we're "in".
			if line[0:1] == "[":
				section = line[1:-1]
				subsection = ""
				continue;

			if section == "defaults":
				# Check for the crypt style setting.
				value = matchKeyEquals(line, "crypt_style")
				if value:
					self.setParam("passwordAlgorithm", value.lower(), ref)
					continue;
		f.close()
		return True

	def readLogindefs(self, ref):
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_LOGIN_DEFS].origPath, "r")
		except IOError:
			return False

		for line in f:
			match = ld_line_re.match(line)
			if match is not None:
				name = match.group(1)
				if name.startswith('#'):
					continue
				value = match.group(3)
				if value is None:
					value = match.group(4)
				if value is None:
					value = ''
			else:
				continue
			if name == "MD5_CRYPT_ENAB" and value == "yes":
				self.setParam("passwordAlgorithm", "md5", ref)
				continue
			if name == "ENCRYPT_METHOD":
				if value == "DES":
					value = "descrypt"
				self.setParam("passwordAlgorithm", value.lower(), ref)
				continue
			if name == "UID_MIN":
				self.setParam("uidMin", value, ref)
		f.close()
		return True

	def readPWQuality(self, ref):
		section = ""
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_PWQUALITY].origPath, "r")
		except IOError:
			return False
	
		for line in f:
                        line = line.split('#')[0]
			line = line.strip()

			# Check for the settings that interest us.
			value = matchKeyEquals(line, "minlen")
			if value:
				self.setIntParam("passMinLen", value, ref)
				continue;
			value = matchKeyEquals(line, "minclass")
			if value:
				self.setIntParam("passMinClass", value, ref)
				continue;
			value = matchKeyEquals(line, "maxrepeat")
			if value:
				self.setIntParam("passMaxRepeat", value, ref)
				continue;
			value = matchKeyEquals(line, "maxclassrepeat")
			if value:
				self.setIntParam("passMaxClassRepeat", value, ref)
				continue;
			value = matchKeyEquals(line, "lcredit")
			if value:
				self.setClassReqParam("passReqLower", value, ref)
				continue;
			value = matchKeyEquals(line, "ucredit")
			if value:
				self.setClassReqParam("passReqUpper", value, ref)
				continue;
			value = matchKeyEquals(line, "dcredit")
			if value:
				self.setClassReqParam("passReqDigit", value, ref)
				continue;
			value = matchKeyEquals(line, "ocredit")
			if value:
				self.setClassReqParam("passReqOther", value, ref)
				continue;
		f.close()
		return True

	def readSSSD(self, ref):
		if not self.sssdConfig:
			return True
		self.sssdConfig = SSSDConfig.SSSDConfig()
		try:
			self.sssdConfig.import_config(all_configs[CFG_SSSD].origPath)
			self.sssdConfigPresent = True
		except (IOError, SSSDConfig.ParsingError):
			self.sssdConfig = SSSDConfig.SSSDConfig()
			self.sssdConfig.new_config()
		try:
			domain = self.sssdDomain = self.sssdConfig.get_domain(SSSD_AUTHCONFIG_DOMAIN)
		except SSSDConfig.NoDomainError:
			try:
				domname = self.sssdConfig.list_active_domains()[0]
			except IndexError:
				try:
					domname = self.sssdConfig.list_domains()[0]
				except IndexError:
					return True
			domain = self.sssdConfig.get_domain(domname)
			try:
				idprov = domain.get_option('id_provider')
			except SSSDConfig.NoOptionError:
				idprov = None
			try:
				authprov = domain.get_option('auth_provider')
			except SSSDConfig.NoOptionError:
				authprov = None
		for (attr, opt) in sssd_options:
			try:
				val = domain.get_option(opt)
				if opt == 'ldap_uri':
					val = " ".join(val.split(","))
				elif opt == 'ldap_schema' and val == 'rfc2307':
					continue
				elif opt == 'krb5_store_password_if_offline':
					continue
				self.setParam(attr, val, ref)
			except SSSDConfig.NoOptionError:
				pass

	def readSmartcard(self, ref):
		lock = False
		smartcardmodule = callPKCS11Setup(["use_module"])
		if smartcardmodule == None:
			self.smartcardModule = ""
			return False
		self.setParam("smartcardModule", smartcardmodule[0], ref)
		rmactions = callPKCS11Setup(["rm_action"])
		if rmactions == None:
			return False
		for action in rmactions:
			if "lockhelper.sh" in action:
				lock = True
		if lock:
			self.setParam("smartcardAction", _("Lock"), ref)
		else:
			self.setParam("smartcardAction", _("Ignore"), ref)
		return True

	# Read Samba setup from /etc/samba/smb.conf.
	def readWinbindGlobal(self, key):
		result = ""
		section = ""
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		try:
			f = open(all_configs[CFG_SMB].origPath, "r")
		except IOError:
			return result

		for line in f:
			line = line.strip()
			# Skip comments.
			if matchLine(line, "#"):
				continue
			if matchLine(line, ";"):
				continue
			# If it's a new section, note which one we're "in".
			value = matchKey(line, "[")
			if value:
				section = value.split("]")[0].lower()
				continue
			# Check for global settings.  Anything else we can skip.
			if not section or section != "global":
				continue
			# Check for a match with the requested setting name.
			res = matchLineSMB(line, key)
			if res:
				result = res
		f.close()
		return result
	
	def readWinbindGlobalBool(self, key):
		tmp = self.readWinbindGlobal(key)
		if tmp:
			if tmp.lower() == "yes" or tmp.lower() == "true" or tmp == "1":
				return True
			else:
				return False
		return None

	# Read winbind settings from /etc/samba/smb.conf.
	def readWinbind(self, ref):
		tmp = self.readWinbindGlobal("workgroup")
		if tmp:
			self.setParam("smbWorkgroup", tmp, ref)

		tmp = self.readWinbindGlobal("password server")
		if tmp:
			self.setParam("smbServers", tmp, ref)
		tmp = self.readWinbindGlobal("realm")
		if tmp:
			self.setParam("smbRealm", tmp, ref)
		tmp = self.readWinbindGlobal("security")
		if tmp:
			self.setParam("smbSecurity", tmp, ref)
		if not self.smbSecurity:
			self.smbSecurity = "user"
		tmp = self.readWinbindGlobal("idmap config * : range")
		if tmp:
			self.setParam("smbIdmapRange", tmp, ref)
		if not self.smbIdmapRange:
			# 2^24 to 2^25 - 1 should be safe
			self.smbIdmapRange = "16777216-33554431"
		tmp = self.readWinbindGlobal("winbind separator")
		if tmp:
			self.setParam("winbindSeparator", tmp, ref)
		tmp = self.readWinbindGlobal("template homedir")
		if tmp:
			self.setParam("winbindTemplateHomedir", tmp, ref)
		tmp = self.readWinbindGlobal("template shell")
		if tmp:
			self.setParam("winbindTemplateShell", tmp, ref)
		if not self.winbindTemplateShell:
			self.winbindTemplateShell = "/bin/false"
		tmp = self.readWinbindGlobalBool("winbind use default domain")
		if tmp != None:
			self.setParam("winbindUseDefaultDomain", tmp, ref)
		tmp = self.readWinbindGlobalBool("winbind offline logon")
		if tmp != None:
			self.setParam("winbindOffline", tmp, ref)

		return True

	# Read NSS setup from /etc/nsswitch.conf.
	def readNSS(self, ref):
		# Open the file.  Bail if it's not there or there's some problem
		# reading it.
		nssconfig = ""
		initgroups = ""

		try:
			f = open(all_configs[CFG_NSSWITCH].origPath, "r")
		except IOError:
			return False

		for line in f:
			line = line.strip()

			value = matchKey(line, "passwd:")
			if value:
				nssconfig = value
			else:
				# wins can be found in hosts only
				value = matchKey(line, "hosts:")
				if value:
					if checkNSS(value, "wins"):
						self.setParam("enableWINS", True, ref)
					if checkNSS(value, "mdns4_minimal [NOTFOUND=return]"):
						self.setParam("enableMDNS", True, ref)
					if checkNSS(value, "myhostname"):
						self.setParam("enableMyhostname", True, ref)

					nispos = checkNSS(value, "nis")
					if nispos == None:
						nispos = checkNSS(value, "wins")
					dnspos = checkNSS(value, "dns")
					if nispos != None and dnspos != None:
						self.setParam("preferDNSinHosts", dnspos < nispos, ref)
				else:
					value = matchKey(line, "initgroups:")
					if value:
						initgroups = value

		if nssconfig:
			nssmap = (('Compat', 'compat'), ('DB', 'db'),
				  ('Directories', 'directories'), ('Hesiod', 'hesiod'),
				  ('LDAP', 'ldap'), ('NIS', 'nis'), ('Altfiles', 'altfiles'),
				  ('NIS3', 'nisplus'), ('Winbind', 'winbind'))
			for attr, nssentry in nssmap:
				if checkNSS(nssconfig, nssentry):
					self.setParam('enable' + attr, True, ref)
			if initgroups and checkNSS(nssconfig, 'sss') and not checkNSS(initgroups, 'sss'):
				self.inconsistentAttrs.append('implicitSSSD')

			self.setParam("implicitSSSD", bool(checkNSS(nssconfig, "sss")), ref)
		f.close()
		return True

	# Read whether or not caching is enabled.
	def readCache(self, ref):
		self.setParam("enableCache", readCache(), ref)
		return True

	# Read hints from the PAM control file.
	def readPAM(self, ref):
		# Open the system-auth file.  Bail if it's not there or
		# there's some problem reading it.
		try:
			f = open(all_configs[CFG_PAM].origPath, "r")
		except IOError:
			try:
				f = open(SYSCONFDIR+"/pam.d/"+AUTH_PAM_SERVICE, "r")
			except IOError:
				return False

		self.readPAMFile(ref, f)
		f.close()

		# Open the postlogin file.  It's ok if it's not there.
		try:
			f = open(all_configs[CFG_POSTLOGIN_PAM].origPath, "r")
		except IOError:
			try:
				f = open(SYSCONFDIR+"/pam.d/"+POSTLOGIN_PAM_SERVICE, "r")
			except IOError:
				return True

		self.readPAMFile(ref, f)
		f.close()
		return True

	def readPAMFile(self, ref, f):
		prevline = ""
		for line in f:
			lst = line.split("#", 1)
			if len(lst) > 1:
				line = lst[0]
				
			line = line.rstrip()
			# Join lines ending with "\\"
			if line[-1:] == "\\":
				prevline += line[:-1] + " "
				continue
			line = prevline + line
			prevline = ""
			line = line.lstrip()
			
			args = ""

			lst = line.split(None, 1)
			if len(lst) < 2:
				continue
			(stack, line) = lst

			if (stack != "auth" and stack != "account"
				and stack != "password" and stack != "session"):
				continue

			if line.startswith("["):
				lst = line.split("]", 1)
			else:
				lst = line.split(None, 1)

			if len(lst) < 2:
				continue
			
			if lst[0] == "include":
				continue

			control = lst[0]
			if control.startswith("["):
				control += "]"

			line = lst[1]

			lst = line.split(None, 1)
			
			if len(lst) < 1:
				continue
			(module,) = lst[0].split("/")[-1:]

			if len(lst) == 2:
				args = lst[1]

			if module.startswith("pam_cracklib") or module.startswith("pam_pwquality"):
				self.setParam("enablePWQuality", True, ref)
				if args:
					self.setParam("pwqualityArgs", args, ref)
				continue
			if module.startswith("pam_ecryptfs"):
				self.setParam("enableEcryptfs", True, ref)
				continue
			if module.startswith("pam_krb5"):
				self.setParam("enableKerberos", True, ref)
				continue
			if module.startswith("pam_ldap"):
				self.setParam("enableLDAPAuth", True, ref)
				continue
			if module.startswith("pam_pkcs11"):
				self.setParam("enableSmartcard", True, ref)
				if "authinfo_unavail" not in control:
					self.setParam("forceSmartcard", True, ref)
				else:
					self.setParam("forceSmartcard", False, ref)
				continue
			if module.startswith("pam_fprintd"):
				self.setParam("enableFprintd", True, ref)
				continue
			if module.startswith("pam_passwdqc"):
				self.setParam("enablePasswdQC", True, ref)
				if args:
					self.setParam("passwdqcArgs", args, ref)
				continue
			if module.startswith("pam_winbind"):
				self.setParam("enableWinbindAuth", True, ref)
				self.setParam("winbindKrb5", args.find("krb5_auth") >= 0, ref)
				continue
			if module.startswith("pam_sss"):
				self.setParam("implicitSSSDAuth", True, ref)
				continue
			if module.startswith("pam_access"):
				self.setParam("enablePAMAccess", True, ref)
				if args:
					self.setParam("pamAccessArgs", args, ref)
				continue
			if module.startswith("pam_mkhomedir") or module.startswith("pam_oddjob_mkhomedir"):
				self.setParam("enableMkHomeDir", True, ref)
				if args:
					# first place where we are setting them
					self.mkhomedirArgs = args
				continue
			if module.startswith("pam_localuser"):
				self.setParam("enableLocAuthorize", True, ref)
				if args:
					self.setParam("localuserArgs", args, ref)
				continue
			if module.startswith("pam_systemd"):
				if args:
					self.setParam("systemdArgs", args, ref)
				continue
			if stack == "password":
				if module.startswith("pam_unix"):
					for algo in password_algorithms:
						if args.find(algo) >= 0:
							self.setParam("passwordAlgorithm", algo, ref)
					try:
						ridx = args.index("rounds=")
						rounds = args[ridx+7:].split(None,1)
						self.setParam("algoRounds", str(int(rounds[0])), ref)
					except (ValueError, IndexError):
						pass
					try:
						os.stat("/etc/shadow")
						self.setParam("enableShadow", True, ref)
					except OSError:
						self.setParam("enableShadow", False, ref)
			if stack == "auth":
				if module.startswith("pam_unix"):
					self.setParam("enableNullOk", args.find("nullok") >= 0, ref)
				if module.startswith("pam_faillock"):
					self.setParam("enableFaillock", True, ref)
					if args and 'authfail' in args:
						args = args.replace('authfail', '').strip()
						self.setParam("faillockArgs", args, ref)
					continue
			if stack == "account":
				if module.startswith("pam_unix"):
					self.setParam("brokenShadow", args.find("broken_shadow") >= 0, ref)
			if stack == "auth" or stack == "account":
				if module.startswith("pam_succeed_if"):
					match = succ_if_re.match(args)
					if match != None and match.group(2) != None:
						self.setParam("uidMin", match.group(2), ref)

		# Special handling for pam_pwquality and pam_passwdqc: there can be
		# only one.
		if self.enablePWQuality and self.enablePasswdQC:
			self.setParam("enablePasswdQC", False, ref)
		if not self.enablePWQuality and not self.enablePasswdQC:
			self.setParam("enablePWQuality", True, ref)

		# Special handling for broken_shadow option
		if (self.brokenShadow and not self.enableLDAPAuth and
			not self.enableKerberos and not self.enableWinbindAuth and
			not self.enableSSSDAuth and not self.enableSmartcard):
			self.forceBrokenShadow = True

	def readSysconfig(self):
		# Read settings from our config file, which provide defaults for anything we
		# figure out by examination.
		# We do not use setParam here as sysconfig is the default and read first
		try:
			shv = shvfile.read(all_configs[CFG_AUTHCONFIG].origPath)

			try:
				self.enableAFS = shv.getBoolValue("USEAFS")
			except ValueError:
				pass
			try:
				self.enableAFSKerberos = shv.getBoolValue("USEAFSKERBEROS")
			except ValueError:
				pass
			try:
				self.enableDB = shv.getBoolValue("USEDB")
			except ValueError:
				pass
			try:
				self.enablePWQuality = shv.getBoolValue("USEPWQUALITY")
			except ValueError:
				pass
			try:
				self.enableDBbind = shv.getBoolValue("USEDBBIND")
			except ValueError:
				pass
			try:
				self.enableDBIbind = shv.getBoolValue("USEDBIBIND")
			except ValueError:
				pass
			try:
				self.enableDirectories = shv.getBoolValue("USEDIRECTORIES")
			except ValueError:
				pass
			try:
				self.enableFaillock = shv.getBoolValue("USEFAILLOCK")
				self.faillockArgs = shv.getValue("FAILLOCKARGS")
			except ValueError:
				pass
			try:
				self.enableEcryptfs = shv.getBoolValue("USEECRYPTFS")
			except ValueError:
				pass
			try:
				self.enableEPS = shv.getBoolValue("USEEPS")
			except ValueError:
				pass
			try:
				self.enableHesiod = shv.getBoolValue("USEHESIOD")
			except ValueError:
				pass
			try:
				self.enableHesiodbind = shv.getBoolValue("USEHESIODBIND")
			except ValueError:
				pass
			try:
				self.enableKerberos = shv.getBoolValue("USEKERBEROS")
			except ValueError:
				pass
			try:
				self.enableLDAP = shv.getBoolValue("USELDAP")
			except ValueError:
				pass
			try:
				self.enableLDAPAuth = shv.getBoolValue("USELDAPAUTH")
			except ValueError:
				pass
			try:
				self.enableSmartcard = shv.getBoolValue("USESMARTCARD")
			except ValueError:
				pass
			try:
				self.enableFprintd = shv.getBoolValue("USEFPRINTD")
			except ValueError:
				pass
			try:
				self.forceSmartcard = shv.getBoolValue("FORCESMARTCARD")
			except ValueError:
				pass
			try:
				self.enableLDAPbind = shv.getBoolValue("USELDAPBIND")
			except ValueError:
				pass
			try:
				enableMD5 = shv.getBoolValue("USEMD5")
				if enableMD5:
					self.passwordAlgorithm = 'md5'
				else:
					self.passwordAlgorithm = 'descrypt'
			except ValueError:
				pass
			try:
				self.enableNIS = shv.getBoolValue("USENIS")
			except ValueError:
				pass
			try:
				self.enableNISP3 = shv.getBoolValue("USENISPLUS")
			except ValueError:
				pass
			try:
				self.enableOdbcbind = shv.getBoolValue("USEODBCBIND")
			except ValueError:
				pass
			try:
				self.enableOTP = shv.getBoolValue("USEOTP")
			except ValueError:
				pass
			try:
				self.enablePasswdQC = shv.getBoolValue("USEPASSWDQC")
			except ValueError:
				pass
			try:
				self.enableShadow = shv.getBoolValue("USESHADOW")
			except ValueError:
				pass
			try:
				self.enableWinbind = shv.getBoolValue("USEWINBIND")
			except ValueError:
				pass
			try:
				self.enableWinbindAuth = shv.getBoolValue("USEWINBINDAUTH")
			except ValueError:
				pass
			try:
				self.winbindKrb5 = shv.getBoolValue("WINBINDKRB5")
			except ValueError:
				pass
			try:
				self.enableSSSD = shv.getBoolValue("USESSSD")
			except ValueError:
				pass
			try:
				self.enableSSSDAuth = shv.getBoolValue("USESSSDAUTH")
			except ValueError:
				pass
			try:
				self.enableLocAuthorize = shv.getBoolValue("USELOCAUTHORIZE")
			except ValueError:
				pass
			try:
				self.enablePAMAccess = shv.getBoolValue("USEPAMACCESS")
			except ValueError:
				pass
			try:
				self.enableMkHomeDir = shv.getBoolValue("USEMKHOMEDIR")
			except ValueError:
				pass
			try:
				self.enableSysNetAuth = shv.getBoolValue("USESYSNETAUTH")
			except ValueError:
				pass
			try:
				self.enableForceLegacy = shv.getBoolValue("FORCELEGACY")
			except ValueError:
				pass
			try:
				self.enableCacheCreds = shv.getBoolValue("CACHECREDENTIALS")
			except ValueError:
				pass
			try:
				self.enableIPAv2 = shv.getBoolValue("USEIPAV2")
			except ValueError:
				pass
			try:
				self.ipaDomainJoined = shv.getBoolValue("IPADOMAINJOINED")
			except ValueError:
				pass
			try:
				self.ipav2NoNTP = shv.getBoolValue("IPAV2NONTP")
			except ValueError:
				pass
			self.ipav2Server = shv.getValue("IPAV2SERVER")
			self.ipav2Domain = shv.getValue("IPAV2DOMAIN")
			self.ipav2Realm = shv.getValue("IPAV2REALM")
			algo = shv.getValue("PASSWDALGORITHM")
			if algo in password_algorithms:
				self.passwordAlgorithm = algo
			shv.close()
		except IOError:
			pass
		return True

	# Read hints from the network control file.
	def readNetwork(self, ref):
		# Open the file.  Bail if it's not there.
		try:
			shv = shvfile.read(all_configs[CFG_NETWORK].origPath)
		except IOError:
			return False

		tmp = shv.getValue("NISDOMAIN")
		if tmp:
			self.nisLocalDomain = tmp

		shv.close()

		if self.nisLocalDomain:
			self.setParam("nisDomain", self.nisLocalDomain, ref)

		return True

	# Compare two authInfoType structures and return True if they have any
	# meaningful differences.
	def differs(self, b):
		sssdsupported = self.sssdSupported()
		if bool(b.implicitSSSD) != sssdsupported or bool(b.implicitSSSDAuth) != sssdsupported:
			return True

		# There is slight inefficiency in that a few of the attributes
		# are duplicated in the save groups, but better than maintain
		# the whole list at two places.
		for group in self.save_groups:
			if group.attrsDiffer(self, b):
				return True
		return False

	# There's some serious strangeness in here, because we get called in two
	# different-but-closely-related scenarios.  The first case is when we're
	# initializing the authInfo structure and we want to fill in defaults with
	# suggestions we "know".  The second case is when the user has just made a
	# change to one field and we need to update another field to somehow
	# compensate for the change.
	def update(self, validate=False):
		self.smbServers = cleanList(self.smbServers)
		self.ipav2Server = cleanList(self.ipav2Server)
		self.kerberosKDC = cleanList(self.kerberosKDC)
		self.kerberosAdminServer = cleanList(self.kerberosAdminServer)
		self.ldapServer = self.ldapHostsToURIs(self.ldapServer, validate)
		if self.smbSecurity == "ads":
			# As of this writing, an ADS implementation always
			# upper-cases the realm name, even if only internally,
			# and we need to reflect that in the krb5.conf file.
			if self.smbRealm:
				self.smbRealm = self.smbRealm.upper()
		self.passwordAlgorithm = self.passwordAlgorithm.lower()
		if self.enableCacheCreds == None:
			self.enableCacheCreds = True # enabled by default
		if self.kerberosRealm == None:
			self.kerberosRealm = ""

	def read(self):
		ref = self.copy()
		self.readSysconfig()
		self.readNSS(ref)
		self.readLibuser(ref)
		self.readPAM(ref)

		reallyimplicit = self.sssdSupported()
		if self.implicitSSSD and not reallyimplicit and not self.enableIPAv2:
			self.setParam("enableSSSD", True, ref)
			self.implicitSSSD = False
		if self.implicitSSSDAuth and not reallyimplicit and not self.enableIPAv2:
			self.setParam("enableSSSDAuth", True, ref)
			self.implicitSSSDAuth = False

		self.readLogindefs(ref)
                self.readPWQuality(ref)
		self.readHesiod(ref)
		self.readWinbind(ref)
		self.readNetwork(ref)
		self.readNIS(ref)
		# if SSSD not implicitely enabled
		if not self.implicitSSSD and not self.implicitSSSDAuth:
			self.readSSSD(ref)
		self.readLDAP(ref)
		self.readKerberos(ref)
		if self.implicitSSSD or self.implicitSSSDAuth:
			self.readSSSD(ref)
		self.readSmartcard(ref)
		self.readCache(ref)

		self.update()


	def copy(self):
		ret = copy.copy(self)
		ret.joinUser = ""
		ret.joinPassword = ""
		return ret

	def writeCache(self):
		all_configs[CFG_CACHE].backup(self.backupDir)
		writeCache(self.enableCache and not self.implicitSSSD)
		return True

	def writeHesiod(self):
		all_configs[CFG_HESIOD].backup(self.backupDir)
		try:
			shv = shvfile.rcreate(all_configs[CFG_HESIOD].origPath)
		except IOError:
			return False
		shv.setValue("lhs", self.hesiodLHS)
		shv.setValue("rhs", self.hesiodRHS)

		shv.write(0644)
		shv.close()

		return True

	# Write NIS setup to /etc/yp.conf.
	def writeNIS(self):
		written = False
		f = None
		output = ""
		all_configs[CFG_YP].backup(self.backupDir)
		try:
			f = SafeFile(all_configs[CFG_YP].origPath, 0644)

			# Read in the old file.
			for line in f.file:
				ls = line.strip()
				
				value = matchKey(ls, "domain")
				if value:
					# Save the domain's name.  To do that, find its end.
					value = value.split(None, 1)
					if len(value) < 1:
						continue
					if value[0] != self.nisDomain and value[0] != self.nisLocalDomain:
						# The domain name doesn't match current or previous domain
						output += line
						continue
 
					if not written and self.nisDomain:
						output += "domain " + self.nisDomain
						# Take an empty server name to mean that we
						# want to use broadcast.
						servers = self.nisServer.split(",")
						if self.nisServer:
							output += " server "
							output += servers[0]
						else:
							output += " broadcast"
						output += "\n"

						servers = servers[1:]
						for s in servers:
							if s:
								output += "ypserver " + s + "\n"

						written = True
				elif matchLine(ls, "ypserver"):
					# If it's a 'ypserver' line, insert ours instead.
					if not written and not self.nisDomain and self.nisServer:
						servers = self.nisServer.split(",")
						for s in servers:
							if s:
								output += "ypserver " + s + "\n"

						written = True
				else:
					# Otherwise, just copy the current line out.
					output += line

			# If we haven't encountered a domain line yet...
			if not written:
				servers = self.nisServer.split(",")
				if self.nisDomain:
					output += "domain " + self.nisDomain
					# Take an empty server name to mean that we
					# want to use broadcast.
					if servers[0]:
						output += " server "
						output += servers[0]
						servers = servers[1:]
					else:
						output += " broadcast"
					output += "\n"

				for s in servers:
					if s:
						output += "ypserver " + s + "\n"
			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	# Write LDAP setup to an ldap.conf using host and base as keys.
	def writeLDAP2(self, filename, uri, host, base, writepadl, writeschema, writepam):
		wrotebasedn = False
		wroteserver = False
		wrotessl = False
		wroteschema = False
		wrotepass = False
		wrotecacertdir = False
		f = None
		output = ""
		if (self.passwordAlgorithm and self.passwordAlgorithm != "descrypt" and
			self.passwordAlgorithm != "bigcrypt"):
			passalgo = "md5"
		else: 
			passalgo = "crypt"
		try:
			f = SafeFile(filename, 0644)

			# Read in the old file.
			for line in f.file:
				ls = line.strip()
				# If it's a 'uri' line, insert ours instead.
				if matchLine(ls, uri):
					if not wroteserver and self.ldapServer:
						output += uri + " " 
						output += " ".join(self.ldapServer.split(","))
						output += "\n"
						wroteserver = True
				# If it's a 'host' line, comment it out.
				elif matchLine(ls, host):
					if self.ldapServer:
						output += "#" + line 
				elif matchBaseLine(ls, base):
					# If it's a 'base' line, insert ours instead.
					if not wrotebasedn and self.ldapBaseDN:
						output += base + " "
						output += self.ldapBaseDN
						output += "\n"
						wrotebasedn = True
				elif writepadl and matchLine(ls, "ssl"):
					# If it's an 'ssl' line, insert ours instead.
					if not wrotessl:
						output += "ssl "
						if self.enableLDAPS:
							output += "start_tls"
						else:
							output += "no"
						output += "\n"
						wrotessl = True
				elif writeschema and matchLine(ls, "nss_schema"):
					# If it's an 'nss_schema' line, insert ours instead.
					if not wroteschema and self.ldapSchema:
						output += "nss_schema "
						output += self.ldapSchema
						output += "\n"
						wroteschema = True
				elif matchLineI(ls, "tls_cacertdir"):
					# If it's an 'tls_cacertdir' line, insert ours instead.
					if not wrotecacertdir:
						if writepadl:
							output += "tls_cacertdir"
						else:
							output += "TLS_CACERTDIR"
						output += " " + self.ldapCacertDir
						output += "\n"
						wrotecacertdir = True
				elif writepam and matchLine(ls, "pam_password"):
					# If it's a 'pam_password' line, write the correct setting.
					if not wrotepass:
						output += "pam_password " + passalgo
						output += "\n"
						wrotepass = True
				else:
					# Otherwise, just copy the current line out.
					output += line

			# If we haven't encountered either of the config lines yet...
			if not wroteserver and self.ldapServer:
				output += uri + " " 
				output += " ".join(self.ldapServer.split(","))
				output += "\n"
			if not wrotebasedn and self.ldapBaseDN:
				output += base + " "
				output += self.ldapBaseDN
				output += "\n"
			if writepadl and not wrotessl:
				output += "ssl "
				if self.enableLDAPS:
					output += "start_tls"
				else:
					output += "no"
				output += "\n"
			if writeschema and not wroteschema and self.ldapSchema:
				output += "nss_schema "
				output += self.ldapSchema
				output += "\n"
			if not wrotecacertdir:
				if writepadl:
					output += "tls_cacertdir"
				else:
					output += "TLS_CACERTDIR"
				output += " " + self.ldapCacertDir
				output += "\n"
			if writepam and not wrotepass:
				output += "pam_password " + passalgo
				output += "\n"
			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	def writeLDAP(self):
		if os.path.isfile(all_configs[CFG_LDAP].origPath):
			all_configs[CFG_LDAP].backup(self.backupDir)
			self.writeLDAP2(all_configs[CFG_LDAP].origPath,
					"uri", "host", "base", True, True, True)
		if os.path.isfile(all_configs[CFG_NSSLDAP].origPath):
			all_configs[CFG_NSSLDAP].backup(self.backupDir)
			self.writeLDAP2(all_configs[CFG_NSSLDAP].origPath,
					"uri", "host", "base", True, True, False)
		if os.path.isfile(all_configs[CFG_PAMLDAP].origPath):
			all_configs[CFG_PAMLDAP].backup(self.backupDir)
			self.writeLDAP2(all_configs[CFG_PAMLDAP].origPath,
					"uri", "host", "base", True, False, True)
		if os.path.isfile(all_configs[CFG_NSLCD].origPath):
			all_configs[CFG_NSLCD].backup(self.backupDir)
			self.writeLDAP2(all_configs[CFG_NSLCD].origPath,
					"uri", "host", "base", True, False, False)
		all_configs[CFG_OPENLDAP].backup(self.backupDir)
		ret = self.writeLDAP2(all_configs[CFG_OPENLDAP].origPath,
					"URI", "HOST", "BASE", False, False, False)
		return ret

	def cryptStyle(self):
		ret = "crypt_style = "
		if self.passwordAlgorithm == "md5":
			return ret + "md5"
		elif self.passwordAlgorithm == "sha256" or self.passwordAlgorithm == "sha512":
			return ret + self.passwordAlgorithm
		else:
			return ret + "des"

	# Write libuser's password algo setting to /etc/libuser.conf.
	def writeLibuser(self):
		wrotecryptstyle = False
		wrotedefaults = False
		section = ""
		f = None
		output = ""
		all_configs[CFG_LIBUSER].backup(self.backupDir)
		try:
			f = SafeFile(all_configs[CFG_LIBUSER].origPath, 0644)

			# Read in the old file.
			for line in f.file:
				ls = line.strip()

				# If this is the "crypt_style" in the defaults section,
				# replace it with the values we now have.
				if section == "defaults" and matchLine(ls, "crypt_style"):
					output += self.cryptStyle() + "\n"
					wrotecryptstyle = True
					continue

				# If it's the beginning of a section, record its name.
				if matchLine(ls, "["):
					# If the previous section was "defaults", and we didn't
					# see the crypt_style setting , write it out.
					if section == "defaults" and not wrotecryptstyle:
						output += self.cryptStyle() + "\n"
						wrotecryptstyle = True
					section = ls[1:].split("]", 1)[0]
					if section == "defaults":
						wrotedefaults = True

				output += line

			# If we haven't encountered a defaults section yet...
			if not wrotedefaults:
				output += "[defaults]\n"
				output += self.cryptStyle() + "\n"
				wrotedefaults = True
				wrotecryptstyle = True
			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	# Write shadow utils password algo setting to /etc/login.defs.
	def writeLogindefs(self):
		wrotemd5crypt = False
		wroteencmethod = False
		section = ""
		f = None
		output = ""
		all_configs[CFG_LOGIN_DEFS].backup(self.backupDir)

		if self.passwordAlgorithm == "md5":
			md5crypt = "MD5_CRYPT_ENAB yes\n"
		else:
			md5crypt = "MD5_CRYPT_ENAB no\n"

		if self.passwordAlgorithm == "descrypt" or self.passwordAlgorithm =="bigcrypt":
			encmethod = "ENCRYPT_METHOD DES\n"
		else:
			encmethod = "ENCRYPT_METHOD " + self.passwordAlgorithm.upper() + "\n"
		try:
			f = SafeFile(all_configs[CFG_LOGIN_DEFS].origPath, 0644)

			# Read in the old file.
			for line in f.file:
				match = ld_line_re.match(line)
				if match is not None:
					name = match.group(1)
					if name.startswith('#'):
						output += line
						continue
					value = match.group(3)
					if value is None:
						value = match.group(4)
					if value is None:
						value = ''
				else:
					output += line
					continue

				if name == "MD5_CRYPT_ENAB":
					output += md5crypt
					wrotemd5crypt = True
					continue

				if name == "ENCRYPT_METHOD":
					output += encmethod
					wroteencmethod = True
					continue

				output += line

			# If we haven't encountered a defaults section yet...
			if not wrotemd5crypt:
				output += md5crypt
			if not wroteencmethod:
				output += encmethod
			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

        def formatClassReqParam(self, line, value):
                ls = line.split('=')
                if len(ls) <= 1:
                        ls = line.split(' ')
                if len(ls) > 1:
                        try:
                                oldval = int(ls[1])
                                if value == None:
                                        return line
                                if value and oldval >= 0:
                                        return ls[0] + " = -1"
                                if not value and oldval < 0:
                                        return ls[0] + " = 0"
                        except ValueError:
                                pass
                if value:
                        value = "-1"
                else:
                        value = "0"
                return ls[0] + " = " + value

	# Write pwquality password requirements settings to /etc/security/pwquality.conf.
	def writePWQuality(self):
		wroteminlen = False
                wroteminclass = False
                wrotemaxrepeat = False
                wrotemaxclassrepeat = False
                wrotereqlower = False
                wroterequpper = False
                wrotereqdigit = False
                wrotereqother = False
		f = None
		output = ""
		all_configs[CFG_PWQUALITY].backup(self.backupDir)
		try:
			f = SafeFile(all_configs[CFG_PWQUALITY].origPath, 0644)

			# Read in the old file.
			for line in f.file:
				ls = line.split('#')[0].strip()

				if matchLine(ls, "minlen"):
                                        if not wroteminlen:
        					output += "minlen = " + self.passMinLen + "\n"
	        				wroteminlen = True
					continue
				if matchLine(ls, "minclass"):
                                        if not wroteminclass:
        					output += "minclass = " + self.passMinClass + "\n"
	        				wroteminclass = True
					continue
				if matchLine(ls, "maxrepeat"):
                                        if not wrotemaxrepeat:
        					output += "maxrepeat = " + self.passMaxRepeat + "\n"
	        				wrotemaxrepeat = True
					continue
				if matchLine(ls, "maxclassrepeat"):
                                        if not wrotemaxclassrepeat:
        					output += "maxclassrepeat = " + self.passMaxClassRepeat + "\n"
	        				wrotemaxclassrepeat = True
					continue
				if matchLine(ls, "lcredit"):
                                        if not wrotereqlower:
        					output += self.formatClassReqParam(ls, self.passReqLower) + "\n"
	        				wrotereqlower = True
					continue
				if matchLine(ls, "ucredit"):
                                        if not wroterequpper:
        					output += self.formatClassReqParam(ls, self.passReqUpper) + "\n"
	        				wroterequpper = True
					continue
				if matchLine(ls, "dcredit"):
                                        if not wrotereqdigit:
        					output += self.formatClassReqParam(ls, self.passReqDigit) + "\n"
        					wrotereqdigit = True
					continue
				if matchLine(ls, "ocredit"):
                                        if not wrotereqother:
        					output += self.formatClassReqParam(ls, self.passReqOther) + "\n"
	        				wrotereqother = True
					continue

				output += line

                        if not wroteminlen:
        			output += "minlen = " + self.passMinLen + "\n"
                        if not wroteminclass:
				output += "minclass = " + self.passMinClass + "\n"
                        if not wrotemaxrepeat:
				output += "maxrepeat = " + self.passMaxRepeat + "\n"
                        if not wrotemaxclassrepeat:
				output += "maxclassrepeat = " + self.passMaxClassRepeat + "\n"
                        if not wrotereqlower:
        			output += self.formatClassReqParam("lcredit", self.passReqLower) + "\n"
                        if not wroterequpper:
				output += self.formatClassReqParam("ucredit", self.passReqUpper) + "\n"
                        if not wrotereqdigit:
        		        output += self.formatClassReqParam("dcredit", self.passReqDigit) + "\n"
                        if not wrotereqother:
				output += self.formatClassReqParam("ocredit", self.passReqOther) + "\n"

			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	# Write Kerberos 5 setup to /etc/krb5.conf.
	def writeKerberos(self):
		wroterealm = False
		wrotekdc = False
		wroteadmin = False
		wrotesmbrealm = False
		wrotesmbkdc = False
		wroterealms = False
		wrotelibdefaults = False
		wroterealms2 = False
		wrotelibdefaults2 = False
		wrotedefaultrealm = False
		wrotednsrealm = False
		wrotednskdc = False
		wroteourdomrealm = False
		wrotedomrealm = False
		wrotedomrealm2 = False
		# No dir -> no incdir line, set as if already written
		wroteincdir = not os.access(PATH_KRB5_INCLUDEDIR, os.R_OK)		
		section = ""
		subsection = ""
		f = None
		output = ""
		all_configs[CFG_KRB5].backup(self.backupDir)
		if self.enableKerberos and self.kerberosRealm:
			defaultrealm = self.kerberosRealm
		elif (self.enableWinbind or 
			self.enableWinbindAuth) and self.smbSecurity == "ads" and self.smbRealm:
			defaultrealm = self.smbRealm
		else:
			defaultrealm = self.kerberosRealm
		if self.kerberosRealm == self.smbRealm:
			wrotesmbrealm = True
		try:
			f = SafeFile(all_configs[CFG_KRB5].origPath, 0644)

			# Read in the old file.
			for line in f.file:
				ls = line.strip()

				if matchLine(ls, "includedir " + PATH_KRB5_INCLUDEDIR):
					if not wroteincdir:
						wroteincdir = True
					else:
						# already written or should be removed
						continue
				# If this is the "kdc" in our realm, replace it with
				# the values we now have.
				if (section == "realms" and subsection and subsection == self.kerberosRealm
					and matchLine(ls, "kdc")):
					if not wrotekdc:
						if self.kerberosKDC:
							output += krbKdc(self.kerberosKDC)
						wrotekdc = True
					continue
				# If this is the "kdc" in the SMB realm, replace it with
				# the values we now have.
				if (section == "realms" and self.smbSecurity == "ads" and subsection
					and subsection == self.smbRealm and matchLine(ls, "kdc")):
					if not wrotesmbkdc:
						if self.smbServers:
							output += krbKdc(self.smbServers)
						wrotesmbkdc = True
					continue
				# If this is the "admin_server" in our realm, replace it with
				# the values we now have.
				if (section == "realms" and subsection and subsection == self.kerberosRealm
					and matchLine(ls, "admin_server")):
					if not wroteadmin:
						if self.kerberosAdminServer:
							output += krbAdminServer(self.kerberosAdminServer)
						wroteadmin = True
					continue
				# If we're in the realms section, but not in a realm, we'd
				# better be looking at the beginning of one.
				if section == "realms" and not subsection:
					# Read the name of the realm.
					value = ls.split(None,1)
					if len(value) < 1:
						output += line
						continue
					subsection = value[0]
					# If this is the section for our realm, mark
					# that.
					if self.kerberosRealm and subsection == self.kerberosRealm:
						wroterealm = True
					if self.smbRealm and subsection == self.smbRealm:
						wrotesmbrealm = True
				# If it's the end of a subsection, mark that.
				if section == "realms" and subsection and matchLine(ls, "}"):
					# If it's the right section of realms, write out
					# info we haven't already written.
					if self.kerberosRealm and subsection == self.kerberosRealm:
						if not wrotekdc:
							output += krbKdc(self.kerberosKDC)
							wrotekdc = True
						if not wroteadmin:
							output += krbAdminServer(self.kerberosAdminServer)
							wroteadmin = True
					if self.smbRealm and subsection == self.smbRealm:
						if not wrotesmbkdc:
							output += krbKdc(self.smbServers)
							wrotesmbkdc = True
					subsection = ""
				# If we're in the libdefaults section, and this is the
				# default_realm keyword, replace it with ours.
				if section == "libdefaults" and matchLine(ls, "default_realm"):
					if defaultrealm and not wrotedefaultrealm:
						output += " default_realm = "
						output += defaultrealm
						output += "\n"
						wrotedefaultrealm = True
					continue
				if section == "libdefaults" and matchLine(ls, "dns_lookup_realm"):
					if not wrotednsrealm:
						output += " dns_lookup_realm = "
						output += str(bool(self.kerberosRealmviaDNS)).lower()
						output += "\n"
						wrotednsrealm = True
					continue
				if section == "libdefaults" and matchLine(ls, "dns_lookup_kdc"):
					if not wrotednskdc:
						output += " dns_lookup_kdc = "
						output += str(bool(self.kerberosKDCviaDNS)).lower()
						output += "\n"
						wrotednskdc = True
					continue
				# don't change the domain_realm mapping if it's already there
				if section == "domain_realm" and self.kerberosRealm and (matchLine(ls, self.kerberosRealm.lower())
					or matchLine(ls, "."+self.kerberosRealm.lower())):
					output += line
					wroteourdomrealm = True
					continue
				# If it's the beginning of a section, record its name.
				if matchLine(ls, "["):
					if not wroteincdir:
						output += "includedir " + PATH_KRB5_INCLUDEDIR + "\n"
						wroteincdir = True
					# If the previous section was "realms", and we didn't
					# see ours, write our realm out.
					if (section == "realms" and self.kerberosRealm
						and not wroterealm):
						output += krbRealm(self.kerberosRealm,
							self.kerberosKDC,
							self.kerberosAdminServer)
						wroterealm = True
					# If the previous section was "realms", and we didn't
					# see the SMB realm, write it out.
					if (section == "realms" and self.smbRealm
						and not wrotesmbrealm):
						output += krbRealm(self.smbRealm,
							self.smbServers, "")
						wrotesmbrealm = True
					# If the previous section was "libdefaults", and we
					# didn't see a "default_realm", write it out.
					if section == "libdefaults":
						if defaultrealm and not wrotedefaultrealm:
							output += " default_realm = "
							output += defaultrealm
							output +=  "\n"
							wrotedefaultrealm = True
						if self.kerberosRealmviaDNS != None and not wrotednsrealm:
							output += " dns_lookup_realm = "
							output += str(bool(self.kerberosRealmviaDNS)).lower()
							output += "\n"
							wrotednsrealm = True
						if self.kerberosKDCviaDNS != None and not wrotednskdc:
							output += " dns_lookup_kdc = "
							output += str(bool(self.kerberosKDCviaDNS)).lower()
							output += "\n"
							wrotednskdc = True
					if section == "domain_realm":
						if self.kerberosRealm and not wroteourdomrealm:
							output += " " + self.kerberosRealm.lower()
							output += " = " + self.kerberosRealm
							output +=  "\n"
							output += " ." + self.kerberosRealm.lower()
							output += " = " + self.kerberosRealm
							output +=  "\n"
							wroteourdomrealm = True
					if section:
						if section == "realms":
							wroterealms2 = True
						elif section == "libdefaults":
							wrotelibdefaults2 = True
						elif section == "domain_realm":
							wrotedomrealm2 = True
					section = ls[1:].split("]", 1)[0]
					if section == "realms":
						wroterealms = True
					elif section == "libdefaults":
						wrotelibdefaults = True
					elif section == "domain_realm":
						wrotedomrealm = True

				# Otherwise, just copy the current line out.
				output += line

			# If we haven't encountered a libdefaults section yet...
			if not wrotelibdefaults2:
				if not wrotelibdefaults:
					output += "[libdefaults]\n"
				if defaultrealm and not wrotedefaultrealm:
					output += " default_realm = "
					output += defaultrealm
					output +=  "\n"
				if self.kerberosRealmviaDNS != None and not wrotednsrealm:
					output += " dns_lookup_realm = "
					output += str(bool(self.kerberosRealmviaDNS)).lower()
					output += "\n"
				if self.kerberosKDCviaDNS != None and not wrotednskdc:
					output += " dns_lookup_kdc = "
					output += str(bool(self.kerberosKDCviaDNS)).lower()
					output += "\n"
			# If we haven't encountered a realms section yet...
			if not wroterealms2 and (self.kerberosRealm or self.smbRealm):
				if not wroterealms:
					output += "[realms]\n"
				if not wroterealm:
					output += krbRealm(self.kerberosRealm, self.kerberosKDC,
						self.kerberosAdminServer)
				if not wrotesmbrealm:
					output += krbRealm(self.smbRealm, self.smbServers, "")
			if not wrotedomrealm2 and self.kerberosRealm:
				if not wrotedomrealm:
					output += "[domain_realm]\n"
				if self.kerberosRealm and not wroteourdomrealm:
					output += " " + self.kerberosRealm.lower()
					output += " = " + self.kerberosRealm
					output +=  "\n"
					output += " ." + self.kerberosRealm.lower()
					output += " = " + self.kerberosRealm
					output +=  "\n"

			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	def changeProvider(self, domain, newprovider, subtype):
		try:
			prov = domain.get_option(subtype + '_provider')
		except SSSDConfig.NoOptionError:
			prov = None
		if prov != newprovider:
			if prov != None:
				domain.remove_provider(subtype)
			domain.add_provider(newprovider, subtype)

	def writeSSSDPAM(self, write_config):
		if not self.sssdConfig:
			return True
		
		if not self.sssdConfigPresent and not self.implicitSSSD:
			# do not write to sssd.conf since the file does not exist yet and
			# we are not creating the domain ourselves
			return True

		try:
			pam = self.sssdConfig.get_service('pam')
		except SSSDConfig.NoServiceError:
			pam = self.sssdConfig.new_service('pam')

		if self.enableSmartcard and self.enableSSSDAuth and self.smartcardModule == "sssd" :
			pam.set_option('pam_cert_auth', 'True')
		else:
			try:
				pam.remove_option('pam_cert_auth')
			except SSSDConfig.NoOptionError:
				pass

		self.sssdConfig.save_service(pam)
		if write_config:
			try:
				self.sssdConfig.write(all_configs[CFG_SSSD].origPath)
			except IOError:
				pass

		return True

	def writeSSSD(self):
		if not self.sssdConfig:
			return True

		all_configs[CFG_SSSD].backup(self.backupDir)
		
		# do not write to the file yet since we will write all changes at ones
		self.writeSSSDPAM(False)

		if self.enableIPAv2:
			# just save the backup
			return True

		if not self.sssdDomain:
			if not self.implicitSSSD:
				# do not create a domain that would be incomplete anyway
				return True
			try:
				self.sssdDomain = self.sssdConfig.new_domain(SSSD_AUTHCONFIG_DOMAIN)
			except SSSDConfig.DomainAlreadyExistsError:
				self.sssdDomain = self.sssdConfig.get_domain(SSSD_AUTHCONFIG_DOMAIN)
		domain = self.sssdDomain

		try:
			self.sssdConfig.get_service('autofs')
		except SSSDConfig.NoServiceError:
			self.sssdConfig.new_service('autofs')
		self.sssdConfig.activate_service('autofs')

		activate = False
		if self.enableLDAP:
			activate = True
			self.changeProvider(domain, 'ldap', 'id')
			self.changeProvider(domain, 'ldap', 'autofs')
		if self.enableKerberos:
			self.changeProvider(domain, 'krb5', 'auth')
			self.changeProvider(domain, 'krb5', 'chpass')
		elif self.enableLDAPAuth:
			self.changeProvider(domain, 'ldap', 'auth')
			self.changeProvider(domain, 'ldap', 'chpass')

		for (attr, option) in sssd_options:
			try:
				val = getattr(self, attr)
				if option == 'ldap_uri':
					val = cleanList(val)
				if type(val) == bool:
					domain.set_option(option, val)
				elif type(val) == str:
					if val:
						domain.set_option(option, val)
					else:
						domain.remove_option(option)
				else:
					domain.remove_option(option)
			except SSSDConfig.NoOptionError:
				pass
		self.sssdConfig.save_domain(domain)

		if activate:
			self.sssdConfig.activate_domain(domain.get_name())
		else:
			self.sssdConfig.deactivate_domain(domain.get_name())

		try:
			self.sssdConfig.write(all_configs[CFG_SSSD].origPath)
		except IOError:
			pass
		return True

	def writeSmartcard(self):
		if self.smartcardModule == None:
			# pam_pkcs11 not installed
			return True
		all_configs[CFG_PAM_PKCS11].backup(self.backupDir)
		insact = "/usr/sbin/gdm-safe-restart"
		rmact = "/usr/sbin/gdm-safe-restart"
		lock = "none"
		if self.smartcardAction == _("Lock"):
			insact += ",/etc/pkcs11/lockhelper.sh -lock"
			rmact += ",/etc/pkcs11/lockhelper.sh -deactivate"
			lock = "lock_screen"

		callPKCS11Setup(["use_module="+self.smartcardModule,
			"ins_action="+insact, "rm_action="+rmact])
		return True

	def writeDConf(self):
		f = None
		output = ""
		locks = ""

		all_configs[CFG_DCONF].backup(self.backupDir)
		all_configs[CFG_DCONF_LOCKS].backup(self.backupDir)

		# create the dconf directories if needed
		locksdir = os.path.dirname(all_configs[CFG_DCONF_LOCKS].origPath)
		if not os.path.isdir(locksdir):
			if self.enableSmartcard:
				os.makedirs(locksdir)
			else:
				# smart cards not enabled - ignore
				return True

		header = "# Generated by authconfig on " + time.strftime("%Y/%m/%d %H:%M:%S") + "\n"
		groupHeader = "\n[org/gnome/login-screen]\n"
		if not self.enableSmartcard or not self.smartcardModule:
			output += header
			header = ""
			output += groupHeader
			groupHeader =""
			output += "enable-smartcard-authentication=false\n"
			locks += "/org/gnome/login-screen/enable-smartcard-authentication"

		if self.enableSmartcard and self.forceSmartcard:
			output += header
			header = ""
			output += groupHeader
			groupHeader =""
			output += "enable-password-authentication=false\n"
			locks += "/org/gnome/login-screen/enable-password-authentication\n"

		if not self.enableFprintd or (self.enableSmartcard and self.smartcardModule and self.forceSmartcard):
			output += header
			header = ""
			output += groupHeader
			groupHeader =""
			output += "enable-fingerprint-authentication=false\n"
			locks += "/org/gnome/login-screen/enable-fingerprint-authentication\n"

		groupHeader = "\n[org/gnome/settings-daemon/peripherals/smartcard]\n"
		if self.smartcardAction == _("Lock"):
			output += header
			header = ""
			output += groupHeader
			groupHeader =""
			output += "removal-action='lock-screen'\n"
			locks += "/org/gnome/settings-daemon/peripherals/smartcard\n"

		try:
			os.unlink(all_configs[CFG_DCONF].origPath)
		except OSError:
			pass
		try:
			os.unlink(all_configs[CFG_DCONF_LOCKS].origPath)
		except OSError:
			pass

		if locks != "":
			try:
				f = SafeFile(all_configs[CFG_DCONF].origPath, 0644)
				f.rewind()
				f.write(output)
				f.save()
			finally:
				try:
					if f:
						f.close()
				except IOError:
					pass

			try:
				f = SafeFile(all_configs[CFG_DCONF_LOCKS].origPath, 0644)
				f.rewind()
				f.write(locks)
				f.save()
			finally:
				try:
					if f:
						f.close()
				except IOError:
					pass

		os.system("dconf update")
		return True

	def paramsWinbind(self):
		output =  "#--authconfig--start-line--\n"
		output += "\n"
		output += "# Generated by authconfig on " + time.strftime("%Y/%m/%d %H:%M:%S") + "\n"
		output += "# DO NOT EDIT THIS SECTION (delimited by --start-line--/--end-line--)\n"
		output += "# Any modification may be deleted or altered by authconfig in future\n"
		output += "\n"

		if self.smbWorkgroup:
			output += "   workgroup = "
			output += self.smbWorkgroup
			output += "\n"
		if self.smbServers:
			output += "   password server = "
			output += self.smbServers.replace(",", " ")
			output += "\n"
		if self.smbRealm:
			output += "   realm = "
			output += self.smbRealm
			output += "\n"
		if self.smbSecurity:
			output += "   security = "
			output += self.smbSecurity
			output += "\n"
		if self.smbIdmapRange:
			output += "   idmap config * : range = "
			output += self.smbIdmapRange
			output += "\n"
		if self.winbindSeparator:
			output += "   winbind separator = "
			output += self.winbindSeparator
			output += "\n"
		if self.winbindTemplateHomedir:
			output += "   template homedir = "
			output += self.winbindTemplateHomedir
			output += "\n"
		if self.winbindTemplateShell:
			output += "   template shell = "
			output += self.winbindTemplateShell
			output += "\n"
		if self.winbindKrb5:
			output += "   kerberos method = secrets and keytab"
			output += "\n"
		else:
			output += "   kerberos method = secrets only"
			output += "\n"
		output += "   winbind use default domain = "
		output += str(bool(self.winbindUseDefaultDomain)).lower()
		output += "\n"
		output += "   winbind offline logon = "
		output += str(bool(self.winbindOffline)).lower()
		output += "\n"

		output += "\n"
		output += "#--authconfig--end-line--\n"

		return output

	def checkLineWinbind(self, line, ls, options):
		output = ""

		# Check if this is a setting we care about.
		for opt in options:
			if matchLineSMB(ls, opt):
				output = ";"
				break

		output += line
		return output;

	# Write winbind settings to /etc/samba/smb.conf.
	def writeWinbind(self):
		authsection = False
		wroteauthsection = False
		section = ""
		all_configs[CFG_SMB].backup(self.backupDir)
		options = ["workgroup", "password server", "realm", "security",
			   "domain logons", "domain master",
			   "idmap uid", "idmap gid", "winbind separator", "template homedir",
			   "template shell", "winbind use default domain",
			   "winbind offline logon", "kerberos method"]
		f = None
		output = ""
		try:
			f = SafeFile(all_configs[CFG_SMB].origPath, 0644)

			# Read in the old file.
			for line in f.file:
				ls = line.strip()

				if authsection:
					if matchLine(ls, "#--authconfig--end-line--"):
						authsection = False
					#skip all previous authconfig generated lines
					continue

				if matchLine(ls, "#--authconfig--start-line--"):
					authsection = True
					continue

				# If it's a comment, just pass it through.
				if matchLine(ls, ";") or matchLine(ls, "#"):
					output += line
					continue

				# If it's a section start, note the section name.
				value = matchKey(ls, "[")
				if value and "]" in value:

					section = value.split("]")[0].lower()

					output += line
					if section == "global":
						output += self.paramsWinbind()
						wroteauthsection = True

					continue

				# Comment out options we set.
				if section == "global":
					output += self.checkLineWinbind(line, ls, options)
					continue

				# Copy anything else as is.
				output += line

			if not wroteauthsection:
				output += "[global]\n"
				output += self.paramsWinbind()

			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	# Write NSS setup to /etc/nsswitch.conf.
	def writeNSS(self):
		users = ""
		normal = ""
		hosts = ""
		wrotepasswd = False
		wrotegroup = False
		wroteshadow = False
		wrotenetgroup = False
		wroteautomount = False
		wrotehosts = False
		wroteinitgroups = False
		wroteservices = False
		f = None
		output = ""
		all_configs[CFG_NSSWITCH].backup(self.backupDir)
		try:
			f = SafeFile(all_configs[CFG_NSSWITCH].origPath, 0644)

			# Determine what we want in that file for most of the databases. If
			# we're using DB, we're doing it for speed, so put it in first.  Then
			# comes files.  Then everything else in reverse alphabetic order.
			if self.enableDB:
				normal += " db"
			normal += " files"
                        if self.enableAltfiles:
                                normal += " altfiles"
			services = normal
			if self.enableDirectories:
				normal += " directories"
			if self.enableOdbcbind:
				normal += " odbcbind"
			if self.enableNIS3:
				normal += " nisplus"
			if self.enableNIS:
				normal += " nis"
			if self.enableSSSD or self.implicitSSSD or self.enableIPAv2:
				normal += " sss"
				services += " sss"
			if self.enableLDAPbind:
				normal += " ldapbind"
			if self.enableLDAP and not self.implicitSSSD:
				normal += " ldap"
			if self.enableHesiodbind:
				normal += " hesiodbind"
			if self.enableHesiod:
				normal += " hesiod"
			if self.enableDBIbind:
				normal += " dbibind"
			if self.enableDBbind:
				normal += " dbbind"

			netgroup = normal

			# Generate the list for users and groups.  The same as most other
			# services, just use "compat" instead of "files" if "compat" is
			# enabled.
			if self.enableCompat:
				users = normal.replace("files", "compat")
			else:
				users = normal

			if self.enableWinbind:
				users += " winbind"

			if not os.access(PATH_LIBSSS_AUTOFS, os.R_OK):
				# No support for automount in sssd
				if self.enableLDAP and self.implicitSSSD:
					normal = normal.replace("sss", "ldap")
				else:
					normal = normal.replace(" sss", "")

			# Hostnames we treat specially.
			hosts += " files"
			if self.enableMDNS:
				hosts += " mdns4_minimal [NOTFOUND=return]"
			if self.preferDNSinHosts:
				hosts += " dns"
			if self.enableWINS:
				hosts += " wins"
			if self.enableNIS3:
				hosts += " nisplus"
			if self.enableNIS:
				hosts += " nis"
			if not self.preferDNSinHosts:
				hosts += " dns"
			if self.enableMyhostname:
				hosts += " myhostname"

			# Read in the old file.
			for line in f.file:
				ls = line.strip()

				# If it's a 'passwd' line, insert ours instead.
				if matchLine(ls, "passwd:"):
					if not wrotepasswd:
						output += "passwd:    "
						output += users
						output += "\n"
						wrotepasswd = True

				# If it's a 'shadow' line, insert ours instead.
				elif matchLine(ls, "shadow:"):
					if not wroteshadow:
						output += "shadow:    "
						output += users
						output += "\n"
						wroteshadow = True
				# If it's a 'group' line, insert ours instead.
				elif matchLine(ls, "group:"):
					if not wrotegroup:
						output += "group:     "
						output += users
						output += "\n"
						wrotegroup = True
				# If it's a 'initgroups' line, comment it out instead.
				elif matchLine(ls, "initgroups:"):
					if not wroteinitgroups:
						output += "#"
						output += line
						wroteinitgroups = True
				# If it's a 'netgroup' line, insert ours instead.
				elif matchLine(ls, "netgroup:"):
					if not wrotenetgroup:
						output += "netgroup:  "
						output += netgroup
						output += "\n"
						wrotenetgroup = True
				# If it's a 'automount' line, insert ours instead.
				elif matchLine(ls, "automount:"):
					if not wroteautomount:
						output += "automount: "
						output += normal
						output += "\n"
						wroteautomount = True
				# If it's a 'hosts' line, insert ours instead.
				elif matchLine(ls, "hosts:"):
					if not wrotehosts:
						output += "hosts:     "
						output += hosts
						output += "\n"
						wrotehosts = True
				# If it's a 'services' line, insert ours instead.
				elif matchLine(ls, "services:"):
					if not wroteservices:
						output += "services:  "
						output += services
						output += "\n"
						wroteservices = True
				# Otherwise, just copy the current line out.
				else:
					output += line

			# If we haven't encountered any of the config lines yet...
			if not wrotepasswd:
				output += "passwd:    "
				output += users
				output += "\n"
			if not wroteshadow:
				output += "shadow:    "
				output += users
				output += "\n"
			if not wrotegroup:
				output += "group:     "
				output += users
				output += "\n"
			if not wrotenetgroup:
				output += "netgroup:  "
				output += netgroup
				output += "\n"
			if not wroteautomount:
				output += "automount: "
				output += normal
				output += "\n"
			if not wrotehosts:
				output += "hosts:     "
				output += hosts
				output += "\n"
			if not wroteservices:
				output += "services:  "
				output += services
				output += "\n"
			# For now we do not write initgroups
			# line if not encountered.

			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass
		return True

	def formatPAMModule(self, module, forcescard, warn):
		stack = pam_stacks[module[STACK]]
		logic = module[LOGIC]
		name = module[NAME]
		output = ""
		if stack and logic:
			args = ""
			if name == "pkcs11" and stack == "auth":
				if forcescard:
					if self.enableKerberos:
						logic = LOGIC_FORCE_PKCS11_KRB5
					else:
						logic = LOGIC_FORCE_PKCS11
					args = " ".join(argv_force_pkcs11_auth)
				else:
					if self.enableKerberos:
						logic = LOGIC_PKCS11_KRB5
			if name == "krb5" and stack == "account":
				if self.enableSmartcard:
					logic = LOGIC_IGNORE_AUTH_ERR
				else:
					logic = LOGIC_IGNORE_UNKNOWN
			if name == "succeed_if":
				if stack == "auth" and logic == LOGIC_SKIPNEXT:
					if self.enableKerberos:
						logic = LOGIC_SKIPNEXT3
				elif stack == "auth" or stack == "account":
					if self.uidMin != None:
						argv = module[ARGV][0:] # shallow copy
						argv[1] = self.uidMin
						args = " ".join(argv)
			# do not continue to following modules if authentication fails
			if name == "unix" and stack == "auth" and (self.enableSSSDAuth or
				self.implicitSSSDAuth or self.enableIPAv2) and (not self.enableNIS):
				logic = LOGIC_SUFFICIENT
			# use oddjob_mkhomedir if available
			if name == "mkhomedir" and os.access("%s/pam_%s.so"
				% (AUTH_MODULE_DIR, "oddjob_mkhomedir"), os.X_OK):
				name = "oddjob_mkhomedir"
			# the missing pam_systemd module should not be logged as error
			if name == "systemd":
				output += "-"
				warn = False
			output += "%-12s%-13s pam_%s.so" % (stack, logic,
				name)
			if warn and not name in self.module_missing and not os.access("%s/pam_%s.so"
				% (AUTH_MODULE_DIR, name), os.X_OK):
				self.messageCB(_("Authentication module %s/pam_%s.so is missing. Authentication process might not work correctly." %
					(AUTH_MODULE_DIR, name)))
				self.module_missing[name] = True
			if name == "pwquality":
				args = self.pwqualityArgs
			if name == "passwdqc":
				args = self.passwdqcArgs
			if name == "localuser":
				args = self.localuserArgs
			if name == "access":
				args = self.pamAccessArgs
			if name == "mkhomedir" or name =="oddjob_mkhomedir":
				args = self.mkhomedirArgs
			if name == "systemd":
				args = self.systemdArgs
			if name == "sss" and stack == "auth" and not self.enableNIS and not module[ARGV] == argv_sssd_missing_name:
				args = "forward_pass"
			if not args and module[ARGV]:
				args = " ".join(module[ARGV])
			if name == "winbind" and self.winbindOffline and stack != "password":
				output += " cached_login"
			if name == "winbind" and self.winbindKrb5:
				output += " krb5_auth krb5_ccache_type=KEYRING"
			if name == "unix":
				if stack == "password":
					if self.passwordAlgorithm and self.passwordAlgorithm != "descrypt":
						output += " " + self.passwordAlgorithm
					if self.algoRounds:
						output += " rounds=" + self.algoRounds
					if self.enableShadow:
						output +=  " shadow"
					if self.enableNIS:
						output += " nis"
					if self.enableNullOk:
						output += " nullok"
				if stack == "auth":
					if self.enableNullOk:
						output += " nullok"
				if stack == "account":
					if (self.forceBrokenShadow or self.enableLDAPAuth or
						self.enableKerberos or self.enableWinbindAuth):
						output += " broken_shadow"
			if name == "faillock" and stack == "auth":
				args = " ".join(module[ARGV]) + " " + self.faillockArgs
			if name == "succeed_if" and stack == "auth" and logic == LOGIC_SKIPNEXT_ON_FAILURE:
				args = args.replace("quiet_success", "quiet")
			if args:
				output += " " + args
		output += "\n"
		return output

	def linkPAMService(self, src, dest):
		f = os.path.isfile(dest)
		l = os.path.islink(dest)
		if (f and not l) or (l and not f):
			# Create the link only if it doesn't exist yet or is invalid
			try:
				os.unlink(dest)
			except OSError:
				pass
			try:
				os.symlink(src, dest)
			except OSError:
				pass

	def checkPAMLinked(self):
		for dest in [AUTH_PAM_SERVICE, POSTLOGIN_PAM_SERVICE, PASSWORD_AUTH_PAM_SERVICE,
                                FINGERPRINT_AUTH_PAM_SERVICE, SMARTCARD_AUTH_PAM_SERVICE]:
			dest = SYSCONFDIR + "/pam.d/" + dest
			f = os.path.isfile(dest)
			l = os.path.islink(dest)
			if (f and not l) or (l and not f):
				self.pamLinked = False
				return

	def writePAMService(self, service, cfg, cfg_basename, cfg_link):
		f = None
		output = ""
		all_configs[cfg].backup(self.backupDir)
		try:
			f = SafeFile(all_configs[cfg].origPath, 0644)

			output += "#%PAM-1.0\n"
			output += "# This file is auto-generated.\n"
			output += "# User changes will be destroyed the next time "
			output += "authconfig is run.\n"

			forceSmartcard = self.forceSmartcard
			enableSmartcard = self.enableSmartcard
			enableFprintd = self.enableFprintd
			warn = False
			if service == STANDARD:
				warn = True
			if service == FINGERPRINT:
				enableFprintd = True
			elif service == SMARTCARD:
				enableSmartcard = True
				forceSmartcard = True

			# configure SSSD Smartcard support instead of
			# pam_pkcs11 if SSSD is used for authentication and no
			# Smartcard module is set, e.g. if pam_pkcs11 is not installed.
			use_sssd_smartcard_support = self.enableSSSDAuth and self.smartcardModule == "sssd"
			prevmodule = []
			for module in pam_modules[service]:
				if prevmodule and module[STACK] != prevmodule[STACK]:
					output += "\n"
				prevmodule = module
				if (module[MANDATORY] or
					(self.enableAFS and module[NAME] == "afs") or
					(self.enableAFSKerberos and module[NAME] == "afs.krb") or
					(self.enablePWQuality and module[NAME] == "pwquality") or
					(self.enableFaillock and module[NAME] == "faillock") or
					(self.enableEcryptfs and module[NAME] == "ecryptfs") or
					(self.enableEPS and module[NAME] == "eps") or
					((self.enableKerberos and not self.implicitSSSDAuth)and module[NAME] == "krb5" and
						not module[ARGV] == argv_krb5_sc_auth) or
					(self.enableKerberos and enableSmartcard and
					    ((module[NAME] == "krb5" and module[ARGV] == argv_krb5_sc_auth) or
					    (module[NAME] == "permit" and module[STACK] == AUTH))) or
					((self.enableLDAPAuth and not self.implicitSSSDAuth) and module[NAME] == "ldap") or
					(enableSmartcard and use_sssd_smartcard_support and module[NAME] == "sss" and module[ARGV] == argv_sssd_missing_name) or
					(enableSmartcard and not use_sssd_smartcard_support and module[STACK] == AUTH and
						module[NAME] == "succeed_if" and module[LOGIC] == LOGIC_SKIPNEXT) or
					(enableSmartcard and not use_sssd_smartcard_support and module[NAME] == "pkcs11") or
					(enableSmartcard and not use_sssd_smartcard_support and forceSmartcard and module[NAME] == "deny") or
					(enableSmartcard and forceSmartcard and module[NAME] == "deny") or 
					(enableFprintd and module[NAME] == "fprintd") or
					(self.enableOTP and module[NAME] == "otp") or
					(self.enablePasswdQC and module[NAME] == "passwdqc") or
					(self.enableWinbindAuth and module[NAME] == "winbind") or
					((self.enableSSSDAuth or self.implicitSSSDAuth or self.enableIPAv2) and module[NAME] == "sss" and module[ARGV] != argv_sssd_missing_name) or
					((self.enableSSSDAuth or self.implicitSSSDAuth or self.enableIPAv2) and
						(not self.enableNIS) and (module[NAME] == "localuser" or
						    (module[NAME] == "succeed_if" and module[LOGIC] == LOGIC_SKIPNEXT_ON_FAILURE and not self.enableSysNetAuth))
						and module[STACK] == AUTH) or
					(self.enableLocAuthorize and module[NAME] == "localuser" and module[STACK] == ACCOUNT) or
					(self.enablePAMAccess and module[NAME] == "access") or
					(self.enableMkHomeDir and module[NAME] == "mkhomedir") or
					(not self.enableSysNetAuth and module[STACK] == AUTH and
						module[NAME] == "succeed_if" and module[LOGIC] == LOGIC_REQUISITE)):
					output += self.formatPAMModule(module, forceSmartcard, warn)

			# Write it out and close it.
			f.rewind()
			f.write(output)
			f.save()
		finally:
			try:
				if f:
					f.close()
			except IOError:
				pass

		self.linkPAMService(cfg_basename, SYSCONFDIR+"/pam.d/"+cfg_link)

		return True

	# Write PAM setup to the control file(s).
	def writePAM(self):
		self.module_missing = {}
		self.writePAMService(STANDARD, CFG_PAM, AUTH_PAM_SERVICE_AC, AUTH_PAM_SERVICE)
		self.writePAMService(POSTLOGIN, CFG_POSTLOGIN_PAM, POSTLOGIN_PAM_SERVICE_AC, POSTLOGIN_PAM_SERVICE)
		self.writePAMService(PASSWORD_ONLY, CFG_PASSWORD_PAM, PASSWORD_AUTH_PAM_SERVICE_AC, PASSWORD_AUTH_PAM_SERVICE)
		self.writePAMService(FINGERPRINT, CFG_FINGERPRINT_PAM, FINGERPRINT_AUTH_PAM_SERVICE_AC, FINGERPRINT_AUTH_PAM_SERVICE)
		self.writePAMService(SMARTCARD, CFG_SMARTCARD_PAM, SMARTCARD_AUTH_PAM_SERVICE_AC, SMARTCARD_AUTH_PAM_SERVICE)
		return True

	def writeSysconfig(self):
		all_configs[CFG_AUTHCONFIG].backup(self.backupDir)
		try:
			shv = shvfile.rcreate(all_configs[CFG_AUTHCONFIG].origPath)
		except IOError:
			return False

		shv.setBoolValue("USEPWQUALITY", self.enablePWQuality)
		shv.setBoolValue("USEFAILLOCK", self.enableFaillock)
		shv.setValue("FAILLOCKARGS", self.faillockArgs)
		shv.setBoolValue("USEDB", self.enableDB)
		shv.setBoolValue("USEHESIOD", self.enableHesiod)
		shv.setBoolValue("USELDAP", self.enableLDAP)
		shv.setBoolValue("USENIS", self.enableNIS)
		shv.setBoolValue("USEECRYPTFS", self.enableEcryptfs)
		shv.setBoolValue("USEPASSWDQC", self.enablePasswdQC)
		shv.setBoolValue("USEWINBIND", self.enableWinbind)
		shv.setBoolValue("WINBINDKRB5", self.winbindKrb5)
		shv.setBoolValue("USESSSD", self.enableSSSD)
		shv.setBoolValue("USEKERBEROS", self.enableKerberos)
		shv.setBoolValue("USELDAPAUTH", self.enableLDAPAuth)
		shv.setBoolValue("USESMARTCARD", self.enableSmartcard)
		shv.setBoolValue("FORCESMARTCARD", self.forceSmartcard)
		shv.setBoolValue("USEFPRINTD", self.enableFprintd)
		shv.setValue("PASSWDALGORITHM", self.passwordAlgorithm)
		shv.setValue("USEMD5", None)
		shv.setBoolValue("USESHADOW", self.enableShadow)
		shv.setBoolValue("USEWINBINDAUTH", self.enableWinbindAuth)
		shv.setBoolValue("USESSSDAUTH", self.enableSSSDAuth)
		shv.setBoolValue("USELOCAUTHORIZE", self.enableLocAuthorize)
		shv.setBoolValue("USEPAMACCESS", self.enablePAMAccess)
		shv.setBoolValue("USEMKHOMEDIR", self.enableMkHomeDir)
		shv.setBoolValue("USESYSNETAUTH", self.enableSysNetAuth)
		shv.setBoolValue("FORCELEGACY", self.enableForceLegacy)
		shv.setBoolValue("CACHECREDENTIALS", self.enableCacheCreds)
		shv.setBoolValue("USEIPAV2", self.enableIPAv2)
		shv.setBoolValue("IPADOMAINJOINED", self.ipaDomainJoined)
		shv.setBoolValue("IPAV2NONTP", self.ipav2NoNTP)
		shv.setValue("IPAV2SERVER", self.ipav2Server)
		shv.setValue("IPAV2DOMAIN", self.ipav2Domain)
		shv.setValue("IPAV2REALM", self.ipav2Realm)

		shv.write(0644)
		shv.close()

		return True

	def writeNetwork(self):
		all_configs[CFG_NETWORK].backup(self.backupDir)
		try:
			shv = shvfile.rcreate(all_configs[CFG_NETWORK].origPath)
		except IOError:
			return False

		shv.setValue("NISDOMAIN", self.nisDomain)

		shv.write(0644)
		shv.close()

		return True

	def prewriteUpdate(self):
		oldimplicit = self.implicitSSSD
		self.implicitSSSD = self.implicitSSSDAuth = self.sssdSupported()
		if not self.enableSSSD and not self.enableSSSDAuth:
			if self.implicitSSSD and not oldimplicit:
				self.inconsistentAttrs.append('forceSSSDUpdate')
		modules = getSmartcardModules()
		if len(modules) > 0 and self.smartcardModule not in modules:
			self.smartcardModule = modules[0]
		if self.ipaDomainJoined and not self.enableIPAv2:
			# must uninstall IPAv2
			self.ipaDomainJoined = False
			self.ipaUninstall = True

	def write(self):
		self.update(True)
		self.prewriteUpdate()
		self.setupBackup(PATH_CONFIG_BACKUPS + "/last")
		try:
			ret = self.writeLibuser()
			ret = ret and self.writeLogindefs()
			ret = ret and self.writeCache()

			if self.enableHesiod:
				ret = ret and self.writeHesiod()
			if self.enableLDAP or self.enableLDAPAuth:
				ret = ret and self.writeLDAP()
			if (self.enableKerberos or
				(self.enableWinbindAuth and
				self.smbSecurity == "ads")):
				ret = ret and self.writeKerberos()
			if self.enableSmartcard:
				ret = ret and self.writeSmartcard()
			if self.enableNIS:
				ret = ret and self.writeNIS()
			if self.enableWinbind or self.enableWinbindAuth:
				ret = ret and self.writeWinbind()
			if self.implicitSSSD or self.implicitSSSDAuth:
				ret = ret and self.writeSSSD()
			elif self.enableSSSDAuth:
				ret = ret and self.writeSSSDPAM(True)
			ret = ret and self.writeNSS()
			ret = ret and self.writePAM()
			ret = ret and self.writeSysconfig()
			ret = ret and self.writeNetwork()
			ret = ret and self.toggleShadow()
			ret = ret and self.writeDConf()
		except (OSError, IOError):
			sys.stderr.write(str(sys.exc_info()[1]) + "\n")
			return False
		for group in self.save_groups:
			if group.toggleFunction:
				self.toggleFunctions.add(group.toggleFunction)
		return ret

	def writeChanged(self, ref):
		self.checkPAMLinked()
		self.update(True)
		self.prewriteUpdate()
		self.setupBackup(PATH_CONFIG_BACKUPS + "/last")
		ret = True
		try:
			for group in self.save_groups:
				if group.attrsDiffer(self, ref):
					if group.saveFunction:
						ret = ret and group.saveFunction()
					if group.toggleFunction:
						self.toggleFunctions.add(group.toggleFunction)
		except (OSError, IOError):
			sys.stderr.write(str(sys.exc_info()[1]) + "\n")
			return False
		return ret

	def probe(self):
		hostname = ""
		qname = ""
		results = []
		result = []
		hesiod = [
			[dnsclient.DNS_C_IN, "hs"],
			[dnsclient.DNS_C_IN, "ns"],
			[dnsclient.DNS_C_HS, "hs"],
			[dnsclient.DNS_C_HS, "ns"]
		]

		# get the local host name
		hostname = socket.getfqdn()
		if not hostname:
			return

		# terminate the host name
		if not hostname.endswith("."):
			hostname += "."

		# first, check for an LDAP server for the local domain
		domain = hostname[hostname.find("."):]
		qname = "_ldap._tcp" + domain
		results = dnsclient.query(qname, dnsclient.DNS_C_IN, dnsclient.DNS_T_SRV)

		for result in results:
			if result.dns_type == dnsclient.DNS_T_SRV:
				self.ldapServer = result.rdata.server.rstrip(".")
				self.ldapBaseDN = domain2dn(domain)

		# now, check for a Kerberos realm the local host or domain is in
		qname = "_kerberos." + hostname
		results = dnsclient.query(qname, dnsclient.DNS_C_IN, dnsclient.DNS_T_TXT)
		if not results:
			qname = "_kerberos" + domain
			results = dnsclient.query(qname, dnsclient.DNS_C_IN, dnsclient.DNS_T_TXT)

		for result in results:
			if result.dns_type == dnsclient.DNS_T_TXT:
				self.kerberosRealm = result.rdata.data
				if self.kerberosRealm:
					break

		if self.kerberosRealm:
			# now fetch server information for the realm
			qname = "_kerberos._udp." + self.kerberosRealm
			results = dnsclient.query(qname, dnsclient.DNS_C_IN, dnsclient.DNS_T_SRV)
			for result in results:
				if result.dns_type == dnsclient.DNS_T_SRV:
					qname = result.rdata.server.rstrip(".")
					if result.rdata.port:
						qname += ":" + result.rdata.port
					if self.kerberosKDC:
						self.kerberosKDC += "," + qname
					else:
						self.kerberosKDC = qname

			# now fetch admin server information for the realm
			qname = "_kerberos-adm._udp." + self.kerberosRealm
			results = dnsclient.query(qname, dnsclient.DNS_C_IN, dnsclient.DNS_T_SRV)
			for result in results:
				if result.dns_type == dnsclient.DNS_T_SRV:
					qname = result.rdata.server.rstrip(".")
					if result.rdata.port:
						qname += ":" + result.rdata.port
					if self.kerberosAdminServer:
						self.kerberosAdminServer += "," + qname
					else:
						self.kerberosAdminServer = qname

		# now check for SOA records for hesiod-style domains under .hs.DOMAIN
 		# and .ns.DOMAIN
		for h in hesiod:
			qname = h[1] + domain
			results = dnsclient.query(qname, h[0], dnsclient.DNS_T_SOA)
			for result in results:
				if (result.dns_type == dnsclient.DNS_T_SOA and
					result.dns_name == qname):
					self.hesiodLHS = "." + h[1]
					self.hesiodRHS = domain.rstrip(".")
					break

	def printInfo(self):
		print "caching is %s" % formatBool(self.enableCache)
		print "nss_files is always enabled"
		print "nss_compat is %s" % formatBool(self.enableCompat)
		print "nss_db is %s" % formatBool(self.enableDB)
		print "nss_hesiod is %s" % formatBool(self.enableHesiod)
		print " hesiod LHS = \"%s\"" % self.hesiodLHS
		print " hesiod RHS = \"%s\"" % self.hesiodRHS
		print "nss_ldap is %s" % formatBool(self.enableLDAP)
		print " LDAP+TLS is %s" % formatBool(self.enableLDAPS)
		print " LDAP server = \"%s\"" % self.ldapServer
		print " LDAP base DN = \"%s\"" % self.ldapBaseDN
		print "nss_nis is %s" % formatBool(self.enableNIS)
		print " NIS server = \"%s\"" % self.nisServer
		print " NIS domain = \"%s\"" % self.nisDomain
		print "nss_nisplus is %s" % formatBool(self.enableNIS3)
		print "nss_winbind is %s" % formatBool(self.enableWinbind)
		print " SMB workgroup = \"%s\"" % self.smbWorkgroup
		print " SMB servers = \"%s\"" % self.smbServers
		print " SMB security = \"%s\"" % self.smbSecurity
		print " SMB realm = \"%s\"" % self.smbRealm
		print " Winbind template shell = \"%s\"" % self.winbindTemplateShell
		print " SMB idmap range = \"%s\"" % self.smbIdmapRange
		print "nss_sss is %s by default" % formatBool(self.enableSSSD)
		print "nss_wins is %s" % formatBool(self.enableWINS)
		print "nss_mdns4_minimal is %s" % formatBool(self.enableMDNS)
		print "myhostname is %s" % formatBool(self.enableMyhostname)
		print "DNS preference over NSS or WINS is %s" % formatBool(self.preferDNSinHosts)
		print "pam_unix is always enabled"
		print " shadow passwords are %s" % formatBool(self.enableShadow)
		print " password hashing algorithm is %s" % self.passwordAlgorithm
		print "pam_krb5 is %s" % formatBool(self.enableKerberos)
		print " krb5 realm = \"%s\"" % self.kerberosRealm
		print " krb5 realm via dns is %s" % formatBool(self.kerberosRealmviaDNS)
		print " krb5 kdc = \"%s\"" % self.kerberosKDC
		print " krb5 kdc via dns is %s" % formatBool(self.kerberosKDCviaDNS)
		print " krb5 admin server = \"%s\"" % self.kerberosAdminServer
		print "pam_ldap is %s" % formatBool(self.enableLDAPAuth)
		print " LDAP+TLS is %s" % formatBool(self.enableLDAPS)
		print " LDAP server = \"%s\"" % self.ldapServer
		print " LDAP base DN = \"%s\"" % self.ldapBaseDN
		print " LDAP schema = \"%s\"" % (self.ldapSchema or "rfc2307")
		print "pam_pkcs11 is %s" % formatBool(self.enableSmartcard and not (self.enableSSSDAuth and self.smartcardModule == "sssd"))
		print "SSSD smartcard support is %s" % formatBool(self.enableSmartcard and (self.enableSSSDAuth and self.smartcardModule == "sssd"))
		print " use only smartcard for login is %s" % formatBool(self.forceSmartcard)
		print " smartcard module = \"%s\"" % self.smartcardModule
		print " smartcard removal action = \"%s\"" % self.smartcardAction
		print "pam_fprintd is %s" % formatBool(self.enableFprintd)
		print "pam_ecryptfs is %s" % (formatBool(self.enableEcryptfs))
		print "pam_winbind is %s" % formatBool(self.enableWinbindAuth)
		print " SMB workgroup = \"%s\"" % self.smbWorkgroup
		print " SMB servers = \"%s\"" % self.smbServers
		print " SMB security = \"%s\"" % self.smbSecurity
		print " SMB realm = \"%s\"" % self.smbRealm
		print "pam_sss is %s by default" % formatBool(self.enableSSSDAuth)
		print " credential caching in SSSD is %s" % formatBool(self.enableCacheCreds)
		print " SSSD use instead of legacy services if possible is %s" % formatBool(not self.enableForceLegacy)
		print "IPAv2 is %s" % formatBool(self.enableIPAv2)
		print "IPAv2 domain was %sjoined" % (not self.ipaDomainJoined and "not " or "")
		print " IPAv2 server = \"%s\"" % self.ipav2Server
		print " IPAv2 realm = \"%s\"" % self.ipav2Realm
		print " IPAv2 domain = \"%s\"" % self.ipav2Domain
		print "pam_pwquality is %s (%s)" % (formatBool(self.enablePWQuality),
			self.pwqualityArgs)
		print "pam_passwdqc is %s (%s)" % (formatBool(self.enablePasswdQC),
			self.passwdqcArgs)
		print "pam_access is %s (%s)" % (formatBool(self.enablePAMAccess),
			self.pamAccessArgs)
		print "pam_faillock is %s (%s)" % (formatBool(self.enableFaillock),
			self.faillockArgs)
		print "pam_mkhomedir or pam_oddjob_mkhomedir is %s (%s)" % (formatBool(self.enableMkHomeDir),
			self.mkhomedirArgs)
		print "Always authorize local users is %s (%s)" % (formatBool(self.enableLocAuthorize),
			self.localuserArgs)
		print "Authenticate system accounts against network services is %s" % formatBool(self.enableSysNetAuth)

	def toggleShadow(self):
		for cfg in (CFG_SHADOW, CFG_PASSWD, CFG_GSHADOW, CFG_GROUP):
			all_configs[cfg].backup(self.backupDir)
		# now, do file manipulation on the password files themselves.
		if self.enableShadow:
			os.system("/usr/sbin/pwconv")
			os.system("/usr/sbin/grpconv")
		else:
			os.system("/usr/sbin/pwunconv")
			os.system("/usr/sbin/grpunconv")
		return True

	def joinDomain(self, echo):
		status = 0
		if (self.enableWinbind or self.enableWinbindAuth) and self.joinUser:
			server = self.smbServers.split(",", 1)[0].split(" ", 1)[0].split("\t", 1)[0]
			domain = self.smbWorkgroup
			protocol = self.smbSecurity
			if not protocol:
				protocol = "ads"
			if protocol != "ads" and protocol != "domain":
				# Not needed -- "joining" is meaningless for other
				# models.
				return
			cmd = PATH_WINBIND_NET + " join %s%s %s%s -U %s" % (
				domain and "-w " or "", domain,
				server and "-S " or "", server,
				self.joinUser)
			
			if echo:
				sys.stderr.write("[%s]\n" % cmd)
			if self.joinPassword or not echo:
				status, error = feedFork(cmd, echo, "sword:", self.joinPassword)
			else:
				child = Popen([cmd], shell=True)
				child.communicate()
				status = child.returncode
			if echo:
				if status != 0:
					self.messageCB(_("Winbind domain join was not successful."))
			else:
				if status != 0:
					errmsg = _("Winbind domain join was not successful. The net join command failed with the following error:")
					errmsg += "\n" + error
					self.messageCB(errmsg)
		return status == 0

	def joinIPADomain(self, echo):
		status = 0
		if self.enableIPAv2:
			server = self.ipav2Server
			domain = self.ipav2Domain
			realm = self.ipav2Realm
			principal = self.joinUser
			password = self.joinPassword
			if self.ipav2NoNTP:
				nontp = "-N"
			else:
				nontp = ""
			cmd = PATH_IPA_CLIENT_INSTALL + " --noac %s%s %s%s %s%s %s%s %s %s" % (
				domain and "--domain=" or "", domain,
				server and "--server=" or "", server,
				realm and "--realm=" or "", realm,
				principal and "--principal=" or "", principal,
				nontp,
				not echo and "--unattended" or "-W")

			if echo:
				sys.stderr.write("[%s]\n" % cmd)
				child = Popen([cmd], shell=True)
				child.communicate()
				status = child.returncode
			else:
				status, error = feedFork(cmd, echo, '', password)

			if status == 0:
				self.ipaDomainJoined = True
			if echo:
				if status != 0:
					self.messageCB(_("IPAv2 domain join was not successful."))
			else:
				if status != 0:
					errmsg = _("IPAv2 domain join was not successful. The ipa-client-install command failed with the following error:")
					errmsg += "\n" + error
					self.messageCB(errmsg)
		return status == 0

	def uninstallIPA(self):
		cmd = PATH_IPA_CLIENT_INSTALL + " --uninstall --noac --unattended"
		os.system(cmd)

	def toggleCachingService(self, nostart):
		if not nostart:
			if self.enableCache:
				Service.stop("nscd")
				Service.start("nscd")
			else:
				try:
					Service.stop("nscd")
				except OSError:
					pass
		return True
	def toggleNisService(self, nostart):
		if self.enableNIS and self.nisDomain:
			if not nostart:
				os.system("/bin/domainname " + self.nisDomain)
			try:
				os.system("[[ $(getsebool allow_ypbind) == *off* ]] && setsebool -P allow_ypbind 1")
				os.stat(PATH_RPCBIND)
				Service.enable("rpcbind")
				if not nostart:
					Service.start("rpcbind")
			except OSError:
				pass
			try:
				os.stat(PATH_YPBIND)
				Service.enable("ypbind")
				if not nostart:
					Service.stop("ypbind")
					Service.start("ypbind")
			except OSError:
				pass
		else:
			if not nostart:
				os.system("/bin/domainname \"(none)\"")
			try:
				os.system("[[ $(getsebool allow_ypbind) == *on* ]] && setsebool -P allow_ypbind 0")
				os.stat(PATH_YPBIND)
				if not nostart:
					try:
						Service.stop("ypbind")
					except OSError:
						pass
				Service.disable("ypbind")
			except OSError:
				pass
		return True

	def toggleLDAPService(self, nostart):
		toggleSplatbindService((self.enableLDAP or self.enableLDAPAuth) and
			not self.implicitSSSD,
			PATH_NSLCD,
			"nslcd", nostart)
		if self.enableLDAP:
			try:
				os.system("[[ $(getsebool authlogin_nsswitch_use_ldap) == *off* ]] && setsebool -P authlogin_nsswitch_use_ldap 1")
			except OSError:
				pass
		else:
			try:
				os.system("[[ $(getsebool authlogin_nsswitch_use_ldap) == *on* ]] && setsebool -P authlogin_nsswitch_use_ldap 0")
			except OSError:
				pass
		return True

	def toggleWinbindService(self, nostart):
		toggleSplatbindService(self.enableWinbind or self.enableWinbindAuth,
			PATH_WINBIND,
			"winbind", nostart)

	def toggleSSSDService(self, nostart):
		explicitenable = ((self.enableSSSD and self.enableSSSDAuth) or
			(self.enableSSSD and os.path.exists(PATH_SSSD_CONFIG)) or
			(self.enableSSSDAuth and os.path.exists(PATH_SSSD_CONFIG)))
		enable = (self.implicitSSSD or self.implicitSSSDAuth or
			self.enableIPAv2 or explicitenable)
		toggleSplatbindService(enable,
			PATH_SSSD,
			"sssd", nostart or (enable and not (self.implicitSSSD or
			self.implicitSSSDAuth or self.enableIPAv2)))

	def toggleOddjobService(self, nostart):
		if self.enableMkHomeDir and os.access("%s/pam_%s.so"
				% (AUTH_MODULE_DIR, "oddjob_mkhomedir"), os.X_OK):
			# only switch on and only if pam_oddjob_mkhomedir exists
			toggleSplatbindService(True,
				PATH_ODDJOBD,
				"oddjobd", nostart)

	def post(self, nostart):
		for togglefunc in self.toggleFunctions:
			togglefunc(nostart)
		if self.ipaUninstall:
			self.uninstallIPA()

	def testLDAPCACerts(self):
		if self.enableLDAP or self.enableLDAPAuth:
			try:
				os.stat(self.ldapCacertDir)
			except OSError as (err, text):
				if err == errno.ENOENT:
					os.mkdir(self.ldapCacertDir, 0755)

			return isEmptyDir(self.ldapCacertDir)
		return False

	def rehashLDAPCACerts(self):
		if ((self.enableLDAP or self.enableLDAPAuth) and
			(self.enableLDAPS or 'ldaps:' in self.ldapServer)):
			os.system("/usr/sbin/cacertdir_rehash " + self.ldapCacertDir)

	def downloadLDAPCACert(self):
		if not self.ldapCacertURL:
			return False
		self.testLDAPCACerts()
		try:
			readf = urllib2.urlopen(self.ldapCacertURL)
			writef = openLocked(self.ldapCacertDir + "/" + LDAP_CACERT_DOWNLOADED, 0644)
			writef.write(readf.read())
			readf.close()
			writef.close()
		except (IOError, OSError, ValueError):
			self.messageCB(_("Error downloading CA certificate"))
			return False
		self.rehashLDAPCACerts()
		return True

	def setupBackup(self, backupdir):
		if backupdir[0] != "/":
			backupdir = PATH_CONFIG_BACKUPS + "/backup-" + backupdir
		self.backupDir = backupdir
		if not isEmptyDir(backupdir):
			try:
				lst = os.listdir(backupdir)
				for filename in lst:
					try:
						os.unlink(backupdir+"/"+filename)
					except OSError:
						pass
			except OSError:
				pass

	def saveBackup(self, backupdir):
		self.setupBackup(backupdir)
		ret = True
		for cfg in all_configs:
			ret = cfg.backup(self.backupDir) and ret
		return ret

	def restoreBackup(self, backupdir):
		if backupdir[0] != "/":
			backupdir = PATH_CONFIG_BACKUPS + "/backup-" + backupdir
		ret = True
		for cfg in all_configs:
			ret = cfg.restore(backupdir) and ret
		return ret

	def restoreLast(self):
		return self.restoreBackup(PATH_CONFIG_BACKUPS + "/last")
