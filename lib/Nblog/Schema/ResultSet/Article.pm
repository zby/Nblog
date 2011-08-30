package Nblog::Schema::ResultSet::Article;
use base 'DBIx::Class::ResultSet';

sub get_latest_articles
{
   my ( $self, $number_of_posts ) = @_;
   my $rows = 10;
   $rows = $number_of_posts if defined $number_of_posts;
   return $self->search( undef, { rows => $rows, order_by => 'article_id desc' } );
}

sub archived
{
   my ( $self, $year, $month, $day ) = @_;

   my $lastday;
   if( defined $day ) {
       $lastday = $day;
   }
   else {
      $day = 1;
      $lastday = DateTime->last_day_of_month( year => $year, month => $month )->day;

   }
   $day   = sprintf '%02d', $day;
   $lastday   = sprintf '%02d', $lastday;
   $month = sprintf '%02d', $month;
   return $self->search(
     {
        created_at => {
           -between => [ "$year-$month-$day 00:00:00", "$year-$month-$lastday 23:59:59" ]
        }
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
