use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $app = Nblog->new_with_config();

my $mech = Test::WWW::Mechanize::PSGI->new( app => $app->psgi_app );

$mech->get_ok( '/Register/', 'Register user page' );
$mech->submit_form_ok( {
        with_fields => {
            username => 'test',
            email => 'not really email',
        }
    },
    'Register user duplicate name and wrong email'
);
$mech->content_contains( 'This username is already registered', );
$mech->content_contains( 'Wrong format of email', );

$mech->submit_form_ok( {
        with_fields => {
            username => 'new_user',
            email => 'test@example.com',
        }
    },
    'Register user'
);
$mech->content_contains( 'Email sent', );
my $user = $app->schema->resultset( 'User' )->search({ username =>  'new_user' })->first;
ok( $user, 'User created' );
ok( $user->email_token, 'email_token set' );
$mech->get_ok( '/Register/confirm?username=new_user&token=aaaa', 'email token' );
$mech->content_contains( 'Token invalid', 'invalid email token' );
$mech->get_ok( '/Register/confirm?username=new_user&token=' . $user->email_token, 'email token' );
$mech->content_contains( 'Email confirmed', 'email token verified' );
$user->discard_changes;
ok( $user->email_confirmed, 'Email confirmed' );

done_testing;
