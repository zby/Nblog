{
  name => 'Nblog',
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
  }
}


