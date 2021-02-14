#!/usr/bin/env sh
#
#####################################################################
#                                                                   #
# This is Gridfinity OX153Mk1 makeweb (Release 20210214A) [GFODLv1] #
#                                                                   #
#####################################################################
#                                                                   #
#     The following license applies to all OUTPUT of this tool:     #
#                                                                   #
#####################################################################
#                                                                   #
# The Gridfinity Open Documentation License v1.0 (GFODLv1)          #
#                                                                   #
# Copyright (c) 2021 Jeffrey H. Johnson <trnsz@pobox.com>           #
#                                                                   #
# All Rights Reserved.                                              #
#                                                                   #
# Redistribution and use, in source and compiled forms,             #
# with or without modification, are permitted, provided             #
# that the following conditions are met:                            #
#                                                                   #
#   1. Redistributions of source code must retain the               #
#      above copyright notice, this list of conditions,             #
# 	   and the following disclaimer, within the first               #
#	   ten lines of this file, completely unmodified.               #
#                                                                   #
#   2. Redistributions in compiled form must reproduce              #
#      the above copyright notice, this list of conditions,         #
#	   and the following disclaimer in the documentation,           #
#	   and/or other materials provided with the distribution.       #
#                                                                   #
# THIS DOCUMENTATION IS PROVIDED BY THE AUTHORS "AS IS",            #
# AND ANY WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT            #
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY         #
# AND FITNESS FOR ANY PARTICULAR PURPOSE ARE DISCLAIMED.            #
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY DIRECT,           #
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL        #
# DAMAGES, INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF            #
# SUBSTITUTE GOODS OR SERVICES, LOSS OF USE, DATA, OR PROFITS,      #
# OR BUSINESS INTERRUPTION, HOWEVER CAUSED, AND ON ANY              #
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,       #
# OR TORT, INCLUDING NEGLIGENCE OR OTHERWISE, ARISING IN            #
# ANY WAY OUT OF THE USE OF THIS DOCUMENTATION, EVEN IF             #
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                        #
#                                                                   #
#####################################################################
# OX153 makeweb 20210103B requires: POSIX sh, semver-tool >=3.2.0,  #
# sponge >=20060219, pandoc >2.9.2, Tidy-HTML5 >=5.7.28, GNU find,  #
# GNU xargs, GNU sed, POSIX cat, and a recent release of Git VCS.   #
#####################################################################
#
#####################################################################
#                                                                   #
#    The following license applies to THIS TOOL (OX153 makeweb):    #
#                                                                   #
#####################################################################
#
##############################################################################
#
# The Oxford 153 Entitlement: Mark I. (OX153Mk1)
#
# LEGAL TERMS AND CONDITIONS FOR USE, COPYING, DISTRIBUTION, AND MODIFICATION
#
# All mankind is hereby permitted to use, copy, and distribute, verbatim or
# modified, copies of this tool, provided the maximum printable line length
# never exceeds the known universal constant of 153 characters, and the usage
# of the Oxford comma is forever retained in all documentation, tool comments,
# and tool output. Those who would not be considered to be part of mankind are
# hereby permitted to USE this tool, but NOT PERMITTED TO COPY, DISTRIBUTE, OR
# MODIFY this tool, UNDER ANY CIRCUMSTANCES. This tool is made available for
# use "AS IS", and without warranty of any kind, either expressed or implied.
#
# This license, henceforth known as the "Oxford 153 Entitlement", is NOT a
# GPL-compatible license, and this tool is NOT "free software", according to
# common and generally accepted definitions of "free software", including, but
# not limited to, the definition of "free software" provided by Richard M.
# Stallman, and, subsequently, the definitions asserted by the Free Software
# Foundation. As the Open Source Initiative has NOT reviewed this license, it
# is understood this tool CANNOT be considered "open source software" per the
# OSI Open Source Definition. This license is LIKELY INCOMPATIBLE with Debian
# Free Software Guidelines, and is EXPLICITLY INCOMPATIBLE with the Debian
# Social Contract, as the priorities of the authors of the tool will always
# trump the priorities of other users in the community. The authors of the
# tool are NOT associated with "Software in the Public Interest, Inc.", pay no
# membership dues, and do NOT receive any form of sponsorship from SPI.
#
# NOTICE: All uses of the Oxford comma within this tool are immutable,
# supported by miraculous revelations, and under no circumstances, alterable.
#
# WARNING: The maximum allowable length of any line within this tool is to be
# no more than 153 displayable characters. If one were to perform any action
# causing the length of the longest line to exceed, at any moment, the
# universal constant of 153 characters, they are hereby reminded that those
# whom the gods wish to destroy they first make mad, stealing away their minds
# of good sense, and turning their thoughts to foolishness.
#
##############################################################################

set -u ||
	true
:
set -e ||
	true
:
if [ ! -f "./README.md" ]; then
	printf '%s\n' \
		"Error: README.md not found" \
		>&2
	exit 1
fi
printf '%s ' \
	"Converting markdown..."
grep  -v "project/badge" ./README.md | pandoc -s --metadata title="OX153MkI" -r markdown -o public/index.html \
	> /dev/null \
	2>&1 ||
	{
		printf '%s\n' \
			"Error: pandoc failed" \
			>&2
		exit 1
	}
printf '%s\n' \
	"ok" ||
	true
:
printf '%s ' \
	"Cleaning HTML..." ||
	true
:
find "./public" -name '*.html' -exec \
	tidy --add-meta-charset true -utf8 -w 76 -qiubnm \
	"{}" \; \
	2> /dev/null \
	> /dev/null \
	2>&1 ||
	{
		printf '%s\n' \
			"Error: cleaning failed" \
			>&2
		exit 1
	}
printf '%s\n' \
	"ok" ||
	true
:
printf '%s ' \
	"Transforming HTML..." ||
	true
:
find ./public -name '*.html' -print0 \
	2> /dev/null |
	xargs -0 -L1 -I{} \
		sh -c \
		'grep -iav ".*generator.*HTML.*Tidy.*>$" "{}" 2>/dev/null |
			sponge "{}" 
			>/dev/null 
				2>&1' \
		printf '%s\n' \
		"Done" ||
	true
:
printf '%s\n' \
	"$(date)" \
	> ./.timestamp &&
	git add ./.timestamp
:
printf '%s\n' \
	"Preparing commit..." ||
	true
:
git gc --aggressive --prune=now ||
	true
:
SEMVER="$(
	eval printf '%s' "$(printf "%s" "$(semver-tool bump patch "$(printf '%d.%d.%d' "2" "0" "$(cut -d '.' -f 3 ./.patch |
		cut -d '.' -f 1)")") |\
	sponge ./.patch")"
	cat ./.patch
)"
git add -A &&
	git tag -a -s "${SEMVER:?}" -m "v${SEMVER:?} - $(date)" &&
	printf '%s\n' \
		"Set new semver tag: ${SEMVER}" &&
	git commit -q -aS -m "Pushing Pages: $(date)" &&
	git pushall master &&
	printf '%s\n' "Complete."
