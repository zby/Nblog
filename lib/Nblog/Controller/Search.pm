use strict;
use warnings;

package Nblog::Controller::Search;

use base 'WebNano::Controller';

sub search_action {
   my ( $self, $phrase ) = @_;

   if ( !defined $phrase )
   {
      $phrase = $self->req->params->{phrase};
   }

   my @finds = $self->app->schema->resultset('Article')->search(
      [
         subject => { like => "%$phrase%" },
         body    => { like => "%$phrase%" },
      ]
   )->all();

   return $self->render( 
       template => 'blog_index.tt',
       articles => [@finds]
   )
}

1;
