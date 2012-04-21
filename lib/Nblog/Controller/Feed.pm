use strict;
use warnings;

package Nblog::Controller::Feed;
use Moose;
use MooseX::NonMoose;
use Plack::Response;

extends 'WebNano::Controller';

use XML::Feed;
use Text::Textile qw(textile);

sub artile_rs { $_[0]->app->schema->resultset( 'Article' ) }

sub comment_rs { $_[0]->app->schema->resultset( 'Comment' ) }

sub tag_rs { $_[0]->app->schema->resultset( 'Tag' ) }


sub comments_action {
   my ( $self, $subject ) = @_;

   my $feed = XML::Feed->new('RSS');
   $feed->title( $self->app->name . ' RSS' );
   $feed->link( $self->self_url );
   $feed->description( $self->app->name . ' RSS Feed' );

   my @comments;
   if ( !defined $subject )
   {
      @comments = $self->comment_rs->all();
   }
   else
   {
      @comments =
         $self->article_rs
         ->search( { subject => { like => $self->app->ravlog_url_to_query($subject) } } )->first()
         ->comments();
   }

   for ( my $i = 0; $i < scalar(@comments); $i++ )
   {
      my $feed_entry = XML::Feed::Entry->new('RSS');
      $feed_entry->title(
         $comments[$i]->name() . "'s comment " . $comments[$i]->created_at->ymd() );
      my $url = $self->app->ravlog_txt_to_url( $comments[$i]->article()->subject() );
      $feed_entry->link( $self->self_url . '/view/' . $url . '#comments' );
      $feed_entry->summary( textile( $comments[$i]->body() ) );
      $feed_entry->issued( $comments[$i]->created_at() );
      $feed->add_entry($feed_entry);
   }
   my $res = Plack::Response->new(200);
   $res->content_type('application/rss+xml');
   $res->body( $feed->as_xml );
   return $res;
}

sub articles_action {
   my ( $self, $tag ) = @_;

   my $feed = XML::Feed->new('RSS');
   $feed->title( $self->app->name . ' RSS' );
   $feed->link( $self->self_url );
   $feed->description( $self->app->name . ' RSS Feed' );

   my @articles;
   if ( !defined $tag )
   {
      @articles = $self->article_rs->get_latest_articles();
   }
   else
   {
      @articles =
         $self->tag_rs
         ->search( { name => { like => $self->app->ravlog_url_to_query($tag) } } )->first()->articles();
   }

   for ( my $i = 0; $i < scalar(@articles); $i++ )
   {
      my $feed_entry = XML::Feed::Entry->new('RSS');
      $feed_entry->title( $articles[$i]->subject() );
      my $url = $self->app->ravlog_txt_to_url( $articles[$i]->subject() );
      $feed_entry->link( $self->self_url . '/view' . $url );
      $feed_entry->summary( textile( $articles[$i]->body() ) );
      $feed_entry->issued( $articles[$i]->created_at() );
      $feed->add_entry($feed_entry);
   }

   my $res = Plack::Response->new(200);
   $res->content_type('application/rss+xml');
   $res->body( $feed->as_xml );
   return $res;
}

1;
