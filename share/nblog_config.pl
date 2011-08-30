use Path::Class;
my $root = file(__FILE__)->dir;


{
  name => 'Nblog',
  static_root => [ $root->subdir( 'static')->stringify ],
  using_frontend_proxy => 0,
  'schema' => {
    connect_info => [
        'dbi:SQLite:dbname=:memory:',
    ],
  },
  'renderer' => {
    root         => $root->subdir( 'templates' )->stringify,
    TEMPLATE_EXTENSION => 'tt',
    INCLUDE_PATH => $root->subdir( 'templates/globals' )->stringify,
    PRE_PROCESS  => 'config.tt',
    WRAPPER      => 'wrapper.tt',
    VARIABLES    => { 
        site_name => 'Writers Unite!',
        sidebar   => 1,
    }
  }
}


