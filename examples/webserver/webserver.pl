#!/usr/bin/perl -w

use strict;
use lib '../../lib';

use OpenFrame::Config;
use OpenFrame::Server::HTTP;

my $config = OpenFrame::Config->new();
$config->setKey(
		'SLOTS',
	        [
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::Images',
		  config   => { directory => 'htdocs/' },
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::HTML',
		  config   => { directory => 'htdocs/' },
		 },
		]
	       );

$config->setKey(DEBUG => 0);
$config->setKey(server_http_port => 8000);

my $h = OpenFrame::Server::HTTP->new($config);
print "Point your browser to http://localhost:8000/ to see the website!\n";
$h->handle();

