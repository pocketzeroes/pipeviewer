#!/bin/sh
#
# Messy script to convert all of the given .po files to a single C file on
# stdout.

cat <<EOF
/*
 * Translation table - automatically generated by po2table.sh.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include <string.h>

struct msgtable_s {
	char *msgid;
	char *msgstr;
};


struct msgtable_s *minigettext__gettable(char *lang)
{
	if (lang == 0)
		return 0;

EOF

for POFILE; do
	LANG=`basename "$POFILE" | sed 's/.po$//'`
	echo "	if (strncmp(lang, \"$LANG\", 2) == 0) {"
	echo "		static struct msgtable_s data[] = {";

	awk 'BEGIN{i=0;s=0;}
	  /^msgid[ 	]+/ {
	    if (s) print "			}, ";
	    print "			{";
	    print "				" substr($0,7);
	    i=1;
	    s=0;
	  }
	  /^msgstr[ 	]+/ {
	    print "			,";
	    i=0;s=1;
	    print "				" substr($0,8);
	  }
	  /^[ 	]*"/ {
	    if (i||s) print "				" $0;
	  }
	  END {if (i||s) print "			}\n";}
	' < "$POFILE"
	echo '			, { 0, 0 } };'
	echo "		return data;"
	echo "	}"
done

cat <<EOF

	return 0;
}

/* EOF */
EOF

# EOF