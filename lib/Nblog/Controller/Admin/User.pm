use strict;
use warnings;

package Nblog::Controller::Admin::User;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::User' );

1;
