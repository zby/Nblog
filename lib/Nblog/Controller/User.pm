use strict;
use warnings;

package Nblog::Controller::User;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use URI::Escape 'uri_unescape';
use Nblog::Form::Comment;

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


1;
