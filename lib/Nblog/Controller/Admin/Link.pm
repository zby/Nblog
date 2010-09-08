use strict;
use warnings;

package Nblog::Controller::Admin::Link;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::Link' );


1;
