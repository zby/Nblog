use strict;
use warnings;

package Nblog::Controller::Admin;
use Moose;
use MooseX::NonMoose;
use Plack::Response;

extends 'WebNano::DirController';

around 'local_dispatch' => sub {
    my $orig = shift;
    my $self = shift;
    my $env = $self->env;
    if( !$env->{user} ){
        my $res = Plack::Response->new;
        $res->redirect( '/login' );
        $env->{'psgix.session'}{redir_to} = $env->{PATH_INFO};
        return $res;
    }
    $self->$orig( @_ );
};

sub index_action {
    my $res = Plack::Response->new;
    $res->redirect( '/Admin/Article/' );
    return $res;
}


1;
