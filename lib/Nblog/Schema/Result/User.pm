package Nblog::Schema::Result::User;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( 'EncodedColumn', "Core" );
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
   "user_id",
   {
      data_type         => 'integer',
      is_auto_increment => 1,
      default_value     => undef,
      is_nullable       => 0,
   },
   "username",
   {
      data_type     => "character varying",
      default_value => undef,
      is_nullable   => 1,
      size          => 255,
   },
   "password",
   {
      data_type     => "character varying",
      default_value => undef,
      is_nullable   => 1,
      size          => 255,
      encode_column => 1,
      encode_class  => 'Digest',
      encode_args   => {algorithm => 'SHA-1', format => 'hex', salt_length => 10},
      encode_check_method => 'check_password',

   },
   "website",
   {
      data_type     => "character varying",
      default_value => undef,
      is_nullable   => 1,
      size          => 255,
   },
   "about_me",
   {
      data_type     => "text",
      default_value => undef,
      is_nullable   => 1,
   },
   "format",
   {
      data_type     => 'varchar',
      is_nullable   => 1,
      size          => 12,
   },
   "email",
   {
      data_type     => "character varying",
      default_value => undef,
      is_nullable   => 1,
      size          => 255,
   },
   "created_at",
   {
      data_type     => "datetime",
      default_value => "now()",
      is_nullable   => 1,
      size          => undef,
   },
   "pass_token",
   {
      data_type     => "character",
      default_value => undef,
      is_nullable   => 1,
      size          => 40,
   },
   "is_email_confirmed",
   {
      data_type     => "character",
      default_value => undef,
      is_nullable   => 1,
      size          => 1,
   },
   "is_admin",
   {
      data_type     => "character",
      default_value => undef,
      is_nullable   => 1,
      size          => 1,
   },


);

__PACKAGE__->set_primary_key("user_id");

__PACKAGE__->has_many(
    'blogs_users' => 'Nblog::Schema::Result::BlogUser',
    'user_id'
);
__PACKAGE__->many_to_many( 'blogs' => 'blogs_users', 'blog' );


sub insert
{
   my $self = shift;
   $self->created_at( DateTime->now() );
   $self->next::method(@_);
}

sub formatted_about_me {
    my $self = shift;
    my $format = $self->format || 'text';
    return Nblog::Format::format_html( $self->about_me, $format );
}

sub email_confirmed { ! defined( shift->email_token ) }

sub confirm_email { shift->update( { email_token => undef } ) }

sub create_blog { shift->add_to_blogs( { @_ }, { role => 'o' } ) }


1;

