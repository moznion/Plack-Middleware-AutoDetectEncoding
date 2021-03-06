requires 'Email::MIME::ContentType';
requires 'Encode';
requires 'HTML::Parser';
requires 'Plack::Middleware';
requires 'parent';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Test::More', '0.98';
};
