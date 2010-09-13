use strict;
use warnings;

package Nblog::Controller;

use base 'WebNano::Controller';

sub index_action {
    my $self = shift;
    my $articles = $self->application->schema->resultset('Nblog::Schema::Result::Article')->get_latest_articles();
    return $self->render( template => 'blog_index.tt', articles => $articles );
}

sub logout_action {
    my $self = shift;
    my $req = $self->request;
    if( $req->param( 'logout' ) ){
        delete $self->env->{'psgix.session'}{user_id};
    }
    my $res = $req->new_response();
    $res->redirect( '/' );
    return $res;
}

sub archived_action {
    my ( $self, $year, $month, $day ) = @_;

    my $articles = $self->application->schema->resultset('Article')->archived( $year, $month, $day );
    return $self->render( 
        template => 'blog_index.tt',
        articles => $articles,
    );
}



1;

