use FileHandle;
use ExtUtils::MakeMaker;

my $PREREQ = {
	      URI                  => 0.01,
	      Template             => 0.01,
	      Data::Denter         => 0.01,
	      Scalar::Util         => 0.01,
	      Data::Dumper         => 0.01,
	      SOAP::Lite           => 0.01,
	      Test::Simple         => 0.01,
	      Class::MethodMaker   => 0.01,
	      File::MMagic         => 0.01,
	      Games::WordGuess     => 0.01,
	      File::Temp           => 0.01,
	      Apache::SessionX     => 0.01,
	      LWP::UserAgent       => 0.01,
	      Time::HiRes          => 0.01,
	     };


my $yn;
print "Do you want to use the Eliza example [y/n]: ";
if (yes()) {
  $PREREQ->{'Chatbot::Eliza'} = 0.01;
} else {
  ## I don't think we test it
}

print "Do you want to use the Hangman example [y/n]: ";
if (yes()) {
  $PREREQ->{'Games::WordGuess'} = 0.01;
} else {
  foreach my $file (qw( t/hangman2.t t/direct.t t/http.t )) {
    my $fh = FileHandle->new("+<$file");
    if (!$fh->seek( 0, 0 )) {
      print "Could not set position in file ($!) -- you will see dubious test results\n";
      $fh->close();
      next;
    } else {
      $fh->print(qq!BEGIN { print "1..0 # Skip\\n"; exit; }\n#!);
      $fh->close();
    }
  }
}


WriteMakefile(
    NAME	 => "OpenFrame",
    VERSION_FROM => 'lib/OpenFrame.pm',
    PREREQ_PM    => $PREREQ,
    AUTHOR       => 'James A. Duncan <jduncan@fotango.com>',
    ABSTRACT     => 'OpenFrame is a Perl based application framework'
);


sub yes {
  my $yn = <STDIN>;
  chomp $yn;
  if ($yn =~ /y/i) {
    return 1;
  } else {
    return 0;
  }
}
