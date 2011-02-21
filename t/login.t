use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $app = Nblog->new_with_config();

my $psgi_app = builder {
    enable "Plack::Middleware::Static",
        path => qr{^/static/}, root => './templates/globals/';
    enable "Plack::Middleware::Static",
        path => qr{^/favicon.ico$}, root => './templates/globals/static/images/';
    enable 'Session';
    $app->psgi_app;;
};

my $mech = Test::WWW::Mechanize::PSGI->new( app => $psgi_app );

$mech->get_ok( '/Admin/Article/', 'Request should succeed' );
is( $mech->uri(), 'http://localhost/login', 'Redirected to login' );
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'username' => 'wrong',
            'password' => 'wrong',
        }
    },
    'Logging in'
);
$mech->content_contains( 'div class="error"' );
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'username' => 'test',
            'password' => 'pass_for_test',
        }
    },
    'Logging in'
);
is( $mech->uri(), 'http://localhost/Admin/Article/', 'Redirected after login' );

done_testing;
