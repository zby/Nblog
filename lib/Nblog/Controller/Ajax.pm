use strict;
use warnings;

package Nblog::Controller::Ajax;

use base 'WebNano::Controller';

=head1 NAME

Nblog::Controller::Ajax 

=head1 DESCRIPTION

=head1 METHODS

=cut

=head2 index 

=cut

sub check_articles_action {
   my ( $self ) = @_;

   my @articles = $self->app->schema->resultset( 'Article' )->search(
      {
         -or => {
            subject => { 'like' => '%' . $self->req->param( 'field' ) . '%' },
            body    => { 'like' => '%' . $self->req->param( 'field' ) . '%' }
         }
      }
   )->all();

   my @out = ();
   push @out, '<div align="center">';
   foreach my $article (@articles)
   {
      push @out,
         '<a href="/Article/'
         . $self->app->ravlog_txt_to_url( $article->subject() ) . '">'
         . $article->subject()
         . '</a><br/>';
   }
   push @out, '</div>';

   return join( ' ', @out );
}

sub sort_by_action {
   my ( $self ) = @_;

   my @tags;
   my @out = ();
   if ( $self->req->param( 'field' ) =~ /alpha/ )
   {
      @tags = $self->app->schema->resultset( 'Tag')->search( undef, { order_by => 'name' } )->all();
   }
   else
   {
      @tags = $self->app->schema->resultset( 'Tag')->search( undef, { order_by => 'tag_id' } )->all();
   }

   push @out, '<ul>';
   foreach my $tag (@tags)
   {
      push @out,
         "<li><a title='"
         . $tag->name()
         . "' href='/tag/"
         . $self->app->ravlog_txt_to_url( $tag->name() ) . "'>"
         . $tag->name()
         . "</a></li>";
   }
   push @out, '</ul>';

   return join( '', @out );
}

sub help_complete_combobox_action {
   my ( $self, $class_name, $field_name ) = @_;

   my @class_instances =
      $self->app->schema->resultset( $class_name )
      ->search( { $field_name => { 'ilike' => $self->req->param( 'field' ) . '%' } } )->all();

   my @out;
   foreach my $item (@class_instances)
   {
      push @out, [ '' . $item->$field_name . '' ];
   }
   my $j = JSON::Any->new;
   return $j->encode( [@out] );
}


=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
