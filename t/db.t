use strict;
use warnings;
use Test::More;
use Config::Any::Perl;
use DateTime;

use_ok( 'Nblog::Schema');
use_ok( 'Nblog::Schema::Result::User');

my $config = Config::Any::Perl->load( 'nblog_local.pl' );
my $schema = Nblog::Schema->connect( @{ $config->{'schema'}{connect_info} } );
 
ok($schema, 'get db schema');

my $user = $schema->resultset('User')->find(1);
unless( $user )
{
   $user = $schema->resultset('User')->create({ username => 'test', password => 'testpw'} );
}
ok( $user,  'get user' );

my ( $article1 ) = $schema->resultset('Article')->get_latest_articles;
is( ref $article1, 'Nblog::Schema::Result::Article', 'get_latest_articles' );

my $time = DateTime->now;
my $article = $schema->resultset('Article')->new_result({});
END{ $article->delete }

ok( $article, 'new result for Article worked' );
$article->insert;
my $archived = $schema->resultset('Article')->archived( $time->year, $time->month );
my $found = 0;
while( $a = $archived->next ){
    $found = 1 if $a->id == $article->id;
}
ok( $found, 'archived' );

done_testing;
