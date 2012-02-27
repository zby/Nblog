package Nblog::Schema::Result::BlogUser;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( "Core" );
__PACKAGE__->table("blogs_users");
__PACKAGE__->add_columns(
   "blog_user_id",
   {
      data_type         => 'integer',
      is_auto_increment => 1,
      default_value     => undef,
      is_nullable       => 0,
   },
   blog_id => { data_type => "integer", is_nullable => 0, size => 4 },
   user_id => { data_type => "integer", is_nullable => 0, size => 4 },
   role => { data_type => 'char', default_value => 'o', is_nullable => 0, size => 1}
);

__PACKAGE__->set_primary_key("blog_user_id");

__PACKAGE__->belongs_to( 'blog', 'Nblog::Schema::Result::Blog', 'blog_id' );
__PACKAGE__->belongs_to( 'user', 'Nblog::Schema::Result::User', 'user_id' );

1;

