use strict;
use warnings;

package Nblog::Controller::Blog;
use Moose;
use MooseX::NonMoose;


extends 'WebNano::Controller';

has blog => ( is => 'ro' );

sub handle {
    my ( $class, %args ) = @_;
    my @path = @{ delete $args{path} };
    my $id = shift @path;
    my $blog;
    if( $id ){
        my $rs = $args{app}->schema->resultset( 'Blog' );
        $blog = $rs->search( { seo_url => $id } )->first;
    }
    if( ! $blog ) {
        my $res = Plack::Response->new(404);
        $res->content_type('text/plain');
        $res->body( 'No blog with id: ' . $id );
        return $res;
    }
    my $self = $class->new( 
        %args, 
        blog => $blog,
        path => \@path,
        self_url => $args{self_url} . "$id/",
    );
    return $self->local_dispatch( @path );
};


sub index_action {
    my $self = shift;
    my $articles = $self->app->schema->resultset('Nblog::Schema::Result::Article')->get_latest_articles(
        10, { blog_id => $self->blog->blog_id }
    );
    return $self->render( site_name => $self->blog->title, articles => $articles );
}

sub login_action {
    my $self = shift;
    my $env = $self->env;
    return $self->render( 
        template => 'login.tt',
        redir_to => $env->{'psgix.session'}{redir_to},
    );
}


sub archived_action {
    my ( $self, $year, $month, $day ) = @_;

    my $articles = $self->app->schema->resultset('Article')->archived( year => $year, month => $month, day => $day );
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

sub tag_action {
   my ( $self, $tag ) = @_;

   my $db_tag =
      $self->app->schema->resultset('Tag')
      ->search( { name => { like => $self->app->ravlog_url_to_query($tag) } } )->first();
   warn $db_tag->id;
   return $self->render(
       template => 'blog_index.tt',
       articles => scalar $db_tag->articles,
       rss      => $db_tag->name,
   );
}

sub page_action {  
   my ( $self, $what ) = @_;

   my $page =
       $self->app->schema->resultset('Page')
      ->search( { name => { like => $self->app->ravlog_url_to_query($what) } } )->first();

   my $name = $self->app->ravlog_txt_to_url( $page->name );
   my $sidebar = $page->display_sidebar();
   return $self->render( 
       template => 'page.tt',
       page => $page,
       title => $page->name,
       sidebar => $sidebar,
       activelink => { $name => 'activelink' },
   )
}


1;

