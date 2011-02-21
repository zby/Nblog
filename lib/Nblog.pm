use strict;
use warnings;
package Nblog;

use Moose;
use MooseX::NonMoose;
use Moose::Util::TypeConstraints;

use Plack::Request;
use HTML::CalendarMonthSimple;
use DateTime;

use Plack::Middleware::Static;
use Plack::Middleware::Session;
use Plack::Session::Store::Cache;
use Plack::App::Cascade;
use Plack::App::URLMap;
use Plack::App::File;
use Plack::Middleware::Auth::Form;

use CHI;

extends 'WebNano';
use Nblog::Schema;
use WebNano::Renderer::TT;

with 'MooseX::SimpleConfig';

has '+configfile' => ( default => 'nblog_local.pl' );

has 'name' => ( is => 'ro', isa => 'Str' );

has 'secure' => ( is => 'ro', isa => 'Num' );

subtype 'Nblog::Schema::Connected' => as class_type( 'Nblog::Schema' );
coerce 'Nblog::Schema::Connected'
    => from 'HashRef' 
        => via { Nblog::Schema->connect( @{ $_->{connect_info} } ) };

has schema => ( is => 'ro', isa => 'Nblog::Schema::Connected', coerce => 1 );

subtype 'Nblog::WebNano::Renderer::TT' => as class_type ( 'WebNano::Renderer::TT' );
coerce 'Nblog::WebNano::Renderer::TT'
    => from 'HashRef'
        => via { WebNano::Renderer::TT->new( %$_ ) };

has renderer => ( is => 'ro', isa => 'Nblog::WebNano::Renderer::TT', coerce => 1 );

around handle => sub {
    my $orig = shift;
    my $self = shift;
    my $env  = shift;
    if( $env->{'psgix.session'}{user_id} ){
        $env->{user} = $self->schema->resultset( 'User' )->find( $env->{'psgix.session'}{user_id} );
    }
    $self->$orig( $env, @_ );
};

sub tags { shift->schema->resultset( 'Tag' )->all }

sub calendar {
   my ( $self ) = @_;

   my $dt  = DateTime->now();
   my $cal = new HTML::CalendarMonthSimple(
      'year'  => $dt->year,
      'month' => $dt->month
   );
   $cal->border(0);
   $cal->width(50);
   $cal->headerclass('month_date');
   $cal->showweekdayheaders(0);

   my @articles = $self->schema->resultset('Article')->from_month( $dt->month );

   foreach my $article (@articles)
   {
      my $location =
           '/archived/'
         . $article->created_at->year() . '/'
         . $article->created_at->month() . '/'
         . $article->created_at->mday();
      $cal->setdatehref( $article->created_at->mday(), $location );
   }

   return $cal->as_HTML;
}

sub ravlog_txt_to_url {
    my $self = shift;

    my ( $txt, $id ) = @_;

    $txt =~ s/(\'|\!|\`|\?)//g;
    $txt =~ s/ /\_/g;

    return $txt;
}
sub render_ravlog_date {
    my $self = shift;
    my $date = shift;
    my $dt = $self->datetime_to_ravlog_time($date);
    my $output = "<span class=\"ravlog_date\" title=\""
      . $dt
      . "\">$dt</span>";
    return $output;
}

sub datetime_to_ravlog_time {
    my $self = shift;

    my ($d) = shift;
    my $ext =
        $d->day_abbr() . ", "
      . $d->day() . " "
      . $d->month_abbr() . " "
      . $d->year() . " "
      . $d->hour . ":"
      . $d->minute . ":"
      . $d->second();
    return $ext;
}


sub archives
{
   my ( $self ) = @_;

   my @articles = $self->schema->resultset('Article')->all();

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
         "<li><a href='/archived/$value->{year}/$value->{month}'>$key</a> <span class='special_text'>($value->{count})</span></li>";
   }
   return join( ' ', @out );
}

sub ravlog_url_to_query {
    my $self = shift;

    my ($txt) = shift;

    $txt =~ s/\_/ /g;
    $txt =~ s/s /\%/g;
    return ( "%" . $txt . "%" );
}

sub pages {
   return shift->schema->resultset('Page')->search( { display_in_drawer => 1 } )->all();
}

has static_root => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    handles    => { static_roots => 'elements' },
);
    

around psgi_app => sub {
    my $orig = shift;
    my $self = shift;
    my $cascade = Plack::App::Cascade->new;
    my $favicon_c = Plack::App::Cascade->new;
    for my $root ( $self->static_roots ){
        $cascade->add( Plack::App::File->new(root => $root )->to_app );
        $favicon_c->add( Plack::App::File->new( file => "$root/images/favicon.ico" )->to_app );
    };
    my $app = Plack::App::URLMap->new;
    $app->map( '/static', $cascade );
    $app->map( '/favicon.ico', $favicon_c );
    $app->map( '/', $self->$orig( @_ ) );
    $app = Plack::Middleware::Auth::Form->wrap( 
        $app->to_app,
        authenticator => sub {
            my( $username, $password ) = @_;
            my $user = $self->schema->resultset( 'User' )->search( { username => $username } )->first;
            if( $user && $user->check_password( $password ) ){
                return { user_id => $user->id };
            }
            return 0;
        },
        no_login_page => 1,
    );
    return Plack::Middleware::Session->wrap( 
        $app, 
        store => Plack::Session::Store::Cache->new(
            cache => CHI->new(driver => 'FastMmap')
        )
    );
};

1;

__END__

# ABSTRACT: A simple blog engine

