use strict;
use warnings;

package DvdDatabase::Controller;

use base 'WebNano::Controller';

sub index_action {
    my $self = shift;
    my $articles = $self->schema->resultset('DB::Article')->get_latest_articles();
    my $out = '';
    $self->render( template => 'blog_index.tt', vars => { articles => $articles }, output => \$out );
    return $out;
}

