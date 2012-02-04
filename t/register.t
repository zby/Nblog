use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $email_log;
local *Nblog::RegisterApp::send_mail = sub {
    my( $self, $mail ) = @_;
    $email_log .= $mail->as_string;
};

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
my $user = $app->schema->resultset( 'User' )->search({ username =>  'new_user', email => 'test@example.com' })->first;
ok( $user, 'User created' );
my $email_addr = $user->email;
like( $email_log, qr/To: $email_addr/, "Email to test user sent" );

done_testing;
