package OpenFrame::Constants;

use strict;
use warnings::register;

use Exporter;
use base qw ( Exporter );

our @EXPORT = qw ( ofOK ofDECLINED ofREDIRECT ofERROR );

##
## constants for messages in OpenFrame
##
use constant ofOK       => 1;
use constant ofDECLINED => 2;
use constant ofREDIRECT => 3;
use constant ofERROR    => 4;

1;
