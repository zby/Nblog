use strict;
use warnings;
package Nblog;

use Moose;
use MooseX::NonMoose;
use Moose::Util::TypeConstraints;

extends 'WebNano';
use Nblog::Schema;
use WebNano::Renderer::TT;

with 'MooseX::SimpleConfig';

subtype 'Nblog::Schema::Connected' => as class_type( 'Nblog::Schema' );
coerce 'Nblog::Schema::Connected'
    => from 'HashRef' 
        => via { Nblog::Schema->connect( $_->{connect_info} ) };

has schema => ( is => 'ro', isa => 'Nblog::Schema::Connected', coerce => 1 );

subtype 'Nblog::WebNano::Renderer::TT' => as class_type ( 'WebNano::Renderer::TT' );
coerce 'Nblog::WebNano::Renderer::TT'
    => from 'HashRef'
        => via { WebNano::Renderer::TT->new( %$_ ) };

has renderer => ( is => 'ro', isa => 'Nblog::WebNano::Renderer::TT', coerce => 1 );

around handle => sub {
    my $orig = shift;
    my $self = shift;
    my $env  = shift;
    if( $env->{'psgix.session'}{user_id} ){
        $env->{user} = $self->schema->resultset( 'User' )->find( $env->{'psgix.session'}{user_id} );
    }
    else{
        my $req = Plack::Request->new( $env );
        if( $req->param( 'login' ) && $req->param( 'password' ) ){
            my $user = $self->schema->resultset( 'User' )->search( { username => $req->param( 'login' ) } )->first;
            if( $user->check_password( $req->param( 'password' ) ) ){
                $env->{user} = $user;
                $env->{'psgix.session'}{user_id} = $user->id;
            }
        }
    }
    $self->$orig( $env, @_ );
};

1;
