use strict;
use warnings;

package Nblog::Controller::Admin::Link;
use Moose;

extends 'WebNano::Controller::CRUD';

has '+form_class' => ( default => 'Nblog::Form::Link' );

sub after_POST { shift->self_url };

sub template_search_path { [ 'Admin', 'Admin::Ling' ] };

1;
