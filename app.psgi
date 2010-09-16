use strict;

use Plack::Builder;
use Nblog;
use Plack::Session::Store::Cache;
use CHI;

my $app = Nblog->new_with_config();

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/static/}, root => './templates/';
    enable "Plack::Middleware::Static",
        path => qr{^/favicon.ico$}, root => './templates/static/images/';
    enable 'Session',
        store => Plack::Session::Store::Cache->new(
            cache => CHI->new(driver => 'FastMmap')
        );
    $app->psgi_callback;;
};

