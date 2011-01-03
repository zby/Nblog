use strict;
use Nblog;

my $app = Nblog->new_with_config();

$app->psgi_app;

