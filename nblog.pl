{
  name => 'Nblog',
  static_root => '',
  using_frontend_proxy => 0,
  site => {
    template => 'default',
    name => 'Writers Unite!',
    description => 'a writers blog',
  },
  'schema' => {
    connect_info => [
        'dbi:SQLite:dbname=./nblog.db',
    ],
  },
  'renderer' => {
    root         => 'templates',
    TEMPLATE_EXTENSION => 'tt',
    INCLUDE_PATH => 'templates/globals',
    PRE_PROCESS  => 'config.tt',
    WRAPPER      => 'wrapper.tt',
    VARIABLES    => { 
        site_name => 'Writers Unite!',
        sidebar   => 1,
    }
  }
}


