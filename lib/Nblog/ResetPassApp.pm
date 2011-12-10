use strict;
use warnings;

package Nblog::ResetPassApp;
use parent 'WebPrototypes::ResetPass';
use Plack::Util::Accessor qw( schema renderer );

sub find_user {
    my( $self, $name ) = @_;
    my $user = $self->schema->resultset( 'User' )->search({ username =>  $name })->next
       //
      $self->schema->resultset( 'User' )->search({ email => $name })->next;
    return $user, $user->email, $user->pass_token if $user;
    return;
}

sub wrap_text{
    my( $self, $text ) = @_;
    return $self->renderer->render( template => \$text );
}

sub update_user{
    my( $self, $user, $fields ) = @_;
    $user->update( $fields );
}


1;

