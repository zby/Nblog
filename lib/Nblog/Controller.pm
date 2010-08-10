use strict;
use warnings;

package Nblog::Controller;

use base 'WebNano::Controller';

sub index_action {
    my $self = shift;
    my $articles = $self->application->schema->resultset('Nblog::Schema::Result::Article')->get_latest_articles();
    my $out = '';
    return $self->render( 'blog_index.tt', { articles => $articles } );
}

1;

