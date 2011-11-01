use strict;
use warnings;

package Nblog::LoginPage;

use parent 'Plack::Middleware::Auth::Form';

use Plack::Util::Accessor qw( renderer );

sub _wrap_body {
    my ($self, $content) = @_;
    return $self->renderer->render( template => \$content );
}

1;

