use Test::More;
use Nblog;

my $app = Nblog->new_with_config(configfile => 'nblog_local.pl');

ok( $app, 'App created' );
isa_ok( $app->schema, 'DBIx::Class::Schema', 'schema created' );
isa_ok( $app->renderer, 'WebNano::Renderer::TT', 'renderer created' );

my $out;
$app->renderer->render( template => 'blog_index.tt', output => \$out );
warn $out;

done_testing;
