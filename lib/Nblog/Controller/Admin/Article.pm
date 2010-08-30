use strict;
use warnings;

package Nblog::Controller::Admin::Article;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use Nblog::Form::Article;

sub list_action {
    my ( $self ) = @_;
    return $self->render( 
        articles => $self->application->schema->resultset('Article'),
        tabnavid => 'tabnav2' 
    );
}



1;
