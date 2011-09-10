use Test::More;
use Nblog;

my $app = Nblog->new_with_config();

ok( $app, 'App created' );
isa_ok( $app->schema, 'DBIx::Class::Schema', 'schema created' );
isa_ok( $app->renderer, 'WebNano::Renderer::TT', 'renderer created' );


my $articles = $app->schema->resultset('Nblog::Schema::Result::Article')->get_latest_articles();
ok( $articles->count, 'Articles found' );

my $out = $app->renderer->render( template => 'blog_index.tt', articles => $articles );

done_testing;
