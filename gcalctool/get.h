
/*  $Header$
 *
 *  Copyright (c) 1987-2007 Sun Microsystems, Inc. All Rights Reserved.
 *           
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2, or (at your option)
 *  any later version.
 *           
 *  This program is distributed in the hope that it will be useful, but 
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
 *  General Public License for more details.
 *           
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 *  02111-1307, USA.
 */

#ifndef GET_H
#define GET_H

#include "calctool.h"

extern char *Rbstr[];          /* Base mode X resource strings. */
extern char *Rdstr[];          /* Display mode X resource strings. */
extern char *Rmstr[];          /* Mode mode X resource strings. */
extern char *Rtstr[];          /* Trig mode X resource strings. */
extern char *Rsstr[];          /* Syntax resource strings. */
extern char *Rcstr[];          /* Bitcalculating mode. */

void read_resources();
char *convert(char *);
void init_vars();
char *set_bool(int);
void usage(char *);
int get_int_resource(enum res_type, int *);
const char *get_radix();
const char *get_tsep();
void get_options(int, char **);
void read_cfdefs();
void read_str(char **, char *);

#endif /* GET_H */