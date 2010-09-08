use strict;
use warnings;

package Nblog::Controller::Admin;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

around 'local_dispatch' => sub {
    my $orig = shift;
    my $self = shift;
    if( !$self->env->{user} ){
        return $self->render( template => 'login_required.tt' );
    }
    $self->$orig( @_ );
};

1;
