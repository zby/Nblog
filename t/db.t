#!/usr/bin/env perl
use lib './lib';
use strict;
use warnings;

use Nblog::Schema;
use Data::Dumper;
use Config::Any::Perl;
use Test::More;
use DateTime;

my $cfg = Config::Any::Perl->load( 'share/nblog_config.pl' );
my $schema = Nblog::Schema->new_from_config( $cfg->{schema} );

my $user = $schema->resultset( 'User' )->create( { username => 'test', password => 'pass_for_test' } );
my $blog = $user->create_blog( title => 'Some blog' );
is( $blog->seo_url, 'Some_blog' );

my @contributors = $blog->contributors;
is( $contributors[0]->id, $user->id );
my @roles = $blog->blogs_users;
is( $roles[0]->role, 'o' );

my $time = DateTime->now;
my $article = $schema->resultset('Article')->new_result({});
END{ $article->delete }

ok( $article, 'new result for Article worked' );
$article->insert;
my $archived = $schema->resultset('Article')->archived( year => $time->year, month => $time->month );
my $found = 0;
while( $a = $archived->next ){
    $found = 1 if $a->id == $article->id;
}
ok( $found, 'archived' );

$blog->add_to_articles( { subject => 'test test', body => 'test', } );
my @archived = $schema->resultset('Article')->archived( 
    year => $time->year,
    month => $time->month,
    restriction => { blog_id => $blog->blog_id },
);
is( ref $archived[0], 'Nblog::Schema::Result::Article', 'archived for a blog' );
is( scalar @archived, 1, 'archived for a blog' );

my @articles = $schema->resultset('Article')->get_latest_articles( 10, { blog_id => $blog->blog_id } );
is( ref $articles[0], 'Nblog::Schema::Result::Article', 'get_latest_articles' );
is( scalar @articles, 1, 'get_latest_articles for a blog' );


done_testing;

