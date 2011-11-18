package Nblog::Form::User;

use HTML::FormHandler::Moose;

extends 'Nblog::Form::BaseUser';

has_field 'username' => (
   required => 1,
   label    => 'User Name',
   size     => 25,
);

has_field 'password' => (
   type     => 'Password',
   label    => 'Password',
   size     => 25,
);

has_field 'is_admin' => (
   label    => 'Is Admin',
   type => 'Boolean',
);


no HTML::FormHandler::Moose;
1;
