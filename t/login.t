use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $app = Nblog->new_with_config();
$app->schema->deploy( { add_drop_table => 0 } );
$app->schema->resultset( 'User' )->create( { username => 'test', password => 'pass_for_test' } );
$app->schema->resultset( 'Article' )->create( { subject => 'test test', body => 'test', } );

my $mech = Test::WWW::Mechanize::PSGI->new( app => $app->psgi_app );

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
