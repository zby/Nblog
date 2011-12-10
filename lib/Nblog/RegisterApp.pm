use strict;
use warnings;

package Nblog::RegisterApp;
use parent qw(Plack::Component);

use String::Random 'random_regex';
use Email::Valid;
use Plack::Util::Accessor qw( schema renderer email_validator );

sub prepare_app {
    my $self = shift;
    $self->email_validator( Email::Valid->new() ) if !defined $self->email_validator;
}

sub find_user {
    my( $self, $name ) = @_;
    my $user = $self->schema->resultset( 'User' )->search({ username =>  $name })->next;
    return $user;
}

sub wrap_text{
    my( $self, $text ) = @_;
    return $self->renderer->render( template => \$text );
}

sub create_user{
    my( $self, %fields ) = @_;
    return $self->schema->resultset( 'User' )->create( { %fields } );
}

sub build_reply{
    my( $self, $text ) = @_;
    return [ 200, [ 'Content-Type' => 'text/html' ], [ $self->wrap_text( $text ) ] ];
}

sub call {
    my($self, $env) = @_;
    my $req = Plack::Request->new( $env );
    my $uerror = '';
    my $eerror = '';
    my $username = '';
    my $email = '';
    if( $req->method eq 'POST' ){
        $username = $req->param( 'username' );
        $email = $req->param( 'email' );
        if( $self->find_user( $username ) ){
            $uerror = '<span class="error">This username is already registered</span>';
        }
        if( !$self->email_validator->address( $email ) ){
            $eerror = '<span class="error">Wrong format of email</span>';
        }
        if( !$uerror && !$eerror ){
            my $user = $self->create_user( username => $username, email => $email, pass_token => random_regex( '\w{40}' ) );
            $self->_send_mail_token( $env, $user, $username, $email );
            return $self->build_reply( "Email sent" );
        }
    }
    return $self->build_reply( <<END );
<form method="POST">
Username: <input type="text" name="username" value="$username"> $uerror
Email: <input type="text" name="email" value="$email"> $eerror
<input type="submit">
</form>
END

}

sub _send_mail_token {}

1;

