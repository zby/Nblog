#!/usr/bin/env perl
use lib './lib';
use strict;
use warnings;

use Nblog::Schema;
use Data::Dumper;
use Config::Any::Perl;
use Test::More;
use DateTime;

my $cfg = Config::Any::Perl->load( 'data/nblog_config.pl' );
my $schema = Nblog::Schema->connect( @{ $cfg->{schema}->{connect_info} } );
$schema->deploy();
$schema->resultset( 'User' )->create( { username => 'test', password => 'pass_for_test' } );

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

my ( $article1 ) = $schema->resultset('Article')->get_latest_articles;
is( ref $article1, 'Nblog::Schema::Result::Article', 'get_latest_articles' );

done_testing;

