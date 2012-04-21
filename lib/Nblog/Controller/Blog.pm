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

sub myroot { $_[0]->self_url }

sub calendar {
   my ( $self ) = @_;

   my $dt  = DateTime->now();
   my $cal = new Nblog::Calendar(
      'year'  => $dt->year,
      'month' => $dt->month
   );
   $cal->border(0);
   $cal->width(50);
   $cal->headerclass('month_date');
   $cal->showweekdayheaders(0);

   my @articles = $self->app->schema->resultset('Article')->search( { blog_id => $self->blog->blog_id } )->from_month( $dt->month );

   foreach my $article (@articles)
   { 
      my $location =
         $self->self_url
         . 'archived/'
         . $article->created_at->year() . '/'
         . $article->created_at->month() . '/'
         . $article->created_at->mday();
      $cal->setdatehref( $article->created_at->mday(), $location );
   }

   return $cal->as_HTML;
}

sub archives
{
   my ( $self ) = @_;

   my @articles = $self->app->schema->resultset('Article')->search( { blog_id => $self->blog->blog_id } )->all();

   unless (@articles)
   { 
      return "<p>No Articles in Archive!</p>";
   }

   my $months;
   foreach my $article (@articles)
   { 
      my $month = $article->created_at()->month_name();
      my $year  = $article->created_at()->year();
      my $key   = "$year $month";
      if ( ( defined $months->{$key}->{count} ) && ( $months->{$key}->{count} > 0 ) )
      { 
         $months->{$key}->{count} += 1;
      }
      else
      {
         $months->{$key}->{count} = 1;
         $months->{$key}->{year}  = $year;
         $months->{$key}->{month} = $article->created_at()->month();
      }
   }

   my @out;
   while ( my ( $key, $value ) = each( %{$months} ) )
   {
      push @out,
         "<li><a href='" . $self->self_url . "archived/$value->{year}/$value->{month}'>$key</a> <span class='special_text'>($value->{count})</span></li>";
   }
   return join( ' ', @out );
}

sub archived_action {
    my ( $self, $year, $month, $day ) = @_;

    my $articles = $self->app->schema->resultset('Article')->search( { blog_id => $self->blog->blog_id } )->archived( year => $year, month => $month, day => $day );
    return $self->render( 
        template => 'index.tt',
        articles => $articles,
        site_name => $self->blog->title,
    );
}


sub search_action {
   my ( $self, $phrase ) = @_;

   if ( !defined $phrase )
   {
      $phrase = $self->req->param( 'phrase' );
   }

   my $articles = $self->app->schema->resultset('Article')->search( { blog_id => $self->blog->blog_id } )->search(
      [
         subject => { like => "%$phrase%" },
         body    => { like => "%$phrase%" },
      ]
   );

   return $self->render( 
       template => 'index.tt',
       articles => $articles,
       site_name => $self->blog->title,
   )
}

sub tag_action {
   my ( $self, $tag ) = @_;

   my $db_tag =
      $self->app->schema->resultset('Tag')
      ->search( { name => { like => $self->app->ravlog_url_to_query($tag) } } )->first();
   warn $db_tag->id;
   return $self->render(
       template => 'index.tt',
       articles => scalar $db_tag->articles->search( { blog_id => $self->blog->blog_id } ),
       rss      => $db_tag->name,
       site_name => $self->blog->title,
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

