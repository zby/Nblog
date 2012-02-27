package Nblog::Schema::Result::Blog;

use strict;
use warnings;
use base 'DBIx::Class';
#use Text::Textile 'textile';
use Nblog::Format;
use namespace::autoclean;

__PACKAGE__->load_components( 'TimeStamp', 'InflateColumn::DateTime', 'Core' );
__PACKAGE__->table('blogs');
__PACKAGE__->add_columns(
   "blog_id",
   {
      data_type         => 'integer',
      is_auto_increment => 1,
      default_value     => undef,
      is_nullable       => 0,
   },
   "title",
   {
      data_type     => "character varying",
      default_value => undef,
      is_nullable   => 1,
      size          => 255,
   },
   "intro",
   {
      data_type     => "text",
      default_value => undef,
      is_nullable   => 1,
      size          => undef,
   },
   "format",
   {
      data_type     => 'varchar',
      is_nullable   => 1,
      size          => 12,
   },
   "created_at",
   {
      data_type     => "datetime",
      set_on_create => 1,
      is_nullable   => 1,
      size          => undef,
   },
   "creator_id",
   {
      data_type     => "integer",
      default_value => undef,
      is_nullable   => 1,
      size          => 4,
   },
);

__PACKAGE__->set_primary_key("blog_id");
__PACKAGE__->has_many(
   'articles' => 'Nblog::Schema::Result::Article',
   'blog_id'
);

__PACKAGE__->has_many(
   'blogs_users' => 'Nblog::Schema::Result::BlogUser',
   'blog_id'
);
__PACKAGE__->many_to_many( 'contributors' => 'blogs_users', 'user' );


sub formatted_intro {
    my $self = shift;
    my $format = $self->format || 'text';
    return Nblog::Format::format_html( $self->intro, $format );
}

1;
