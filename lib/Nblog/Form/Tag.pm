package Nblog::Form::Tag;

use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has_field 'name' => (
   required => 1,
   label    => 'Tag Name',
   size     => 40,
);

has_field 'submit' => ( 
      type => 'Submit',
      value => 'Save' 
);

no HTML::FormHandler::Moose;
1;
