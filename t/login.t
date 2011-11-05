use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $app = Nblog->new_with_config();

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

$mech->get_ok( '/ResetPass/', 'ResetPass page' );
$mech->submit_form_ok( {
        with_fields => {
            'username' => 'wrong',
        }
    },
    'ResetPass wrong name'
);
$mech->content_contains( 'User not found', 'ResetPass wrong name' );

$mech->get( '/ResetPass/', 'ResetPass page' );
$mech->submit_form_ok( {
        with_fields => {
            'username' => 'test',
        }
    },
    'ResetPass for test'
);
$mech->content_contains( 'Email sent', 'ResetPass for test' );

my $user = $app->schema->resultset( 'User' )->search({ username =>  'test' })->first;
ok( $user->pass_token, 'pass_token set' );
$mech->get_ok( '/ResetPass/reset?name=test&token=aaaa', 'reset token' );
$mech->content_contains( 'Token invalid', 'invalid reset token' );
$mech->get_ok( '/ResetPass/reset?name=test&token=' . $user->pass_token, 'reset token' );
$mech->content_contains( 'New password:<input', 'reset token verified' );
$mech->submit_form_ok( {
        with_fields => {
            'password' => 'new password',
        }
    },
    'ResetPass for test'
);
my $password = $user->password;
my $new_user = $app->schema->resultset( 'User' )->search({ username =>  'test' })->first;
ok( $password ne $new_user->password, 'ResetPass updated password' );

done_testing;
