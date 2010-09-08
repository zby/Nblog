use strict;
use warnings;

package Nblog::Controller::Admin::Tag;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::Tag' );


1;
