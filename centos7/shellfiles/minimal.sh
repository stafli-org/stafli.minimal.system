#!/bin/bash
#
#    CentOS 7 (centos7) Minimal10 System (shellscript)
#    Copyright (C) 2016-2017 Stafli
#    Luís Pedro Algarvio
#    This file is part of the Stafli Application Stack.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Workaround for docker commands
alias FROM="#";
alias MAINTAINER="#";
alias ENV='export';
alias ARG='export';
alias RUN='';
shopt -s expand_aliases;

# Suppress warnings about the terminal
printf "\
TERM=\"linux\"\n\
" >> /etc/environment;
source /etc/environment;

# Load dockerfile
source "$(dirname $(readlink -f $0))/../dockerfiles/minimal.dockerfile";

# Configure timezone and locales
printf "\
TZ=\"Etc/UTC\"\n\
LANGUAGE=\"en_US.UTF-8\"\n\
LANG=\"en_US.UTF-8\"\n\
LC_ALL=\"en_US.UTF-8\"\n\
" >> /etc/environment;
source /etc/environment;

