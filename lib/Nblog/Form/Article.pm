package Nblog::Form::Article;

use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has_field 'subject' => (
      label    => 'Subject',
      size     => 40,
      required => 1,
);

has_field 'tags' => (
      type     => 'Select',
      label    => 'Tags',
      multiple => 1,
);

with 'Nblog::Form::Formats';

has_field 'body' => (
      required => 1,
      type     => 'TextArea',
      label    => 'Body',
      rows     => 20,
      cols     => 40,
);
has_field 'submit' => ( 
      type => 'Submit',
      id => '_submit',
      value => 'Save',
      order => 20
);


no HTML::FormHandler::Moose;
1;
