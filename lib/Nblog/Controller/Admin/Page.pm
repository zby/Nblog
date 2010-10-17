use strict;
use warnings;

package Nblog::Controller::Admin::Page;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::Page' );

sub after_POST { shift->self_url }

1;
