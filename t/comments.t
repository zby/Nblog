use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $app = Nblog->new_with_config();

my $psgi_callback = builder {
    enable "Plack::Middleware::Static",
        path => qr{^/static/}, root => './templates/globals/';
    enable "Plack::Middleware::Static",
        path => qr{^/favicon.ico$}, root => './templates/globals/static/images/';
    enable 'Session';
    $app->psgi_callback;;
};

my $mech = Test::WWW::Mechanize::PSGI->new( app => $psgi_callback );
use String::Random qw(random_string random_regex);

my $schema = $app->schema;

$mech->get_ok( '/', 'Request should succeed' );
$mech->get_ok( '/Article/test_test/view', 'Request should succeed' );
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'comment_form.name' => 'some_user',
            'comment_form.email' => 'some_user@example.com',
            'comment_form.url' => 'www.example.com',
            'comment_form.body' => 'adasdfd asdfkjl; a sfjl;dkjfja dfa aslkfjl a;lskjflj;asdfljdkk;',
        }
    },
    'Creating comment'
);

$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'username' => 'test',
            'password' => 'pass_for_test',
        }
    },
    'Logging in'
);
$mech->content_contains( 'Logged in as: test', 'Logged in' );
$mech->get_ok( '/Article/test_test/view', 'Request should succeed' );
$mech->content_contains( 'Logged in as: test', 'Logged in' );
$mech->content_contains( 'comment_form.body', 'Comment form after login' );
$mech->content_lacks( 'comment_form.name', 'Comment form after login' );
my $random_comment = 'random ' . random_regex('\w{20}');
$mech->submit_form_ok( {
        form_number => 1,
        fields => {
            'comment_form.body' => $random_comment,
        }
    },
    'Creating comment by user'
);
my $new_comment = $schema->resultset( 'Comment' )->search( { body => $random_comment } )->next;
ok( defined $new_comment && defined $new_comment->user && $new_comment->user->username eq 'test' );

done_testing;
