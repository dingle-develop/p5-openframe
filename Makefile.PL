use ExtUtils::MakeMaker;


WriteMakefile(
    NAME	 => "OpenFrame",
    VERSION_FROM => 'lib/OpenFrame.pm',
    PREREQ_PM    => {
		     URI                  => 0.01,
		     Apache               => 0.01,
		     Template             => 0.01,
		     Data::Denter         => 0.01,
		     Scalar::Util         => 0.01,
		     Attribute::Abstract  => 0.01,
		     Attribute::Signature => 0.01,
		     Apache::Cookie       => 0.01,
		     Data::Dumper         => 0.01,
		    },
    AUTHOR       => 'James A. Duncan <jduncan@fotango.com>',
    ABSTRACT     => 'OpenFrame is a Perl based application framework'
);


