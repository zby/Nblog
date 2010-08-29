use strict;

use Plack::Builder;
use Nblog;

my $app = Nblog->new_with_config();

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/static/}, root => './templates/globals/';
    enable "Plack::Middleware::Static",
        path => qr{^/favicon.ico$}, root => './templates/globals/static/images/';
    enable 'Session';
    $app->psgi_callback;;
};

