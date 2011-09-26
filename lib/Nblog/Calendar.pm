# HTML::CalendarMonthSimple.pm
# Generate HTML calendars. An alternative to HTML::CalendarMonth
# Herein, the symbol $self is used to refer to the object that's being passed around.

package Nblog::Calendar;
use strict;

use base 'HTML::CalendarMonthSimple';
use Date::Calc;

sub new {
   my $class = shift;
   my $self = $class->SUPER::new();
   
   # Set the default calendar header
   $self->{'header'} = sprintf("<h1 class='month_date'>%s %d</h1>",
       Date::Calc::Month_to_Text($self->{'month'}),$self->{'year'});
   return $self;
}

sub as_HTML {
    my $self = shift;
    my $html = $self->SUPER::as_HTML( @_ );
    $html =~ s{<p><b>(.*?)</b></p>}{<span>$1</span>}g;
    return $html;
}

1;
