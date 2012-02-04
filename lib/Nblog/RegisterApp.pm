use strict;
use warnings;

package Nblog::RegisterApp;
use parent qw(WebPrototypes::Registration);

use Plack::Util::Accessor qw( renderer schema );

sub find_user {
    my( $self, $name ) = @_;
    my $user = $self->schema->resultset( 'User' )->search({ username =>  $name })->next;
    return $user;
}

sub wrap_text{
    my( $self, $text ) = @_;
    return $self->renderer->render( template => \$text );
}

sub create_user{
    my( $self, %fields ) = @_;
    return $self->schema->resultset( 'User' )->create( { %fields } );
}

1;

