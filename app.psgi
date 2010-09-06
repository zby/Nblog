use strict;

use Plack::Builder;
use Nblog;

my $app = Nblog->new_with_config();

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/static/}, root => './templates/';
    enable "Plack::Middleware::Static",
        path => qr{^/favicon.ico$}, root => './templates/static/images/';
    enable 'Session';
    $app->psgi_callback;;
};

