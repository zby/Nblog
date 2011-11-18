package Nblog::Form::Comment;

use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';
# with 'HTML::FormHandler::TraitFor::Captcha';
has '+item_class' => ( default => 'Comment' );

has '+name' => ( default => 'comment_form' );
has '+html_prefix' => ( default => 1 );

has 'user' => ( is => 'rw' );
has 'article_id' => ( is => 'rw' );
has 'remote_ip' => ( is => 'rw' );
has 'ctx' => ( is => 'rw' );

has_field 'name' => (
    required => 1,
    label    => 'Name',
    size     => 25,
    inactive => 1,
);

has_field 'email' => (
    label    => 'Email',
    size     => 25,
    inactive => 1,
);

has_field 'url' => (
    label    => 'Website',
    size     => 25,
    inactive => 1,
);

with 'Nblog::Form::Formats';

has_field 'body' => (
    type     => 'TextArea',
    required => 1,
    label    => 'Body',
    cols     => 30,
    rows     => 10
);

has_field 'verification' => (
    label    => 'Verification',
    size     => 25,
    inactive => 1,
    required => 1,
);

has_field 'submit' => (
    type  => 'Submit',
    value => 'Save'
);

before 'set_active' => sub {
    my $self = shift;
    $self->active( [ 'name', 'email']) unless ( $self->user ); 
};

after 'update_model' => sub {
    my $self = shift;
    my %update = ( article_id => $self->article_id, remote_ip => $self->remote_ip );
    $update{user_id} = $self->user->id if $self->user;
    $self->item->update( \%update );
};

no HTML::FormHandler::Moose;
1;
