use strict;
use warnings;

package Nblog::Controller::Admin::Article;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::Article' );


1;
