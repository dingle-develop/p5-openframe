
##
## -*- Mode: CPerl -*-
##

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME         => "OpenFrame",
	      VERSION_FROM => "lib/OpenFrame.pm",
	      PREREQ_PM    => {
			       'Pipeline'      => '2.00',
			       'HTTP::Request' => '0.01',
			       'File::MMagic'  => '0.01',
			       'CGI::Cookie'   => '0.01',
			      },
	     );

