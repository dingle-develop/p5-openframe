package OpenFrame::Slot::Images;

use strict;
use warnings::register;

use File::MMagic;
use FileHandle;
use OpenFrame::Slot;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $absrq = shift;
  my $uri = $absrq->uri();

  warnings::warn("[slot:images] checking to make sure we are processing images") if (warnings::enabled || $OpenFrame::DEBUG);

  if ($uri->path() =~ /\/$/) {
    return;
  }

  my $file = $uri->path();
  $file =~ s|^/||;

  if ($config->{directory}) {
    $file = $config->{directory} . $file;
  }

  if (-e $file && -r _) {
    my $mm = File::MMagic->new();
    my $type = $mm->checktype_filename($file);

    warnings::warn("[slot:images] file $file has type $type") if (warnings::enabled || $OpenFrame::DEBUG);

    if ($type ne "text/html") {
      warnings::warn("[slot:images] file $file is being handled as an image") if (warnings::enabled || $OpenFrame::DEBUG);

      my $response = OpenFrame::AbstractResponse->new();
      $response->code(ofOK);
      $response->mimetype($type);
      my $fh = FileHandle->new("<$file");
      my $message;
      if ($fh) {
	local $/ = undef;
	$message = <$fh>;
	$fh->close;
      }
      $response->message($message);
      return $response;
    }
  }
  warnings::warn("[slot:images] file $file was not  handled as an image") if (warnings::enabled || $OpenFrame::DEBUG);

}

1;


