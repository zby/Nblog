package Nblog::Schema::ResultSet::Article;
use base 'DBIx::Class::ResultSet';

sub get_latest_articles
{
   my ( $self, $rows, $restriction ) = @_;
   $rows = 10 if not defined $rows;
   return $self->search( $restriction, { rows => $rows, order_by => 'article_id desc' } );
}

sub archived {
   my ( $self, %params ) = @_;

   my $day = $params->{day};
   my $lastday;
   if( defined $day ) {
       $lastday = $day;
   }
   else {
      $day = 1;
      $lastday = DateTime->last_day_of_month( year => $params{year}, month => $params{month} )->day;
   }
   $day   = sprintf '%02d', $day;
   $lastday   = sprintf '%02d', $lastday;
   my $month = sprintf '%02d', $params{month};
   my $year  = $params{year};
    
   return $self->search(
     {
        created_at => {
           -between => [ "$year-$month-$day 00:00:00", "$year-$month-$lastday 23:59:59" ]
        },
        %{ $params{restriction} },
     },
     { order_by => 'article_id desc' }
   );
}

sub from_month
{
   my ( $self, $month, $year ) = @_;
   $month = sprintf '%02d', $month;

   $year = DateTime->now()->year() unless defined $year;

   my $dt      = DateTime->now();
   my $lastday = DateTime->last_day_of_month( year => $year, month => $month )->day;
   my $hour    = $dt->hour();

   return $self->search(
      { created_at => { -between => [ "$year-$month-01", "$year-$month-$lastday" ] } },
      { order_by   => 'article_id desc' } )->all();
}

1;
