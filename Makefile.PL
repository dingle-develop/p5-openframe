use ExtUtils::MakeMaker;

WriteMakefile(
    NAME	 => "OpenFrame",
    VERSION_FROM => 'lib/OpenFrame.pm',
    PREREQ_PM    =>  {
	      URI                  => 0.01,
	      Template             => 0.01,
	      Data::Denter         => 0.01,
	      Scalar::Util         => 0.01,
	      Data::Dumper         => 0.01,
	      SOAP::Lite           => 0.01,
	      Test::Simple         => 0.01,
	      Class::MethodMaker   => 0.01,
	      File::MMagic         => 0.01,
	      Games::GuessWord     => 0.01,
	      Chatbot::Eliza       => 0.01,
	      File::Temp           => 0.01,
	      Cache::Cache         => 0.01,
	      LWP::UserAgent       => 0.01,
	      Time::HiRes          => 0.01,
	     },
    AUTHOR       => 'James A. Duncan <jduncan@fotango.com>',
    ABSTRACT     => 'OpenFrame is a Perl based application framework'
);


