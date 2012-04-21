use strict;
use warnings;

package Nblog::Controller::Blog::Feed;
use Moose;
extends 'Nblog::Controller::Feed';

has blog => ( is => 'ro', required => 1 );

sub article_rs { 
    my $self = shift;
    return $self->blog->articles;
}

sub comment_rs { 
    my $self = shift;
    return $self->blog->comments;
}

sub tag_rs { 
    my $self = shift;
    return $self->blog->tags;
}


1;

