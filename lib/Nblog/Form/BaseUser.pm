package Nblog::Form::BaseUser;

use HTML::FormHandler::Moose;
use HTML::FormHandler::Types ('Email');

use Nblog::Form::Formats;

extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';


has_field 'website' => (
   label    => 'Website',
   size     => 25,
);

has_field 'email' => (
      required => 1,
      label    => 'E-Mail',
      apply => [ Email ],
      size     => 25,
);

with 'Nblog::Form::Formats';

has_field 'about_me' => (
    type     => 'TextArea',
    label    => 'About Me',
    rows     => 20,
    cols     => 40,
);

has_field 'submit' => (
   type => 'Submit',
   value => 'Save',
   order => 20
);



no HTML::FormHandler::Moose;
1;
