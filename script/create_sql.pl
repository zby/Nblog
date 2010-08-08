#!/usr/bin/env perl
use lib './lib';
use Nblog::Schema;
use Data::Dumper;
use Config::Any::Perl;

my $cfg = Config::Any::Perl->load('nblog_local.pl');

my $db = Nblog::Schema->connect($cfg->{Nblog::Schema}->{connect_info});

#$db->deploy();
$db->create_ddl_dir();

