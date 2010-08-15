use strict;
use warnings;

package Nblog::Controller::Article;
use Moose;
use MooseX::NonMoose;

extends 'WebNano::Controller';

use URI::Escape 'uri_unescape';
use Nblog::Form::Comment;

has article => ( is => 'ro' );

around handle => sub {
    my ( $orig, $class, %args ) = @_;
    my $path = delete $args{path};
    my( $path_part, $new_path ) = ( $path =~ qr{^([^/]*)/?(.*)} );
    my $application = $args{application};
    my $title = uri_unescape( $path_part );
    $args{article} = 
          $application->schema->resultset('Article')
                ->search( { 'subject' => { like => $application->ravlog_url_to_query($title) } } )->first;
    $args{path} = $new_path;
    $args{self_url} = $args{self_url} . $title;
    $class->$orig( %args );
};

sub index_action {
    return shift->view_action( @_ );
}

sub view_action {
    my $self = shift;
    my $form = Nblog::Form::Comment->new( 
        user => $self->env->{user},
        article_id => $self->article->id, 
        remote_ip => $self->env->{remote_ip},
        schema => $self->application->schema,
    );
    $form->process( params => $self->request->parameters->as_hashref );
    return $self->render( 'blog_view.tt', {
            article => $self->article,
            title   => $self->article->subject,
            comments => [ $self->article->comments->all ],
            comment_form => $form,
        }
    );
}


1;
