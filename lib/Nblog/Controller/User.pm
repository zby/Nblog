use strict;
use warnings;

package Nblog::Controller::User;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use URI::Escape 'uri_unescape';
use Nblog::Form::User;

has user => ( is => 'rw' );

around local_dispatch => sub {
    my ( $orig, $self, $username, @args ) = @_;
    my $app = $self->app;
    my $user= $app->schema->resultset('User')
        ->search( { 'username' => $username } )->first;
        warn $username;
    if( $user ){
        $self->user( $user);
        $self->$orig( @args );
    }
    else{
        my $res = Plack::Response->new(404);
        $res->content_type('text/plain');
        $res->body( 'No such page' );
        return $res;
    }
};


sub index_action {
    my $self = shift;
    return $self->render(); 
}

sub edit_action {
    my $self = shift;
    my $params = $self->req->parameters->as_hashref_mixed;
    my $form = Nblog::Form::BaseUser->new(
        params => $params,
        item => $self->user,
    );
    if( $self->req->method eq 'POST' && $form->process() ){
        my $res = Plack::Response->new();
        $res->redirect( $self->self_url . $self->user->username );
        return $res;
    }
    my $rendered = $form->render;
    return $self->render( template => \$rendered );
}



1;
