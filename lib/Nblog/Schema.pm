package Nblog::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

sub new_from_config {
    my( $class, $config ) = @_;
    my $schema = Nblog::Schema->connect( @{ $config->{connect_info} } );
    if( $config->{deploy_on_start} ){
        $schema->deploy();
        my $user = $schema->resultset( 'User' )->create( { username => 'test', password => 'pass_for_test', email => 'root@localhost', is_admin => 1, about_me => 'This is the test user with admin privileges' } );
        my $user2 = $schema->resultset( 'User' )->create( { username => 'test2', password => 'pass_for_test', email => 'root@localhost', about_me => 'This is the test user without admin privileges' } );

        my $blog = $user->create_blog( title => 'Test blog' );
        $blog->add_to_articles( { subject => 'test test', body => 'test', } );
        my $blog2 = $user2->create_blog( title => 'Test blog 2' );
        my $article = $blog2->add_to_articles( { subject => 'test2 test2', body => 'test2', } );
        my $tag = $schema->resultset( 'Tag' )->create( { name => 'test' } );
        $article->add_to_tags( $tag );
    }
    return $schema;
}
 

1;
