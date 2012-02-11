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
    if( $self->app->secure && $env->{'psgi.url_scheme'} ne 'https' ){
        my $res = Plack::Response->new;
        my $secure_url = 'https://' . $env->{SERVER_NAME} . $env->{PATH_INFO};
        $res->redirect( $secure_url );
        return $res;
    }
    if( $env->{user} && !$env->{user}->is_admin ){
        return $self->app->renderer->render( template => \"You have no access to this part of the site", c => $self );
    }
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
