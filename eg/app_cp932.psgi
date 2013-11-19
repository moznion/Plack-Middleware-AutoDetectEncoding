use strict;
use warnings;
use Plack::Builder;

my $form = <<FORM;
<html>
  <head><title>the form</title></head>
  <body>
    <form action="/" method="get">
      <input type="text" name="name" />
      <input type="submit" value="‘—M" />
    </form>
  </body>
</html>
FORM

my $app = sub {
    my $env = shift;

    [200, ['Content-Type' => 'text/html;charset=Shift_JIS'], [$form]];
};

builder {
    enable 'AutoDetectEncoding';
    $app;
};
