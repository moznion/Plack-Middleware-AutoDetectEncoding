package Plack::Middleware::AutoDetectEncoding;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Plack::Middleware/;
use Encode;
use HTML::Parser;
use Email::MIME::ContentType ();

our $VERSION = "0.01";

use constant ENCODING_MAP => {
    'utf8'   => '%E9%A7%B1%E9%A7%9D',
    'euc-jp' => '%F1%D1%F1%CC',
    'cp932'  => '%E9p%E9k',
};

sub call {
    my ($self, $env) = @_;

    if (my ($detector) = $env->{QUERY_STRING} =~ m/__plack_middleware_auto_detect_encoding=([^&]+)/) {
        foreach my $encoding (keys %{+ENCODING_MAP}) {
            if ($detector eq ENCODING_MAP->{$encoding}) {
                $env->{'plack.request.withencoding.encoding'} = $encoding;
                last;
            }
        }
    }

    return $self->response_cb($self->app->($env), sub {
        my $res = shift;
        my $ct  = Plack::Util::header_get($res->[1], 'Content-Type');
        if($ct !~ m{^text/html}i and $ct !~ m{^application/xhtml[+]xml}i){
            return $res;
        }

        # If Content-Type doesn't contain charset, it uses utf8 as default
        my $charset = Email::MIME::ContentType::parse_content_type($ct)->{attributes}->{charset} || 'utf8';

        my @out;
        my $p = HTML::Parser->new(
            api_version => 3,
            start_h => [sub {
                my($tag, $attr, $text) = @_;
                push @out, $text;

                if(
                    lc($tag) ne 'form' or
                    lc($attr->{'method'}) ne 'get'
                ) {
                    return;
                }

                # 駱駝 means camel :p
                push @out, Encode::encode($charset, qq{<input type="hidden" name="__plack_middleware_auto_detect_encoding" value="駱駝" />});
            }, "tagname, attr, text"],
            default_h => [\@out , '@{text}'],
        );
        my $done;

        return sub {
            return if $done;

            if(defined(my $chunk = shift)) {
                $p->parse($chunk);
            }
            else {
                $p->eof;
                $done++;
            }
            join '', splice @out;
        }
    });
}

1;
__END__


1;
__END__

=encoding utf-8

=head1 NAME

Plack::Middleware::AutoDetectEncoding - It's new $module

=head1 *** CAUTION ***

This module is incomplete. Probably, there are many points which are not good.

So, please B<DO NOT USE THIS>.

=head1 SYNOPSIS

    use Plack::Middleware::AutoDetectEncoding;

=head1 DESCRIPTION

Plack::Middleware::AutoDetectEncoding is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

