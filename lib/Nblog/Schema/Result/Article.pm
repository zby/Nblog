package Nblog::Schema::Result::Article;

use strict;
use warnings;
use base 'DBIx::Class';
#use Text::Textile 'textile';
use Nblog::Format;
use namespace::autoclean;

__PACKAGE__->load_components( 'TimeStamp', 'InflateColumn::DateTime', 'Core' );
__PACKAGE__->table('articles');
__PACKAGE__->resultset_class('Nblog::Schema::ResultSet::Article');
__PACKAGE__->add_columns(
   "article_id",
   {
      data_type         => 'integer',
      is_auto_increment => 1,
      default_value     => undef,
      is_nullable       => 0,
   },
   "subject",
   {
      data_type     => "character varying",
      default_value => undef,
      is_nullable   => 1,
      size          => 255,
   },
   "body",
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
   "updated_at",
   {
      data_type     => "datetime",
      set_on_create => 1,
      set_on_update => 1,
      is_nullable   => 1,
      size          => undef,
   },

   "user_id",
   {
      data_type     => "integer",
      default_value => undef,
      is_nullable   => 1,
      size          => 4,
   },
);

__PACKAGE__->set_primary_key("article_id");
__PACKAGE__->has_many(
   'comments' => 'Nblog::Schema::Result::Comment',
   'article_id'
);

__PACKAGE__->belongs_to(
   'user' => 'Nblog::Schema::Result::User',
   'user_id'
);

__PACKAGE__->has_many(
   'tags_articles' => 'Nblog::Schema::Result::TagArticle',
   'article_id'
);
__PACKAGE__->many_to_many( 'tags' => 'tags_articles', 'tag' );


sub formatted_body {
    my $self = shift;
    my $format = $self->format || 'text';
    return Nblog::Format::format_html( $self->body, $format );
}

1;
