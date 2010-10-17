use strict;
use warnings;

package Nblog::Controller;

use base 'WebNano::DirController';

sub index_action {
    my $self = shift;
    my $articles = $self->app->schema->resultset('Nblog::Schema::Result::Article')->get_latest_articles();
    return $self->render( template => 'blog_index.tt', articles => $articles );
}

sub logout_action {
    my $self = shift;
    my $req = $self->req;
    if( $req->param( 'logout' ) ){
        delete $self->env->{'psgix.session'}{user_id};
    }
    my $res = $req->new_response();
    $res->redirect( '/' );
    return $res;
}

sub archived_action {
    my ( $self, $year, $month, $day ) = @_;

    my $articles = $self->app->schema->resultset('Article')->archived( $year, $month, $day );
    return $self->render( 
        template => 'blog_index.tt',
        articles => $articles,
    );
}


sub search_action {
   my ( $self, $phrase ) = @_;

   if ( !defined $phrase )
   {
      $phrase = $self->req->param( 'phrase' );
   }

   my $articles = $self->app->schema->resultset('Article')->search(
      [
         subject => { like => "%$phrase%" },
         body    => { like => "%$phrase%" },
      ]
   );

   return $self->render( 
       template => 'blog_index.tt',
       articles => $articles,
   )
}

sub page_action {  
   my ( $self, $what ) = @_;

   my $page =
       $self->app->schema->resultset('Page')
      ->search( { name => { like => $self->app->ravlog_url_to_query($what) } } )->first();

   my $name = $self->app->ravlog_txt_to_url( $page->name );
   my $sidebar = undef unless $page->display_sidebar();
   return $self->render( 
       template => 'page.tt',
       page => $page,
       title => $page->name,
       sidebar => $sidebar,
       activelink => { $name => 'activelink' },
   )
}


1;

