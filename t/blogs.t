use strict;
use warnings;

use Test::More;
use Nblog;
use Test::WWW::Mechanize::PSGI;
use Plack::Builder;

my $app = Nblog->new_with_config();

my $mech = Test::WWW::Mechanize::PSGI->new( app => $app->psgi_app );
use String::Random qw(random_string random_regex);

my $schema = $app->schema;

$mech->get_ok( '/Blog/Test_blog', 'test blog' );

done_testing;
