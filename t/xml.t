#!/usr/bin/perl

##
## tests for OpenFrame::Slot::(XML|XSLT)
##

BEGIN {
  no warnings qw ( uninitialized );
  eval {
    require XML::LibXML;
    require XML::LibXSLT;
  };
  if ($@) {
    print "1..0 # Skipped - do not have XML::LibXML or XML::LibXSLT installed\n";
    exit;
  }
}

use Test::Simple tests => 3;

use OpenFrame;
use OpenFrame::Constants;
use OpenFrame::Server::Direct;

my $config = OpenFrame::Config->new();
ok($config, "should get config");
$config->setKey(
                'SLOTS',
	        [
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::XML',
		  config   => {
			       filetypes => '(xml)',
			       directory => 't/xmldir',
			      },
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::XSLT',
		  config   => {
			       stylesheets => [
					       {
						pattern    => '/default',
						stylesheet => 't/xmldir/mystylesheet.xsl'
					       }
					      ],
			      },
		 }
		]
	       );

$config->setKey(DEBUG => 0);

my $direct = OpenFrame::Server::Direct->new();
ok($direct, "should get direct object");
my ($response, $cookietin) = $direct->handle("http://localhost/myfile.xml");
ok($response->code eq ofOK, "response object is okay and completed");

