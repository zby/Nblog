use strict;
use warnings;

use File::Copy;

copy( 'nblog.pl', 't/data/nblog_local.pl' ) or die "Copy failed: $!";


