use strict;
use warnings;

package Nblog::Controller::Admin::Page;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::Page' );

sub after_POST { shift->self_url };

sub template_search_path { [ 'Admin', 'Admin::Page' ] };

1;
